import 'dart:ui' show Path;

import 'doodle_geometry.dart';

/// Walks [stroke] as one move followed by its cubic segments.
///
/// This is the single place that defines how [DoodleStroke] geometry becomes
/// drawable geometry. The Flutter `Path` adapter below and the rough `OpSet`
/// adapters in the logo, loader, and doodle widgets all consume this
/// traversal, so the three renderers cannot drift apart.
void walkDoodleStroke(
  DoodleStroke stroke, {
  required void Function(DoodlePoint point) moveTo,
  required void Function(DoodleCurve curve) curveTo,
}) {
  moveTo(stroke.start);
  stroke.curves.forEach(curveTo);
}

/// Builds a Flutter [Path] for [stroke] in the drawing's 100-unit space.
///
/// Set [close] to join the end of the stroke back to [DoodleStroke.start];
/// open strokes stay open.
Path doodleStrokePath(DoodleStroke stroke, {bool close = false}) {
  final path = Path();
  walkDoodleStroke(
    stroke,
    moveTo: (point) => path.moveTo(point.x, point.y),
    curveTo: (curve) => path.cubicTo(
      curve.first.x,
      curve.first.y,
      curve.second.x,
      curve.second.y,
      curve.end.x,
      curve.end.y,
    ),
  );
  if (close) path.close();
  return path;
}
