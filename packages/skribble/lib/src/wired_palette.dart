import 'dart:ui';

/// Warm paper, plum ink, vivid marker colours, and quiet accent washes shared
/// with the Figma kit.
///
/// The vivid colours ([sunshine] through [lime]) are the markers and accents
/// of the [WiredColorway]s. Every one of them reads with plum [ink] or
/// [night] lettering on top at 4.5:1 or better, so labels on a vivid wash
/// stay legible in light and dark themes alike.
abstract final class WiredPalette {
  /// The light background.
  static const paper = Color(0xFFFFFAF0);

  /// The dark background.
  static const night = Color(0xFF292331);

  /// The light foreground and outline.
  static const ink = Color(0xFF34283F);

  /// A pale purple accent wash: the quiet colourway's marker.
  static const lilac = Color(0xFFE5DDF4);

  /// A warm pink accent wash.
  static const peach = Color(0xFFF6DFD5);

  /// A pale green accent wash.
  static const sage = Color(0xFFDDEAD9);

  /// A soft yellow accent wash.
  static const butter = Color(0xFFF6E8AF);

  /// Secondary text on light paper.
  static const mutedInk = Color(0xFF736678);

  /// Secondary text on dark paper.
  static const mutedPaper = Color(0xFFB9ACBF);

  /// A deep plum wash: the quiet colourway's evening marker on [night].
  static const dusk = Color(0xFF4A3B5E);

  /// A bold warm coral accent (stamp ink), used for primary actions.
  static const coral = Color(0xFFE87960);

  /// Rosy cheeks: the blush on the logo's face and on happy emoji.
  static const blush = Color(0xFFF59C9C);

  /// A bright highlighter yellow: the default marker.
  static const sunshine = Color(0xFFFFD43B);

  /// A vivid red-orange: the default accent for primary actions.
  static const tomato = Color(0xFFFF6B4A);

  /// A juicy orange.
  static const tangerine = Color(0xFFFF9F1C);

  /// A clear, bright sky blue.
  static const sky = Color(0xFF4CC3FF);

  /// A pale, glowing aqua.
  static const aqua = Color(0xFF6BE3F2);

  /// A fresh green mint.
  static const mint = Color(0xFF3DDC97);

  /// A loud, acid lime.
  static const lime = Color(0xFFC4F04D);

  /// A hot bubblegum pink.
  static const bubblegum = Color(0xFFFF85C0);

  /// A bright violet grape.
  static const grape = Color(0xFFA98BFF);

  /// A cornflower blue.
  static const cobalt = Color(0xFF6AA6FF);

  /// A deep cherry red: error ink on light paper (4.8:1 on [paper]).
  static const cherry = Color(0xFFD61F45);

  /// A bright cherry: error ink on [night] (5.5:1).
  static const cherryGlow = Color(0xFFFF6B81);
}

/// A named set of vivid colours for a `WiredThemeData`: the highlighter
/// under selected things, the accent on primary actions, and a run of washes
/// for colour-coding content.
///
/// Every colourway keeps skribble's plum ink on warm paper (or paper ink on
/// night) and changes only the colour. Pick one with
/// `WiredThemeData.colorway(WiredColorway.berry)`. [sunny] is the default;
/// [quiet] is the calm lilac look that used to be the default.
enum WiredColorway {
  /// Highlighter yellow and tomato red, with sky, mint, bubblegum, and
  /// grape washes. The default.
  sunny(
    marker: WiredPalette.sunshine,
    accent: WiredPalette.tomato,
    accents: [
      WiredPalette.sunshine,
      WiredPalette.sky,
      WiredPalette.bubblegum,
      WiredPalette.mint,
      WiredPalette.grape,
      WiredPalette.tangerine,
    ],
  ),

  /// Bubblegum pink and grape violet, with tangerine, sky, and sunshine.
  berry(
    marker: WiredPalette.bubblegum,
    accent: WiredPalette.grape,
    accents: [
      WiredPalette.bubblegum,
      WiredPalette.grape,
      WiredPalette.tangerine,
      WiredPalette.aqua,
      WiredPalette.sunshine,
      WiredPalette.mint,
    ],
  ),

  /// Glowing aqua and cornflower blue, with mint, lime, and a tangerine
  /// spark.
  ocean(
    marker: WiredPalette.aqua,
    accent: WiredPalette.cobalt,
    accents: [
      WiredPalette.aqua,
      WiredPalette.cobalt,
      WiredPalette.mint,
      WiredPalette.tangerine,
      WiredPalette.lime,
      WiredPalette.grape,
    ],
  ),

  /// Acid lime and juicy tangerine, with sunshine, mint, and bubblegum.
  citrus(
    marker: WiredPalette.lime,
    accent: WiredPalette.tangerine,
    accents: [
      WiredPalette.lime,
      WiredPalette.tangerine,
      WiredPalette.sunshine,
      WiredPalette.bubblegum,
      WiredPalette.sky,
      WiredPalette.mint,
    ],
  ),

  /// The calm lilac, peach, sage, and butter washes, for apps that want to
  /// whisper. The marker is [WiredPalette.dusk] on dark paper.
  quiet(
    marker: WiredPalette.lilac,
    darkMarker: WiredPalette.dusk,
    accent: WiredPalette.lilac,
    darkAccent: WiredPalette.dusk,
    accents: [
      WiredPalette.lilac,
      WiredPalette.peach,
      WiredPalette.sage,
      WiredPalette.butter,
    ],
    darkAccents: [WiredPalette.dusk],
  );

  const WiredColorway({
    required this.marker,
    required this.accent,
    required this.accents,
    this._darkMarker,
    this._darkAccent,
    this._darkAccents,
  });

  /// The highlighter under selected and active things on light paper.
  final Color marker;

  /// The fill of primary actions on light paper.
  final Color accent;

  /// Washes for colour-coding content on light paper, in order.
  final List<Color> accents;

  final Color? _darkMarker;
  final Color? _darkAccent;
  final List<Color>? _darkAccents;

  /// The marker for [brightness]. Vivid colourways glow the same on night.
  Color markerFor(Brightness brightness) =>
      brightness == Brightness.dark ? _darkMarker ?? marker : marker;

  /// The accent for [brightness].
  Color accentFor(Brightness brightness) =>
      brightness == Brightness.dark ? _darkAccent ?? accent : accent;

  /// The colour-coding washes for [brightness].
  List<Color> accentsFor(Brightness brightness) =>
      brightness == Brightness.dark ? _darkAccents ?? accents : accents;
}
