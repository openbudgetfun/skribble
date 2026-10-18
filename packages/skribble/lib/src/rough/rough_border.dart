import 'dart:collection';
import 'dart:math';

import 'package:flutter/painting.dart';
import 'package:skribble_rough/skribble_rough.dart';

import 'rough_drawing.dart';

/// How far inside its box the centre of a rough outline drawn with a pen of
/// [strokeWidth] lands.
///
/// The outline keeps its whole line, including its wobble and the pen's
/// widest point, inside the box. A fill or clip inset by this much meets the
/// line at its centre. [config] defaults to [DrawConfig.defaultValues].
double roughInkInset(double strokeWidth, [DrawConfig? config]) {
  final resolved = config ?? DrawConfig.defaultValues;
  return strokeWidth * resolved.pen.reach +
      1 +
      resolved.maxRandomnessOffset * resolved.roughness;
}

/// Inks a rough rounded-rectangle outline of [side] inside [rect].
///
/// Prepared drawings are shared through a bounded cache keyed by everything
/// that shapes them, so a border repainted every frame, or the same border on
/// many controls, prepares its outline once. The seed is part of the key, so
/// a control keeps the same wobble while it is pressed, focused, or rebuilt.
void paintRoughOutline(
  Canvas canvas,
  Rect rect, {
  required BorderSide side,
  required BorderRadius borderRadius,
  required int seed,
  DrawConfig? drawConfig,
}) {
  if (side.style == BorderStyle.none ||
      side.width <= 0 ||
      side.color.a == 0 ||
      rect.isEmpty) {
    return;
  }
  final size = rect.size;
  final drawing = _RoughOutlineCache.resolve(
    (size, side.color, side.width, borderRadius, seed, drawConfig),
    () => _prepare(size, side, borderRadius, seed, drawConfig),
  );
  canvas
    ..save()
    ..translate(rect.left, rect.top);
  drawing.paint(canvas);
  canvas.restore();
}

RoughDrawing _prepare(
  Size size,
  BorderSide side,
  BorderRadius borderRadius,
  int seed,
  DrawConfig? drawConfig,
) {
  final config = drawConfig ?? DrawConfig.build(seed: seed);
  config.randomizer.reset();
  final inset = min(roughInkInset(side.width, config), size.shortestSide / 2);
  final rect = (Offset.zero & size).deflate(inset);
  final drawable = Generator(config, NoFiller()).roundedRectangle(
    rect.left,
    rect.top,
    rect.width,
    rect.height,
    borderRadius.topLeft.x,
    borderRadius.topRight.x,
    borderRadius.bottomRight.x,
    borderRadius.bottomLeft.x,
  );
  final pen = Paint()
    ..style = PaintingStyle.stroke
    ..isAntiAlias = true
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round
    ..strokeWidth = side.width
    ..color = side.color;
  return RoughDrawing(drawable, pen, pen);
}

/// A least-recently-used store of prepared outlines, shared by every rough
/// border.
abstract final class _RoughOutlineCache {
  static const int _capacity = 256;
  static final LinkedHashMap<Object, RoughDrawing> _drawings =
      LinkedHashMap<Object, RoughDrawing>();

  static RoughDrawing resolve(Object key, RoughDrawing Function() prepare) {
    // Re-inserting marks the entry as most recently used.
    final drawing = _drawings.remove(key) ?? prepare();
    _drawings[key] = drawing;
    if (_drawings.length > _capacity) {
      _drawings.remove(_drawings.keys.first);
    }
    return drawing;
  }
}

/// A rounded rectangle whose edge is drawn by hand.
///
/// Anything that takes an [OutlinedBorder] or a [ShapeBorder] — a
/// `ShapeDecoration`, or the `shape` of a themed control — gets the rough
/// outline without restyling each call site. The border only inks the
/// [side]; the control paints its own fill, which [getOuterPath] stops at the
/// centre of the pen line so no fill shows outside the wobble.
///
/// The [seed] is fixed, so a control of a given size draws the same wobble on
/// every frame and never shimmers while it is pressed or focused. Give
/// neighbouring surfaces different seeds when identical wobbles would show.
class RoughOutlinedBorder extends OutlinedBorder {
  /// Creates a rough rounded-rectangle border.
  const RoughOutlinedBorder({
    super.side,
    this.borderRadius = const BorderRadius.all(Radius.circular(16)),
    this.seed = 1,
    this.drawConfig,
  });

  /// Corner radii of the outline.
  final BorderRadius borderRadius;

  /// Seed for the outline's wobble. Ignored when [drawConfig] is set.
  final int seed;

  /// Draw configuration for the outline, compared by identity. Defaults to
  /// `DrawConfig.build(seed: seed)`.
  final DrawConfig? drawConfig;

  double get _inset => side.style == BorderStyle.none || side.width == 0
      ? 0
      : roughInkInset(side.width, drawConfig);

  RRect _shape(Rect rect) => borderRadius.toRRect(
    rect.deflate(min(_inset, rect.shortestSide / 2)),
  );

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.all(side.strokeInset);

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) =>
      Path()..addRRect(_shape(rect).deflate(side.strokeInset));

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) =>
      Path()..addRRect(_shape(rect));

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) =>
      paintRoughOutline(
        canvas,
        rect,
        side: side,
        borderRadius: borderRadius,
        seed: seed,
        drawConfig: drawConfig,
      );

  @override
  RoughOutlinedBorder copyWith({
    BorderSide? side,
    BorderRadius? borderRadius,
    int? seed,
  }) => RoughOutlinedBorder(
    side: side ?? this.side,
    borderRadius: borderRadius ?? this.borderRadius,
    seed: seed ?? this.seed,
    drawConfig: drawConfig,
  );

  @override
  ShapeBorder scale(double t) => RoughOutlinedBorder(
    side: side.scale(t),
    borderRadius: borderRadius * t,
    seed: seed,
    drawConfig: drawConfig,
  );

  @override
  ShapeBorder? lerpFrom(ShapeBorder? a, double t) {
    if (a is RoughOutlinedBorder) {
      return RoughOutlinedBorder(
        side: BorderSide.lerp(a.side, side, t),
        borderRadius: BorderRadius.lerp(a.borderRadius, borderRadius, t)!,
        seed: t < 0.5 ? a.seed : seed,
        drawConfig: t < 0.5 ? a.drawConfig : drawConfig,
      );
    }
    return super.lerpFrom(a, t);
  }

  @override
  ShapeBorder? lerpTo(ShapeBorder? b, double t) {
    if (b is RoughOutlinedBorder) {
      return RoughOutlinedBorder(
        side: BorderSide.lerp(side, b.side, t),
        borderRadius: BorderRadius.lerp(borderRadius, b.borderRadius, t)!,
        seed: t < 0.5 ? seed : b.seed,
        drawConfig: t < 0.5 ? drawConfig : b.drawConfig,
      );
    }
    return super.lerpTo(b, t);
  }

  @override
  bool operator ==(Object other) =>
      other is RoughOutlinedBorder &&
      other.side == side &&
      other.borderRadius == borderRadius &&
      other.seed == seed &&
      identical(other.drawConfig, drawConfig);

  @override
  int get hashCode => Object.hash(side, borderRadius, seed, drawConfig);

  @override
  String toString() => 'RoughOutlinedBorder($side, $borderRadius, seed: $seed)';
}
