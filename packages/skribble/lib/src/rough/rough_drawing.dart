import 'dart:ui';

import 'core.dart';
import 'entities.dart';
import 'ink_stroke.dart';

/// A snapshot of generated ink, reusable across animation frames.
///
/// Geometry, pen outlines, and contour lengths are retained locally. Recreate
/// this object when the shape, size, seed, pen, or paints change. It never
/// modifies its inputs.
///
/// Outlines and patterned fills are laid down with the drawable's `RoughPen`
/// (from [Drawable.options]); a drawable without options uses the classic
/// constant-width stroke. Use [DrawableInk.svgPaths] on the same drawable to
/// export exactly this ink.
class RoughDrawing {
  /// Copies the generated operations and paints into a stable drawing.
  RoughDrawing(Drawable drawable, Paint borderPaint, Paint fillPaint)
    : _borderPaint = Paint.from(borderPaint),
      _fillPaint = Paint.from(fillPaint),
      _sets = [
        for (final set in DrawableInk(
          drawable,
          outlineWidth: borderPaint.strokeWidth,
          sketchWidth: fillPaint.strokeWidth,
          inkOutline: borderPaint.style == PaintingStyle.stroke,
          inkSketch: fillPaint.style == PaintingStyle.stroke,
        ).sets)
          _InkSet(set),
      ];

  final Paint _borderPaint;
  final Paint _fillPaint;
  final List<_InkSet> _sets;

  /// Draws an outline, followed by overlapping strokes of patterned fill.
  ///
  /// [progress] is clamped to 0–1. Solid backgrounds remain opaque to preserve
  /// label contrast. [pressure] reinforces the existing pen up to 25 percent,
  /// without moving the outline or changing its seed. Non-finite progress
  /// settles the drawing; non-finite pressure uses the resting pen.
  void paint(Canvas canvas, {double progress = 1, double pressure = 0}) {
    final t = progress.isFinite ? progress.clamp(0.0, 1.0) : 1.0;
    final emphasis = pressure.isFinite ? pressure.clamp(0.0, 1.0) : 0.0;
    final outlineProgress = (t / 0.65).clamp(0.0, 1.0);
    final fillProgress = ((t - 0.3) / 0.7).clamp(0.0, 1.0);
    for (final type in [
      OpSetType.fillPath,
      OpSetType.fillSketch,
      OpSetType.path,
    ]) {
      final sets = _sets.where((set) => set.type == type);
      final isOutline = type == OpSetType.path;
      final fraction = isOutline ? outlineProgress : fillProgress;
      final paint = isOutline ? _borderPaint : _fillPaint;
      // Metrics are lazy, so ordinary static painting never measures paths.
      var remaining =
          fraction == 1 || fraction == 0 || type == OpSetType.fillPath
          ? 0.0
          : sets.fold(0.0, (sum, set) => sum + set.length) * fraction;
      for (final set in sets) {
        if (type == OpSetType.fillPath) {
          canvas.drawPath(
            set.centreline,
            Paint.from(_fillPaint)..style = PaintingStyle.fill,
          );
          continue;
        }
        if (fraction == 0) continue;
        set.paint(
          canvas,
          paint,
          distance: fraction == 1 ? double.infinity : remaining,
          emphasis: isOutline ? emphasis : 0,
        );
        if (fraction != 1) remaining -= set.length;
      }
    }
  }
}

/// One prepared op set with its Flutter paths cached.
class _InkSet {
  _InkSet(DrawableInkSet ink)
    : type = ink.type,
      centreline = _roughPath(ink.ops),
      _strokes = ink.strokes?.map(_PathStroke.new).toList(growable: false) {
    if (type == OpSetType.fillPath) centreline.close();
  }

  final OpSetType type;

  /// The rough centreline, or the closed polygon of a solid fill.
  final Path centreline;

  /// Pen strokes, one per contour, or null when the set is stroked uniformly.
  final List<_PathStroke>? _strokes;

  late final List<PathMetric> _metrics = centreline.computeMetrics().toList();
  late final List<Path> _contours = [
    for (final metric in _metrics) metric.extractPath(0, metric.length),
  ];

  /// Distance the pen travels to draw this set completely.
  late final double length = switch (_strokes) {
    final strokes? => strokes.fold(0, (sum, stroke) => sum + stroke.length),
    null => _metrics.fold(0, (sum, metric) => sum + metric.length),
  };

  void paint(
    Canvas canvas,
    Paint paint, {
    required double distance,
    required double emphasis,
  }) {
    final strokes = _strokes;
    if (strokes == null) {
      final path = distance >= length ? centreline : _prefix(distance);
      canvas.drawPath(
        path,
        emphasis == 0
            ? paint
            : (Paint.from(paint)
                ..strokeWidth = paint.strokeWidth * (1 + emphasis * 0.25)),
      );
      return;
    }

    final ink = Paint.from(paint)..style = PaintingStyle.fill;
    // Stroking an outline grows it evenly on both sides, which reinforces
    // the pen without rebuilding the tapered geometry.
    final reinforce = emphasis == 0
        ? null
        : (Paint.from(paint)
            ..style = PaintingStyle.stroke
            ..strokeJoin = StrokeJoin.round
            ..strokeWidth = paint.strokeWidth * emphasis * 0.25);
    var remaining = distance;
    for (final stroke in strokes) {
      if (remaining <= 0) break;
      final outline = stroke.prefix(remaining);
      canvas.drawPath(outline, ink);
      if (reinforce != null) canvas.drawPath(outline, reinforce);
      remaining -= stroke.length;
    }
  }

  Path _prefix(double distance) {
    var remaining = distance;
    final result = Path();
    for (var i = 0; i < _metrics.length && remaining > 0; i++) {
      final metric = _metrics[i];
      result.addPath(
        remaining >= metric.length
            ? _contours[i]
            : metric.extractPath(0, remaining),
        Offset.zero,
      );
      remaining -= metric.length;
    }
    return result;
  }
}

/// An [InkStroke] with its complete outline cached as a Flutter [Path].
class _PathStroke {
  _PathStroke(this.ink);

  final InkStroke ink;

  late final Path outline = _write(double.infinity);

  double get length => ink.length;

  Path prefix(double distance) =>
      distance >= ink.length ? outline : _write(distance);

  Path _write(double distance) {
    final sink = PathInkOutline();
    ink.writeOutline(sink, distance: distance);
    return sink.path;
  }
}

/// Writes an [InkStroke] outline into a Flutter [Path].
final class PathInkOutline implements InkOutlineSink {
  /// The path receiving the outline.
  final Path path = Path();

  @override
  void moveTo(double x, double y) => path.moveTo(x, y);

  @override
  void lineTo(double x, double y) => path.lineTo(x, y);

  @override
  void quadraticTo(double cx, double cy, double x, double y) =>
      path.quadraticBezierTo(cx, cy, x, y);

  @override
  void close() => path.close();
}

/// Converts rough engine operations to a Flutter path without changing them.
Path _roughPath(List<Op> ops) {
  final path = Path();
  for (final op in ops) {
    final data = op.data;
    switch (op.op) {
      case OpType.move:
        path.moveTo(data[0].x, data[0].y);
      case OpType.curveTo:
        path.cubicTo(
          data[0].x,
          data[0].y,
          data[1].x,
          data[1].y,
          data[2].x,
          data[2].y,
        );
      case OpType.lineTo:
        path.lineTo(data[0].x, data[0].y);
    }
  }
  return path;
}
