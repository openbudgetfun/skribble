import 'dart:io';

import 'package:skribble_font_roughen/skribble_font_roughen.dart';
import 'package:test/test.dart';

void main() {
  test(
    'specimens embed real fonts, escape text and measure changed outlines',
    () async {
      final temporary = Directory.systemTemp.createTempSync('font-specimen-');
      addTearDown(() => temporary.deleteSync(recursive: true));
      final output = '${temporary.path}/specimen.html';
      final result = await VisualDiff(
        originalPath: '../skribble/tool/font/RecursiveSansCslSt-Regular.ttf',
        roughenedPath: '../skribble/assets/fonts/Skribble-Regular.ttf',
        outputPath: output,
        sampleText: '<script>alert("test")</script> Café',
      ).compare();
      expect(result.differenceCount, greaterThan(80000));
      expect(result.similarityScore, inInclusiveRange(0, 1));
      final html = File(output).readAsStringSync();
      expect('data:font/ttf;base64,'.allMatches(html), hasLength(2));
      expect(html, contains('&lt;script&gt;'));
      expect(html, isNot(contains('<script>')));
    },
  );

  test('image extensions fail instead of creating fake screenshots', () async {
    await expectLater(
      const VisualDiff(
        originalPath: 'unused',
        roughenedPath: 'unused',
        outputPath: 'misleading.png',
      ).compare(),
      throwsArgumentError,
    );
  });
}
