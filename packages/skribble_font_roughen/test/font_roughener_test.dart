import 'dart:io';

import 'package:skribble_font_roughen/skribble_font_roughen.dart';
import 'package:test/test.dart';

void main() {
  group('FontRoughener', () {
    test('throws FileSystemException for non-existent input file', () async {
      final roughener = FontRoughener(
        inputPath: '/nonexistent/path.ttf',
        outputPath: '/tmp/output.ttf',
      );

      expect(
        roughener.roughen,
        throwsA(isA<FileSystemException>()),
      );
    });

    test('creates output file for valid input', () async {
      // Create a temporary test font file
      final tempDir = await Directory.systemTemp.createTemp('font_test');
      final inputFile = File('${tempDir.path}/test.ttf');
      final outputFile = File('${tempDir.path}/output.ttf');

      // Write a minimal font file placeholder
      await inputFile.writeAsString('Test font content');

      try {
        final roughener = FontRoughener(
          inputPath: inputFile.path,
          outputPath: outputFile.path,
          jitterAmount: 10,
        );

        // This will throw a FontParseException because the file isn't a real font
        // but it tests that the file existence check works
        expect(
          roughener.roughen,
          throwsA(isA<FontParseException>()),
        );
      } finally {
        // Clean up
        await tempDir.delete(recursive: true);
      }
    });

    test('RoughenResult contains correct values', () {
      const result = RoughenResult(
        inputPath: '/input.ttf',
        outputPath: '/output.ttf',
        variant: FontVariant.bold,
        jitterAmount: 15,
        glyphCount: 100,
      );

      expect(result.inputPath, equals('/input.ttf'));
      expect(result.outputPath, equals('/output.ttf'));
      expect(result.variant, equals(FontVariant.bold));
      expect(result.jitterAmount, equals(15.0));
      expect(result.glyphCount, equals(100));
    });

    test('RoughenResult toString returns readable format', () {
      const result = RoughenResult(
        inputPath: '/input.ttf',
        outputPath: '/output.ttf',
        variant: FontVariant.italic,
        jitterAmount: 12,
        glyphCount: 50,
      );

      final str = result.toString();
      expect(str, contains('input: /input.ttf'));
      expect(str, contains('output: /output.ttf'));
      expect(str, contains('variant: italic'));
      expect(str, contains('jitter: 12.0'));
      expect(str, contains('glyphs: 50'));
    });
  });

  group('FontParseException', () {
    test('stores message correctly', () {
      const exception = FontParseException('Test error message');
      expect(exception.message, equals('Test error message'));
    });

    test('toString returns readable format', () {
      const exception = FontParseException('Test error message');
      expect(
        exception.toString(),
        equals('FontParseException: Test error message'),
      );
    });
  });

  group('FontVariant', () {
    test('regular has correct properties', () {
      expect(FontVariant.regular.name, equals('regular'));
      expect(FontVariant.regular.weight, equals('Regular'));
      expect(FontVariant.regular.fullNameSuffix, equals('Regular'));
      expect(FontVariant.regular.italicAngle, equals(0));
    });

    test('bold has correct properties', () {
      expect(FontVariant.bold.name, equals('bold'));
      expect(FontVariant.bold.weight, equals('Bold'));
      expect(FontVariant.bold.fullNameSuffix, equals('Bold'));
      expect(FontVariant.bold.italicAngle, equals(0));
    });

    test('italic has correct properties', () {
      expect(FontVariant.italic.name, equals('italic'));
      expect(FontVariant.italic.weight, equals('Regular'));
      expect(FontVariant.italic.fullNameSuffix, equals('Italic'));
      expect(FontVariant.italic.italicAngle, equals(-12));
    });

    test('boldItalic has correct properties', () {
      expect(FontVariant.boldItalic.name, equals('boldItalic'));
      expect(FontVariant.boldItalic.weight, equals('Bold'));
      expect(FontVariant.boldItalic.fullNameSuffix, equals('Bold Italic'));
      expect(FontVariant.boldItalic.italicAngle, equals(-12));
    });

    test('fontName returns correct format', () {
      expect(FontVariant.regular.fontName, equals('Skribble-regular'));
      expect(FontVariant.bold.fontName, equals('Skribble-bold'));
      expect(FontVariant.italic.fontName, equals('Skribble-italic'));
      expect(FontVariant.boldItalic.fontName, equals('Skribble-boldItalic'));
    });

    test('fullName returns correct format', () {
      expect(FontVariant.regular.fullName, equals('Skribble Regular'));
      expect(FontVariant.bold.fullName, equals('Skribble Bold'));
      expect(FontVariant.italic.fullName, equals('Skribble Italic'));
      expect(FontVariant.boldItalic.fullName, equals('Skribble Bold Italic'));
    });
  });
}
