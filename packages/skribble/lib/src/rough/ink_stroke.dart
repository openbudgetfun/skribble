import 'dart:math' as math;
import 'dart:typed_data';

import 'core.dart';
import 'entities.dart';
import 'pen.dart';

/// Receives the outline of an [InkStroke].
///
/// One outline builder serves every destination: a Flutter `Path` while
/// painting, SVG path data for design exports, or anything else that speaks
/// moves, lines, and quadratic curves.
abstract interface class InkOutlineSink {
  /// Starts a new closed shape at ([x], [y]).
  void moveTo(double x, double y);

  /// Continues the shape with a straight segment.
  void lineTo(double x, double y);

  /// Continues the shape with a quadratic Bézier segment.
  void quadraticTo(double cx, double cy, double x, double y);

  /// Closes the current shape.
  void close();
}

/// Writes an [InkStroke] outline as SVG path data.
final class SvgInkOutline implements InkOutlineSink {
  final StringBuffer _data = StringBuffer();

  static String _number(double value) {
    final fixed = value.toStringAsFixed(3);
    final trimmed = fixed.contains('.')
        ? fixed.replaceFirst(RegExp(r'\.?0+$'), '')
        : fixed;
    return trimmed == '-0' ? '0' : trimmed;
  }

  @override
  void moveTo(double x, double y) =>
      _data.write('M${_number(x)} ${_number(y)}');

  @override
  void lineTo(double x, double y) =>
      _data.write('L${_number(x)} ${_number(y)}');

  @override
  void quadraticTo(double cx, double cy, double x, double y) => _data.write(
    'Q${_number(cx)} ${_number(cy)} ${_number(x)} ${_number(y)}',
  );

  @override
  void close() => _data.write('Z');

  /// The accumulated path data.
  @override
  String toString() => _data.toString();
}

/// One pen stroke along rough centreline geometry, sampled once.
///
/// The rough engine's operations are flattened and resampled at a spacing
/// tied to the pen width, then each sample gets a width from the [RoughPen].
/// [writeOutline] turns the samples into a filled shape, either completely or
/// up to a distance for draw-on animation, without sampling again.
///
/// Pure Dart: usable by command-line exporters as well as painters.
final class InkStroke {
  /// Samples every contour in [ops] as ink [width] wide.
  ///
  /// Each move operation starts a contour. [seed] chooses where closed loops
  /// start and the phase of the pressure swells, so the same inputs always
  /// produce the same ink. A [weight] other than one scales this stroke
  /// relative to [width], and a [coverage] below one inks only a seeded
  /// stretch of each contour. Repeat passes use both to become lighter and
  /// partial.
  factory InkStroke(
    List<Op> ops, {
    required double width,
    required RoughPen pen,
    int seed = 1,
    double weight = 1,
    double coverage = 1,
  }) {
    final random = math.Random(seed);
    final contours = <_InkContour>[];
    for (final polyline in _flatten(ops)) {
      final contour = _InkContour.sample(
        polyline,
        width * weight,
        pen,
        random,
        coverage.clamp(0.05, 1.0),
      );
      if (contour != null) contours.add(contour);
    }
    return InkStroke._(contours);
  }

  InkStroke._(this._contours);

  final List<_InkContour> _contours;

  /// Total distance the pen travels, including loop closures.
  late final double length = _contours.fold(
    0,
    (sum, contour) => sum + contour.length,
  );

  /// The outline of the whole stroke as SVG path data, to be filled.
  late final String svgPathData = () {
    final sink = SvgInkOutline();
    writeOutline(sink);
    return sink.toString();
  }();

  /// Writes the filled outline of the first [distance] the pen travels.
  ///
  /// Omit [distance] for the whole stroke. A cut end is round and keeps the
  /// width it had at that point, like a pen that is still on the paper.
  void writeOutline(InkOutlineSink sink, {double distance = double.infinity}) {
    var remaining = distance;
    for (final contour in _contours) {
      if (remaining <= 0) break;
      contour.write(sink, remaining);
      remaining -= contour.length;
    }
  }
}

/// A flattened contour: points with cumulative distances.
final class _Polyline {
  _Polyline(this.xs, this.ys, this.distances);

  final List<double> xs;
  final List<double> ys;
  final List<double> distances;

  double get length => distances.last;

  bool get isEmpty => xs.length < 2 || length == 0;

  /// The point [distance] along the polyline.
  (double, double) at(double distance) {
    final d = distance.clamp(0.0, length);
    var low = 0;
    var high = distances.length - 1;
    while (high - low > 1) {
      final mid = (low + high) >> 1;
      if (distances[mid] <= d) {
        low = mid;
      } else {
        high = mid;
      }
    }
    final span = distances[high] - distances[low];
    final t = span == 0 ? 0.0 : (d - distances[low]) / span;
    return (
      xs[low] + (xs[high] - xs[low]) * t,
      ys[low] + (ys[high] - ys[low]) * t,
    );
  }
}

/// Walks a polyline forward, restarting when the distance wraps around.
final class _PolylineWalker {
  _PolylineWalker(this.polyline);

  final _Polyline polyline;
  int _segment = 0;
  double x = 0;
  double y = 0;

  void moveTo(double distance) {
    final distances = polyline.distances;
    final last = distances.length - 1;
    final d = distance.clamp(0.0, polyline.length);
    if (d < distances[_segment]) _segment = 0;
    while (_segment < last - 1 && distances[_segment + 1] < d) {
      _segment++;
    }
    final from = distances[_segment];
    final span = distances[_segment + 1] - from;
    final t = span == 0 ? 0.0 : (d - from) / span;
    final xs = polyline.xs;
    final ys = polyline.ys;
    x = xs[_segment] + (xs[_segment + 1] - xs[_segment]) * t;
    y = ys[_segment] + (ys[_segment + 1] - ys[_segment]) * t;
  }
}

/// Splits [ops] into contours and flattens their curves into polylines.
List<_Polyline> _flatten(List<Op> ops) {
  final result = <_Polyline>[];
  List<double>? xs;
  List<double>? ys;
  List<double>? distances;

  void finish() {
    final px = xs;
    final py = ys;
    final pd = distances;
    if (px != null &&
        py != null &&
        pd != null &&
        px.length > 1 &&
        pd.last > 0) {
      result.add(_Polyline(px, py, pd));
    }
  }

  void add(double x, double y) {
    final px = xs!;
    final py = ys!;
    final pd = distances!;
    final step = _distance(px.last, py.last, x, y);
    if (step < 1e-6) return;
    px.add(x);
    py.add(y);
    pd.add(pd.last + step);
  }

  for (final op in ops) {
    final data = op.data;
    switch (op.op) {
      case OpType.move:
        finish();
        xs = [data[0].x];
        ys = [data[0].y];
        distances = [0];
      case OpType.lineTo:
        if (xs == null) {
          xs = [data[0].x];
          ys = [data[0].y];
          distances = [0];
        } else {
          add(data[0].x, data[0].y);
        }
      case OpType.curveTo:
        if (xs == null) {
          xs = [data[2].x];
          ys = [data[2].y];
          distances = [0];
          continue;
        }
        final x0 = xs.last;
        final y0 = ys!.last;
        final c1 = data[0];
        final c2 = data[1];
        final end = data[2];
        // The control polygon bounds the curve's length. A segment every two
        // logical pixels stays within a hair of the curve for the gentle bends
        // rough geometry makes, and resampling smooths the tangents.
        final hull =
            _distance(x0, y0, c1.x, c1.y) +
            _distance(c1.x, c1.y, c2.x, c2.y) +
            _distance(c2.x, c2.y, end.x, end.y);
        final segments = (hull / 2).ceil().clamp(2, 64);
        for (var i = 1; i <= segments; i++) {
          final t = i / segments;
          final u = 1 - t;
          final a = u * u * u;
          final b = 3 * u * u * t;
          final c = 3 * u * t * t;
          final d = t * t * t;
          add(
            a * x0 + b * c1.x + c * c2.x + d * end.x,
            a * y0 + b * c1.y + c * c2.y + d * end.y,
          );
        }
    }
  }
  finish();
  return result;
}

double _distance(double x0, double y0, double x1, double y1) {
  final dx = x1 - x0;
  final dy = y1 - y0;
  return math.sqrt(dx * dx + dy * dy);
}

final class _InkContour {
  _InkContour(this.xs, this.ys, this.nxs, this.nys, this.radii, this.distances);

  final Float64List xs;
  final Float64List ys;
  final Float64List nxs;
  final Float64List nys;
  final Float64List radii;
  final Float64List distances;

  double get length => distances.last;

  static _InkContour? sample(
    _Polyline polyline,
    double width,
    RoughPen pen,
    math.Random random,
    double coverage,
  ) {
    if (polyline.isEmpty || width <= 0) return null;
    final contourLength = polyline.length;
    final startToEnd = _distance(
      polyline.xs.first,
      polyline.ys.first,
      polyline.xs.last,
      polyline.ys.last,
    );

    // A loop whose ends meet keeps going a little past its start. Its start
    // moves to a seeded point so the seam is not always at the same corner.
    final closed = contourLength > width * 4 && startToEnd < width;
    final partial = coverage < 1;
    final drawn = partial
        ? contourLength * coverage * (0.75 + 0.25 * random.nextDouble())
        : contourLength;
    final from = closed
        ? random.nextDouble() * contourLength
        : partial
        ? random.nextDouble() * (contourLength - drawn)
        : 0.0;
    final closing = closed && !partial ? math.max(0, pen.closure) * width : 0.0;
    final total = drawn + closing;
    // The closing tail curls inward, and less on small loops, so it never
    // reaches past the outline painters reserve room for.
    final drift = closing > 0
        ? pen.closureDrift.abs() *
              width *
              math.min(1, contourLength / (60 * width)) *
              _inwardSign(polyline, from)
        : 0.0;

    final step = (width * 0.8).clamp(0.4, 3.0);
    final count = math.max(1, (total / step).ceil());
    final taperIn = math.min(total * 0.3, math.max(0, pen.taperIn) * width);
    final taperOut = math.min(total * 0.4, math.max(0, pen.taperOut) * width);
    final startWidth = pen.startWidth.clamp(0.05, 1.0);
    final endWidth = pen.endWidth.clamp(0.05, 1.0);
    final pressure = pen.pressure.clamp(0.0, 1.0);
    final wavelength = math.max(1, pen.pressureWavelength);
    final phase1 = random.nextDouble() * math.pi * 2;
    final phase2 = random.nextDouble() * math.pi * 2;

    // Positions first, in one forward walk along the polyline.
    final xs = Float64List(count + 1);
    final ys = Float64List(count + 1);
    final distances = Float64List(count + 1);
    final walker = _PolylineWalker(polyline);
    for (var i = 0; i <= count; i++) {
      final travelled = total * i / count;
      var at = from + travelled;
      if (closed) at %= contourLength;
      walker.moveTo(at);
      xs[i] = walker.x;
      ys[i] = walker.y;
      distances[i] = travelled;
    }

    // Tangents from neighbouring samples smooth the flattening without
    // rounding off real corners. Widths come from the pen.
    final nxs = Float64List(count + 1);
    final nys = Float64List(count + 1);
    final radii = Float64List(count + 1);
    var tx = 1.0;
    var ty = 0.0;
    for (var i = 0; i <= count; i++) {
      final before = i == 0 ? 0 : i - 1;
      final after = i == count ? count : i + 1;
      final dx = xs[after] - xs[before];
      final dy = ys[after] - ys[before];
      final tangentLength = math.sqrt(dx * dx + dy * dy);
      if (tangentLength > 1e-9) {
        tx = dx / tangentLength;
        ty = dy / tangentLength;
      }
      nxs[i] = -ty;
      nys[i] = tx;

      final travelled = distances[i];
      var factor = 1.0;
      if (taperIn > 0 && travelled < taperIn) {
        factor *= startWidth + (1 - startWidth) * _easeOut(travelled / taperIn);
      }
      final toEnd = total - travelled;
      if (taperOut > 0 && toEnd < taperOut) {
        factor *= endWidth + (1 - endWidth) * _easeOut(toEnd / taperOut);
      }
      if (pressure > 0) {
        final cycle = travelled / wavelength * math.pi * 2;
        factor *=
            1 +
            pressure *
                (0.65 * math.sin(cycle + phase1) +
                    0.35 * math.sin(cycle * 2.7 + phase2));
      }
      radii[i] = math.max(0.1, factor * width) / 2;
    }

    // The closing stretch eases off the line it is retracing.
    if (closing > 0) {
      for (var i = 0; i <= count; i++) {
        final travelled = distances[i];
        if (travelled <= drawn) continue;
        final off = drift * _easeOut((travelled - drawn) / closing);
        xs[i] += nxs[i] * off;
        ys[i] += nys[i] * off;
      }
    }
    return _InkContour(xs, ys, nxs, nys, radii, distances);
  }

  static double _easeOut(double t) => 1 - (1 - t) * (1 - t);

  /// +1 when the normal at [distance] points into the loop, otherwise -1.
  static double _inwardSign(_Polyline polyline, double distance) {
    var cx = 0.0;
    var cy = 0.0;
    for (var i = 0; i < polyline.xs.length; i++) {
      cx += polyline.xs[i];
      cy += polyline.ys[i];
    }
    cx /= polyline.xs.length;
    cy /= polyline.xs.length;
    final (x, y) = polyline.at(distance);
    final (ax, ay) = polyline.at(math.min(distance + 1, polyline.length));
    final (bx, by) = polyline.at(math.max(distance - 1, 0));
    final nx = -(ay - by);
    final ny = ax - bx;
    return nx * (cx - x) + ny * (cy - y) >= 0 ? 1 : -1;
  }

  /// Writes the outline of this contour, cut at [distance] when shorter.
  void write(InkOutlineSink sink, double distance) {
    var last = xs.length - 1;
    var cut = 1.0;
    if (distance < length) {
      last = 1;
      while (last < distances.length - 1 && distances[last] < distance) {
        last++;
      }
      final span = distances[last] - distances[last - 1];
      cut = span == 0 ? 1 : (distance - distances[last - 1]) / span;
    }

    double value(Float64List values, int i) => i == last
        ? values[i - 1] + (values[i] - values[i - 1]) * cut
        : values[i];

    final leftX = <double>[];
    final leftY = <double>[];
    final rightX = <double>[];
    final rightY = <double>[];
    var previousNx = nxs[0];
    var previousNy = nys[0];
    for (var i = 0; i <= last; i++) {
      final x = value(xs, i);
      final y = value(ys, i);
      final nx = value(nxs, i);
      final ny = value(nys, i);
      final r = value(radii, i);
      // A sharp turn between samples leaves a notch on its outer side. Sweep
      // that side around the corner so the joint stays round.
      final dot = previousNx * nx + previousNy * ny;
      if (i > 0 && dot < 0.82) {
        final angle = math.atan2(previousNx * ny - previousNy * nx, dot);
        final steps = (angle.abs() / 0.35).ceil();
        final outerX = angle > 0 ? rightX : leftX;
        final outerY = angle > 0 ? rightY : leftY;
        final sign = angle > 0 ? -1.0 : 1.0;
        final base = math.atan2(previousNy, previousNx);
        for (var s = 1; s < steps; s++) {
          final a = base + angle * s / steps;
          outerX.add(x + sign * math.cos(a) * r);
          outerY.add(y + sign * math.sin(a) * r);
        }
      }
      leftX.add(x + nx * r);
      leftY.add(y + ny * r);
      rightX.add(x - nx * r);
      rightY.add(y - ny * r);
      previousNx = nx;
      previousNy = ny;
    }

    sink.moveTo(leftX.first, leftY.first);
    _smooth(sink, leftX, leftY, reversed: false);
    _cap(
      sink,
      value(xs, last),
      value(ys, last),
      value(nxs, last),
      value(nys, last),
      value(radii, last),
      forward: true,
    );
    _smooth(sink, rightX, rightY, reversed: true);
    _cap(sink, xs[0], ys[0], nxs[0], nys[0], radii[0], forward: false);
    sink.close();
  }

  /// Draws through the midpoints of [xs]/[ys] with each point as a control,
  /// which keeps the edge smooth between samples.
  static void _smooth(
    InkOutlineSink sink,
    List<double> xs,
    List<double> ys, {
    required bool reversed,
  }) {
    final n = xs.length;
    int at(int i) => reversed ? n - 1 - i : i;
    sink.lineTo(xs[at(0)], ys[at(0)]);
    for (var i = 1; i < n - 1; i++) {
      final here = at(i);
      final next = at(i + 1);
      sink.quadraticTo(
        xs[here],
        ys[here],
        (xs[here] + xs[next]) / 2,
        (ys[here] + ys[next]) / 2,
      );
    }
    sink.lineTo(xs[at(n - 1)], ys[at(n - 1)]);
  }

  /// A half circle from one side of the stroke to the other, bulging along
  /// the direction of travel at the end and against it at the start.
  static void _cap(
    InkOutlineSink sink,
    double x,
    double y,
    double nx,
    double ny,
    double radius, {
    required bool forward,
  }) {
    final fx = forward ? nx : -nx;
    final fy = forward ? ny : -ny;
    final ax = forward ? ny : -ny;
    final ay = forward ? -nx : nx;
    const steps = 6;
    for (var i = 1; i <= steps; i++) {
      final angle = math.pi * i / steps;
      final c = math.cos(angle);
      final s = math.sin(angle);
      sink.lineTo(
        x + (fx * c + ax * s) * radius,
        y + (fy * c + ay * s) * radius,
      );
    }
  }
}

/// The ink a [Drawable] lays down, prepared once.
///
/// Splits each op set into contours and gives every contour an [InkStroke]
/// from the drawable's [RoughPen], with repeat passes lighter and partial.
/// Painters and exporters share this so exported ink is the painted ink.
final class DrawableInk {
  /// Prepares [drawable]'s outlines at [outlineWidth] and its sketched fills
  /// at [sketchWidth].
  ///
  /// A drawable without options is drawn with [RoughPen.uniform]. Pass
  /// `false` for [inkOutline] or [inkSketch] to keep that part as a plain
  /// centreline, for example when its paint fills instead of strokes.
  ///
  /// Uniform pens normally keep plain centrelines, because stroking them is
  /// cheaper and exact. Pass [inkUniform] when every part must arrive as a
  /// filled outline regardless of the pen.
  DrawableInk(
    Drawable drawable, {
    required double outlineWidth,
    required double sketchWidth,
    bool inkOutline = true,
    bool inkSketch = true,
    bool inkUniform = false,
  }) : sets = _prepare(
         drawable,
         outlineWidth,
         sketchWidth,
         inkOutline,
         inkSketch,
         inkUniform,
       );

  /// One entry per op set, in the drawable's order.
  final List<DrawableInkSet> sets;

  static List<DrawableInkSet> _prepare(
    Drawable drawable,
    double outlineWidth,
    double sketchWidth,
    bool inkOutline,
    bool inkSketch,
    bool inkUniform,
  ) {
    final pen = drawable.options?.pen ?? RoughPen.uniform;
    final seed = drawable.options?.seed ?? 1;
    var index = 0;
    return [
      for (final set in drawable.sets ?? const <OpSet>[])
        () {
          final type = set.type ?? OpSetType.path;
          final ops = set.ops ?? const <Op>[];
          final width = type == OpSetType.path ? outlineWidth : sketchWidth;
          final inked =
              (inkUniform || !pen.isUniform) &&
              width > 0 &&
              switch (type) {
                OpSetType.path => inkOutline,
                OpSetType.fillSketch => inkSketch,
                OpSetType.fillPath => false,
              };
          return DrawableInkSet._(
            type,
            ops,
            width,
            inked
                ? [
                    for (final (contour, pass) in _splitContours(ops))
                      InkStroke(
                        contour,
                        width: width,
                        pen: pen,
                        seed: seed * 7919 + index++,
                        weight: pass == 0 ? 1 : pen.repeatWidth,
                        coverage: pass == 0 ? 1 : pen.repeatCoverage,
                      ),
                  ]
                : null,
          );
        }(),
    ];
  }

  /// The completed ink as SVG paths, in paint order: solid fills, sketched
  /// fills, then outlines.
  List<InkSvgPath> svgPaths() => [
    for (final type in const [
      OpSetType.fillPath,
      OpSetType.fillSketch,
      OpSetType.path,
    ])
      for (final set in sets.where((set) => set.type == type))
        ...set.svgPaths(),
  ];
}

/// The prepared ink for one [OpSet].
final class DrawableInkSet {
  DrawableInkSet._(this.type, this.ops, this.width, this.strokes);

  /// Which part of the drawing this set is.
  final OpSetType type;

  /// The rough centreline or fill polygon.
  final List<Op> ops;

  /// The pen width for this set.
  final double width;

  /// Pen strokes, one per contour, or null when the set keeps a plain
  /// centreline (uniform pens, solid fills, or ink turned off).
  final List<InkStroke>? strokes;

  /// This set as SVG paths.
  Iterable<InkSvgPath> svgPaths() sync* {
    final inked = strokes;
    if (inked != null) {
      for (final stroke in inked) {
        yield InkSvgPath(
          type: type,
          data: stroke.svgPathData,
          filled: true,
          strokeWidth: 0,
        );
      }
      return;
    }
    if (ops.isEmpty) return;
    final data = StringBuffer();
    for (final op in ops) {
      data
        ..write(switch (op.op) {
          OpType.move => 'M',
          OpType.lineTo => 'L',
          OpType.curveTo => 'C',
        })
        ..write(op.data.map((point) => '${point.x} ${point.y}').join(' '))
        ..write(' ');
    }
    final fill = type == OpSetType.fillPath;
    yield InkSvgPath(
      type: type,
      data: '${data.toString().trimRight()}${fill ? ' Z' : ''}',
      filled: fill,
      strokeWidth: fill ? 0 : width,
    );
  }
}

/// One SVG `<path>` of exported ink.
final class InkSvgPath {
  /// Creates an exported path.
  const InkSvgPath({
    required this.type,
    required this.data,
    required this.filled,
    required this.strokeWidth,
  });

  /// Which part of the drawing this path came from.
  final OpSetType type;

  /// The SVG `d` attribute.
  final String data;

  /// Whether [data] is filled; otherwise it is stroked at [strokeWidth].
  final bool filled;

  /// The stroke width when not [filled]; zero for fills.
  final double strokeWidth;
}

/// Splits operations into contours, with the pass that drew each.
Iterable<(List<Op>, int)> _splitContours(List<Op> ops) sync* {
  List<Op>? current;
  var pass = 0;
  for (final op in ops) {
    if (op.op == OpType.move) {
      if (current != null) yield (current, pass);
      current = [];
      pass = op.pass;
    }
    (current ??= []).add(op);
  }
  if (current != null) yield (current, pass);
}
