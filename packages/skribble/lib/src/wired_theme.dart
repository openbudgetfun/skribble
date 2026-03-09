import 'package:flutter/material.dart';

import 'rough/skribble_rough.dart';

/// Theme data for Wired widgets.
class WiredThemeData {
  final Color borderColor;
  final Color textColor;
  final Color disabledTextColor;
  final Color fillColor;
  final double strokeWidth;
  final DrawConfig? _drawConfig;
  final double roughness;

  WiredThemeData({
    this.borderColor = const Color(0xFF1A2B3C),
    this.textColor = Colors.black,
    this.disabledTextColor = Colors.grey,
    this.fillColor = const Color(0xFFFEFEFE),
    this.strokeWidth = 2,
    this.roughness = 1,
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
  }) {
    return WiredThemeData(
      borderColor: borderColor ?? this.borderColor,
      textColor: textColor ?? this.textColor,
      disabledTextColor: disabledTextColor ?? this.disabledTextColor,
      fillColor: fillColor ?? this.fillColor,
      strokeWidth: strokeWidth ?? this.strokeWidth,
      drawConfig: drawConfig ?? _drawConfig,
      roughness: roughness ?? this.roughness,
    );
  }
}

/// Provides [WiredThemeData] to descendant Wired widgets.
class WiredTheme extends InheritedWidget {
  final WiredThemeData data;

  const WiredTheme({
    super.key,
    required this.data,
    required super.child,
  });

  static WiredThemeData of(BuildContext context) {
    final theme = context.dependOnInheritedWidgetOfExactType<WiredTheme>();
    return theme?.data ?? WiredThemeData.defaultTheme;
  }

  @override
  bool updateShouldNotify(WiredTheme oldWidget) {
    return data != oldWidget.data;
  }
}
