import 'dart:io';
import 'dart:typed_data';

import 'package:skribble_font_roughen/src/truetype_font.dart';
import 'package:test/test.dart';

void main() {
  const source = '../skribble/tool/font/Recursive-Variable.ttf';
  const assets = '../skribble/assets/fonts';

  test('sparse variable input is rejected before outline edits', () {
    expect(
      () => TrueTypeFont(File(source).readAsBytesSync()),
      throwsFormatException,
    );
  });

  test('expanded variations survive warping and interpolate away from the default', () async {
    final scratch = Directory.systemTemp.createTempSync('variable-test-');
    addTearDown(() => scratch.deleteSync(recursive: true));
    final expanded = '${scratch.path}/expanded.ttf';
    await instance(source, expanded, ['wght=300:400:900', '--no-optimize']);
    final original = TrueTypeFont(File(expanded).readAsBytesSync());
    final edited = TrueTypeFont(
      File('$assets/SkribbleVariablePlayful-Regular.ttf').readAsBytesSync(),
    );
    for (final table in [
      'fvar',
      'gvar',
      'avar',
      'HVAR',
      'MVAR',
      'GSUB',
      'GPOS',
      'GDEF',
      'cmap',
      'hmtx',
    ]) {
      expect(edited.tables[table], original.tables[table], reason: table);
    }
    var outlineChanges = 0;
    for (var id = 0; id < original.glyphCount; id++) {
      if (original.glyphPoints(id).isNotEmpty) {
        expect(edited.glyphPoints(id), isNot(original.glyphPoints(id)));
        outlineChanges++;
      }
    }
    expect(outlineChanges, greaterThan(1000));
    for (final point in [
      (weight: 300, casual: 1.0, mono: 0.0, slant: 0.0, cursive: 0.0),
      (weight: 550, casual: 0.35, mono: 0.4, slant: -8.0, cursive: 0.5),
      (weight: 900, casual: 0.0, mono: 1.0, slant: -15.0, cursive: 1.0),
    ]) {
      final coordinates = [
        'wght=${point.weight}',
        'CASL=${point.casual}',
        'MONO=${point.mono}',
        'slnt=${point.slant}',
        'CRSV=${point.cursive}',
      ];
      final beforePath = '${scratch.path}/before.ttf';
      final afterPath = '${scratch.path}/after.ttf';
      await instance(expanded, beforePath, coordinates);
      await instance(
        '$assets/SkribbleVariablePlayful-Regular.ttf',
        afterPath,
        coordinates,
      );
      final before = TrueTypeFont(File(beforePath).readAsBytesSync());
      final afterBytes = File(afterPath).readAsBytesSync();
      final after = TrueTypeFont(afterBytes);
      expect(after.tables.containsKey('fvar'), isFalse);
      expect(TrueTypeFont.checksum(afterBytes), 0xb1b0afba);
      // Bearings follow the changed contour bounds; advances must stay intact.
      final metrics = ByteData.sublistView(before.tables['hhea']!)
          .getUint16(34);
      final originalMetrics = ByteData.sublistView(before.tables['hmtx']!);
      final editedMetrics = ByteData.sublistView(after.tables['hmtx']!);
      for (var i = 0; i < metrics; i++) {
        expect(
          editedMetrics.getUint16(i * 4),
          originalMetrics.getUint16(i * 4),
        );
      }
      for (var id = 0; id < before.glyphCount; id++) {
        final a = before.glyphPoints(id);
        final b = after.glyphPoints(id);
        expect(b.length, a.length);
        for (var i = 0; i < a.length; i++) {
          expect(
            b[i].distanceTo(a[i]),
            lessThan(100),
            reason: 'glyph $id at $coordinates',
          );
        }
      }
      final shaped = await Process.run('hb-shape', [
        afterPath,
        'Hamburgefontsiv café ffi 0123456789',
      ]);
      expect(shaped.exitCode, 0, reason: '${shaped.stderr}');
      expect(shaped.stdout.toString(), isNot(contains('.notdef')));
    }
  }, timeout: const Timeout(Duration(minutes: 3)));

  test('every family ships seven real weights in upright and italic', () {
    for (final prefix in ['Skribble', 'SkribbleLinear', 'SkribbleMono']) {
      for (final level in ['Gentle', 'Playful', 'Expressive']) {
        final family = prefix == 'Skribble' && level == 'Expressive'
            ? prefix
            : '$prefix$level';
        for (final weight in [
          (300, 'Light'),
          (400, 'Regular'),
          (500, 'Medium'),
          (600, 'SemiBold'),
          (700, 'Bold'),
          (800, 'ExtraBold'),
          (900, 'Black'),
        ]) {
          for (final italic in [false, true]) {
            final suffix = italic && weight.$1 == 400
                ? 'Italic'
                : '${weight.$2}${italic ? 'Italic' : ''}';
            final bytes = File('$assets/$family-$suffix.ttf').readAsBytesSync();
            final font = TrueTypeFont(bytes);
            final os2 = ByteData.sublistView(font.tables['OS/2']!);
            expect(font.tables.containsKey('fvar'), isFalse);
            expect(os2.getUint16(4), weight.$1);
            expect(os2.getUint16(62) & 1, italic ? 1 : 0);
            expect(TrueTypeFont.checksum(bytes), 0xb1b0afba);
          }
        }
      }
    }
  });
}

Future<void> instance(String input, String output, List<String> axes) async {
  final result = await Process.run('fonttools', [
    'varLib.instancer',
    input,
    ...axes,
    '--no-recalc-timestamp',
    '-q',
    '-o',
    output,
  ]);
  expect(result.exitCode, 0, reason: '${result.stdout}\n${result.stderr}');
}
