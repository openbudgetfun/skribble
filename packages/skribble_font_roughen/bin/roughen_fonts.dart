import 'dart:io';

import 'package:skribble_font_roughen/skribble_font_roughen.dart';

/// Rebuilds every bundled roughness level and style from repository root.
/// Pass --check to verify artifacts without changing them.
Future<void> main(List<String> arguments) async {
  final check = arguments.contains('--check');
  final scratch = await Directory.systemTemp.createTemp('skribble-fonts-');
  var stale = false;

  try {
    final notice = await File('packages/skribble/tool/font/RECURSIVE-OFL.txt')
        .readAsString();

    for (final directory in [
      'packages/skribble/assets/fonts',
      'apps/skribble_storybook/assets/fonts',
    ]) {
      final destination = File('$directory/OFL.txt');

      if (check) {
        if (!destination.existsSync() ||
            await destination.readAsString() != notice) {
          stderr.writeln('Stale font notice: ${destination.path}');
          stale = true;
        }
      } else {
        await destination.writeAsString(notice);
      }
    }

    for (final source in [
      (name: 'RecursiveSansCslSt', prefix: 'Skribble'),
      (name: 'RecursiveSansLnrSt', prefix: 'SkribbleLinear'),
      (name: 'RecursiveMonoLnrSt', prefix: 'SkribbleMono'),
    ]) {
      for (final level in [
        (family: '${source.prefix}Gentle', strength: 18.0),
        (family: '${source.prefix}Playful', strength: 27.0),
        (
          family: source.prefix == 'Skribble'
              ? 'Skribble'
              : '${source.prefix}Expressive',
          strength: 36.0,
        ),
      ]) {
        for (final variant in FontVariant.values) {
          final suffix = variant.fullNameSuffix.replaceAll(' ', '');
          final name = '${level.family}-$suffix.ttf';
          final result = await FontRoughener(
            inputPath: 'packages/skribble/tool/font/${source.name}-$suffix.ttf',
            outputPath: '${scratch.path}/$name',
            variant: variant,
            familyName: level.family,
            jitterAmount: level.strength,
          ).roughen();
          final bytes = await File(result.outputPath).readAsBytes();

          for (final directory in [
            'packages/skribble/assets/fonts',
            if (level.family == 'Skribble') ...[
              'packages/skribble/tool/font',
              'apps/skribble_storybook/assets/fonts',
            ],
          ]) {
            final destination = File('$directory/$name');

            if (check) {
              final current = await destination.readAsBytes();
              if (current.length != bytes.length ||
                  !List.generate(
                    bytes.length,
                    (i) => i,
                  ).every((i) => bytes[i] == current[i])) {
                stderr.writeln('Stale font: ${destination.path}');
                stale = true;
              }
            } else {
              await destination.writeAsBytes(bytes);
            }
          }

          stdout.writeln('$name: ${result.glyphCount} outlined glyphs');
        }
      }
    }
  } finally {
    await scratch.delete(recursive: true);
  }

  if (stale) exitCode = 1;
}
