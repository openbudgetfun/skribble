import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:skribble_font_roughen/src/truetype_font.dart';

/// Verifies built experiment files with the real HarfBuzz shaper.
/// Run from repository root; optionally pass the hb-shape executable path.
Future<void> main(List<String> arguments) async {
  final shaper = arguments.isEmpty ? 'hb-shape' : arguments.single;
  final report = <String, Object>{};
  const output = '.screenshots/font-exploration';

  for (final style in ['Regular', 'Bold', 'Italic', 'BoldItalic']) {
    final codePath = '$output/SkribbleCode-$style.ttf';
    final codeSource = TrueTypeFont(await File('packages/skribble/tool/font/RecMonoCasual-$style.ttf').readAsBytes());
    final codeBytes = await File(codePath).readAsBytes();
    final code = TrueTypeFont(codeBytes);
    _metadata(code, 'SkribbleCode', style);
    _require(TrueTypeFont.checksum(codeBytes) == 0xb1b0afba, '$style Code checksum');
    _require(code.glyphCount == codeSource.glyphCount, '$style Code glyph count');

    for (final tag in ['cmap', 'hmtx', 'hhea', 'GSUB', 'GPOS', 'GDEF', 'OS/2', 'post']) {
      _require(_same(code.tables[tag], codeSource.tables[tag]), '$style Code $tag preservation');
    }

    _require(!_same(code.tables['glyf'], codeSource.tables['glyf']), '$style Code outlines change');
    _require(ByteData.sublistView(code.tables['post']!).getUint32(12) == 1, '$style fixed pitch');
    final ascii = String.fromCharCodes(List.generate(95, (i) => i + 32));
    final asciiShape = await _shape(shaper, codePath, ascii, 'calt=0');
    _require(asciiShape.length == 95 && asciiShape.every((g) => g['ax'] == 600), '$style ASCII 600-unit cells');

    for (final operator in ['->', '=>', '==', '===', '!=', '!==', '<=', '>=', '<-', '&&', '||']) {
      final off = await _shape(shaper, codePath, operator, 'calt=0');
      final on = await _shape(shaper, codePath, operator, 'calt=1');
      _require(jsonEncode(on) != jsonEncode(off), '$style $operator activates');
      _require(on.length == operator.length && on.every((g) => g['ax'] == 600), '$style $operator preserves individual cells');
    }

    final casualPath = '$output/SkribblePetal-$style.ttf';
    final casualSource = TrueTypeFont(await File('packages/skribble/tool/font/RecursiveSansCslSt-$style.ttf').readAsBytes());
    final casualBytes = await File(casualPath).readAsBytes();
    final casual = TrueTypeFont(casualBytes);
    _metadata(casual, 'SkribblePetal', style);
    _require(TrueTypeFont.checksum(casualBytes) == 0xb1b0afba, '$style Casual checksum');
    final sourceCharacters = _characters(casualSource.tables['cmap']!);
    final newCharacters = _characters(casual.tables['cmap']!);
    _require(newCharacters.containsAll(sourceCharacters), '$style Casual source character coverage');

    for (final letters in ['fi', 'fl', 'ff', 'ffi', 'ffl', 'ct', 'st', 'tt']) {
      final off = await _shape(shaper, casualPath, letters, 'liga=0,dlig=0,swsh=0');
      final on = await _shape(shaper, casualPath, letters, 'liga=1,dlig=1,swsh=0');
      _require(off.length == letters.length, '$style $letters off');
      _require(on.length == 1 && on.single['g'] == '${letters.split('').join('_')}.petal', '$style $letters new drawn glyph');
    }

    for (final letter in 'aehkmnrtu'.split('')) {
      final on = await _shape(shaper, casualPath, letter, 'liga=0,dlig=0,swsh=1');
      _require(on.length == 1 && on.single['g'] == '$letter.petalSwash', '$style $letter swash');
    }

    report[style] = {
      'codeGlyphs': code.glyphCount,
      'casualGlyphs': casual.glyphCount,
      'casualSourceCodepointsRetained': sourceCharacters.length,
      'asciiCellWidth': 600,
      'codeSequencesChecked': 11,
      'textLigaturesChecked': 8,
      'swashesChecked': 9,
    };
    stdout.writeln('$style: coverage, outline checksums, ligatures, and code cells passed');
  }

  await File('$output/verification.json').writeAsString('${const JsonEncoder.withIndent('  ').convert(report)}\n');
}

/// Checks installed family grouping and style flags rather than filenames.
void _metadata(TrueTypeFont font, String family, String style) {
  final names = ByteData.sublistView(font.tables['name']!);
  final strings = names.getUint16(4);
  var foundFamily = false;

  for (var i = 0; i < names.getUint16(2); i++) {
    final offset = 6 + i * 12;
    final id = names.getUint16(offset + 6);

    if (names.getUint16(offset) != 3 || (id != 1 && id != 16)) continue;
    final length = names.getUint16(offset + 8);
    final start = strings + names.getUint16(offset + 10);
    final value = String.fromCharCodes([
      for (var j = 0; j < length; j += 2) names.getUint16(start + j),
    ]);
    _require(value == family, '$style family name $id is $value');
    foundFamily = true;
  }

  _require(foundFamily, '$style installed family name exists');
  final os2 = ByteData.sublistView(font.tables['OS/2']!);
  _require(os2.getUint16(4) == (style.contains('Bold') ? 700 : 400), '$style weight metadata');
  _require((os2.getUint16(62) & 1 != 0) == style.contains('Italic'), '$style italic metadata');
}

/// Executes a real shaping run and rejects missing glyphs.
Future<List<Map<String, Object?>>> _shape(String executable, String font, String text, String features) async {
  final arguments = [font, '--text=$text', '--features=$features', '--output-format=json'];
  final result = await Process.run(executable, arguments);

  if (result.exitCode != 0) {
    throw ProcessException(executable, arguments, result.stderr.toString(), result.exitCode);
  }

  final rows = (jsonDecode(result.stdout.toString()) as List<Object?>)
      .map((row) => row! as Map<String, Object?>).toList();
  _require(rows.every((row) => row['g'] != '.notdef'), 'No missing glyph in $text');

  return rows;
}

/// Collects mapped Unicode scalars from OpenType cmap formats 4 and 12.
Set<int> _characters(Uint8List bytes) {
  final data = ByteData.sublistView(bytes);
  final result = <int>{};

  for (var i = 0; i < data.getUint16(2); i++) {
    final start = data.getUint32(8 + i * 8);
    final format = data.getUint16(start);

    if (format == 12) {
      final count = data.getUint32(start + 12);

      for (var group = 0; group < count; group++) {
        final offset = start + 16 + group * 12;

        for (var code = data.getUint32(offset); code <= data.getUint32(offset + 4); code++) {
          result.add(code);
        }
      }
    }

    if (format != 4) continue;
    final count = data.getUint16(start + 6) ~/ 2;
    final ends = start + 14;
    final starts = ends + count * 2 + 2;
    final deltas = starts + count * 2;
    final ranges = deltas + count * 2;

    for (var segment = 0; segment < count; segment++) {
      final offset = segment * 2;
      final delta = data.getInt16(deltas + offset);
      final range = data.getUint16(ranges + offset);
      final first = data.getUint16(starts + offset);
      final last = data.getUint16(ends + offset);

      for (var code = first; code <= last && code < 0xffff; code++) {
        final glyph = range == 0 ? (code + delta) & 0xffff : data.getUint16(ranges + offset + range + (code - first) * 2);

        if (glyph != 0) result.add(code);
      }
    }
  }

  _require(result.isNotEmpty, 'Supported Unicode cmap required');

  return result;
}

/// Compares optional source tables, including intentional absence.
bool _same(Uint8List? a, Uint8List? b) => a == null || b == null
    ? a == b
    : a.length == b.length && Iterable<int>.generate(a.length).every((i) => a[i] == b[i]);

/// Makes failures fatal even when Dart assertions are disabled.
void _require(bool condition, String message) {
  if (!condition) throw StateError(message);
}
