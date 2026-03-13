import 'dart:math';

import 'core.dart';
import 'entities.dart';

List<PointD> rotatePoints(List<PointD>? points, PointD center, double degrees) {
  if (points != null && points.isNotEmpty) {
    return points.map((p) => rotatePoint(p, center, degrees)).toList();
  } else {
    return [];
  }
}

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

List<Line> rotateLines(List<Line> lines, PointD center, double degrees) => lines
    .map(
      (line) => Line(
        rotatePoint(line.source, center, degrees),
        rotatePoint(line.target, center, degrees),
      ),
    )
    .toList();

enum PointsOrientation { collinear, clockwise, counterclockwise }

PointsOrientation getOrientation(PointD p, PointD q, PointD r) {
  final double val = (q.x - p.x) * (r.y - q.y) - (q.y - p.y) * (r.x - q.x);
  if (val == 0) {
    return PointsOrientation.collinear;
  }
  return val > 0
      ? PointsOrientation.clockwise
      : PointsOrientation.counterclockwise;
}

bool onSegmentPoints(PointD source, PointD point, PointD target) =>
    Line(source, target).onSegment(point);

/// Pre-computed points along an ellipse path, split into core and
/// all (interpolated) points for rendering.
class ComputedEllipsePoints {
  List<PointD>? corePoints;
  List<PointD>? allPoints;

  ComputedEllipsePoints({this.corePoints, this.allPoints});
}

/// Parameters for ellipse generation — radii and angular increment.
class EllipseParams {
  final double? rx;
  final double? ry;
  final double? increment;

  EllipseParams({this.rx, this.ry, this.increment});
}

/// The result of generating an ellipse — the `OpSet` for rendering
/// and estimated boundary points.
class EllipseResult {
  OpSet? opSet;
  List<PointD>? estimatedPoints;

  EllipseResult({this.opSet, this.estimatedPoints});
}

/// A polygon edge used in scan-line fill algorithms, tracking
/// y-range, x-intercept, and slope.
class Edge {
  double? yMin;
  double? yMax;
  double? x;
  double? slope;

  Edge({this.yMin, this.yMax, this.x, this.slope});

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

/// An active edge in the scan-line fill algorithm with its current
/// x-intercept position [s].
class ActiveEdge {
  double s;
  Edge edge;

  ActiveEdge(this.s, this.edge);
}
