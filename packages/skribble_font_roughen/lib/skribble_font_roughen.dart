/// Dart CLI tool for roughening fonts with hand-drawn jitter effects.
///
/// Part of the Skribble hand-drawn Flutter design system.
///
/// This library provides functionality to:
/// - Read static TrueType font files
/// - Apply coherent deformation to all glyph outline points
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
///   jitterAmount: 18.0,
///   variant: FontVariant.regular,
/// );
/// await roughener.roughen();
/// ```
library;

export 'src/font_roughener.dart';
export 'src/font_variant.dart';
export 'src/jitter_algorithm.dart';

export 'src/visual_diff.dart';
