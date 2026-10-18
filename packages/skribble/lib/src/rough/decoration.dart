import 'dart:math';
import 'dart:ui' show lerpDouble;

import 'package:flutter/animation.dart';
import 'package:flutter/painting.dart';
import 'package:skribble_rough/skribble_rough.dart';

import 'rough_border.dart';
import 'rough_drawing.dart';

/// Style configuration for rough-drawn strokes and fills.
///
/// Controls [width], [color], [gradient], and [blendMode] of
/// border and fill paints in a `RoughBoxDecoration`.
class RoughDrawingStyle {
  final double? width;
  final Color? color;
  final Gradient? gradient;
  final BlendMode? blendMode;

  const RoughDrawingStyle({
    this.width,
    this.color,
    this.gradient,
    this.blendMode,
  });

  /// Interpolates between two styles, so a [RoughBoxDecoration] can animate
  /// its pen weight and ink.
  ///
  /// [width] and [color] interpolate; [gradient] and [blendMode] switch at
  /// the midpoint. Either end may be null.
  static RoughDrawingStyle? lerp(
    RoughDrawingStyle? a,
    RoughDrawingStyle? b,
    double t,
  ) {
    if (identical(a, b)) return a;
    return RoughDrawingStyle(
      width: lerpDouble(a?.width, b?.width, t),
      color: Color.lerp(a?.color, b?.color, t),
      gradient: Gradient.lerp(a?.gradient, b?.gradient, t),
      blendMode: t < 0.5 ? a?.blendMode : b?.blendMode,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is RoughDrawingStyle &&
      other.width == width &&
      other.color == color &&
      other.gradient == gradient &&
      other.blendMode == blendMode;

  @override
  int get hashCode => Object.hash(width, color, gradient, blendMode);
}

/// The shape painted by a [RoughBoxDecoration].
enum RoughBoxShape { rectangle, roundedRectangle, circle, ellipse }

/// A `Decoration` that paints a hand-drawn box using the rough engine.
///
/// Supports rectangle, rounded rectangle, circle, and ellipse shapes
/// with configurable border and fill styles.
///
/// Set [color] for a level fill under the hand-drawn outline, the way a
/// `BoxDecoration` paints its colour. The fill, and any clip taken from this
/// decoration (`Container(clipBehavior: ...)`), stop at the centre of the
/// pen line, so neither pokes out past the outline.
///
/// Two decorations with the same values are equal, so a parent that rebuilds
/// with an equal decoration keeps the prepared drawing instead of preparing a
/// new one. [drawConfig], [filler], [progress], and [pressure] compare by
/// identity: pass a shared instance, such as the theme's `drawConfig`.
/// Decorations of the same [shape] interpolate, so an `AnimatedContainer`
/// can move between two hand-drawn states.
class RoughBoxDecoration extends Decoration {
  /// Optional pen progress. Resolve ambient motion policy before supplying it.
  /// See WiredDrawTransition.progressOf for context-aware integration.
  final Animation<double>? progress;

  /// Optional pen pressure for interaction feedback, from zero to one.
  final Animation<double>? pressure;

  final RoughBoxShape shape;

  /// A level fill painted beneath the outline, inset to the pen's centre.
  ///
  /// Unlike [fillStyle], which inks the [filler]'s strokes, this is a flat
  /// field that text and artwork can sit on. Null paints no level fill.
  final Color? color;

  final RoughDrawingStyle? borderStyle;
  final DrawConfig? drawConfig;
  final RoughDrawingStyle? fillStyle;
  final Filler? filler;

  final BorderRadius? borderRadius;

  /// A fixed seed for deterministic rough shapes. The same seed always
  /// produces the same wobble, so hover/unhover doesn't re-randomise.
  /// Set [seed] to a unique value per widget instance (e.g. hash of label)
  /// for variety, or pass a random value for full randomness. Defaults to 1.
  final int seed;

  const RoughBoxDecoration({
    this.progress,
    this.pressure,
    this.borderStyle,
    this.drawConfig,
    this.fillStyle,
    this.shape = RoughBoxShape.rectangle,
    this.filler,
    this.borderRadius,
    this.seed = 1,
    this.color,
  });

  /// How far inside the box the centre of the outline lands.
  ///
  /// The outline keeps its whole line, including its wobble and the pen's
  /// widest point, inside the box. A fill or clip inset by this much meets
  /// the line at its centre. Boxes too small for the full inset use half
  /// their shortest side instead.
  double get inkInset => roughInkInset(borderStyle?.width ?? 0, drawConfig);

  @override
  EdgeInsetsGeometry get padding =>
      EdgeInsets.all(max(0.1, (borderStyle?.width ?? 0.1) / 2));

  @override
  Path getClipPath(Rect rect, TextDirection textDirection) =>
      _shapePath(rect.deflate(min(inkInset, rect.shortestSide / 2)));

  Path _shapePath(Rect rect) {
    final path = Path();
    switch (shape) {
      case RoughBoxShape.rectangle:
        path.addRect(rect);
      case RoughBoxShape.roundedRectangle:
        path.addRRect((borderRadius ?? BorderRadius.zero).toRRect(rect));
      case RoughBoxShape.circle:
        path.addOval(
          Rect.fromCircle(center: rect.center, radius: rect.shortestSide / 2),
        );
      case RoughBoxShape.ellipse:
        path.addOval(rect);
    }
    return path;
  }

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) {
    return RoughDecorationPainter(this, onChanged);
  }

  /// Interpolates between two decorations of the same [shape].
  ///
  /// Colours, pen styles, and corner radii interpolate. The seed, draw
  /// config, filler, and animations switch at the midpoint, so the outline
  /// re-rolls its wobble at most once. Returns null when the shapes differ,
  /// which makes `Decoration.lerp` cross over at the midpoint instead.
  static RoughBoxDecoration? lerp(
    RoughBoxDecoration? a,
    RoughBoxDecoration? b,
    double t,
  ) {
    if (identical(a, b)) return a;
    if (a == null || b == null || a.shape != b.shape) return null;
    final RoughBoxDecoration near = t < 0.5 ? a : b;
    return RoughBoxDecoration(
      progress: near.progress,
      pressure: near.pressure,
      shape: b.shape,
      color: Color.lerp(a.color, b.color, t),
      borderStyle: RoughDrawingStyle.lerp(a.borderStyle, b.borderStyle, t),
      fillStyle: RoughDrawingStyle.lerp(a.fillStyle, b.fillStyle, t),
      borderRadius: BorderRadius.lerp(a.borderRadius, b.borderRadius, t),
      drawConfig: near.drawConfig,
      filler: near.filler,
      seed: near.seed,
    );
  }

  @override
  Decoration? lerpFrom(Decoration? a, double t) =>
      a is RoughBoxDecoration ? lerp(a, this, t) : super.lerpFrom(a, t);

  @override
  Decoration? lerpTo(Decoration? b, double t) =>
      b is RoughBoxDecoration ? lerp(this, b, t) : super.lerpTo(b, t);

  @override
  bool operator ==(Object other) =>
      other is RoughBoxDecoration &&
      identical(other.progress, progress) &&
      identical(other.pressure, pressure) &&
      other.shape == shape &&
      other.color == color &&
      other.borderStyle == borderStyle &&
      identical(other.drawConfig, drawConfig) &&
      other.fillStyle == fillStyle &&
      identical(other.filler, filler) &&
      other.borderRadius == borderRadius &&
      other.seed == seed;

  @override
  int get hashCode => Object.hash(
    progress,
    pressure,
    shape,
    color,
    borderStyle,
    drawConfig,
    fillStyle,
    filler,
    borderRadius,
    seed,
  );
}

/// The `BoxPainter` implementation for `RoughBoxDecoration`.
///
/// Generates rough shapes via `Generator` and paints them onto
/// the canvas with the configured styles.
class RoughDecorationPainter extends BoxPainter {
  final RoughBoxDecoration roughDecoration;

  RoughDecorationPainter(this.roughDecoration, [VoidCallback? onChanged])
    : super(onChanged) {
    if (onChanged != null) {
      for (final animation in _animations) {
        animation.addListener(onChanged);
      }
    }
  }

  Set<Animation<double>> get _animations => {
    ?roughDecoration.progress,
    ?roughDecoration.pressure,
  };
  Size? _size;
  late RoughDrawing _drawing;
  Path? _fill;
  late final Paint _fillPaint = Paint()..color = roughDecoration.color!;

  @override
  void dispose() {
    final callback = onChanged;
    if (callback != null) {
      for (final animation in _animations) {
        animation.removeListener(callback);
      }
    }
    super.dispose();
  }

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    final size = configuration.size;
    if (size == null || size.isEmpty) return;
    if (_size != size) {
      _drawing = _prepare(size);
      _fill = roughDecoration.color == null
          ? null
          : roughDecoration.getClipPath(
              Offset.zero & size,
              configuration.textDirection ?? TextDirection.ltr,
            );
      _size = size;
    }
    canvas.save();
    canvas.translate(offset.dx, offset.dy);
    if (_fill case final fill?) {
      canvas.drawPath(fill, _fillPaint);
    }
    _drawing.paint(
      canvas,
      progress: roughDecoration.progress?.value ?? 1,
      pressure: roughDecoration.pressure?.value ?? 0,
    );
    canvas.restore();
  }

  RoughDrawing _prepare(Size size) {
    final DrawConfig drawConfig =
        roughDecoration.drawConfig ??
        DrawConfig.build(seed: roughDecoration.seed);
    drawConfig.randomizer.reset();
    final Filler filler = roughDecoration.filler ?? NoFiller();
    final Generator generator = Generator(drawConfig, filler);
    final Rect rect = (Offset.zero & size).deflate(
      min(roughDecoration.inkInset, size.shortestSide / 2),
    );

    final Paint borderPaint = _buildDrawPaint(
      roughDecoration.borderStyle ?? const RoughDrawingStyle(),
      rect,
    );

    final Paint fillPaint = roughDecoration.fillStyle == null
        ? borderPaint
        : _buildDrawPaint(roughDecoration.fillStyle!, rect);

    Drawable drawable;
    switch (roughDecoration.shape) {
      case RoughBoxShape.rectangle:
        drawable = generator.rectangle(
          rect.left,
          rect.top,
          rect.width,
          rect.height,
        );
      case RoughBoxShape.roundedRectangle:
        final br = roughDecoration.borderRadius ?? BorderRadius.zero;
        drawable = generator.roundedRectangle(
          rect.left,
          rect.top,
          rect.width,
          rect.height,
          br.topLeft.x,
          br.topRight.x,
          br.bottomRight.x,
          br.bottomLeft.x,
        );
      case RoughBoxShape.circle:
        final double centerX = rect.center.dx;
        final double centerY = rect.center.dy;
        final double diameter = rect.shortestSide;
        drawable = generator.circle(centerX, centerY, diameter);
      case RoughBoxShape.ellipse:
        final double centerX = rect.center.dx;
        final double centerY = rect.center.dy;
        drawable = generator.ellipse(
          centerX,
          centerY,
          rect.width,
          rect.height,
        );
    }

    return RoughDrawing(drawable, borderPaint, fillPaint);
  }

  Paint _buildDrawPaint(RoughDrawingStyle roughDrawDecoration, Rect rect) {
    const defaultColor = Color(0x00000000);
    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..isAntiAlias = true
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = roughDrawDecoration.width ?? 0.1
      ..color = roughDrawDecoration.color ?? defaultColor
      ..shader = roughDrawDecoration.gradient?.createShader(rect);
    if (roughDrawDecoration.blendMode != null) {
      paint.blendMode = roughDrawDecoration.blendMode!;
    }
    return paint;
  }
}
