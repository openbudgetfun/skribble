import 'dart:math';

import 'core.dart';
import 'entities.dart';

/// Rotates a list of [points] around [center] by [degrees].
List<PointD> rotatePoints(List<PointD>? points, PointD center, double degrees) {
  if (points != null && points.isNotEmpty) {
    return points.map((p) => rotatePoint(p, center, degrees)).toList();
  } else {
    return [];
  }
}

/// Rotates a single [point] around [center] by [degrees].
PointD rotatePoint(PointD point, PointD center, double degrees) {
  final double angle = (pi / 180) * degrees;
  final double angleCos = cos(angle);
  final double angleSin = sin(angle);

  return PointD(
    ((point.x - center.x) * angleCos) -
        ((point.y - center.y) * angleSin) +
        center.x,
    ((point.x - center.x) * angleSin) +
        ((point.y - center.y) * angleCos) +
        center.y,
  );
}

/// Rotates a list of [lines] around [center] by [degrees].
List<Line> rotateLines(List<Line> lines, PointD center, double degrees) => lines
    .map(
      (line) => Line(
        rotatePoint(line.source, center, degrees),
        rotatePoint(line.target, center, degrees),
      ),
    )
    .toList();

/// The orientation of three ordered points — used for intersection tests.
enum PointsOrientation {
  /// The three points lie on one line.
  collinear,

  /// The points turn clockwise.
  clockwise,

  /// The points turn counterclockwise.
  counterclockwise,
}

/// Returns the orientation of the ordered triplet (p, q, r).
PointsOrientation getOrientation(PointD p, PointD q, PointD r) {
  final double val = (q.x - p.x) * (r.y - q.y) - (q.y - p.y) * (r.x - q.x);

  if (val == 0) {
    return PointsOrientation.collinear;
  }

  return val > 0
      ? PointsOrientation.clockwise
      : PointsOrientation.counterclockwise;
}

/// Returns whether [point] lies on the segment from [source] to [target].
bool onSegmentPoints(PointD source, PointD point, PointD target) =>
    Line(source, target).onSegment(point);

/// Pre-computed points along an ellipse path, split into core and
/// all (interpolated) points for rendering.
class ComputedEllipsePoints {
  /// The points on the ellipse itself.
  final List<PointD> corePoints;

  /// [corePoints] plus the extra points that close and overlap the curve.
  final List<PointD> allPoints;

  /// Creates a set of computed ellipse points.
  ComputedEllipsePoints({required this.corePoints, required this.allPoints});
}

/// Parameters for ellipse generation — radii and angular increment.
class EllipseParams {
  /// The horizontal radius, after rough jitter.
  final double rx;

  /// The vertical radius, after rough jitter.
  final double ry;

  /// The angle between neighbouring points on the ellipse, in radians.
  final double increment;

  /// Creates ellipse parameters with radii [rx] and [ry].
  EllipseParams({required this.rx, required this.ry, required this.increment});
}

/// The result of generating an ellipse — the `OpSet` for rendering
/// and estimated boundary points.
class EllipseResult {
  /// The operations that draw the ellipse outline.
  final OpSet opSet;

  /// Points around the ellipse, for filling it.
  final List<PointD> estimatedPoints;

  /// Creates an ellipse result.
  EllipseResult({required this.opSet, required this.estimatedPoints});
}

/// A polygon edge used in scan-line fill algorithms, tracking
/// y-range, x-intercept, and slope.
class Edge {
  /// The smaller y of the edge's two end points.
  final double yMin;

  /// The larger y of the edge's two end points.
  final double yMax;

  /// The edge's x at the current scanline; at [yMin] when first built.
  final double x;

  /// How far x moves for each unit of y along the edge.
  final double slope;

  /// Creates an edge spanning [yMin] to [yMax].
  Edge({
    required this.yMin,
    required this.yMax,
    required this.x,
    required this.slope,
  });

  /// Returns a copy with the given values replaced.
  Edge copyWith({double? yMin, double? yMax, double? x, double? slope}) => Edge(
    yMin: yMin ?? this.yMin,
    yMax: yMax ?? this.yMax,
    x: x ?? this.x,
    slope: slope ?? this.slope,
  );

  @override
  String toString() {
    return 'Edge{yMin: $yMin, yMax: $yMax, x: $x, slope: $slope}';
  }
}

/// An active edge in the scan-line fill algorithm, crossing the
/// scanline [s].
class ActiveEdge {
  /// The y of the scanline where the edge became active.
  double s;

  /// The edge, with [Edge.x] at the current scanline.
  Edge edge;

  /// Creates an active edge that joined at scanline [s].
  ActiveEdge(this.s, this.edge);
}
