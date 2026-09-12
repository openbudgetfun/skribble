import 'dart:io';
import 'dart:typed_data';

import 'package:skribble_font_roughen/skribble_font_roughen.dart';
import 'package:skribble_font_roughen/src/truetype_font.dart';
import 'package:test/test.dart';

void main() {
  for (final variant in FontVariant.values) {
    final suffix = variant.fullNameSuffix.replaceAll(' ', '');
    final source = File('../skribble/tool/font/RecursiveSansCslSt-$suffix.ttf');

    test(
      '$suffix changes every outline and preserves coverage and shaping',
      () {
        final bytes = source.readAsBytesSync();
        final original = TrueTypeFont(bytes);
        final edited = TrueTypeFont(bytes);
        expect(edited.roughen(36), 1296);
        final output = edited.encode(
          family: 'Skribble',
          style: variant.fullNameSuffix,
        );
        final saved = TrueTypeFont(output);
        expect(saved.glyphCount, original.glyphCount);
        expect(TrueTypeFont.checksum(output), 0xb1b0afba);

        for (final table in ['cmap', 'hmtx', 'GSUB', 'GPOS', 'GDEF', 'OS/2']) {
          expect(saved.tables[table], original.tables[table], reason: table);
        }

        for (var id = 0; id < original.glyphCount; id++) {
          final before = original.glyphPoints(id);
          final after = saved.glyphPoints(id);
          expect(
            after.length,
            before.length,
            reason: 'point count in glyph $id',
          );
          if (before.isEmpty) continue;
          expect(after, isNot(before), reason: 'unchanged glyph $id');

          for (var p = 0; p < before.length; p++) {
            expect(
              after[p].distanceTo(before[p]),
              lessThan(100),
              reason: 'glyph $id point $p',
            );
          }
        }

        expect(saved.tables.containsKey('DSIG'), isFalse);
        expect(saved.tables.containsKey('prep'), isFalse);
        final second = TrueTypeFont(bytes)..roughen(36);
        expect(
          second.encode(family: 'Skribble', style: variant.fullNameSuffix),
          output,
        );
      },
    );

    test('$suffix zero strength preserves all simple and composite points', () {
      final bytes = source.readAsBytesSync();
      final original = TrueTypeFont(bytes);
      final edited = TrueTypeFont(bytes)..roughen(0);
      final saved = TrueTypeFont(
        edited.encode(family: 'Control', style: variant.fullNameSuffix),
      );

      for (var id = 0; id < original.glyphCount; id++) {
        expect(
          saved.glyphPoints(id),
          original.glyphPoints(id),
          reason: 'glyph $id',
        );
      }
    });

    test(
      '$suffix doubles the previous deformation without changing spacing',
      () {
        final bytes = source.readAsBytesSync();
        final original = TrueTypeFont(bytes);
        final previous = TrueTypeFont(bytes)..roughen(18);
        final current = TrueTypeFont(bytes)..roughen(36);
        var oldDistance = 0.0;
        var newDistance = 0.0;

        for (var id = 0; id < original.glyphCount; id++) {
          final points = original.glyphPoints(id);
          final oldPoints = previous.glyphPoints(id);
          final newPoints = current.glyphPoints(id);

          for (var i = 0; i < points.length; i++) {
            oldDistance += points[i].distanceTo(oldPoints[i]);
            newDistance += points[i].distanceTo(newPoints[i]);
          }
        }

        expect(newDistance / oldDistance, closeTo(2, 0.02));
        expect(current.tables['hmtx'], original.tables['hmtx']);
        expect(FontRoughener(inputPath: '', outputPath: '').jitterAmount, 36);
      },
    );
  }

  test(
    'CLI writes a real font and leaves existing output intact on failure',
    () async {
      final temporary = Directory.systemTemp.createTempSync('roughener-test-');
      addTearDown(() => temporary.deleteSync(recursive: true));
      final output = File('${temporary.path}/nested/output.ttf');
      await FontRoughener(
        inputPath: '../skribble/tool/font/RecursiveSansCslSt-Regular.ttf',
        outputPath: output.path,
      ).roughen();
      final bytes = output.readAsBytesSync();
      expect(TrueTypeFont(bytes).glyphCount, greaterThan(1296));
      final invalid = File('${temporary.path}/broken.ttf')
        ..writeAsStringSync('not a font');
      await expectLater(
        FontRoughener(
          inputPath: invalid.path,
          outputPath: output.path,
        ).roughen(),
        throwsA(isA<FontParseException>()),
      );
      expect(output.readAsBytesSync(), bytes);
    },
  );

  test('invalid strengths and unsupported formats fail explicitly', () {
    for (final strength in [-1.0, 51.0, double.nan, double.infinity]) {
      expect(
        () => FontRoughener(
          inputPath: '',
          outputPath: '',
          jitterAmount: strength,
        ),
        throwsArgumentError,
      );
    }
    for (final bytes in [
      <int>[],
      [0],
      [0x4f, 0x54, 0x54, 0x4f],
    ]) {
      expect(
        () => TrueTypeFont(Uint8List.fromList(bytes)),
        throwsFormatException,
      );
    }
  });
}
