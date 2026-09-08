import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'canvas/wired_painter_base.dart';
import 'rough/skribble_rough.dart';

/// Default border color when no theme is provided.
const Color _defaultBorderColor = Color(0xFF1A2B3C);

/// Default fill color when no theme is provided.
const Color _defaultFillColor = Color(0xFFFEFEFE);

/// Standard height for Skribble button widgets (matches Material default).
const double kWiredButtonHeight = 42.0;

/// Utility class with default Paint objects for wired widgets.
class WiredBase {
  static Paint fillPainter(Color color) {
    return Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..isAntiAlias = true
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = 2;
  }

  static Paint pathPainter(
    double strokeWidth, {
    Color color = _defaultBorderColor,
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
  final Color borderColor;
  final double strokeWidth;

  WiredRectangleBase({
    this.leftIndent = 0.0,
    this.rightIndent = 0.0,
    this.fillColor = _defaultFillColor,
    this.borderColor = _defaultBorderColor,
    this.strokeWidth = 2.4,
  });

  @override
  void paintRough(
    Canvas canvas,
    Size size,
    DrawConfig drawConfig,
    Filler filler,
  ) {
    final Generator generator = Generator(drawConfig, filler);
    final rect = _inkRect(size, strokeWidth, drawConfig);
    final Drawable figure = generator.rectangle(
      rect.left + leftIndent,
      rect.top,
      math.max(0, rect.width - leftIndent - rightIndent),
      rect.height,
    );
    canvas.drawRough(
      figure,
      WiredBase.pathPainter(strokeWidth, color: borderColor),
      WiredBase.fillPainter(fillColor),
    );
  }
}

/// Base wired inverted triangle painter.
class WiredInvertedTriangleBase extends WiredPainterBase {
  final Color borderColor;
  final double strokeWidth;

  WiredInvertedTriangleBase({
    this.borderColor = _defaultBorderColor,
    this.strokeWidth = 2.4,
  });

  @override
  void paintRough(
    Canvas canvas,
    Size size,
    DrawConfig drawConfig,
    Filler filler,
  ) {
    final Generator generator = Generator(drawConfig, filler);
    final rect = _inkRect(size, strokeWidth, drawConfig);
    final points = [
      PointD(rect.left, rect.top),
      PointD(rect.right, rect.top),
      PointD(rect.center.dx, rect.bottom),
    ];
    final Drawable figure = generator.polygon(points);
    canvas.drawRough(
      figure,
      WiredBase.pathPainter(strokeWidth, color: borderColor),
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
  final Color borderColor;
  final double strokeWidth;

  WiredLineBase({
    required this.x1,
    required this.y1,
    required this.x2,
    required this.y2,
    this.borderColor = _defaultBorderColor,
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
    final rect = _inkRect(size, strokeWidth, drawConfig);
    final Drawable figure = generator.line(
      lx1.clamp(rect.left, rect.right),
      ly1.clamp(rect.top, rect.bottom),
      lx2.clamp(rect.left, rect.right),
      ly2.clamp(rect.top, rect.bottom),
    );
    canvas.drawRough(
      figure,
      WiredBase.pathPainter(strokeWidth, color: borderColor),
      WiredBase.fillPainter(borderColor),
    );
  }
}

/// Base wired rounded rectangle painter.
class WiredRoundedRectangleBase extends WiredPainterBase {
  final BorderRadius borderRadius;
  final Color fillColor;
  final Color borderColor;
  final double strokeWidth;

  WiredRoundedRectangleBase({
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
    this.fillColor = _defaultFillColor,
    this.borderColor = _defaultBorderColor,
    this.strokeWidth = 2.4,
  });

  @override
  void paintRough(
    Canvas canvas,
    Size size,
    DrawConfig drawConfig,
    Filler filler,
  ) {
    final Generator generator = Generator(drawConfig, filler);
    final rect = _inkRect(size, strokeWidth, drawConfig);
    final Drawable figure = generator.roundedRectangle(
      rect.left,
      rect.top,
      rect.width,
      rect.height,
      borderRadius.topLeft.x,
      borderRadius.topRight.x,
      borderRadius.bottomRight.x,
      borderRadius.bottomLeft.x,
    );
    canvas.drawRough(
      figure,
      WiredBase.pathPainter(strokeWidth, color: borderColor),
      WiredBase.fillPainter(fillColor),
    );
  }
}

/// Base wired circle painter.
class WiredCircleBase extends WiredPainterBase {
  final double diameterRatio;
  final Color fillColor;
  final Color borderColor;
  final double strokeWidth;

  WiredCircleBase({
    this.diameterRatio = 1,
    this.fillColor = _defaultFillColor,
    this.borderColor = _defaultBorderColor,
    this.strokeWidth = 2.4,
  });

  @override
  void paintRough(
    Canvas canvas,
    Size size,
    DrawConfig drawConfig,
    Filler filler,
  ) {
    // A thumb needs a paper centre: full card-sized jitter consumes most of a
    // 24px circle. Scale both the wobble and its inset with the available size.
    final config = drawConfig.copyWith(
      roughness: drawConfig.roughness! * math.min(1, size.shortestSide / 48),
    );
    final Generator generator = Generator(config, filler);
    final rect = _inkRect(size, strokeWidth, config);
    final Drawable figure = generator.circle(
      size.width / 2,
      size.height / 2,
      rect.shortestSide * diameterRatio,
    );
    canvas.drawRough(
      figure,
      WiredBase.pathPainter(strokeWidth, color: borderColor),
      WiredBase.fillPainter(fillColor),
    );
  }
}

// Keep both pen passes inside a clipped parent, including at fractional DPR.
Rect _inkRect(Size size, double strokeWidth, DrawConfig config) {
  final bleed =
      strokeWidth / 2 +
      1 +
      (config.maxRandomnessOffset ?? 0) * (config.roughness ?? 0);
  return (Offset.zero & size).deflate(math.min(bleed, size.shortestSide / 2));
}
