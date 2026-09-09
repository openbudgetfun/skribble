import 'wired_roughness.dart';

/// Bundled hand-drawn typefaces, each with all three roughness levels.
///
/// Each family contains real regular, bold, italic, and bold italic faces.
/// These are static fonts with weights 400 and 700, not variable fonts.
enum WiredFont {
  /// Recursive Sans Casual, the default handwriting.
  casual,

  /// Recursive Sans Linear, with simpler shapes before roughening.
  linear,

  /// Recursive Mono Linear, preserving equal character advances for code.
  mono;

  /// Package font family for [roughness], suitable for a Flutter TextStyle.
  /// Set `package: 'skribble'` when using this name directly.
  String familyFor(WiredRoughness roughness) {
    if (this == casual) return roughness.fontFamily;

    final prefix = this == linear ? 'SkribbleLinear' : 'SkribbleMono';
    final suffix = switch (roughness) {
      WiredRoughness.gentle => 'Gentle',
      WiredRoughness.playful => 'Playful',
      WiredRoughness.expressive => 'Expressive',
    };

    return '$prefix$suffix';
  }

  /// Whether [family] is a font supplied by the Skribble package.
  static bool isBundled(String family) => values.any(
    (font) => WiredRoughness.values.any(
      (roughness) => font.familyFor(roughness) == family,
    ),
  );
}
