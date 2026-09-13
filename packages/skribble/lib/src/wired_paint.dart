import 'package:flutter/widgets.dart';

/// Default border color when no theme is provided.
///
/// Internal to the library; exposed through [WiredBase]'s defaults rather than
/// the public barrel.
const Color kWiredDefaultBorderColor = Color(0xFF1A2B3C);

/// Default fill color when no theme is provided.
///
/// Internal to the library; exposed through [WiredBase]'s defaults rather than
/// the public barrel.
const Color kWiredDefaultFillColor = Color(0xFFFEFEFE);

/// Standard height for skribble button widgets (matches Material default).
const double kWiredButtonHeight = 42.0;

/// Utility class with default Paint objects for wired widgets.
class WiredBase {
  /// Returns the standard fill paint used by hand-drawn shapes.
  ///
  /// The paint is stroked rather than filled: standalone fillers receive it to
  /// draw their hachure, dots, or solid wash inside a shape.
  static Paint fillPainter(Color color) {
    return Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..isAntiAlias = true
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = 2;
  }

  /// Returns the standard outline paint used by hand-drawn shapes.
  ///
  /// [strokeWidth] is the pen width in logical pixels; [color] defaults to the
  /// built-in border color used when no theme is present.
  static Paint pathPainter(
    double strokeWidth, {
    Color color = kWiredDefaultBorderColor,
  }) {
    return Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..isAntiAlias = true
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = strokeWidth;
  }
}
