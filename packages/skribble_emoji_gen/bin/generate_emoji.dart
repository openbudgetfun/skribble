import 'dart:io';

import 'package:args/args.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:xml/xml.dart';

const _defaultCsvUrl =
    'https://raw.githubusercontent.com/hfg-gmuend/openmoji/master/data/openmoji.csv';

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
  final seenCodepoints = <int>{};
  final seenNames = <String>{};

  var skippedSkin = 0;
  var skippedZwj = 0;
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
    final skintone = (map['skintone'] ?? '').trim();

    if (skintone.isNotEmpty) {
      skippedSkin++;
      continue;
    }

    final parts = hexcode.split('-');
    final meaningful = parts.where((p) => p != 'FE0F').toList();
    if (meaningful.length >= 3) {
      skippedZwj++;
      continue;
    }

    final svgFile = p.join(svgDir, '$hexcode.svg');
    if (!File(svgFile).existsSync()) {
      skippedMissing++;
      continue;
    }

    final primaryCp = int.parse(parts[0], radix: 16);

    if (seenCodepoints.contains(primaryCp)) {
      skippedDupCp++;
      continue;
    }

    var name = annotation.isNotEmpty ? _annotationToIdentifier(annotation) : '';
    if (name.isEmpty) {
      name = 'emoji_${hexcode.toLowerCase().replaceAll('-', '_')}';
    }

    if (seenNames.contains(name)) {
      name = '${name}_${primaryCp.toRadixString(16)}';
    }
    if (seenNames.contains(name)) {
      skippedDupName++;
      continue;
    }

    final pathList = _extractPaths(svgFile);
    if (pathList.isEmpty) {
      skippedNoPaths++;
      continue;
    }

    seenCodepoints.add(primaryCp);
    seenNames.add(name);
    entries.add(_EmojiEntry(codepoint: primaryCp, name: name, paths: pathList));
    processed++;

    if (processed % 500 == 0) {
      print('  Processing $processed/${dataRows.length}...');
    }
  }

  entries.sort((a, b) => a.codepoint.compareTo(b.codepoint));

  // 3. Write files
  final emojiPath = p.join(outputDir, 'skribble_emoji.g.dart');
  await File(emojiPath).parent.create(recursive: true);
  await File(emojiPath).writeAsString(_generateEmojiDart(entries));
  print('Written: $emojiPath');

  final cpPath = p.join(outputDir, 'skribble_emoji_codepoints.g.dart');
  await File(cpPath).writeAsString(_generateCodepointsDart(entries));
  print('Written: $cpPath');

  // 4. Summary
  print('');
  print('=== Summary ===');
  print('Catalog rows:          ${dataRows.length}');
  print('Included:              ${entries.length}');
  print('Skipped (skin tones):  $skippedSkin');
  print('Skipped (3+ ZWJ):      $skippedZwj');
  print('Skipped (missing SVG): $skippedMissing');
  print('Skipped (no paths):    $skippedNoPaths');
  print('Skipped (dup codepoint): $skippedDupCp');
  print('Skipped (dup name):    $skippedDupName');
}

// ---------------------------------------------------------------------------
// SVG extraction
// ---------------------------------------------------------------------------

List<String> _extractPaths(String svgFile) {
  final file = File(svgFile);
  if (!file.existsSync()) return [];

  XmlDocument doc;
  try {
    doc = XmlDocument.parse(file.readAsStringSync());
  } on XmlParserException {
    return [];
  }

  final paths = <String>[];
  _processElement(doc.rootElement, paths);
  return paths;
}

void _processElement(XmlElement element, List<String> paths) {
  final tag = element.name.local;

  if (tag == 'path') {
    final d = element.getAttribute('d')?.trim() ?? '';
    if (d.isNotEmpty && d.toLowerCase() != 'none' && !_shouldSkip(element)) {
      paths.add(d);
    }
  } else if (tag == 'polygon') {
    final pts = element.getAttribute('points')?.trim() ?? '';
    if (pts.isNotEmpty && !_shouldSkip(element)) {
      final pd = _polygonPointsToPath(pts);
      if (pd.isNotEmpty) paths.add(pd);
    }
  } else if (tag == 'polyline') {
    final pts = element.getAttribute('points')?.trim() ?? '';
    if (pts.isNotEmpty && !_shouldSkip(element)) {
      var pd = _polygonPointsToPath(pts);
      if (pd.isNotEmpty) {
        if (pd.endsWith('Z')) pd = pd.substring(0, pd.length - 1);
        paths.add(pd);
      }
    }
  } else if (tag == 'circle') {
    if (!_shouldSkip(element)) {
      final cx = double.tryParse(element.getAttribute('cx') ?? '0') ?? 0;
      final cy = double.tryParse(element.getAttribute('cy') ?? '0') ?? 0;
      final r = double.tryParse(element.getAttribute('r') ?? '0') ?? 0;
      if (r > 0) {
        paths.add(_circleToPath(cx, cy, r));
      }
    }
  } else if (tag == 'ellipse') {
    if (!_shouldSkip(element)) {
      final cx = double.tryParse(element.getAttribute('cx') ?? '0') ?? 0;
      final cy = double.tryParse(element.getAttribute('cy') ?? '0') ?? 0;
      final rx = double.tryParse(element.getAttribute('rx') ?? '0') ?? 0;
      final ry = double.tryParse(element.getAttribute('ry') ?? '0') ?? 0;
      if (rx > 0 && ry > 0) {
        paths.add(_ellipseToPath(cx, cy, rx, ry));
      }
    }
  } else if (tag == 'rect') {
    if (!_shouldSkip(element)) {
      final x = double.tryParse(element.getAttribute('x') ?? '0') ?? 0;
      final y = double.tryParse(element.getAttribute('y') ?? '0') ?? 0;
      final w = double.tryParse(element.getAttribute('width') ?? '0') ?? 0;
      final h = double.tryParse(element.getAttribute('height') ?? '0') ?? 0;
      final rx = double.tryParse(element.getAttribute('rx') ?? '0') ?? 0;
      final ry = double.tryParse(element.getAttribute('ry') ?? '0') ?? 0;
      if (w > 0 && h > 0) {
        paths.add(_rectToPath(x, y, w, h, rx, ry));
      }
    }
  } else if (tag == 'line') {
    if (!_shouldSkip(element)) {
      final x1 = element.getAttribute('x1') ?? '0';
      final y1 = element.getAttribute('y1') ?? '0';
      final x2 = element.getAttribute('x2') ?? '0';
      final y2 = element.getAttribute('y2') ?? '0';
      paths.add('M$x1,$y1 L$x2,$y2');
    }
  }

  for (final child in element.childElements) {
    _processElement(child, paths);
  }
}

bool _shouldSkip(XmlElement elem) {
  final fill = (elem.getAttribute('fill') ?? '').toLowerCase();
  final stroke = (elem.getAttribute('stroke') ?? '').toLowerCase();
  return fill == 'none' && (stroke.isEmpty || stroke == 'none');
}

String _polygonPointsToPath(String input) {
  final pointsStr = input.trim();
  final parts = RegExp(r'\s+').allMatches(pointsStr).isEmpty
      ? [pointsStr]
      : pointsStr.split(RegExp(r'\s+'));
  if (parts.isEmpty) return '';

  final pathParts = <String>[];
  for (var i = 0; i < parts.length; i++) {
    final part = parts[i];
    if (part.contains(',')) {
      final xy = part.split(',');
      if (xy.length >= 2) {
        pathParts.add(i == 0 ? 'M${xy[0]} ${xy[1]}' : 'L${xy[0]} ${xy[1]}');
      }
    }
  }

  if (pathParts.isNotEmpty) {
    pathParts.add('Z');
    return pathParts.join('');
  }

  final values = <String>[];
  for (final part in parts) {
    if (part.contains(',')) {
      values.addAll(part.split(','));
    } else {
      values.add(part);
    }
  }

  final fallbackParts = <String>[];
  for (var i = 0; i < values.length - 1; i += 2) {
    final x = values[i];
    final y = values[i + 1];
    fallbackParts.add(i == 0 ? 'M$x $y' : 'L$x $y');
  }
  fallbackParts.add('Z');
  return fallbackParts.join('');
}

String _circleToPath(double cx, double cy, double r) {
  return 'M${cx - r},$cy'
      ' A$r,$r,0,1,0,${cx + r},$cy'
      ' A$r,$r,0,1,0,${cx - r},$cy'
      'Z';
}

String _ellipseToPath(double cx, double cy, double rx, double ry) {
  return 'M${cx - rx},$cy'
      ' A$rx,$ry,0,1,0,${cx + rx},$cy'
      ' A$rx,$ry,0,1,0,${cx - rx},$cy'
      'Z';
}

String _rectToPath(
  double x,
  double y,
  double w,
  double h, [
  double rx = 0,
  double ry = 0,
]) {
  if (rx == 0 && ry == 0) {
    return 'M$x,${y}L${x + w},$y L${x + w},${y + h}L$x,${y + h}Z';
  }
  var rxVal = rx;
  var ryVal = ry;
  if (rxVal == 0) rxVal = ryVal;
  if (ryVal == 0) ryVal = rxVal;
  return 'M${x + rxVal},$y'
      ' L${x + w - rxVal},$y'
      ' A$rxVal,$ryVal,0,0,1,${x + w},${y + ryVal}'
      ' L${x + w},${y + h - ryVal}'
      ' A$rxVal,$ryVal,0,0,1,${x + w - rxVal},${y + h}'
      ' L${x + rxVal},${y + h}'
      ' A$rxVal,$ryVal,0,0,1,$x,${y + h - ryVal}'
      ' L$x,${y + ryVal}'
      ' A$rxVal,$ryVal,0,0,1,${x + rxVal},$y'
      'Z';
}

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

String _generateEmojiDart(List<_EmojiEntry> entries) {
  final buf = StringBuffer()
    ..writeln('// GENERATED CODE - DO NOT MODIFY BY HAND.')
    ..writeln('// ignore_for_file: lines_longer_than_80_chars')
    ..writeln()
    ..writeln("import '../wired_svg_icon_data.dart';")
    ..writeln()
    ..writeln(
      'const Map<int, WiredSvgIconData> kSkribbleEmoji = <int, WiredSvgIconData>{',
    );

  for (final entry in entries) {
    final hexStr = entry.codepoint.toRadixString(16);
    buf
      ..writeln('  // ${entry.name}')
      ..writeln('  0x$hexStr: WiredSvgIconData(')
      ..writeln('    width: 72.0,')
      ..writeln('    height: 72.0,')
      ..writeln('    primitives: <WiredSvgPrimitive>[');
    for (final p in entry.paths) {
      buf.writeln("      WiredSvgPrimitive.path('${_escape(p)}'),");
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
    ..writeln('// ignore_for_file: lines_longer_than_80_chars')
    ..writeln()
    ..writeln(
      '/// Maps each emoji identifier string to its Unicode codepoint in',
    )
    ..writeln('/// `kSkribbleEmoji`.')
    ..writeln(
      'const Map<String, int> kSkribbleEmojiCodePoints = <String, int>{',
    );

  for (final entry in entries) {
    final hexStr = entry.codepoint.toRadixString(16);
    buf.writeln("  '${entry.name}': 0x$hexStr,");
  }

  buf
    ..writeln('};')
    ..writeln();
  return buf.toString();
}

class _EmojiEntry {
  final int codepoint;
  final String name;
  final List<String> paths;

  const _EmojiEntry({
    required this.codepoint,
    required this.name,
    required this.paths,
  });
}
