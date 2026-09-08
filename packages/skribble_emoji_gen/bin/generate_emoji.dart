import 'dart:io';

import 'package:args/args.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:skribble_emoji_gen/svg_shapes.dart';

const _defaultCsvUrl =
    'https://raw.githubusercontent.com/hfg-gmuend/openmoji/17.0.0/data/openmoji.csv';

Future<void> main(List<String> arguments) async {
  final parser = ArgParser()
    ..addOption(
      'svg-dir',
      mandatory: true,
      help: 'Directory containing OpenMoji SVG files (named <HEXCODE>.svg).',
    )
    ..addOption(
      'csv-url',
      defaultsTo: _defaultCsvUrl,
      help: 'URL of the OpenMoji catalog CSV.',
    )
    ..addOption(
      'csv-file',
      help: 'Path to a local copy of the OpenMoji CSV (overrides --csv-url).',
    )
    ..addOption(
      'output-dir',
      mandatory: true,
      help: 'Directory where generated .g.dart files are written.',
    );

  final args = parser.parse(arguments);

  final svgDir = p.canonicalize(args['svg-dir'] as String);
  final outputDir = p.canonicalize(args['output-dir'] as String);

  // 1. Load CSV
  String csvText;
  if (args['csv-file'] != null) {
    print('Reading local CSV: ${args['csv-file']}');
    csvText = await File(args['csv-file'] as String).readAsString();
  } else {
    print('Downloading CSV from: ${args['csv-url']}');
    final response = await http.get(Uri.parse(args['csv-url'] as String));
    if (response.statusCode != 200) {
      exitCode = 1;
      print('Failed to download CSV: ${response.statusCode}');
      return;
    }
    csvText = response.body;
  }

  final rows = _parseCsv(csvText);
  if (rows.isEmpty) {
    exitCode = 1;
    print('CSV has no rows.');
    return;
  }

  final header = rows.first;
  final dataRows = rows.skip(1).toList();
  print('Catalog rows: ${dataRows.length}');

  // 2. Process
  final entries = <_EmojiEntry>[];
  final seenSequences = <String>{};
  final seenNames = <String>{};

  var skippedMissing = 0;
  var skippedNoPaths = 0;
  var skippedDupCp = 0;
  var skippedDupName = 0;
  var processed = 0;

  for (var i = 0; i < dataRows.length; i++) {
    final row = dataRows[i];
    final map = <String, String>{};
    for (var j = 0; j < header.length && j < row.length; j++) {
      map[header[j]] = row[j];
    }

    final hexcode = (map['hexcode'] ?? '').trim();
    final annotation = (map['annotation'] ?? '').trim();

    final parts = hexcode.split('-');
    final meaningful = parts.where((p) => p != 'FE0F').toList();
    final sequence = meaningful.join('-');

    final svgFile = p.join(svgDir, '$hexcode.svg');
    if (!File(svgFile).existsSync()) {
      skippedMissing++;
      continue;
    }

    final primaryCp = int.parse(parts[0], radix: 16);

    if (seenSequences.contains(sequence)) {
      skippedDupCp++;
      continue;
    }

    var name = annotation.isNotEmpty ? _annotationToIdentifier(annotation) : '';
    if (name.isEmpty) {
      name = 'emoji_${hexcode.toLowerCase().replaceAll('-', '_')}';
    }

    if (seenNames.contains(name)) {
      name = '${name}_${sequence.toLowerCase().replaceAll('-', '_')}';
    }
    if (seenNames.contains(name)) {
      skippedDupName++;
      continue;
    }

    final shapeList = extractShapes(svgFile);
    if (shapeList.isEmpty) {
      skippedNoPaths++;
      continue;
    }

    seenSequences.add(sequence);
    seenNames.add(name);
    entries.add(
      _EmojiEntry(
        codepoint: primaryCp,
        name: name,
        sequence: sequence,
        paths: shapeList,
      ),
    );
    processed++;

    if (processed % 500 == 0) {
      print('  Processing $processed/${dataRows.length}...');
    }
  }

  entries.sort((a, b) => a.sequence.compareTo(b.sequence));

  if (skippedMissing != 0 || skippedNoPaths != 0) {
    throw StateError(
      'Incomplete OpenMoji source: missing=$skippedMissing, empty=$skippedNoPaths',
    );
  }

  // 3. Write files
  final emojiPath = p.join(outputDir, 'skribble_emoji.g.dart');
  await File(emojiPath).parent.create(recursive: true);
  await File(emojiPath).writeAsString(
    _generateEmojiDart(
      entries.where((e) => !e.sequence.contains('-')).toList(),
    ),
  );
  await File(p.join(outputDir, 'skribble_emoji_sequences.g.dart'))
      .writeAsString(
        _generateEmojiDart(
          entries.where((e) => e.sequence.contains('-')).toList(),
          sequences: true,
        ),
      );
  print('Written: $emojiPath');

  final cpPath = p.join(outputDir, 'skribble_emoji_codepoints.g.dart');
  await File(cpPath).writeAsString(_generateCodepointsDart(entries));
  print('Written: $cpPath');

  // 4. Summary
  print('');
  print('=== Summary ===');
  print('Catalog rows:          ${dataRows.length}');
  print('Included:              ${entries.length}');
  print('Skipped (missing SVG): $skippedMissing');
  print('Skipped (no paths):    $skippedNoPaths');
  print('Skipped (dup codepoint): $skippedDupCp');
  print('Skipped (dup name):    $skippedDupName');
}

// ---------------------------------------------------------------------------
// SVG extraction
// ---------------------------------------------------------------------------

// ---------------------------------------------------------------------------
// CSV parsing
// ---------------------------------------------------------------------------

List<List<String>> _parseCsv(String text) {
  final lines = text.split('\n').where((l) => l.trim().isNotEmpty).toList();
  if (lines.isEmpty) return [];

  final rows = <List<String>>[];
  for (final line in lines) {
    final row = <String>[];
    var inQuotes = false;
    final current = StringBuffer();

    for (var i = 0; i < line.length; i++) {
      final char = line[i];
      if (char == '"') {
        inQuotes = !inQuotes;
      } else if (char == ',' && !inQuotes) {
        row.add(current.toString().trim());
        current.clear();
      } else {
        current.write(char);
      }
    }
    row.add(current.toString().trim());
    rows.add(row);
  }

  return rows;
}

// ---------------------------------------------------------------------------
// Name normalization
// ---------------------------------------------------------------------------

final _nonAlpha = RegExp(r'[^a-z0-9_]+');
final _multiUnderscore = RegExp(r'_+');

String _annotationToIdentifier(String annotation) {
  var s = annotation.toLowerCase().trim();
  s = s.replaceAll(' ', '_').replaceAll('-', '_');
  s = s.replaceAll(_nonAlpha, '');
  s = s.replaceAll(_multiUnderscore, '_').replaceAll(RegExp(r'^_|_$'), '');
  if (s.isNotEmpty && RegExp(r'^\d').hasMatch(s)) {
    s = 'emoji_$s';
  }
  return s;
}

// ---------------------------------------------------------------------------
// Escape helper
// ---------------------------------------------------------------------------

String _escape(String d) => d.replaceAll("'", r"\'");

// ---------------------------------------------------------------------------
// Dart code generation
// ---------------------------------------------------------------------------

String _generateEmojiDart(List<_EmojiEntry> entries, {bool sequences = false}) {
  final buf = StringBuffer()
    ..writeln('// GENERATED CODE - DO NOT MODIFY BY HAND.')
    ..writeln('// OpenMoji 17.0.0, CC-BY-SA 4.0; outlines adapted by Skribble.')
    ..writeln('// ignore_for_file: lines_longer_than_80_chars')
    ..writeln()
    ..writeln("import 'dart:ui' show StrokeCap, StrokeJoin;")
    ..writeln("import '../wired_svg_icon_data.dart';")
    ..writeln()
    ..writeln(
      sequences
          ? 'const Map<String, WiredSvgIconData> kSkribbleEmojiSequences = <String, WiredSvgIconData>{'
          : 'const Map<int, WiredSvgIconData> kSkribbleEmoji = <int, WiredSvgIconData>{',
    );

  for (final entry in entries) {
    final hexStr = entry.codepoint.toRadixString(16);
    buf
      ..writeln('  // ${entry.name}')
      ..writeln(
        sequences
            ? "  '${entry.sequence}': WiredSvgIconData("
            : '  0x$hexStr: WiredSvgIconData(',
      )
      ..writeln('    width: 72.0,')
      ..writeln('    height: 72.0,')
      ..writeln('    primitives: <WiredSvgPrimitive>[');
    for (final shape in entry.paths) {
      final params = StringBuffer();
      if (shape.clipPaths.isNotEmpty)
        params.write(
          'clipPaths: ${shape.clipPaths.map((path) => "'$path'").toList()}, ',
        );
      if (shape.evenOdd) params.write('fillRule: WiredSvgFillRule.evenOdd, ');
      if (shape.fillColor != null)
        params.write("fillColor: '${shape.fillColor}', ");
      if (shape.strokeColor != null) {
        params.write("strokeColor: '${shape.strokeColor}', ");
        params.write('strokeWidth: ${shape.strokeWidth.toStringAsFixed(3)}, ');
        params.write(
          'strokeCap: StrokeCap.${shape.strokeCap}, strokeJoin: StrokeJoin.${shape.strokeJoin}, ',
        );
        if (shape.strokeMiterLimit != 4)
          params.write('strokeMiterLimit: ${shape.strokeMiterLimit}, ');
        if (shape.strokeDashArray.isNotEmpty) {
          params.write(
            'strokeDashArray: ${shape.strokeDashArray}, strokeDashOffset: ${shape.strokeDashOffset}, ',
          );
        }
      }
      if (params.isEmpty) {
        buf.writeln("      WiredSvgPrimitive.path('${_escape(shape.data)}'),");
      } else {
        buf.writeln(
          "      WiredSvgPrimitive.path('${_escape(shape.data)}', ${params.toString().trim()}),",
        );
      }
    }
    buf
      ..writeln('    ],')
      ..writeln('  ),');
  }

  buf
    ..writeln('};')
    ..writeln();
  return buf.toString();
}

String _generateCodepointsDart(List<_EmojiEntry> entries) {
  final buf = StringBuffer()
    ..writeln('// GENERATED CODE - DO NOT MODIFY BY HAND.')
    ..writeln('// OpenMoji 17.0.0, CC-BY-SA 4.0; outlines adapted by Skribble.')
    ..writeln('// ignore_for_file: lines_longer_than_80_chars')
    ..writeln()
    ..writeln(
      '/// Maps each emoji identifier string to its Unicode codepoint in',
    )
    ..writeln('/// `kSkribbleEmoji`.')
    ..writeln(
      'const Map<String, int> kSkribbleEmojiCodePoints = <String, int>{',
    );

  for (final entry in entries.where((e) => !e.sequence.contains('-'))) {
    final hexStr = entry.codepoint.toRadixString(16);
    buf.writeln("  '${entry.name}': 0x$hexStr,");
  }

  buf
    ..writeln('};')
    ..writeln();
  buf.writeln(
    '/// Maps names to complete Unicode sequences, including modifiers.',
  );
  buf.writeln(
    'const Map<String, String> kSkribbleEmojiNames = <String, String>{',
  );
  for (final entry in entries) {
    buf.writeln("  '${entry.name}': '${entry.sequence}',");
  }
  buf.writeln('};');
  return buf.toString();
}

class _EmojiEntry {
  final String sequence;
  final int codepoint;
  final String name;
  final List<SvgShape> paths;

  const _EmojiEntry({
    required this.sequence,
    required this.codepoint,
    required this.name,
    required this.paths,
  });
}
