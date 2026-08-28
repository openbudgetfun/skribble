import 'dart:io';

import 'package:opentype_dart/opentype.dart' as opentype;

import 'package:skribble_font_roughen/src/font_variant.dart';
import 'package:skribble_font_roughen/src/jitter_algorithm.dart';

// opentype_dart 0.0.1 exposes a JS-port style dynamic API surface (parseBuffer,
// glyph paths, and font metadata are all `dynamic`), so typed calls are not
// available here. Revisit when the package gains a typed API.
//
// Progress prints are intentional: this library drives CLI output.
// ignore_for_file: avoid_dynamic_calls, avoid_print

/// Main class for roughening font files with hand-drawn jitter effects.
///
/// This class orchestrates the process of:
/// 1. Reading a source font file (TTF or OTF)
/// 2. Extracting glyph outlines via the path API
/// 3. Applying deterministic jitter to path command coordinates
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
  /// Creates a font roughener with the specified configuration.
  FontRoughener({
    required this.inputPath,
    required this.outputPath,
    this.jitterAmount = 12.0,
    this.variant = FontVariant.regular,
  }) {
    _jitter = JitterAlgorithm(jitterAmount: jitterAmount);
  }

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
    print(
      'Variant: ${variant.name} '
      '(weight=${variant.weight}, '
      'fullname="${variant.fullName}")',
    );
    print('Jitter amount: $jitterAmount');

    try {
      // Read the font file
      final bytes = await inputFile.readAsBytes();
      final buffer = bytes.buffer;

      // Parse the font using opentype_dart
      final font = opentype.parseBuffer(buffer, opt: <String, dynamic>{});

      if (font == null) {
        throw const FontParseException('Failed to parse font file');
      }

      print('Font loaded: ${font.numGlyphs} glyphs');

      // Apply jitter to all glyphs via path commands
      var processedCount = 0;
      final dynamic glyphs = font.glyphs;

      if (glyphs != null) {
        for (var i = 0; i < (glyphs.length as int); i++) {
          final glyph = glyphs.get(i);
          if (glyph != null) {
            try {
              // Get the glyph path and jitter its commands
              final pathRaw = glyph.getPath(
                0,
                0,
                72,
                <String, dynamic>{},
                font,
              );
              final path = pathRaw as opentype.Path?;
              if (path != null && path.commands.isNotEmpty) {
                for (var j = 0; j < path.commands.length; j++) {
                  final cmd = path.commands[j] as Map<String, Object?>;

                  // Apply jitter to coordinate values in commands
                  if (cmd.containsKey('x')) {
                    final dx = _jitter.jitterValue(i, j);
                    final val = cmd['x'];
                    if (val is num) {
                      cmd['x'] = val + dx;
                    }
                  }
                  if (cmd.containsKey('y')) {
                    final dy = _jitter.jitterValue(i, j, offset: 7919);
                    final val = cmd['y'];
                    if (val is num) {
                      cmd['y'] = val + dy;
                    }
                  }
                  if (cmd.containsKey('x1')) {
                    final dx1 = _jitter.jitterValue(i, j, offset: 3823);
                    final val = cmd['x1'];
                    if (val is num) {
                      cmd['x1'] = val + dx1;
                    }
                  }
                  if (cmd.containsKey('y1')) {
                    final dy1 = _jitter.jitterValue(i, j, offset: 5413);
                    final val = cmd['y1'];
                    if (val is num) {
                      cmd['y1'] = val + dy1;
                    }
                  }
                  if (cmd.containsKey('x2')) {
                    final dx2 = _jitter.jitterValue(i, j, offset: 6701);
                    final val = cmd['x2'];
                    if (val is num) {
                      cmd['x2'] = val + dx2;
                    }
                  }
                  if (cmd.containsKey('y2')) {
                    final dy2 = _jitter.jitterValue(i, j, offset: 8237);
                    final val = cmd['y2'];
                    if (val is num) {
                      cmd['y2'] = val + dy2;
                    }
                  }
                }
                processedCount++;
              }
            } on Object catch (_) {
              // Skip glyphs that can't be pathed; opentype_dart throws untyped
              // errors for non-pathable glyphs.
            }
          }
        }
      }

      // Update font metadata for the variant
      font
        ..familyName = 'Skribble'
        ..fontName = 'Skribble-${variant.name}'
        ..fullName = variant.fullName
        ..weight = variant.weight;

      if (variant.italicAngle != 0) {
        font.italicAngle = variant.italicAngle;
      }

      // Write the roughened font
      print('Saving to: $outputPath');
      final outputRaw = font.download();
      final outputBytes = outputRaw as List<int>;
      await File(outputPath).writeAsBytes(outputBytes);

      print('Done!');

      return RoughenResult(
        inputPath: inputPath,
        outputPath: outputPath,
        variant: variant,
        jitterAmount: jitterAmount,
        glyphCount: processedCount,
      );
    }
    // Wraps any processing failure in FontParseException.
    on Object catch (e) {
      if (e is FontParseException) {
        rethrow;
      }
      throw FontParseException('Failed to process font: $e');
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
