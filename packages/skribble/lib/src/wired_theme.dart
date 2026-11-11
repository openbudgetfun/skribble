import 'package:flutter/foundation.dart' show listEquals;
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'motion/wired_ink_interaction.dart';
import 'rough/skribble_rough.dart';
import 'wired_font.dart';
import 'wired_paint.dart';
import 'wired_palette.dart';
import 'wired_roughness.dart';
import 'wired_theme_scope.dart';

/// The default hand-drawn font family: Skribble Noto Sketch.
///
/// Redrawn from Google Noto Sans with a round marker pen, a slight bounce, and
/// three alternating drawings of every Latin letter. The family is registered
/// by the `skribble_font_noto_sketch` package; pass that as `TextStyle.package`
/// when using this name in a bare `TextStyle`.
const String skribbleFontFamily = 'SkribbleNotoSketch';

/// Theme data for Wired widgets: the palette, the pen, the roughness level,
/// the typeface, and the motion policy.
///
/// The defaults are skribble's light theme: plum [WiredPalette.ink] on warm
/// [WiredPalette.paper], with the vivid [WiredColorway.sunny] colours: a
/// highlighter-yellow [markerColor], a tomato [accentColor] on primary
/// actions, and a run of [accents] for colour-coding content.
/// [WiredThemeData.colorway] picks another colourway and brightness, and
/// [WiredThemeData.cuddly] builds the sunny theme for either brightness. Install a theme with
/// `SkribbleApp`, [WiredThemeScope], or [WiredTheme], and read it with
/// [WiredTheme.of].
///
/// Two themes with the same values are equal, so rebuilding with an equal
/// theme does not notify dependants.
class WiredThemeData {
  /// Whether decorative ink motion is permitted. Reduced motion still wins.
  final bool motionEnabled;

  /// Default decorative feedback for buttons in this theme.
  final WiredInkInteraction inkInteraction;

  /// Ink for outlines: the hand-drawn border of every control and surface.
  final Color borderColor;

  /// Ink for text and, through [WiredThemeScope], for icons without a colour
  /// of their own.
  final Color textColor;

  /// Ink for the labels of disabled controls.
  final Color disabledTextColor;

  /// Ink for errors: the border of an input with error text and the error
  /// text itself.
  final Color errorColor;

  /// The paper: the fill inside controls and surfaces.
  final Color fillColor;

  /// The highlighter wash under selected and active things: navigation
  /// indicators, progress and slider fills, switch tracks, and selected
  /// segments.
  ///
  /// Ink still draws the shape and the label on top, so selection never
  /// relies on this colour alone.
  final Color markerColor;

  /// The fill of primary actions: `WiredFilledButton`s, the floating action
  /// button, and badges. Defaults to [WiredPalette.tomato].
  ///
  /// Labels on it use [onAccentColor], so any accent stays legible.
  final Color accentColor;

  /// Vivid washes for colour-coding content: cards, chips, tags, and chart
  /// series. Read one with [accentAt], which cycles through the list.
  ///
  /// Defaults to the [WiredColorway.sunny] washes. Never empty.
  final List<Color> accents;

  /// The pen width of outlines, in logical pixels. Icons scale their ink
  /// with it too. Defaults to [kWiredStrokeWidth].
  final double strokeWidth;
  final DrawConfig? _drawConfig;

  /// Coordinated icon, border, and font settings. Defaults to playful ink.
  final WiredRoughness roughnessLevel;
  final double? _roughness;
  final String? _fontFamily;
  final RoughPen? _pen;

  /// Bundled typeface. Defaults to [WiredFont.notoSketch], which keeps the
  /// same lettering at every [roughnessLevel]; the Recursive fonts
  /// ([WiredFont.casual], [WiredFont.linear], [WiredFont.mono]) follow it.
  /// An explicit [fontFamily] overrides this choice.
  final WiredFont font;

  /// Geometry amplitude; an explicit constructor value overrides the level.
  double get roughness => _roughness ?? roughnessLevel.roughness;

  /// How lines are inked; an explicit constructor value overrides the level.
  ///
  /// Gentle uses [RoughPen.fineliner], Playful [RoughPen.ink], and Expressive
  /// [RoughPen.brush]. Pass [RoughPen.uniform] for constant-width lines.
  RoughPen get pen => _pen ?? roughnessLevel.pen;

  /// Font family; an explicit constructor value overrides the level.
  String get fontFamily => _fontFamily ?? font.familyFor(roughnessLevel);

  /// Asset package for bundled fonts, or null for an app-provided family.
  ///
  /// Recursive families resolve to `skribble_font_recursive`; Skribble Noto
  /// families resolve to their own `skribble_font_noto*` package.
  String? get fontPackage => WiredFont.packageFor(fontFamily);

  /// App font families to try for characters [fontFamily] lacks, such as the
  /// Skribble Noto kit scripts an app registers itself (`SkribbleNotoJP`).
  ///
  /// Names are used as written: they are never prefixed with [fontPackage].
  final List<String>? fontFamilyFallback;

  /// [fontFamily] already qualified with [fontPackage]
  /// (`packages/<package>/<family>`), or [fontFamily] itself for an
  /// app-provided family.
  ///
  /// The theme applies this name with no `TextStyle.package`, so fallback
  /// families merged in below the theme keep their own, unprefixed names.
  String get qualifiedFontFamily {
    final package = fontPackage;
    return package == null ? fontFamily : 'packages/$package/$fontFamily';
  }

  /// Creates a theme. Every value has a default; see the fields.
  ///
  /// `roughness`, `fontFamily`, `drawConfig`, and `pen` override what
  /// [roughnessLevel] and [font] would choose.
  WiredThemeData({
    this.motionEnabled = true,
    this.inkInteraction = WiredInkInteraction.pressure,
    this.borderColor = WiredPalette.ink,
    this.textColor = WiredPalette.ink,
    this.disabledTextColor = WiredPalette.mutedInk,
    this.errorColor = WiredPalette.cherry,
    this.fillColor = WiredPalette.paper,
    this.markerColor = WiredPalette.sunshine,
    this.accentColor = WiredPalette.tomato,
    List<Color>? accents,
    this.strokeWidth = kWiredStrokeWidth,
    this.roughnessLevel = WiredRoughness.playful,
    this.font = WiredFont.notoSketch,
    this.fontFamilyFallback,
    this._roughness,
    this._fontFamily,
    this._drawConfig,
    this._pen,
  }) : accents = accents == null || accents.isEmpty
           ? WiredColorway.sunny.accents
           : List.unmodifiable(accents);

  /// Warm paper and plum ink with the default [WiredColorway.sunny]
  /// colours, for either [brightness].
  ///
  /// `WiredThemeData.cuddly(brightness: Brightness.dark)` is skribble's night
  /// theme: paper ink on [WiredPalette.night], with the same vivid marker
  /// and accent glowing on the dark paper.
  factory WiredThemeData.cuddly({
    Brightness brightness = Brightness.light,
    WiredRoughness roughnessLevel = WiredRoughness.playful,
  }) => WiredThemeData.colorway(
    WiredColorway.sunny,
    brightness: brightness,
    roughnessLevel: roughnessLevel,
  );

  /// Warm paper and plum ink (or paper ink on night) in one of skribble's
  /// [WiredColorway]s.
  ///
  /// ```dart
  /// SkribbleApp(
  ///   wiredTheme: WiredThemeData.colorway(WiredColorway.berry),
  ///   darkWiredTheme: WiredThemeData.colorway(
  ///     WiredColorway.berry,
  ///     brightness: Brightness.dark,
  ///   ),
  ///   home: const Home(),
  /// )
  /// ```
  factory WiredThemeData.colorway(
    WiredColorway colorway, {
    Brightness brightness = Brightness.light,
    WiredRoughness roughnessLevel = WiredRoughness.playful,
  }) {
    final dark = brightness == Brightness.dark;
    return WiredThemeData(
      borderColor: dark ? WiredPalette.paper : WiredPalette.ink,
      textColor: dark ? WiredPalette.paper : WiredPalette.ink,
      disabledTextColor: dark ? WiredPalette.mutedPaper : WiredPalette.mutedInk,
      errorColor: dark ? WiredPalette.cherryGlow : WiredPalette.cherry,
      fillColor: dark ? WiredPalette.night : WiredPalette.paper,
      markerColor: colorway.markerFor(brightness),
      accentColor: colorway.accentFor(brightness),
      accents: colorway.accentsFor(brightness),
      roughnessLevel: roughnessLevel,
    );
  }

  /// Resolved drawing configuration, built once per theme instance.
  ///
  /// Painters replay its random stream before each shape, so sharing one
  /// instance across a subtree stays deterministic.
  late final DrawConfig drawConfig =
      _drawConfig ??
      DrawConfig.build(
        roughness: roughness,
        maxRandomnessOffset: roughnessLevel.maxRandomnessOffset,
        lineWobble: roughnessLevel.lineWobble,
        pen: pen,
      );

  /// The theme used where none is installed: `WiredThemeData()`.
  static final defaultTheme = WiredThemeData();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WiredThemeData &&
          runtimeType == other.runtimeType &&
          motionEnabled == other.motionEnabled &&
          inkInteraction == other.inkInteraction &&
          borderColor == other.borderColor &&
          textColor == other.textColor &&
          disabledTextColor == other.disabledTextColor &&
          errorColor == other.errorColor &&
          fillColor == other.fillColor &&
          markerColor == other.markerColor &&
          accentColor == other.accentColor &&
          listEquals(accents, other.accents) &&
          strokeWidth == other.strokeWidth &&
          roughnessLevel == other.roughnessLevel &&
          font == other.font &&
          _roughness == other._roughness &&
          _fontFamily == other._fontFamily &&
          listEquals(fontFamilyFallback, other.fontFamilyFallback) &&
          _drawConfig == other._drawConfig &&
          _pen == other._pen;

  @override
  int get hashCode => Object.hash(
    motionEnabled,
    inkInteraction,
    borderColor,
    textColor,
    disabledTextColor,
    errorColor,
    fillColor,
    markerColor,
    accentColor,
    Object.hashAll(accents),
    strokeWidth,
    roughnessLevel,
    font,
    _roughness,
    _fontFamily,
    fontFamilyFallback == null ? null : Object.hashAll(fontFamilyFallback!),
    _drawConfig,
    _pen,
  );

  /// Returns a copy with the given values replaced.
  ///
  /// Explicit `roughness`, `fontFamily`, `drawConfig`, and `pen` overrides
  /// carry over, including when [roughnessLevel] changes. A null argument
  /// keeps the current value, so a copy cannot clear an override.
  WiredThemeData copyWith({
    bool? motionEnabled,
    WiredInkInteraction? inkInteraction,
    Color? borderColor,
    Color? textColor,
    Color? disabledTextColor,
    Color? errorColor,
    Color? fillColor,
    Color? markerColor,
    Color? accentColor,
    List<Color>? accents,
    double? strokeWidth,
    DrawConfig? drawConfig,
    double? roughness,
    String? fontFamily,
    WiredRoughness? roughnessLevel,
    WiredFont? font,
    List<String>? fontFamilyFallback,
    RoughPen? pen,
  }) {
    return WiredThemeData(
      motionEnabled: motionEnabled ?? this.motionEnabled,
      inkInteraction: inkInteraction ?? this.inkInteraction,
      borderColor: borderColor ?? this.borderColor,
      textColor: textColor ?? this.textColor,
      disabledTextColor: disabledTextColor ?? this.disabledTextColor,
      errorColor: errorColor ?? this.errorColor,
      fillColor: fillColor ?? this.fillColor,
      markerColor: markerColor ?? this.markerColor,
      accentColor: accentColor ?? this.accentColor,
      accents: accents ?? this.accents,
      strokeWidth: strokeWidth ?? this.strokeWidth,
      drawConfig: drawConfig ?? _drawConfig,
      roughnessLevel: roughnessLevel ?? this.roughnessLevel,
      font: font ?? this.font,
      fontFamilyFallback: fontFamilyFallback ?? this.fontFamilyFallback,
      roughness: roughness ?? _roughness,
      fontFamily: fontFamily ?? _fontFamily,
      pen: pen ?? _pen,
    );
  }

  /// The wash at [index] in [accents], cycling past the end, so a list of
  /// any length can colour-code its items: `theme.accentAt(i)`.
  ///
  /// Negative indexes count back from the end.
  Color accentAt(int index) => accents[index % accents.length];

  /// Whichever of [textColor] and [fillColor] reads better on [background]:
  /// the colour for a label, icon, or number drawn on a wash.
  Color onColor(Color background) =>
      _contrastRatio(background, textColor) >=
          _contrastRatio(background, fillColor)
      ? textColor
      : fillColor;

  /// This theme with its ink swapped for one that reads on [wash], for
  /// content drawn on a coloured surface such as a card washed with
  /// [accentAt].
  ///
  /// Returns this theme when [textColor] already reads better on [wash] than
  /// [fillColor]: plum ink on any vivid wash in light themes. On night paper,
  /// where the ink is light, it swaps ink and paper, so text, icons, and
  /// outlines inside a sunshine card turn dark.
  WiredThemeData inkOn(Color wash) {
    if (onColor(wash) == textColor) return this;
    return copyWith(
      borderColor: fillColor,
      textColor: fillColor,
      fillColor: textColor,
      disabledTextColor: fillColor.withValues(alpha: 0.7),
    );
  }

  /// The ink for labels and icons on [markerColor].
  Color get onMarkerColor => onColor(markerColor);

  /// The ink for labels and icons on [accentColor].
  Color get onAccentColor => onColor(accentColor);

  /// Space required by a divider's pen, wobble, and anti-aliased edges.
  double get inkExtent =>
      strokeWidth * drawConfig.pen.reach * 2 +
      2 +
      drawConfig.maxRandomnessOffset * drawConfig.roughness * 2;

  /// A softly lifted paper tone for Material page backgrounds.
  Color get paperBackgroundColor =>
      Color.alphaBlend(fillColor.withValues(alpha: 0.92), Colors.white);

  /// Builds a Material [ColorScheme] from skribble theme colors.
  ColorScheme toColorScheme({Brightness brightness = Brightness.light}) {
    final base = ColorScheme.fromSeed(
      seedColor: borderColor,
      brightness: brightness,
      surface: fillColor,
    );

    return base.copyWith(
      primary: borderColor,
      onPrimary: _bestContrastingColor(borderColor),
      secondary: textColor,
      onSecondary: _bestContrastingColor(textColor),
      primaryContainer: markerColor,
      onPrimaryContainer: onMarkerColor,
      secondaryContainer: markerColor,
      onSecondaryContainer: onMarkerColor,
      tertiary: accentColor,
      onTertiary: onAccentColor,
      tertiaryContainer: accentColor,
      onTertiaryContainer: onAccentColor,
      surface: fillColor,
      onSurface: textColor,
      error: errorColor,
      onError: _bestContrastingColor(errorColor),
      outline: borderColor.withValues(alpha: 0.7),
      surfaceTint: borderColor,
      shadow: borderColor.withValues(alpha: 0.12),
    );
  }

  /// Builds a Material [ThemeData] aligned with the active skribble palette.
  ThemeData toThemeData({
    Brightness brightness = Brightness.light,
    bool useMaterial3 = true,
    TextTheme? textTheme,
  }) {
    final colorScheme = toColorScheme(brightness: brightness);
    final baseTextTheme =
        textTheme ??
        ThemeData(brightness: brightness, useMaterial3: useMaterial3).textTheme;
    final themedTextTheme = baseTextTheme
        .apply(
          fontFamily: qualifiedFontFamily,
          fontFamilyFallback: fontFamilyFallback,
        )
        .apply(bodyColor: textColor, displayColor: textColor);

    return ThemeData(
      brightness: brightness,
      useMaterial3: useMaterial3,
      colorScheme: colorScheme,
      fontFamily: qualifiedFontFamily,
      fontFamilyFallback: fontFamilyFallback,
      scaffoldBackgroundColor: paperBackgroundColor,
      canvasColor: fillColor,
      dividerColor: borderColor.withValues(alpha: 0.35),
      textTheme: themedTextTheme,
      iconTheme: IconThemeData(color: textColor),
      primaryIconTheme: IconThemeData(color: colorScheme.onPrimary),
      appBarTheme: AppBarTheme(
        backgroundColor: paperBackgroundColor,
        foregroundColor: textColor,
        elevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        color: fillColor,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        margin: EdgeInsets.zero,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: fillColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: fillColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      dividerTheme: DividerThemeData(
        color: borderColor.withValues(alpha: 0.35),
        thickness: 1,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: fillColor,
        contentTextStyle: TextStyle(color: textColor),
        actionTextColor: borderColor,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: fillColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: borderColor, width: strokeWidth),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: borderColor, width: strokeWidth),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: borderColor, width: strokeWidth + 0.5),
        ),
      ),
    );
  }
}

double _contrastRatio(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  return la > lb ? (la + 0.05) / (lb + 0.05) : (lb + 0.05) / (la + 0.05);
}

Color _bestContrastingColor(Color color) {
  return ThemeData.estimateBrightnessForColor(color) == Brightness.dark
      ? Colors.white
      : Colors.black;
}

/// Cascades geometry, ink colors, and typography to descendant Wired widgets,
/// and keeps the surrounding Material text styles in sync.
///
/// Use `SkribbleApp` at the app root for a widgets-only tree, or
/// `WiredMaterialApp` when the app already depends on Material. A nested
/// [WiredTheme] can override a section; use
/// `WiredTheme.of(context).copyWith(roughnessLevel: ...)` to
/// retain the surrounding palette. Explicit font and geometry overrides are
/// preserved by `copyWith`, including when changing levels.
///
/// Material sync is the only reason this widget imports `material.dart`. For a
/// boundary that does not touch Material, use [WiredThemeScope]; `WiredTheme`
/// builds on it.
class WiredTheme extends HookWidget {
  /// Creates a theme boundary without rebuilding its child's local state.
  const WiredTheme({super.key, required this.data, required this.child});

  /// The resolved theme for this subtree.
  final WiredThemeData data;

  /// The subtree that inherits this theme.
  final Widget child;

  /// Returns the nearest Wired theme, or the playful default.
  ///
  /// Finds a [WiredThemeScope] as well as a [WiredTheme], so widgets keep
  /// working in a widgets-only shell such as `SkribbleApp`.
  static WiredThemeData of(BuildContext context) => WiredThemeScope.of(context);

  /// Returns the nearest Wired theme, or null when none is installed.
  static WiredThemeData? maybeOf(BuildContext context) =>
      WiredThemeScope.maybeOf(context);

  @override
  Widget build(BuildContext context) {
    // The compatibility bridge updates Material text styles as well as plain
    // Text, so local font overrides reach existing Material-backed controls.
    final parent = Theme.of(context);
    TextTheme apply(TextTheme value) => value.apply(
      fontFamily: data.qualifiedFontFamily,
      fontFamilyFallback: data.fontFamilyFallback,
      bodyColor: data.textColor,
      displayColor: data.textColor,
    );
    return WiredThemeScope(
      data: data,
      child: Theme(
        data: parent.copyWith(
          textTheme: apply(parent.textTheme),
          primaryTextTheme: apply(parent.primaryTextTheme),
        ),
        child: child,
      ),
    );
  }
}
