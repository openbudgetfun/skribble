import 'dart:io';
import 'dart:typed_data';

import 'package:skribble_font_roughen/skribble_font_roughen.dart';
import 'package:skribble_font_roughen/src/truetype_font.dart';
import 'package:test/test.dart';

String familyName(TrueTypeFont font) {
  final data = ByteData.sublistView(font.tables['name']!);
  final count = data.getUint16(2);
  final start = data.getUint16(4);
  for (var i = 0; i < count; i++) {
    final record = 6 + i * 12;
    if (data.getUint16(record) != 3 || data.getUint16(record + 6) != 1) {
      continue;
    }
    final length = data.getUint16(record + 8);
    final offset = start + data.getUint16(record + 10);
    return String.fromCharCodes([
      for (var j = 0; j < length; j += 2) data.getUint16(offset + j),
    ]);
  }
  throw StateError('No Windows family name');
}

void main() {
  test('family metadata rejects unsafe or unbounded PostScript names', () {
    for (final family in ['', 'A family', '1Family', 'A/B', 'a' * 49]) {
      expect(
        () => FontRoughener(
          inputPath: 'unused',
          outputPath: 'unused',
          familyName: family,
        ),
        throwsArgumentError,
      );
    }
  });

  for (final variant in FontVariant.values) {
    final suffix = variant.fullNameSuffix.replaceAll(' ', '');
    test('$suffix levels retain every glyph, spacing and shaping', () {
      final source = TrueTypeFont(
        File('../skribble/tool/font/RecursiveSansCslSt-$suffix.ttf')
            .readAsBytesSync(),
      );
      var previousDistance = 0.0;
      for (final family in ['SkribbleGentle', 'SkribblePlayful', 'Skribble']) {
        final bytes = File('../skribble/assets/fonts/$family-$suffix.ttf')
            .readAsBytesSync();
        final font = TrueTypeFont(bytes);
        expect(familyName(font), family);
        expect(TrueTypeFont.checksum(bytes), 0xb1b0afba);
        expect(font.glyphCount, source.glyphCount);
        for (final table in [
          'cmap',
          'hmtx',
          'hhea',
          'GSUB',
          'GPOS',
          'GDEF',
          'OS/2',
        ]) {
          expect(
            font.tables[table],
            source.tables[table],
            reason: '$family $table',
          );
        }
        var distance = 0.0;
        for (var glyph = 0; glyph < source.glyphCount; glyph++) {
          final before = source.glyphPoints(glyph);
          final after = font.glyphPoints(glyph);
          expect(after.length, before.length);
          if (before.isEmpty) continue;
          expect(after, isNot(before), reason: '$family glyph $glyph');
          for (var point = 0; point < before.length; point++) {
            distance += before[point].distanceTo(after[point]);
          }
        }
        expect(distance, greaterThan(previousDistance));
        previousDistance = distance;
      }
    });
  }
  test(
    'custom strength and family survive a complete generator round trip',
    () async {
      final directory = await Directory.systemTemp.createTemp('custom-ink-');
      addTearDown(() => directory.delete(recursive: true));
      final output = '${directory.path}/CustomInk.ttf';
      final result = await FontRoughener(
        inputPath: '../skribble/tool/font/RecursiveSansCslSt-Regular.ttf',
        outputPath: output,
        familyName: 'CustomInk',
        jitterAmount: 23.5,
      ).roughen();
      expect(
        familyName(TrueTypeFont(await File(output).readAsBytes())),
        'CustomInk',
      );
      expect(result.jitterAmount, 23.5);
      expect(result.glyphCount, 1297);
    },
  );
}
