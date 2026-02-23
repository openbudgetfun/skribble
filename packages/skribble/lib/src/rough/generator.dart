import 'dart:math';

import 'config.dart';
import 'core.dart';
import 'entities.dart';
import 'filler.dart';
import 'geometry.dart';
import 'renderer.dart';

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

    // Build outline: 4 lines + 4 corner arcs
    final List<Op> ops = [];

    // Top side: from (x + tl, y) to (x + width - tr, y)
    if (width - tl - tr > 0) {
      ops.addAll(
        OpsGenerator.doubleLine(x + tl, y, x + width - tr, y, drawConfig!),
      );
    }

    // Top-right corner arc
    if (tr > 0) {
      final arcOps = OpSetBuilder.arc(
        PointD(x + width - tr, y + tr),
        tr * 2,
        tr * 2,
        -pi / 2,
        0,
        false,
        false,
        drawConfig!,
      );
      ops.addAll(arcOps.ops!);
    }

    // Right side: from (x + width, y + tr) to (x + width, y + height - br)
    if (height - tr - br > 0) {
      ops.addAll(
        OpsGenerator.doubleLine(
          x + width,
          y + tr,
          x + width,
          y + height - br,
          drawConfig!,
        ),
      );
    }

    // Bottom-right corner arc
    if (br > 0) {
      final arcOps = OpSetBuilder.arc(
        PointD(x + width - br, y + height - br),
        br * 2,
        br * 2,
        0,
        pi / 2,
        false,
        false,
        drawConfig!,
      );
      ops.addAll(arcOps.ops!);
    }

    // Bottom side: from (x + width - br, y + height) to (x + bl, y + height)
    if (width - br - bl > 0) {
      ops.addAll(
        OpsGenerator.doubleLine(
          x + width - br,
          y + height,
          x + bl,
          y + height,
          drawConfig!,
        ),
      );
    }

    // Bottom-left corner arc
    if (bl > 0) {
      final arcOps = OpSetBuilder.arc(
        PointD(x + bl, y + height - bl),
        bl * 2,
        bl * 2,
        pi / 2,
        pi,
        false,
        false,
        drawConfig!,
      );
      ops.addAll(arcOps.ops!);
    }

    // Left side: from (x, y + height - bl) to (x, y + tl)
    if (height - bl - tl > 0) {
      ops.addAll(
        OpsGenerator.doubleLine(
          x,
          y + height - bl,
          x,
          y + tl,
          drawConfig!,
        ),
      );
    }

    // Top-left corner arc
    if (tl > 0) {
      final arcOps = OpSetBuilder.arc(
        PointD(x + tl, y + tl),
        tl * 2,
        tl * 2,
        pi,
        3 * pi / 2,
        false,
        false,
        drawConfig!,
      );
      ops.addAll(arcOps.ops!);
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
        PointD(
          x + w - tr + tr * cos(angle),
          y + tr + tr * sin(angle),
        ),
      );
    }

    // Bottom-right corner
    for (int i = 0; i <= steps; i++) {
      final angle = (pi / 2) * (i / steps);
      points.add(
        PointD(
          x + w - br + br * cos(angle),
          y + h - br + br * sin(angle),
        ),
      );
    }

    // Bottom-left corner
    for (int i = 0; i <= steps; i++) {
      final angle = pi / 2 + (pi / 2) * (i / steps);
      points.add(
        PointD(
          x + bl + bl * cos(angle),
          y + h - bl + bl * sin(angle),
        ),
      );
    }

    return points;
  }
}
