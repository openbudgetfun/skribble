/// Coordinated border and lettering presets for a Wired theme.
///
/// Each level bundles regular, bold, italic, and bold italic fonts. Borders
/// remain seed-stable; changing levels does not randomize the drawing.
enum WiredRoughness {
  /// The gentler original lettering and softly bowed borders.
  gentle(
    fontFamily: 'SkribbleGentle',
    roughness: 1.25,
    maxRandomnessOffset: 1.2,
    lineWobble: 0,
  ),

  /// An intermediate amount of wavering ink and lettering.
  playful(
    fontFamily: 'SkribblePlayful',
    roughness: 1.5,
    maxRandomnessOffset: 1.6,
    lineWobble: 0.65,
  ),

  /// Strongly hand-drawn lettering and locally wandering borders.
  expressive(
    fontFamily: 'Skribble',
    roughness: 1.8,
    maxRandomnessOffset: 2,
    lineWobble: 1,
  );

  const WiredRoughness({
    required this.fontFamily,
    required this.roughness,
    required this.maxRandomnessOffset,
    required this.lineWobble,
  });

  /// The font family bundled by the `skribble` package for this level.
  final String fontFamily;

  /// The amplitude multiplier for rough geometry.
  final double roughness;

  /// The base displacement in logical pixels.
  final double maxRandomnessOffset;

  /// The strength of local direction changes along long edges.
  final double lineWobble;
}
