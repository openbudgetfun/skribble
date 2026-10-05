import 'dart:math' as math;
import 'dart:ui';

import '../rough/skribble_rough.dart';

/// One contour of a path after [waverPath]: a polyline, open or closed.
final class WaveredContour {
  /// Creates a contour from its points.
  const WaveredContour(this.points, {required this.closed});

  /// The displaced points, about a logical pixel apart.
  final List<Offset> points;

  /// Whether the source contour was closed.
  final bool closed;

  /// The contour as rough engine operations, ready for an `InkStroke`.
  List<Op> toOps() => [
    Op.move(PointD(points.first.dx, points.first.dy)),
    for (final point in points.skip(1)) Op.lineTo(PointD(point.dx, point.dy)),
    if (closed) Op.lineTo(PointD(points.first.dx, points.first.dy)),
  ];
}

/// Redraws [path] as if by hand, keeping its shape readable.
///
/// Every contour is sampled about once per logical pixel and displaced by one
/// smooth field, so both sides of a stroke move together and narrow counters
/// stay open; independent jitter on tiny segments would look like raster
/// fuzz instead. The field's linear trend is removed across [bounds]
/// (defaulting to the path's own), sampled corners and the ends of open
/// contours stay put, and gentle opposing bends between corners keep short
/// straight edges visibly drawn without making the shape lean.
///
/// Amplitude is `roughness × maxRandomnessOffset × amplitude` from [config];
/// [config]'s seed sets the phase. Fill the contours with
/// [waveredPolygons], or ink them with `InkStroke(contour.toOps(), ...)`.
List<WaveredContour> waverPath(
  Path path,
  DrawConfig config, {
  Rect? bounds,
  double amplitude = 0.12,
}) {
  final contours = <WaveredContour>[];
  final strength = config.roughness * config.maxRandomnessOffset * amplitude;
  final phase = config.seed * 0.61803398875;
  final area = bounds ?? path.getBounds();
  // Keep enlarged shapes from accumulating extra ripples along every edge.
  final wavelengthScale = math.max(1.0, area.longestSide / 24);

  // Remove the field's linear trend across the area. Endpoints on opposite
  // sides receive no relative shift, keeping upright strokes upright.
  double wavering(
    double position,
    double start,
    double extent,
    double wavelength,
    double phase,
  ) {
    if (extent == 0) return 0;
    final t = (position - start) / extent;
    final first = math.sin(start / wavelength + phase);
    final last = math.sin((start + extent) / wavelength + phase);
    return math.sin(position / wavelength + phase) -
        (first + (last - first) * t);
  }

  Offset displacement(Offset point) => strength == 0
      ? Offset.zero
      : Offset(
          strength *
              wavering(
                point.dy,
                area.top,
                area.height,
                5.5 * wavelengthScale,
                phase,
              ),
          strength *
              wavering(
                point.dx,
                area.left,
                area.width,
                7 * wavelengthScale,
                phase + 1.7,
              ),
        );

  for (final metric in path.computeMetrics()) {
    final points = _sample(metric);
    if (points.length < 2) continue;
    final offsets = points.map(displacement).toList(growable: false);
    // Anchor corners as well as the ends of open strokes. Removing only the
    // whole shape's trend can still lean interior stems, such as a door.
    final anchors = [
      0,
      for (var i = 1; i < points.length - 1; i++)
        if (_isCorner(points[i - 1], points[i], points[i + 1])) i,
      points.length - 1,
    ];
    final anchorCorners = !metric.isClosed || anchors.length > 2;
    var segment = 0;
    final result = <Offset>[];
    for (var i = 0; i < points.length; i++) {
      var offset = offsets[i];
      if (anchorCorners) {
        while (segment < anchors.length - 2 && i > anchors[segment + 1]) {
          segment++;
        }
        final first = anchors[segment];
        final last = anchors[segment + 1];
        final t = (i - first) / (last - first);
        offset -= Offset.lerp(offsets[first], offsets[last], t)!;
        final chord = points[last] - points[first];
        final length = chord.distance;
        if (length > 0) {
          // Opposing bends keep short straight edges visibly hand-drawn
          // without moving their corners or choosing a consistent lean.
          final bend =
              strength *
              0.2 *
              math.min(1, length / 8) *
              math.sin(t * math.pi * 2);
          offset += Offset(-chord.dy, chord.dx) * (bend / length);
        }
      }
      // Open contours keep their exact ends so strokes land where the
      // source put them.
      if (!metric.isClosed && (i == 0 || i == points.length - 1)) {
        offset = Offset.zero;
      }
      result.add(points[i] + offset);
    }
    contours.add(WaveredContour(result, closed: metric.isClosed));
  }
  return contours;
}

/// The wavered [contours] as one fillable path with [fillType].
Path waveredPolygons(
  Iterable<WaveredContour> contours, {
  PathFillType fillType = PathFillType.nonZero,
}) {
  final path = Path()..fillType = fillType;
  for (final contour in contours) {
    path.addPolygon(contour.points, contour.closed);
  }
  return path;
}

bool _isCorner(Offset before, Offset point, Offset after) {
  final incoming = point - before;
  final outgoing = after - point;
  final length = incoming.distance * outgoing.distance;
  return length > 0 &&
      (incoming.dx * outgoing.dx + incoming.dy * outgoing.dy) / length < 0.9;
}

/// Samples [metric] about every 1.2 logical pixels.
List<Offset> _sample(PathMetric metric) {
  final length = metric.length;
  if (length == 0) {
    final tangent = metric.getTangentForOffset(0);
    return tangent == null ? const [] : [tangent.position, tangent.position];
  }
  final count = math.max(2, (length / 1.2).ceil());
  final points = <Offset>[];
  for (var index = 0; index <= count; index++) {
    final tangent = metric.getTangentForOffset(length * index / count);
    if (tangent == null) continue;
    final position = tangent.position;
    if (points.isEmpty || (points.last - position).distance > 0.15) {
      points.add(position);
    }
  }
  if (metric.isClosed && points.length > 1) {
    if ((points.first - points.last).distance < 0.15) points.removeLast();
  }
  return points;
}
