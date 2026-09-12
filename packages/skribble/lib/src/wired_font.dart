import 'wired_roughness.dart';

/// Bundled hand-drawn typefaces, each with all three roughness levels.
///
/// Each family contains upright and italic static faces at weights 300–900.
/// [variableFamilyFor] resolves a shared font with continuous style axes.
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

  /// Shared variable family for [roughness], with weight 300–900, casualness,
  /// monospace, slant, and cursive axes. Use `package: 'skribble'` and explicit
  /// `FontVariation` values in a TextStyle. Defaults are linear sans at 400.
  static String variableFamilyFor(WiredRoughness roughness) =>
      switch (roughness) {
        WiredRoughness.gentle => 'SkribbleVariableGentle',
        WiredRoughness.playful => 'SkribbleVariablePlayful',
        WiredRoughness.expressive => 'SkribbleVariableExpressive',
      };

  /// Whether [family] is a font supplied by the Skribble package.
  static bool isBundled(String family) =>
      WiredRoughness.values.any(
        (roughness) => variableFamilyFor(roughness) == family,
      ) ||
      values.any(
        (font) => WiredRoughness.values.any(
          (roughness) => font.familyFor(roughness) == family,
        ),
      );
}
