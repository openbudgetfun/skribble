import 'wired_roughness.dart';

/// Bundled hand-drawn typefaces.
///
/// [casual], [linear], and [mono] come from `skribble_font_recursive`. They
/// follow the theme's [WiredRoughness] and contain upright and italic static
/// faces at weights 300–900. [variableFamilyFor] resolves a shared font with
/// continuous style axes.
///
/// [noto], [notoSketch], and [notoLively] are Skribble Noto, generated from
/// Google Noto Sans. Each is a fixed level of hand-drawn character in its own
/// package, so they ignore the roughness level. They ship a Regular face for
/// Latin, Greek, and Cyrillic; every other Noto script is in the Skribble Noto
/// font kit attached to each release.
enum WiredFont {
  /// Recursive Sans Casual, the default handwriting.
  casual,

  /// Recursive Sans Linear, with simpler shapes before roughening.
  linear,

  /// Recursive Mono Linear, preserving equal character advances for code.
  mono,

  /// Skribble Noto, the calmest Noto level: a round pen with a gentle wobble.
  /// Requires the `skribble_font_noto` package.
  noto,

  /// Skribble Noto Sketch: a stronger wobble, a slight bounce, and three
  /// alternating drawings of every Latin letter. Requires the
  /// `skribble_font_noto_sketch` package.
  notoSketch,

  /// Skribble Noto Lively: a wider pen, the strongest wobble and bounce, and
  /// roomier spacing. Requires the `skribble_font_noto_lively` package.
  notoLively;

  /// The Recursive typefaces, which follow the roughness level.
  static const List<WiredFont> recursiveFonts = [casual, linear, mono];

  /// The Skribble Noto typefaces, from calmest to most playful.
  static const List<WiredFont> notoFonts = [noto, notoSketch, notoLively];

  /// The package whose pubspec registers this typeface's families.
  ///
  /// Pass it as `TextStyle.package` when using [familyFor] directly.
  String get package => switch (this) {
    casual || linear || mono => 'skribble_font_recursive',
    noto => 'skribble_font_noto',
    notoSketch => 'skribble_font_noto_sketch',
    notoLively => 'skribble_font_noto_lively',
  };

  /// Whether [familyFor] changes with the roughness level.
  bool get followsRoughness => recursiveFonts.contains(this);

  /// Package font family for [roughness], suitable for a Flutter TextStyle.
  /// Set `package:` to [package] when using this name directly.
  ///
  /// Skribble Noto families are fixed levels and ignore [roughness].
  String familyFor(WiredRoughness roughness) {
    switch (this) {
      case noto:
        return 'SkribbleNoto';
      case notoSketch:
        return 'SkribbleNotoSketch';
      case notoLively:
        return 'SkribbleNotoLively';
      case casual:
        return roughness.fontFamily;
      case linear:
      case mono:
        break;
    }

    final prefix = this == linear ? 'SkribbleLinear' : 'SkribbleMono';

    final suffix = switch (roughness) {
      WiredRoughness.gentle => 'Gentle',
      WiredRoughness.playful => 'Playful',
      WiredRoughness.expressive => 'Expressive',
    };

    return '$prefix$suffix';
  }

  /// Shared variable family for [roughness], with weight 300–900, casualness,
  /// monospace, slant, and cursive axes. Use
  /// `package: 'skribble_font_recursive'` and explicit `FontVariation` values
  /// in a TextStyle. Defaults are linear sans at 400.
  static String variableFamilyFor(WiredRoughness roughness) =>
      switch (roughness) {
        WiredRoughness.gentle => 'SkribbleVariableGentle',
        WiredRoughness.playful => 'SkribbleVariablePlayful',
        WiredRoughness.expressive => 'SkribbleVariableExpressive',
      };

  /// The package that ships [family], or null for an app-provided family.
  static String? packageFor(String family) {
    if (WiredRoughness.values.any(
      (roughness) => variableFamilyFor(roughness) == family,
    )) {
      return casual.package;
    }

    for (final font in values) {
      if (WiredRoughness.values.any(
        (roughness) => font.familyFor(roughness) == family,
      )) {
        return font.package;
      }
    }

    return null;
  }

  /// Whether [family] is a font supplied by a skribble font package.
  static bool isBundled(String family) => packageFor(family) != null;
}
