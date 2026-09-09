import 'dart:ui';

import 'core.dart';
import 'entities.dart';

/// A snapshot of generated ink, reusable across animation frames.
///
/// Geometry and contour lengths are retained locally. Recreate this object when
/// the shape, size, seed, or paints change. It never modifies its inputs.
class RoughDrawing {
  /// Copies the generated operations and paints into a stable drawing.
  RoughDrawing(Drawable drawable, Paint borderPaint, Paint fillPaint)
    : _borderPaint = Paint.from(borderPaint),
      _fillPaint = Paint.from(fillPaint),
      _sets = [
        for (final set in drawable.sets ?? <OpSet>[])
          _InkPath(set.type!, _roughPath(set)),
      ];

  final Paint _borderPaint;
  final Paint _fillPaint;
  final List<_InkPath> _sets;

  /// Draws an outline, followed by overlapping strokes of patterned fill.
  ///
  /// [progress] is clamped to 0–1. Solid backgrounds remain opaque to preserve
  /// label contrast. [pressure] reinforces the existing pen up to 25 percent,
  /// without moving the outline or changing its seed. Non-finite progress
  /// settles the drawing; non-finite pressure uses the resting pen.
  void paint(Canvas canvas, {double progress = 1, double pressure = 0}) {
    final t = progress.isFinite ? progress.clamp(0.0, 1.0) : 1.0;
    final emphasis = pressure.isFinite ? pressure.clamp(0.0, 1.0) : 0.0;
    final border = Paint.from(_borderPaint)
      ..strokeWidth = _borderPaint.strokeWidth * (1 + emphasis * 0.25);
    final outlineProgress = (t / 0.65).clamp(0.0, 1.0);
    final fillProgress = ((t - 0.3) / 0.7).clamp(0.0, 1.0);
    for (final type in [
      OpSetType.fillPath,
      OpSetType.fillSketch,
      OpSetType.path,
    ]) {
      final sets = _sets.where((set) => set.type == type);
      final fraction = type == OpSetType.path ? outlineProgress : fillProgress;
      // Metrics are lazy, so ordinary static painting never measures paths.
      var remaining =
          fraction == 1 || fraction == 0 || type == OpSetType.fillPath
          ? 0.0
          : sets.fold(0.0, (sum, set) => sum + set.length) * fraction;
      for (final set in sets) {
        if (type == OpSetType.fillPath) {
          canvas.drawPath(
            set.path,
            Paint.from(_fillPaint)..style = PaintingStyle.fill,
          );
        } else if (fraction > 0) {
          final path = fraction == 1 ? set.path : set.prefix(remaining);
          canvas.drawPath(path, type == OpSetType.path ? border : _fillPaint);
          if (fraction != 1) remaining -= set.length;
        }
      }
    }
  }
}

class _InkPath {
  _InkPath(this.type, this.path) {
    if (type == OpSetType.fillPath) path.close();
  }

  final OpSetType type;
  final Path path;
  late final List<PathMetric> _metrics = path.computeMetrics().toList();
  late final double length = _metrics.fold(
    0,
    (sum, metric) => sum + metric.length,
  );
  late final List<Path> _contours = [
    for (final metric in _metrics) metric.extractPath(0, metric.length),
  ];

  Path prefix(double distance) {
    var remaining = distance;
    if (distance >= length) return path;
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

/// Converts rough engine operations to a Flutter path without changing them.
Path _roughPath(OpSet drawing) {
  final path = Path();
  for (final op in drawing.ops ?? <Op>[]) {
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
