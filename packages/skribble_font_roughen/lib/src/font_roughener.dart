import 'dart:io';
import 'dart:typed_data';

import 'package:opentype_dart/opentype.dart' as opentype;

import 'font_variant.dart';
import 'jitter_algorithm.dart';

/// Main class for roughening font files with hand-drawn jitter effects.
///
/// This class orchestrates the process of:
/// 1. Reading a source font file (TTF or OTF)
/// 2. Extracting glyph outlines
/// 3. Applying deterministic jitter to on-curve points
/// 4. Writing the roughened font to a new file
///
/// ## Example
///
/// ```dart
/// final roughener = FontRoughener(
///   inputPath: 'input.ttf',
///   outputPath: 'output.ttf',
///   jitterAmount: 12.0,
///   variant: FontVariant.regular,
/// );
/// await roughener.roughen();
/// ```
class FontRoughener {
  /// Path to the input font file.
  final String inputPath;

  /// Path for the output roughened font file.
  final String outputPath;

  /// The jitter amount in font units (default: 12.0).
  final double jitterAmount;

  /// The font variant to apply (default: regular).
  final FontVariant variant;

  /// The jitter algorithm to use.
  late final JitterAlgorithm _jitter;

  /// Creates a font roughener with the specified configuration.
  FontRoughener({
    required this.inputPath,
    required this.outputPath,
    this.jitterAmount = 12.0,
    this.variant = FontVariant.regular,
  }) {
    _jitter = JitterAlgorithm(jitterAmount: jitterAmount);
  }

  /// Roughens the input font and writes the result to the output path.
  ///
  /// Returns a [RoughenResult] with statistics about the process.
  ///
  /// Throws [FileSystemException] if the input file doesn't exist.
  /// Throws [FontParseException] if the font cannot be parsed.
  Future<RoughenResult> roughen() async {
    // Verify input file exists
    final inputFile = File(inputPath);
    if (!inputFile.existsSync()) {
      throw FileSystemException('Input font file not found', inputPath);
    }

    print('Opening font: $inputPath');
    print('Variant: ${variant.name} (weight=${variant.weight}, '
        'fullname="${variant.fullName}")');
    print('Jitter amount: $jitterAmount');

    try {
      // Read the font file
      final bytes = await inputFile.readAsBytes();
      final buffer = bytes.buffer;

      // Parse the font using opentype_dart
      final font = opentype.parseBuffer(buffer, opt: {});

      if (font == null) {
        throw const FontParseException('Failed to parse font file');
      }

      print('Font loaded: ${font.numGlyphs} glyphs');

      // Apply jitter to all glyphs
      int processedCount = 0;
      final glyphs = font.glyphs;

      if (glyphs != null) {
        for (int i = 0; i < glyphs.length; i++) {
          final glyph = glyphs.get(i);
          if (glyph != null && glyph.points != null) {
            // Apply jitter to the glyph points
            final points = glyph.points!;
            final jitteredPoints = <opentype.Point>[];

            for (int j = 0; j < points.length; j++) {
              final point = points[j];
              if (point.onCurve) {
                // Apply jitter to on-curve points
                final dx = _jitter.jitterValue(i, j);
                final dy = _jitter.jitterValue(i, j, offset: 7919);
                jitteredPoints.add(opentype.Point(
                  x: point.x + dx,
                  y: point.y + dy,
                  onCurve: true,
                ));
              } else {
                // Keep control points unchanged
                jitteredPoints.add(point);
              }
            }

            // Update the glyph points
            glyph.points = jitteredPoints;
            processedCount++;
          }
        }
      }

      // Update font metadata for the variant
      font.familyName = 'Skribble';
      font.fontName = 'Skribble-${variant.name}';
      font.fullName = variant.fullName;
      font.weight = variant.weight;

      if (variant.italicAngle != 0) {
        font.italicAngle = variant.italicAngle;
      }

      // Write the roughened font
      print('Saving to: $outputPath');
      final outputFile = File(outputPath);
      final outputBytes = font.download();
      await outputFile.writeAsBytes(outputBytes);

      print('Done!');

      return RoughenResult(
        inputPath: inputPath,
        outputPath: outputPath,
        variant: variant,
        jitterAmount: jitterAmount,
        glyphCount: processedCount,
      );
    } catch (e) {
      if (e is FontParseException) {
        rethrow;
      }
      throw FontParseException('Failed to process font: $e');
    }
  }
}

/// Result of a font roughening operation.
class RoughenResult {
  /// Path to the input font file.
  final String inputPath;

  /// Path to the output roughened font file.
  final String outputPath;

  /// The font variant that was applied.
  final FontVariant variant;

  /// The jitter amount that was used.
  final double jitterAmount;

  /// Number of glyphs that were processed.
  final int glyphCount;

  /// Creates a roughen result with the specified values.
  const RoughenResult({
    required this.inputPath,
    required this.outputPath,
    required this.variant,
    required this.jitterAmount,
    required this.glyphCount,
  });

  @override
  String toString() => 'RoughenResult('
      'input: $inputPath, '
      'output: $outputPath, '
      'variant: ${variant.name}, '
      'jitter: $jitterAmount, '
      'glyphs: $glyphCount'
      ')';
}

/// Exception thrown when a font file cannot be parsed.
class FontParseException implements Exception {
  /// A message describing the parse error.
  final String message;

  /// Creates a font parse exception with the specified message.
  const FontParseException(this.message);

  @override
  String toString() => 'FontParseException: $message';
}
