import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import 'canvas/wired_painter_base.dart';
import 'rough/skribble_rough.dart';
import 'wired_paint.dart';

/// Base wired rectangle painter.
class WiredRectangleBase extends _PreparedWiredPainter {
  /// Inset applied to the left edge before drawing.
  final double leftIndent;

  /// Inset applied to the right edge before drawing.
  final double rightIndent;

  /// Interior fill color.
  final Color fillColor;

  /// Outline color.
  final Color borderColor;

  /// Outline pen width.
  final double strokeWidth;

  /// Creates a rectangle painter.
  WiredRectangleBase({
    this.leftIndent = 0.0,
    this.rightIndent = 0.0,
    this.fillColor = kWiredDefaultFillColor,
    this.borderColor = kWiredDefaultBorderColor,
    this.strokeWidth = 2.4,
  });

  @override
  RoughDrawing prepare(
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
    return RoughDrawing(
      figure,
      WiredBase.pathPainter(strokeWidth, color: borderColor),
      WiredBase.fillPainter(fillColor),
    );
  }
}

/// Base wired inverted triangle painter.
class WiredInvertedTriangleBase extends _PreparedWiredPainter {
  /// Outline color.
  final Color borderColor;

  /// Outline pen width.
  final double strokeWidth;

  /// Creates an inverted triangle painter.
  WiredInvertedTriangleBase({
    this.borderColor = kWiredDefaultBorderColor,
    this.strokeWidth = 2.4,
  });

  @override
  RoughDrawing prepare(
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
    return RoughDrawing(
      figure,
      WiredBase.pathPainter(strokeWidth, color: borderColor),
      WiredBase.fillPainter(borderColor),
    );
  }
}

/// Base wired line painter.
class WiredLineBase extends _PreparedWiredPainter {
  /// Start x coordinate in local space.
  final double x1;

  /// Start y coordinate in local space.
  final double y1;

  /// End x coordinate in local space.
  final double x2;

  /// End y coordinate in local space.
  final double y2;

  /// Line color.
  final Color borderColor;

  /// Line pen width.
  final double strokeWidth;

  /// Creates a line painter from two local-space points.
  WiredLineBase({
    required this.x1,
    required this.y1,
    required this.x2,
    required this.y2,
    this.borderColor = kWiredDefaultBorderColor,
    this.strokeWidth = 1,
  });

  @override
  RoughDrawing prepare(
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
    return RoughDrawing(
      figure,
      WiredBase.pathPainter(strokeWidth, color: borderColor),
      WiredBase.fillPainter(borderColor),
    );
  }
}

/// Base wired rounded rectangle painter.
class WiredRoundedRectangleBase extends _PreparedWiredPainter {
  /// Corner radii.
  final BorderRadius borderRadius;

  /// Interior fill color.
  final Color fillColor;

  /// Outline color.
  final Color borderColor;

  /// Outline pen width.
  final double strokeWidth;

  /// Creates a rounded rectangle painter.
  WiredRoundedRectangleBase({
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
    this.fillColor = kWiredDefaultFillColor,
    this.borderColor = kWiredDefaultBorderColor,
    this.strokeWidth = 2.4,
  });

  @override
  RoughDrawing prepare(
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
    return RoughDrawing(
      figure,
      WiredBase.pathPainter(strokeWidth, color: borderColor),
      WiredBase.fillPainter(fillColor),
    );
  }
}

/// Base wired circle painter.
class WiredCircleBase extends _PreparedWiredPainter {
  /// Diameter as a fraction of the available short side.
  final double diameterRatio;

  /// Interior fill color.
  final Color fillColor;

  /// Outline color.
  final Color borderColor;

  /// Outline pen width.
  final double strokeWidth;

  /// Creates a circle painter.
  WiredCircleBase({
    this.diameterRatio = 1,
    this.fillColor = kWiredDefaultFillColor,
    this.borderColor = kWiredDefaultBorderColor,
    this.strokeWidth = 2.4,
  });

  @override
  RoughDrawing prepare(
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
    return RoughDrawing(
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

// Preserve the imperative public painter protocol for existing consumers.
abstract class _PreparedWiredPainter extends WiredPainterBase {
  @override
  RoughDrawing prepare(Size size, DrawConfig drawConfig, Filler filler);

  @override
  void paintRough(
    Canvas canvas,
    Size size,
    DrawConfig drawConfig,
    Filler filler,
  ) {
    prepare(size, drawConfig, filler).paint(canvas);
  }
}
