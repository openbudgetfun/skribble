/// Dart CLI tool for roughening fonts with hand-drawn jitter effects.
///
/// Part of the Skribble hand-drawn Flutter design system.
///
/// This library provides functionality to:
/// - Read TTF/OTF font files
/// - Apply deterministic jitter to on-curve glyph points
/// - Output roughened font variants with hand-drawn character
///
/// ## Usage
///
/// ```dart
/// import 'package:skribble_font_roughen/skribble_font_roughen.dart';
///
/// final roughener = FontRoughener(
///   inputPath: 'input.ttf',
///   outputPath: 'output.ttf',
///   jitterAmount: 12.0,
///   variant: FontVariant.regular,
/// );
/// await roughener.roughen();
/// ```
library;

export 'src/font_roughener.dart';
export 'src/font_variant.dart';
export 'src/jitter_algorithm.dart';
