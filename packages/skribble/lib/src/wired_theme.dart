import 'package:flutter/material.dart';

import 'rough/skribble_rough.dart';

/// The default hand-drawn font family bundled with Skribble.
///
/// Based on Recursive (Casual axis) with hand-drawn roughening applied via
/// FontForge. See `tool/font/roughen_font.py` for the generation script.
const skribbleFontFamily = 'Skribble';

/// Theme data for Wired widgets.
class WiredThemeData {
  final Color borderColor;
  final Color textColor;
  final Color disabledTextColor;
  final Color fillColor;
  final double strokeWidth;
  final DrawConfig? _drawConfig;
  final double roughness;
  final String fontFamily;

  WiredThemeData({
    this.borderColor = const Color(0xFF1A2B3C),
    this.textColor = Colors.black,
    this.disabledTextColor = Colors.grey,
    this.fillColor = const Color(0xFFFEFEFE),
    this.strokeWidth = 2,
    this.roughness = 1,
    this.fontFamily = skribbleFontFamily,
    DrawConfig? drawConfig,
  }) : _drawConfig = drawConfig;

  DrawConfig get drawConfig => _drawConfig ?? DrawConfig.defaultValues;

  static final defaultTheme = WiredThemeData();

  WiredThemeData copyWith({
    Color? borderColor,
    Color? textColor,
    Color? disabledTextColor,
    Color? fillColor,
    double? strokeWidth,
    DrawConfig? drawConfig,
    double? roughness,
    String? fontFamily,
  }) {
    return WiredThemeData(
      borderColor: borderColor ?? this.borderColor,
      textColor: textColor ?? this.textColor,
      disabledTextColor: disabledTextColor ?? this.disabledTextColor,
      fillColor: fillColor ?? this.fillColor,
      strokeWidth: strokeWidth ?? this.strokeWidth,
      drawConfig: drawConfig ?? _drawConfig,
      roughness: roughness ?? this.roughness,
      fontFamily: fontFamily ?? this.fontFamily,
    );
  }

  /// A softly lifted paper tone for Material page backgrounds.
  Color get paperBackgroundColor =>
      Color.alphaBlend(fillColor.withValues(alpha: 0.92), Colors.white);

  /// Builds a Material [ColorScheme] from Skribble theme colors.
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
      surface: fillColor,
      onSurface: textColor,
      outline: borderColor.withValues(alpha: 0.7),
      surfaceTint: borderColor,
      shadow: borderColor.withValues(alpha: 0.12),
    );
  }

  /// Builds a Material [ThemeData] aligned with the active Skribble palette.
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
        .apply(fontFamily: fontFamily)
        .apply(bodyColor: textColor, displayColor: textColor);

    return ThemeData(
      brightness: brightness,
      useMaterial3: useMaterial3,
      colorScheme: colorScheme,
      fontFamily: fontFamily,
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

Color _bestContrastingColor(Color color) {
  return ThemeData.estimateBrightnessForColor(color) == Brightness.dark
      ? Colors.white
      : Colors.black;
}

/// Provides [WiredThemeData] to descendant Wired widgets.
class WiredTheme extends InheritedWidget {
  final WiredThemeData data;

  const WiredTheme({super.key, required this.data, required super.child});

  static WiredThemeData of(BuildContext context) {
    final theme = context.dependOnInheritedWidgetOfExactType<WiredTheme>();
    return theme?.data ?? WiredThemeData.defaultTheme;
  }

  @override
  bool updateShouldNotify(WiredTheme oldWidget) {
    return data != oldWidget.data;
  }
}
