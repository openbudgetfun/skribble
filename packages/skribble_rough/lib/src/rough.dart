import 'package:flutter/material.dart';

import 'core.dart';
import 'entities.dart';

/// Extension on Canvas for drawing rough/hand-drawn shapes.
extension Rough on Canvas {
  Path _drawToContext(OpSet drawing) {
    final Path path = Path();
    for (final Op op in drawing.ops!) {
      final data = op.data;
      switch (op.op) {
        case OpType.move:
          path.moveTo(data[0].x, data[0].y);
        case OpType.curveTo:
          path.cubicTo(
            data[0].x,
            data[0].y,
            data[1].x,
            data[1].y,
            data[2].x,
            data[2].y,
          );
        case OpType.lineTo:
          path.lineTo(data[0].x, data[0].y);
      }
    }
    return path;
  }

  void drawRough(Drawable drawable, Paint pathPaint, Paint fillPaint) {
    for (final OpSet drawing in drawable.sets ?? []) {
      switch (drawing.type!) {
        case OpSetType.path:
          drawPath(_drawToContext(drawing), pathPaint);
        case OpSetType.fillPath:
          final Paint fillPaint0 = fillPaint;
          fillPaint0.style = PaintingStyle.fill;
          final Path path = _drawToContext(drawing)..close();
          drawPath(path, fillPaint0);
        case OpSetType.fillSketch:
          drawPath(_drawToContext(drawing), fillPaint);
      }
    }
  }
}
