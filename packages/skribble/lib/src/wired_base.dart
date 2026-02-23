import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:skribble_rough/skribble_rough.dart';

import 'canvas/wired_painter_base.dart';
import 'const.dart';

/// Utility class with default Paint objects for wired widgets.
class WiredBase {
  static final Paint pathPaint = Paint()
    ..color = borderColor
    ..style = PaintingStyle.stroke
    ..isAntiAlias = true
    ..strokeCap = StrokeCap.square
    ..strokeWidth = 2;

  static final Paint fillPaint = Paint()
    ..color = filledColor
    ..style = PaintingStyle.stroke
    ..isAntiAlias = true
    ..strokeWidth = 2;

  static Paint fillPainter(Color color) {
    return Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..isAntiAlias = true
      ..strokeWidth = 2;
  }

  static Paint pathPainter(double strokeWidth) {
    return Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..isAntiAlias = true
      ..strokeWidth = strokeWidth;
  }
}

/// Base widget that wraps children with [RepaintBoundary] to isolate repaints.
abstract class WiredBaseWidget extends HookWidget {
  const WiredBaseWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(child: buildWiredElement());
  }

  Widget buildWiredElement();
}

/// Mixin for isolating repaints.
abstract mixin class WiredRepaintMixin {
  Widget buildWiredElement({Key? key, required Widget child}) {
    return RepaintBoundary(key: key, child: child);
  }
}

Widget buildWiredElement({Key? key, required Widget child}) {
  return RepaintBoundary(key: key, child: child);
}

/// Base wired rectangle painter.
class WiredRectangleBase extends WiredPainterBase {
  final double leftIndent;
  final double rightIndent;
  final Color fillColor;
  final double strokeWidth;

  WiredRectangleBase({
    this.leftIndent = 0.0,
    this.rightIndent = 0.0,
    this.fillColor = filledColor,
    this.strokeWidth = 2,
  });

  @override
  void paintRough(
    Canvas canvas,
    Size size,
    DrawConfig drawConfig,
    Filler filler,
  ) {
    final Generator generator = Generator(drawConfig, filler);
    final Drawable figure = generator.rectangle(
      0 + leftIndent,
      0,
      size.width - leftIndent - rightIndent,
      size.height,
    );
    canvas.drawRough(
      figure,
      WiredBase.pathPainter(strokeWidth),
      WiredBase.fillPainter(fillColor),
    );
  }
}

/// Base wired inverted triangle painter.
class WiredInvertedTriangleBase extends WiredPainterBase {
  final double strokeWidth;

  WiredInvertedTriangleBase({this.strokeWidth = 2});

  @override
  void paintRough(
    Canvas canvas,
    Size size,
    DrawConfig drawConfig,
    Filler filler,
  ) {
    final Generator generator = Generator(drawConfig, filler);
    final points = [
      PointD(0, 0),
      PointD(size.width, 0),
      PointD(size.width / 2, size.height),
    ];
    final Drawable figure = generator.polygon(points);
    canvas.drawRough(
      figure,
      WiredBase.pathPainter(strokeWidth),
      WiredBase.fillPainter(borderColor),
    );
  }
}

/// Base wired line painter.
class WiredLineBase extends WiredPainterBase {
  final double x1;
  final double y1;
  final double x2;
  final double y2;
  final double strokeWidth;

  WiredLineBase({
    required this.x1,
    required this.y1,
    required this.x2,
    required this.y2,
    this.strokeWidth = 1,
  });

  @override
  void paintRough(
    Canvas canvas,
    Size size,
    DrawConfig drawConfig,
    Filler filler,
  ) {
    var lx1 = x1;
    var ly1 = y1;
    var lx2 = x2;
    var ly2 = y2;
    if (lx1 < 0) lx1 = 0;
    if (lx1 > size.width) lx1 = size.width;
    if (ly1 < 0) ly1 = 0;
    if (ly1 > size.height) ly1 = size.height;

    if (lx2 < 0) lx2 = 0;
    if (lx2 > size.width) lx2 = size.width;
    if (ly2 < 0) ly2 = 0;
    if (ly2 > size.height) ly2 = size.height;

    final Generator generator = Generator(drawConfig, filler);
    final Drawable figure = generator.line(lx1, ly1, lx2, ly2);
    canvas.drawRough(
      figure,
      WiredBase.pathPainter(strokeWidth),
      WiredBase.fillPaint,
    );
  }
}

/// Base wired circle painter.
class WiredCircleBase extends WiredPainterBase {
  final double diameterRatio;
  final Color fillColor;
  final double strokeWidth;

  WiredCircleBase({
    this.diameterRatio = 1,
    this.fillColor = filledColor,
    this.strokeWidth = 2,
  });

  @override
  void paintRough(
    Canvas canvas,
    Size size,
    DrawConfig drawConfig,
    Filler filler,
  ) {
    final Generator generator = Generator(drawConfig, filler);
    final Drawable figure = generator.circle(
      size.width / 2,
      size.height / 2,
      size.width > size.height
          ? size.width * diameterRatio
          : size.height * diameterRatio,
    );
    canvas.drawRough(
      figure,
      WiredBase.pathPainter(strokeWidth),
      WiredBase.fillPainter(fillColor),
    );
  }
}
