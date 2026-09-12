import 'dart:io';
import 'dart:typed_data';

import 'package:skribble_font_roughen/src/truetype_font.dart';

/// Builds variable families and matching 300–900 static faces. Run at repo root.
/// FontTools expands source deltas before warping and instances finished fonts.
Future<void> main(List<String> arguments) async {
  final check = arguments.contains('--check');
  final scratch = await Directory.systemTemp.createTemp('skribble-fonts-');
  var stale = false;

  Future<void> publish(String source, String destination) async {
    final bytes = await File(source).readAsBytes();
    final file = File(destination);
    if (!check) {
      await file.parent.create(recursive: true);
      await file.writeAsBytes(bytes);
      return;
    }
    final current = file.existsSync() ? await file.readAsBytes() : <int>[];
    if (current.length != bytes.length ||
        Iterable<int>.generate(bytes.length)
            .any((i) => current[i] != bytes[i])) {
      stderr.writeln('Stale font asset: $destination');
      stale = true;
    }
  }

  try {
    for (final directory in [
      'packages/skribble/assets/fonts',
      'apps/skribble_storybook/assets/fonts',
    ]) {
      await publish(
        'packages/skribble/tool/font/RECURSIVE-OFL.txt',
        '$directory/OFL.txt',
      );
    }
    final expanded = '${scratch.path}/expanded.ttf';
    await _instance(
      'packages/skribble/tool/font/Recursive-Variable.ttf',
      expanded,
      ['wght=300:400:900'],
      expand: true,
    );
    final jobs = <Future<void> Function()>[];
    for (final level in [
      (name: 'Gentle', strength: 18.0),
      (name: 'Playful', strength: 27.0),
      (name: 'Expressive', strength: 36.0),
    ]) {
      final variableFamily = 'SkribbleVariable${level.name}';
      final variable = '${scratch.path}/$variableFamily-Regular.ttf';
      final font = TrueTypeFont(await File(expanded).readAsBytes())
        ..roughen(level.strength);
      await File(variable)
          .writeAsBytes(font.encode(family: variableFamily, style: 'Regular'));
      await publish(
        variable,
        'packages/skribble/assets/fonts/$variableFamily-Regular.ttf',
      );

      for (final source in [
        (prefix: 'Skribble', mono: 0, casual: 1),
        (prefix: 'SkribbleLinear', mono: 0, casual: 0),
        (prefix: 'SkribbleMono', mono: 1, casual: 0),
      ]) {
        final family = source.prefix == 'Skribble' && level.name == 'Expressive'
            ? 'Skribble'
            : '${source.prefix}${level.name}';
        for (final weight in [
          (value: 300, name: 'Light'),
          (value: 400, name: 'Regular'),
          (value: 500, name: 'Medium'),
          (value: 600, name: 'SemiBold'),
          (value: 700, name: 'Bold'),
          (value: 800, name: 'ExtraBold'),
          (value: 900, name: 'Black'),
        ]) {
          for (final italic in [false, true]) {
            jobs.add(() async {
              final suffix = italic && weight.value == 400
                  ? 'Italic'
                  : '${weight.name}${italic ? 'Italic' : ''}';
              final path = '${scratch.path}/$family-$suffix.ttf';
              await _instance(variable, path, [
                'wght=${weight.value}',
                'MONO=${source.mono}',
                'CASL=${source.casual}',
                'slnt=${italic ? -15 : 0}',
                'CRSV=${italic ? 1 : 0}',
              ]);
              final instance = TrueTypeFont(await File(path).readAsBytes());
              ByteData.sublistView(instance.tables['post']!)
                  .setUint32(12, source.mono);
              final bytes = instance.encode(
                family: family,
                weight: weight.value,
                italic: italic,
                style: italic
                    ? '${weight.name == 'Regular' ? '' : '${weight.name} '}Italic'
                    : weight.name,
              );
              await File(path).writeAsBytes(bytes);
              await publish(
                path,
                'packages/skribble/assets/fonts/$family-$suffix.ttf',
              );
              if (level.name == 'Gentle' && [400, 700].contains(weight.value)) {
                final originalPrefix = switch (source.prefix) {
                  'Skribble' => 'RecursiveSansCslSt',
                  'SkribbleLinear' => 'RecursiveSansLnrSt',
                  _ => 'RecursiveMonoLnrSt',
                };
                final original = '${scratch.path}/$originalPrefix-$suffix.ttf';
                await _instance(expanded, original, [
                  'wght=${weight.value}',
                  'MONO=${source.mono}',
                  'CASL=${source.casual}',
                  'slnt=${italic ? -15 : 0}',
                  'CRSV=${italic ? 1 : 0}',
                ]);
                await publish(
                  original,
                  'packages/skribble/tool/font/$originalPrefix-$suffix.ttf',
                );
              }
              // Retain the four compatibility copies used by older tooling.
              if (family == 'Skribble' && [400, 700].contains(weight.value)) {
                for (final directory in [
                  'packages/skribble/tool/font',
                  'apps/skribble_storybook/assets/fonts',
                ]) {
                  await publish(path, '$directory/$family-$suffix.ttf');
                }
              }
              stdout.writeln('$family-$suffix');
            });
          }
        }
      }
    }
    // Bound compiler memory while building the full family matrix.
    for (var i = 0; i < jobs.length; i += 4) {
      await Future.wait(jobs.skip(i).take(4).map((job) => job()));
    }
  } finally {
    await scratch.delete(recursive: true);
  }
  if (stale) exitCode = 1;
}

Future<void> _instance(
  String source,
  String output,
  List<String> axes, {
  bool expand = false,
}) async {
  final args = [
    'varLib.instancer',
    source,
    ...axes,
    if (expand) '--no-optimize',
    '--no-recalc-timestamp',
    '-q',
    '-o',
    output,
  ];
  final result = await Process.run('fonttools', args);
  if (result.exitCode != 0) {
    throw ProcessException(
      'fonttools',
      args,
      '${result.stdout}\n${result.stderr}',
      result.exitCode,
    );
  }
}
