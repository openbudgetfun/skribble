import 'dart:ui';

import 'package:flutter/foundation.dart' show immutable;

/// A named colour in skribble's emoji palette.
///
/// Art refers to colours by role rather than by value, so one drawing serves
/// every skin tone and a palette can be restyled without redrawing anything.
/// The person tokens ([skin], [skinShade], [hair], and their `2` partners for
/// a second person) resolve through [EmojiSkinTone].
enum EmojiToken {
  /// Outlines and dark details: skribble's plum ink.
  ink,

  /// Warm white, for eyes, teeth, and highlights.
  paper,

  /// Pure white, for snow, clouds, and flags.
  white,

  /// Near black, for fur, hair, and night.
  black,

  /// Emoji yellow: faces, stars, and sunshine.
  yellow,

  /// The shaded side of [yellow].
  yellowShade,

  /// Marker orange.
  orange,

  /// The shaded side of [orange].
  orangeShade,

  /// Tomato red.
  red,

  /// The shaded side of [red].
  redShade,

  /// Coral, skribble's accent.
  coral,

  /// Bubblegum pink.
  pink,

  /// The shaded side of [pink].
  pinkShade,

  /// Berry magenta.
  magenta,

  /// Grape purple.
  purple,

  /// The shaded side of [purple].
  purpleShade,

  /// Pale lilac.
  lilac,

  /// Cobalt blue.
  blue,

  /// The shaded side of [blue].
  blueShade,

  /// Pale sky blue, for water, ice, and glass.
  sky,

  /// Teal.
  teal,

  /// Leaf green.
  green,

  /// The shaded side of [green].
  greenShade,

  /// Deep forest green.
  leaf,

  /// Lime.
  lime,

  /// Pale mint.
  mint,

  /// Wood and chocolate brown.
  brown,

  /// The shaded side of [brown].
  brownShade,

  /// Sand and biscuit tan.
  tan,

  /// Cream, for paper, rice, and dough.
  cream,

  /// Stone grey.
  grey,

  /// The shaded side of [grey].
  greyShade,

  /// Pale silver.
  silver,

  /// Blushing cheeks.
  cheek,

  /// The first person's skin.
  skin,

  /// The shaded side of [skin].
  skinShade,

  /// The first person's hair.
  hair,

  /// The second person's skin, in two-person emoji.
  skin2,

  /// The shaded side of [skin2].
  skin2Shade,

  /// The second person's hair, in two-person emoji.
  hair2;

  /// The token's name in emoji art sources, such as `yellow-shade`.
  String get artName => name.replaceAllMapped(
    RegExp('[A-Z]'),
    (match) => '-${match.group(0)!.toLowerCase()}',
  );

  /// Looks up a token by its [artName], or returns null.
  static EmojiToken? fromArtName(String name) => _byArtName[name];

  static final Map<String, EmojiToken> _byArtName = {
    for (final token in values) token.artName: token,
  };
}

/// How an emoji shape is painted: a palette [token] or a literal colour.
///
/// Flags use literal colours because their colours are part of their
/// identity; everything else uses tokens.
@immutable
final class EmojiPaint {
  /// A literal colour as `0xAARRGGBB`.
  const EmojiPaint(int argb) : _argb = argb, token = null;

  const EmojiPaint._(EmojiToken this.token) : _argb = 0;

  final int _argb;

  /// The palette role, or null for a literal colour.
  final EmojiToken? token;

  /// Resolves this paint against [palette] for one or two people.
  Color resolve(
    EmojiPalette palette, {
    EmojiSkinTone tone = EmojiSkinTone.none,
    EmojiSkinTone tone2 = EmojiSkinTone.none,
  }) => switch (token) {
    null => Color(_argb),
    final token => palette.colorOf(token, tone: tone, tone2: tone2),
  };

  @override
  bool operator ==(Object other) =>
      other is EmojiPaint && other.token == token && other._argb == _argb;

  @override
  int get hashCode => Object.hash(token, _argb);

  /// [EmojiToken.ink].
  static const ink = EmojiPaint._(EmojiToken.ink);

  /// [EmojiToken.paper].
  static const paper = EmojiPaint._(EmojiToken.paper);

  /// [EmojiToken.white].
  static const white = EmojiPaint._(EmojiToken.white);

  /// [EmojiToken.black].
  static const black = EmojiPaint._(EmojiToken.black);

  /// [EmojiToken.yellow].
  static const yellow = EmojiPaint._(EmojiToken.yellow);

  /// [EmojiToken.yellowShade].
  static const yellowShade = EmojiPaint._(EmojiToken.yellowShade);

  /// [EmojiToken.orange].
  static const orange = EmojiPaint._(EmojiToken.orange);

  /// [EmojiToken.orangeShade].
  static const orangeShade = EmojiPaint._(EmojiToken.orangeShade);

  /// [EmojiToken.red].
  static const red = EmojiPaint._(EmojiToken.red);

  /// [EmojiToken.redShade].
  static const redShade = EmojiPaint._(EmojiToken.redShade);

  /// [EmojiToken.coral].
  static const coral = EmojiPaint._(EmojiToken.coral);

  /// [EmojiToken.pink].
  static const pink = EmojiPaint._(EmojiToken.pink);

  /// [EmojiToken.pinkShade].
  static const pinkShade = EmojiPaint._(EmojiToken.pinkShade);

  /// [EmojiToken.magenta].
  static const magenta = EmojiPaint._(EmojiToken.magenta);

  /// [EmojiToken.purple].
  static const purple = EmojiPaint._(EmojiToken.purple);

  /// [EmojiToken.purpleShade].
  static const purpleShade = EmojiPaint._(EmojiToken.purpleShade);

  /// [EmojiToken.lilac].
  static const lilac = EmojiPaint._(EmojiToken.lilac);

  /// [EmojiToken.blue].
  static const blue = EmojiPaint._(EmojiToken.blue);

  /// [EmojiToken.blueShade].
  static const blueShade = EmojiPaint._(EmojiToken.blueShade);

  /// [EmojiToken.sky].
  static const sky = EmojiPaint._(EmojiToken.sky);

  /// [EmojiToken.teal].
  static const teal = EmojiPaint._(EmojiToken.teal);

  /// [EmojiToken.green].
  static const green = EmojiPaint._(EmojiToken.green);

  /// [EmojiToken.greenShade].
  static const greenShade = EmojiPaint._(EmojiToken.greenShade);

  /// [EmojiToken.leaf].
  static const leaf = EmojiPaint._(EmojiToken.leaf);

  /// [EmojiToken.lime].
  static const lime = EmojiPaint._(EmojiToken.lime);

  /// [EmojiToken.mint].
  static const mint = EmojiPaint._(EmojiToken.mint);

  /// [EmojiToken.brown].
  static const brown = EmojiPaint._(EmojiToken.brown);

  /// [EmojiToken.brownShade].
  static const brownShade = EmojiPaint._(EmojiToken.brownShade);

  /// [EmojiToken.tan].
  static const tan = EmojiPaint._(EmojiToken.tan);

  /// [EmojiToken.cream].
  static const cream = EmojiPaint._(EmojiToken.cream);

  /// [EmojiToken.grey].
  static const grey = EmojiPaint._(EmojiToken.grey);

  /// [EmojiToken.greyShade].
  static const greyShade = EmojiPaint._(EmojiToken.greyShade);

  /// [EmojiToken.silver].
  static const silver = EmojiPaint._(EmojiToken.silver);

  /// [EmojiToken.cheek].
  static const cheek = EmojiPaint._(EmojiToken.cheek);

  /// [EmojiToken.skin].
  static const skin = EmojiPaint._(EmojiToken.skin);

  /// [EmojiToken.skinShade].
  static const skinShade = EmojiPaint._(EmojiToken.skinShade);

  /// [EmojiToken.hair].
  static const hair = EmojiPaint._(EmojiToken.hair);

  /// [EmojiToken.skin2].
  static const skin2 = EmojiPaint._(EmojiToken.skin2);

  /// [EmojiToken.skin2Shade].
  static const skin2Shade = EmojiPaint._(EmojiToken.skin2Shade);

  /// [EmojiToken.hair2].
  static const hair2 = EmojiPaint._(EmojiToken.hair2);
}

/// A Fitzpatrick skin tone, or [none] for the default emoji yellow.
enum EmojiSkinTone {
  /// The default, unmodified yellow.
  none(null),

  /// Light skin tone, `U+1F3FB`.
  light(0x1F3FB),

  /// Medium-light skin tone, `U+1F3FC`.
  mediumLight(0x1F3FC),

  /// Medium skin tone, `U+1F3FD`.
  medium(0x1F3FD),

  /// Medium-dark skin tone, `U+1F3FE`.
  mediumDark(0x1F3FE),

  /// Dark skin tone, `U+1F3FF`.
  dark(0x1F3FF);

  const EmojiSkinTone(this.modifier);

  /// The Unicode modifier codepoint, or null for [none].
  final int? modifier;

  /// The tone for a modifier [codePoint], or null when it is not one.
  static EmojiSkinTone? fromModifier(int codePoint) {
    for (final tone in values) {
      if (tone.modifier == codePoint) return tone;
    }
    return null;
  }
}

/// The colours emoji are drawn with.
///
/// [EmojiPalette.skribble] is the default: marker colours tuned to sit beside
/// skribble's plum ink and warm paper. Build your own to restyle every emoji
/// at once, for example a softer pastel set, without redrawing anything.
final class EmojiPalette {
  /// Creates a palette from [colors] for every non-person token, plus the
  /// skin and hair colours for each tone.
  const EmojiPalette({
    required this.colors,
    required this.skins,
    required this.skinShades,
    required this.hairs,
  });

  /// Colours for every token except the person tokens.
  final Map<EmojiToken, Color> colors;

  /// Skin colour for each tone.
  final Map<EmojiSkinTone, Color> skins;

  /// Shaded skin colour for each tone.
  final Map<EmojiSkinTone, Color> skinShades;

  /// Hair colour for each tone.
  final Map<EmojiSkinTone, Color> hairs;

  /// Resolves [token] for the first person's [tone] and the second's [tone2].
  Color colorOf(
    EmojiToken token, {
    EmojiSkinTone tone = EmojiSkinTone.none,
    EmojiSkinTone tone2 = EmojiSkinTone.none,
  }) => switch (token) {
    EmojiToken.skin => skins[tone]!,
    EmojiToken.skinShade => skinShades[tone]!,
    EmojiToken.hair => hairs[tone]!,
    EmojiToken.skin2 => skins[tone2]!,
    EmojiToken.skin2Shade => skinShades[tone2]!,
    EmojiToken.hair2 => hairs[tone2]!,
    _ => colors[token]!,
  };

  /// skribble's marker palette.
  static const EmojiPalette skribble = EmojiPalette(
    colors: {
      EmojiToken.ink: Color(0xFF34283F),
      EmojiToken.paper: Color(0xFFFFFAF0),
      EmojiToken.white: Color(0xFFFFFFFF),
      EmojiToken.black: Color(0xFF2E2733),
      EmojiToken.yellow: Color(0xFFFFCC4D),
      EmojiToken.yellowShade: Color(0xFFF4A93A),
      EmojiToken.orange: Color(0xFFFF9A47),
      EmojiToken.orangeShade: Color(0xFFE5772E),
      EmojiToken.red: Color(0xFFEE5A52),
      EmojiToken.redShade: Color(0xFFC9403B),
      EmojiToken.coral: Color(0xFFE87960),
      EmojiToken.pink: Color(0xFFF7A1C0),
      EmojiToken.pinkShade: Color(0xFFE57AA0),
      EmojiToken.magenta: Color(0xFFD65BA6),
      EmojiToken.purple: Color(0xFF9C7BD4),
      EmojiToken.purpleShade: Color(0xFF7B5DB8),
      EmojiToken.lilac: Color(0xFFD7CCF2),
      EmojiToken.blue: Color(0xFF4E8FDA),
      EmojiToken.blueShade: Color(0xFF356FB8),
      EmojiToken.sky: Color(0xFFA6D8F2),
      EmojiToken.teal: Color(0xFF3FB3A4),
      EmojiToken.green: Color(0xFF72C25B),
      EmojiToken.greenShade: Color(0xFF4F9E41),
      EmojiToken.leaf: Color(0xFF3C8C49),
      EmojiToken.lime: Color(0xFFC3E26A),
      EmojiToken.mint: Color(0xFFC7EBCB),
      EmojiToken.brown: Color(0xFFA86A40),
      EmojiToken.brownShade: Color(0xFF84502E),
      EmojiToken.tan: Color(0xFFDDB07A),
      EmojiToken.cream: Color(0xFFF6E3B4),
      EmojiToken.grey: Color(0xFFA9A3AE),
      EmojiToken.greyShade: Color(0xFF827B88),
      EmojiToken.silver: Color(0xFFD9D6DC),
      EmojiToken.cheek: Color(0xFFF59C9C),
    },
    skins: {
      EmojiSkinTone.none: Color(0xFFFFCC4D),
      EmojiSkinTone.light: Color(0xFFF9DCBE),
      EmojiSkinTone.mediumLight: Color(0xFFE7BA90),
      EmojiSkinTone.medium: Color(0xFFC68F63),
      EmojiSkinTone.mediumDark: Color(0xFF9A6541),
      EmojiSkinTone.dark: Color(0xFF5F4134),
    },
    skinShades: {
      EmojiSkinTone.none: Color(0xFFF4A93A),
      EmojiSkinTone.light: Color(0xFFECC29E),
      EmojiSkinTone.mediumLight: Color(0xFFD29E73),
      EmojiSkinTone.medium: Color(0xFFAD754C),
      EmojiSkinTone.mediumDark: Color(0xFF7F4F31),
      EmojiSkinTone.dark: Color(0xFF4A3228),
    },
    hairs: {
      EmojiSkinTone.none: Color(0xFF5C3B28),
      EmojiSkinTone.light: Color(0xFFC08A4E),
      EmojiSkinTone.mediumLight: Color(0xFF7B4A2A),
      EmojiSkinTone.medium: Color(0xFF4A2F21),
      EmojiSkinTone.mediumDark: Color(0xFF3A2519),
      EmojiSkinTone.dark: Color(0xFF2A1C15),
    },
  );
}
