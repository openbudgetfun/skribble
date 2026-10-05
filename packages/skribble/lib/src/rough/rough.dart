import 'dart:ui';

import 'entities.dart';
import 'rough_drawing.dart';

/// Extension on Canvas for drawing rough/hand-drawn shapes.
extension Rough on Canvas {
  /// Paints [drawable] once with its configured pen.
  ///
  /// Prefer keeping a [RoughDrawing] when the same shape paints more than
  /// once: it samples the pen strokes a single time.
  void drawRough(Drawable drawable, Paint pathPaint, Paint fillPaint) {
    RoughDrawing(drawable, pathPaint, fillPaint).paint(this);
  }
}
