import 'dart:math';

import 'config.dart';
import 'core.dart';
import 'entities.dart';
import 'filler.dart';
import 'geometry.dart';
import 'renderer.dart';

/// The main entry point for generating rough/sketchy `Drawable` shapes.
///
/// Combines a `DrawConfig` and `Filler` to produce rectangles, circles,
/// arcs, lines, and polygons with hand-drawn imperfections.
class Generator {
  final DrawConfig? drawConfig;
  final Filler? filler;

  Generator(this.drawConfig, this.filler)
    : assert(drawConfig != null),
      assert(filler != null);

  Drawable _buildDrawable(OpSet drawSets, [List<PointD>? fillPoints]) {
    final List<OpSet> sets = [];
    if (fillPoints != null) {
      sets.add(filler!.fill(fillPoints));
    }
    sets.add(drawSets);
    return Drawable(sets: sets, options: drawConfig);
  }

  Drawable line(double x1, double y1, double x2, double y2) {
    return _buildDrawable(OpSetBuilder.buildLine(x1, y1, x2, y2, drawConfig!));
  }

  Drawable rectangle(double x, double y, double width, double height) {
    final List<PointD> points = [
      PointD(x, y),
      PointD(x + width, y),
      PointD(x + width, y + height),
      PointD(x, y + height),
    ];
    final OpSet outline = OpSetBuilder.buildPolygon(points, drawConfig!);
    return _buildDrawable(outline, points);
  }

  Drawable ellipse(double x, double y, double width, double height) {
    final EllipseParams ellipseParams = generateEllipseParams(
      width,
      height,
      drawConfig!,
    );
    final OpSet ellipseOp = ellipseSet(x, y, drawConfig!, ellipseParams);
    final List<PointD> estimatedPoints = computeEllipseAllPoints(
      increment: ellipseParams.increment!,
      cx: x,
      cy: y,
      rx: ellipseParams.rx!,
      ry: ellipseParams.ry!,
      offset: 0,
      overlap: 0,
      config: drawConfig!,
    );
    return _buildDrawable(ellipseOp, estimatedPoints);
  }

  Drawable circle(double x, double y, double diameter) {
    return ellipse(x, y, diameter, diameter);
  }

  Drawable linearPath(List<PointD> points) {
    return _buildDrawable(OpSetBuilder.linearPath(points, true, drawConfig!));
  }

  Drawable polygon(List<PointD> points) {
    final OpSet path = OpSetBuilder.linearPath(points, true, drawConfig!);
    return _buildDrawable(path, points);
  }

  Drawable arc(
    double x,
    double y,
    double width,
    double height,
    double start,
    double stop, [
    bool closed = false,
  ]) {
    final OpSet outline = OpSetBuilder.arc(
      PointD(x, y),
      width,
      height,
      start,
      stop,
      closed,
      true,
      drawConfig!,
    );
    final List<PointD> fillPoints = OpSetBuilder.arcPolygon(
      PointD(x, y),
      width,
      height,
      start,
      stop,
      drawConfig!,
    );
    return _buildDrawable(outline, fillPoints);
  }

  Drawable curvePath(List<PointD> points) {
    return _buildDrawable(OpSetBuilder.curve(points, drawConfig!));
  }

  Drawable roundedRectangle(
    double x,
    double y,
    double width,
    double height,
    double topLeft,
    double topRight,
    double bottomRight,
    double bottomLeft,
  ) {
    // Clamp radii to half of the smallest side
    final maxRadiusH = width / 2;
    final maxRadiusV = height / 2;
    final tl = topLeft.clamp(0, min(maxRadiusH, maxRadiusV)).toDouble();
    final tr = topRight.clamp(0, min(maxRadiusH, maxRadiusV)).toDouble();
    final br = bottomRight.clamp(0, min(maxRadiusH, maxRadiusV)).toDouble();
    final bl = bottomLeft.clamp(0, min(maxRadiusH, maxRadiusV)).toDouble();

    // Each pen pass follows one closed contour. Separate rough corner arcs
    // overlap at small radii and leave knots where they meet the straight edges.
    final List<Op> ops = [];
    final config = drawConfig!;
    final offset = min(config.maxRandomnessOffset!, min(width, height) / 16);
    const kappa = 0.5522847498307936;

    for (var pass = 0; pass < 2; pass++) {
      final gain = pass == 0 ? 0.45 : 0.7;
      final dx = config.offsetSymmetric(offset, gain);
      final dy = config.offsetSymmetric(offset, gain);
      final left = x + dx;
      final top = y + dy;
      final right = x + width + dx;
      final bottom = y + height + dy;
      var cursor = PointD(left + tl, top);
      ops.add(Op.move(cursor));

      void curve(PointD first, PointD second, PointD end) {
        ops.add(Op.curveTo(first, second, end));
        cursor = end;
      }

      void edge(PointD end) {
        final start = cursor;
        final dx = end.x - start.x;
        final dy = end.y - start.y;
        final length = sqrt(dx * dx + dy * dy);
        if (length == 0) return;

        // Bow a continuous stroke gently; longer edges can wander locally.
        // Endpoint handles stay tangent to the rounded corners.
        final bow = config.offsetSymmetric(
          min(offset, length / 12),
          config.bowing! * gain,
        );
        final drift = config.offsetSymmetric(
          min(offset, length / 12),
          config.lineWobble! * gain,
        );
        final normalX = -dy / length;
        final normalY = dx / length;
        final middle = PointD(
          start.x + dx / 2 + normalX * bow,
          start.y + dy / 2 + normalY * bow,
        );
        curve(
          PointD(start.x + dx / 6, start.y + dy / 6),
          PointD(
            middle.x - dx / 6 + normalX * drift,
            middle.y - dy / 6 + normalY * drift,
          ),
          middle,
        );
        curve(
          PointD(
            middle.x + dx / 6 - normalX * drift,
            middle.y + dy / 6 - normalY * drift,
          ),
          PointD(end.x - dx / 6, end.y - dy / 6),
          end,
        );
      }

      edge(PointD(right - tr, top));
      curve(
        PointD(right - tr + tr * kappa, top),
        PointD(right, top + tr - tr * kappa),
        PointD(right, top + tr),
      );
      edge(PointD(right, bottom - br));
      curve(
        PointD(right, bottom - br + br * kappa),
        PointD(right - br + br * kappa, bottom),
        PointD(right - br, bottom),
      );
      edge(PointD(left + bl, bottom));
      curve(
        PointD(left + bl - bl * kappa, bottom),
        PointD(left, bottom - bl + bl * kappa),
        PointD(left, bottom - bl),
      );
      edge(PointD(left, top + tl));
      curve(
        PointD(left, top + tl - tl * kappa),
        PointD(left + tl - tl * kappa, top),
        PointD(left + tl, top),
      );
    }

    final outline = OpSet(type: OpSetType.path, ops: ops);

    // Build fill polygon by sampling points along the rounded perimeter
    final fillPoints = _roundedRectFillPoints(
      x,
      y,
      width,
      height,
      tl,
      tr,
      br,
      bl,
    );
    return _buildDrawable(outline, fillPoints);
  }

  List<PointD> _roundedRectFillPoints(
    double x,
    double y,
    double w,
    double h,
    double tl,
    double tr,
    double br,
    double bl,
  ) {
    final points = <PointD>[];
    const steps = 8;

    // Top-left corner
    for (int i = 0; i <= steps; i++) {
      final angle = pi + (pi / 2) * (i / steps);
      points.add(PointD(x + tl + tl * cos(angle), y + tl + tl * sin(angle)));
    }

    // Top-right corner
    for (int i = 0; i <= steps; i++) {
      final angle = -pi / 2 + (pi / 2) * (i / steps);
      points.add(
        PointD(x + w - tr + tr * cos(angle), y + tr + tr * sin(angle)),
      );
    }

    // Bottom-right corner
    for (int i = 0; i <= steps; i++) {
      final angle = (pi / 2) * (i / steps);
      points.add(
        PointD(x + w - br + br * cos(angle), y + h - br + br * sin(angle)),
      );
    }

    // Bottom-left corner
    for (int i = 0; i <= steps; i++) {
      final angle = pi / 2 + (pi / 2) * (i / steps);
      points.add(
        PointD(x + bl + bl * cos(angle), y + h - bl + bl * sin(angle)),
      );
    }

    return points;
  }
}
