import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';
import 'package:path/path.dart' as p;
import 'package:skribble_emoji_gen/svg_shapes.dart';
import 'package:xml/xml.dart';

const _defaultManifest =
    'packages/skribble_icons_curated/tool/skribble_icons.manifest.json';
const _defaultOutput =
    'packages/skribble_icons_curated/lib/src/generated/skribble_curated_icons.g.dart';

/// Generates the curated simple icon catalog from its checked-in SVG manifest.
///
/// Emits the geometry map and the identifier-to-codepoint map from the same
/// source, so the two can never drift the way a hand-maintained map does.
Future<void> main(List<String> arguments) async {
  final parser = ArgParser()
    ..addOption('manifest', defaultsTo: _defaultManifest)
    ..addOption('output', defaultsTo: _defaultOutput)
    ..addFlag(
      'check',
      negatable: false,
      help: 'Verify the committed catalog is current without writing it.',
    );
  final args = parser.parse(arguments);

  final manifest = File(args['manifest'] as String);
  final output = File(args['output'] as String);
  final data =
      jsonDecode(await manifest.readAsString()) as Map<String, Object?>;
  final icons = (data['icons']! as List<Object?>).cast<Map<String, Object?>>();

  final geometry = StringBuffer();
  final codePoints = StringBuffer();

  for (final item in icons) {
    final identifier = item['identifier']! as String;
    final codePoint = _parseCodePoint(item['codePoint']! as String);
    final source = p.normalize(
      p.join(manifest.parent.path, item['svgPath']! as String),
    );
    final root = XmlDocument.parse(File(source).readAsStringSync()).rootElement;
    final viewBox = root.getAttribute('viewBox')!.split(RegExp(r'[ ,]+'));
    final shapes = extractShapes(source);

    geometry
      ..writeln('  0x${codePoint.toRadixString(16)}:')
      ..writeln('  WiredSvgIconData(')
      ..writeln('    width: ${viewBox[2]},')
      ..writeln('    height: ${viewBox[3]},')
      ..writeln('    primitives: <WiredSvgPrimitive>[');
    for (final shape in shapes) {
      geometry
        ..write('      WiredSvgPrimitive.path(')
        ..write("'${_escape(shape.data)}'")
        ..write(', fillRule: WiredSvgFillRule.')
        ..write(shape.evenOdd ? 'evenOdd' : 'nonZero')
        ..writeln('),');
    }
    geometry
      ..writeln('    ],')
      ..writeln('  ),');

    codePoints.writeln(
      "  '${_escape(identifier)}': 0x${codePoint.toRadixString(16)},",
    );
  }

  final buffer = StringBuffer()
    ..writeln('// GENERATED CODE - DO NOT MODIFY BY HAND.')
    ..writeln('// ignore_for_file: lines_longer_than_80_chars')
    ..writeln('//')
    ..writeln(
      '// Source: ${p.basename(manifest.path)} (${icons.length} icons).',
    )
    ..writeln('// Regenerate with: melos run icons-curated')
    ..writeln()
    ..writeln("import '../wired_svg_icon_data.dart';")
    ..writeln()
    ..writeln('const Map<int, WiredSvgIconData> kSkribbleCuratedIcons = {')
    ..write(geometry)
    ..writeln('};')
    ..writeln()
    ..writeln('const Map<String, int> kSkribbleCuratedIconCodePoints = {')
    ..write(codePoints)
    ..writeln('};');
  final rendered = buffer.toString();

  if (args['check'] as bool) {
    if (await _isStale(output.path, rendered)) {
      stderr.writeln('Stale curated icon catalog: ${output.path}');
      exitCode = 1;
    } else {
      stdout.writeln('Curated icons up to date (${icons.length}).');
    }
    return;
  }

  await output.parent.create(recursive: true);
  await output.writeAsString(rendered);
  await _format(output.path);
  stdout.writeln(
    'Generated ${icons.length} curated icons into ${output.path}.',
  );
}

String _escape(String value) =>
    value.replaceAll(r'\', r'\\').replaceAll("'", r"\'");

int _parseCodePoint(String value) {
  final normalized = value
      .toLowerCase()
      .replaceFirst('u+', '')
      .replaceFirst('0x', '');
  final parsed = int.tryParse(normalized, radix: 16);
  if (parsed == null) throw ArgumentError('Invalid codepoint: $value');
  return parsed;
}

/// Formats [path] with the same `dart format` the repo enforces, so a
/// regenerated catalog is byte-identical to the committed file. Without this,
/// running `dart format .` would desync the catalog from its generator.
Future<void> _format(String path) async {
  final result = await Process.run(Platform.resolvedExecutable, [
    'format',
    path,
  ]);
  if (result.exitCode != 0) {
    stderr.write(result.stderr);
    throw ProcessException(
      Platform.resolvedExecutable,
      ['format', path],
      'Formatting the generated catalog failed',
      result.exitCode,
    );
  }
}

/// Reports whether [path] differs from [rendered] once formatted.
///
/// The comparison runs through a scratch file so the committed catalog and the
/// generator's output pass through the same formatter.
Future<bool> _isStale(String path, String rendered) async {
  final scratch = File('$path.check');
  try {
    await scratch.writeAsString(rendered);
    await _format(scratch.path);
    final formatted = await scratch.readAsString();
    final committed = File(path);
    final current = committed.existsSync() ? committed.readAsStringSync() : '';
    return formatted != current;
  } finally {
    if (scratch.existsSync()) scratch.deleteSync();
  }
}
