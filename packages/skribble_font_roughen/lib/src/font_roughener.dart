import 'dart:io';

import 'package:skribble_font_roughen/src/font_variant.dart';
import 'package:skribble_font_roughen/src/truetype_font.dart';

/// Produces a hand-lettered TrueType font with coherent outline warping.
///
/// All source characters, layout features, and advance widths are preserved.
/// CFF must be converted to TrueType. Variable input must have fully expanded
/// gvar deltas, produced by `fonttools varLib.instancer --no-optimize`.
class FontRoughener {
  /// Creates a roughener. [jitterAmount] is measured per 1000 units per em.
  FontRoughener({
    required this.inputPath,
    required this.outputPath,
    this.jitterAmount = 36,
    this.familyName = 'Skribble',
    this.variant = FontVariant.regular,
  }) {
    if (!RegExp(r'^[A-Za-z][A-Za-z0-9-]{0,47}$').hasMatch(familyName)) {
      throw ArgumentError.value(
        familyName,
        'familyName',
        'Use 1–48 ASCII letters, digits or hyphens, starting with a letter.',
      );
    }
    if (!jitterAmount.isFinite || jitterAmount < 0 || jitterAmount > 50) {
      throw ArgumentError.value(
        jitterAmount,
        'jitterAmount',
        'Use 0 through 50.',
      );
    }
  }

  /// Source TrueType font, with explicit point deltas if variable.
  final String inputPath;

  /// Destination font file, written only after complete serialization.
  final String outputPath;

  /// Strength of the handwriting deformation, normalized to a 1000-unit em.
  final double jitterAmount;

  /// Family name embedded in the output font, distinct for each roughness level.
  ///
  /// Use 1–48 ASCII letters, digits or hyphens, starting with a letter.
  /// This also forms a valid, bounded PostScript name with the style suffix.
  final String familyName;

  /// Naming metadata for the source weight and style.
  final FontVariant variant;

  /// Roughens every outlined glyph and returns the number processed.
  Future<RoughenResult> roughen() async {
    final bytes = await File(inputPath).readAsBytes();
    try {
      final font = TrueTypeFont(bytes);
      final count = font.roughen(jitterAmount);
      final output = font.encode(
        family: familyName,
        style: variant.fullNameSuffix,
      );
      // Reparse the saved representation before replacing an existing artifact.
      final verified = TrueTypeFont(output);
      if (verified.glyphCount != font.glyphCount ||
          TrueTypeFont.checksum(output) != 0xb1b0afba) {
        throw const FormatException('Serialized font failed validation.');
      }
      await File(outputPath).parent.create(recursive: true);
      await File(outputPath).writeAsBytes(output);
      return RoughenResult(
        inputPath: inputPath,
        outputPath: outputPath,
        variant: variant,
        jitterAmount: jitterAmount,
        glyphCount: count,
      );
    } on FormatException catch (error) {
      throw FontParseException(error.message);
      // Binary table access may reject malformed offsets before parsing finishes.
      // ignore: avoid_catching_errors
    } on RangeError catch (error) {
      throw FontParseException('Invalid font structure: $error');
    }
  }
}

/// Result of a font roughening operation.
class RoughenResult {
  /// Creates a roughen result with the specified values.
  const RoughenResult({
    required this.inputPath,
    required this.outputPath,
    required this.variant,
    required this.jitterAmount,
    required this.glyphCount,
  });

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

  @override
  String toString() =>
      'RoughenResult('
      'input: $inputPath, '
      'output: $outputPath, '
      'variant: ${variant.name}, '
      'jitter: $jitterAmount, '
      'glyphs: $glyphCount'
      ')';
}

/// Exception thrown when a font file cannot be parsed.
class FontParseException implements Exception {
  /// Creates a font parse exception with the specified message.
  const FontParseException(this.message);

  /// A message describing the parse error.
  final String message;

  @override
  String toString() => 'FontParseException: $message';
}
