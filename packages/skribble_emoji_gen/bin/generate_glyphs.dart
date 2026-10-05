import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';
import 'package:path/path.dart' as p;
import 'package:skribble_emoji_gen/svg_shapes.dart';
import 'package:xml/xml.dart';

const _defaultSource = 'packages/skribble/tool/glyphs';
const _defaultOutput =
    'packages/skribble/lib/src/generated/skribble_glyphs.g.dart';

/// Generates skribble's built-in glyphs from their checked-in SVG sources.
///
/// Each glyph is a 24-unit stroke drawing in `tool/glyphs`, listed in
/// `glyphs.json` with a description and the Material icon codepoints it can
/// stand in for. The output is `SkribbleGlyphs`, a set of named constants, and
/// the codepoint fallback map `WiredIcon` uses when no catalog is registered.
/// Geometry, names, and fallbacks come from one source, so they cannot drift.
Future<void> main(List<String> arguments) async {
  final parser = ArgParser()
    ..addOption('source', defaultsTo: _defaultSource)
    ..addOption('output', defaultsTo: _defaultOutput)
    ..addFlag(
      'check',
      negatable: false,
      help: 'Verify the committed glyphs are current without writing them.',
    );
  final args = parser.parse(arguments);

  final source = Directory(args['source'] as String);
  final output = File(args['output'] as String);
  final manifest = jsonDecode(
    File(p.join(source.path, 'glyphs.json')).readAsStringSync(),
  ) as Map<String, Object?>;
  final glyphs = (manifest['glyphs']! as List<Object?>)
      .cast<Map<String, Object?>>();
  final svgs = source
      .listSync()
      .whereType<File>()
      .where((file) => file.path.endsWith('.svg'))
      .map((file) => p.basenameWithoutExtension(file.path))
      .toSet();
  final listed = glyphs.map((glyph) => glyph['name']! as String).toSet();
  if (svgs.difference(listed).isNotEmpty ||
      listed.difference(svgs).isNotEmpty) {
    throw StateError(
      'glyphs.json and the SVG sources disagree: '
      'unlisted ${svgs.difference(listed)}, missing ${listed.difference(svgs)}',
    );
  }

  final constants = StringBuffer();
  final all = StringBuffer();
  final fallbacks = StringBuffer();
  final seenCodePoints = <int>{};

  for (final glyph in glyphs) {
    final name = glyph['name']! as String;
    final description = glyph['description']! as String;
    final file = p.join(source.path, '$name.svg');
    final root = XmlDocument.parse(File(file).readAsStringSync()).rootElement;
    final viewBox = root.getAttribute('viewBox')!.split(RegExp(r'[ ,]+'));
    final shapes = extractShapes(file);
    if (shapes.isEmpty) throw StateError('Glyph "$name" has no shapes.');
    final constant = _camelCase(name);

    constants
      ..writeln('  /// $description.')
      ..writeln('  static const WiredSvgIconData $constant = WiredSvgIconData(')
      ..writeln('    width: ${viewBox[2]},')
      ..writeln('    height: ${viewBox[3]},')
      ..writeln('    primitives: <WiredSvgPrimitive>[');
    for (final shape in shapes) {
      constants
        ..write('      WiredSvgPrimitive.path(')
        ..write("'${shape.data}'")
        ..write(', fillRule: WiredSvgFillRule.')
        ..write(shape.evenOdd ? 'evenOdd' : 'nonZero');
      if (shape.fillColor != null) {
        constants.write(", fillColor: '${shape.fillColor}'");
      }
      if (shape.strokeColor != null) {
        constants.write(", strokeColor: '${shape.strokeColor}'");
      }
      if (shape.strokeWidth != 1) {
        constants.write(', strokeWidth: ${_number(shape.strokeWidth)}');
      }
      constants.writeln('),');
    }
    constants
      ..writeln('    ],')
      ..writeln('  );')
      ..writeln();
    all.writeln("    '$name': $constant,");

    for (final value in (glyph['material'] as List<Object?>? ?? const [])) {
      final codePoint = int.parse(
        (value! as String).toLowerCase().replaceFirst('0x', ''),
        radix: 16,
      );
      if (!seenCodePoints.add(codePoint)) {
        throw StateError(
          'Codepoint 0x${codePoint.toRadixString(16)} is '
          'claimed by more than one glyph.',
        );
      }
      fallbacks.writeln(
        '  0x${codePoint.toRadixString(16)}: SkribbleGlyphs.$constant,',
      );
    }
  }

  final buffer = StringBuffer()
    ..writeln('// GENERATED CODE - DO NOT MODIFY BY HAND.')
    ..writeln('// ignore_for_file: lines_longer_than_80_chars')
    ..writeln('//')
    ..writeln(
      '// Source: packages/skribble/tool/glyphs (${glyphs.length} glyphs).',
    )
    ..writeln('// Regenerate with: melos run glyphs')
    ..writeln()
    ..writeln("import '../wired_svg_icon_data.dart';")
    ..writeln()
    ..writeln("/// skribble's own hand-drawn interface glyphs.")
    ..writeln('///')
    ..writeln(
      '/// Each glyph is a 24-unit stroke drawing, so the theme pen inks',
    )
    ..writeln('/// it and `weight` makes it thinner or bolder. Draw one with')
    ..writeln(
      '/// `SkribbleIcon(data: SkribbleGlyphs.home)` or `WiredSvgIcon`.',
    )
    ..writeln('abstract final class SkribbleGlyphs {')
    ..write(constants)
    ..writeln("  /// Every glyph by its identifier, such as `'arrow_left'`.")
    ..writeln('  static const Map<String, WiredSvgIconData> all = {')
    ..write(all)
    ..writeln('  };')
    ..writeln('}')
    ..writeln()
    ..writeln(
      '/// Glyphs that stand in for common Material icons, keyed by the',
    )
    ..writeln(
      '/// `MaterialIcons` codepoint, when no icon catalog is registered.',
    )
    ..writeln(
      'const Map<int, WiredSvgIconData> kSkribbleGlyphMaterialFallbacks = {',
    )
    ..write(fallbacks)
    ..writeln('};');
  final rendered = buffer.toString();

  if (args['check'] as bool) {
    if (await _isStale(output.path, rendered)) {
      stderr.writeln('Stale glyphs: ${output.path}. Run melos run glyphs.');
      exitCode = 1;
    } else {
      stdout.writeln('Glyphs up to date (${glyphs.length}).');
    }
    return;
  }

  await output.parent.create(recursive: true);
  await output.writeAsString(rendered);
  await _format(output.path);
  stdout.writeln('Generated ${glyphs.length} glyphs into ${output.path}.');
}

String _camelCase(String name) {
  final parts = name.split('_');
  return [
    parts.first,
    for (final part in parts.skip(1)) part[0].toUpperCase() + part.substring(1),
  ].join();
}

String _number(double value) =>
    value == value.roundToDouble() ? value.toInt().toString() : '$value';

/// Formats [path] with the same `dart format` the repo enforces, so a
/// regenerated file is byte-identical to the committed one.
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
      'Formatting the generated glyphs failed',
      result.exitCode,
    );
  }
}

/// Reports whether [path] differs from [rendered] once formatted.
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
