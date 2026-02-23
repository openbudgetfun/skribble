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
}
