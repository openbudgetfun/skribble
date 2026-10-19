import 'package:skribble_rough/skribble_rough.dart' show RoughPen;

/// Coordinated icon, border, pen, and lettering presets for a Wired theme.
///
/// Each level bundles regular, bold, italic, and bold italic fonts and the
/// pen its lines are inked with. Borders remain seed-stable; changing levels
/// does not randomize the drawing.
enum WiredRoughness {
  /// The gentler original lettering and tidy, softly bowed borders.
  gentle(
    fontFamily: 'SkribbleGentle',
    roughness: 0.9,
    maxRandomnessOffset: 1,
    lineWobble: 0,
    pen: RoughPen.fineliner,
  ),

  /// The default: neat, lightly wavering ink, like a careful drawing in a
  /// notebook, with playful lettering.
  playful(
    fontFamily: 'SkribblePlayful',
    roughness: 1.1,
    maxRandomnessOffset: 1.2,
    lineWobble: 0.35,
    pen: RoughPen.ink,
  ),

  /// Strongly hand-drawn lettering and locally wandering borders.
  expressive(
    fontFamily: 'Skribble',
    roughness: 1.8,
    maxRandomnessOffset: 2,
    lineWobble: 1,
    pen: RoughPen.brush,
  );

  const WiredRoughness({
    required this.fontFamily,
    required this.roughness,
    required this.maxRandomnessOffset,
    required this.lineWobble,
    required this.pen,
  });

  /// The font family bundled by the `skribble` package for this level.
  final String fontFamily;

  /// The amplitude multiplier for rough geometry.
  final double roughness;

  /// The base displacement in logical pixels.
  final double maxRandomnessOffset;

  /// The strength of local direction changes along long edges.
  final double lineWobble;

  /// How ink is laid along every line drawn at this level.
  final RoughPen pen;
}
