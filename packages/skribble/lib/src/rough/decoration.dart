import 'dart:math';

import 'package:flutter/painting.dart';

import 'config.dart';
import 'entities.dart';
import 'filler.dart';
import 'generator.dart';
import 'rough.dart';

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
}

/// The shape painted by a [RoughBoxDecoration].
enum RoughBoxShape { rectangle, roundedRectangle, circle, ellipse }

/// A `Decoration` that paints a hand-drawn box using the rough engine.
///
/// Supports rectangle, rounded rectangle, circle, and ellipse shapes
/// with configurable border and fill styles.
class RoughBoxDecoration extends Decoration {
  final RoughBoxShape shape;
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
    this.borderStyle,
    this.drawConfig,
    this.fillStyle,
    this.shape = RoughBoxShape.rectangle,
    this.filler,
    this.borderRadius,
    this.seed = 1,
  });

  @override
  EdgeInsetsGeometry get padding =>
      EdgeInsets.all(max(0.1, (borderStyle?.width ?? 0.1) / 2));

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) {
    return RoughDecorationPainter(this);
  }
}

/// The `BoxPainter` implementation for `RoughBoxDecoration`.
///
/// Generates rough shapes via `Generator` and paints them onto
/// the canvas with the configured styles.
class RoughDecorationPainter extends BoxPainter {
  final RoughBoxDecoration roughDecoration;

  RoughDecorationPainter(this.roughDecoration);

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    final DrawConfig drawConfig =
        roughDecoration.drawConfig ??
        DrawConfig.build(seed: roughDecoration.seed);
    drawConfig.randomizer?.reset();
    final Filler filler = roughDecoration.filler ?? NoFiller();
    final Generator generator = Generator(drawConfig, filler);
    final size = configuration.size;
    if (size == null || size.isEmpty) return;
    final bleed =
        (roughDecoration.borderStyle?.width ?? 0) / 2 +
        1 +
        (drawConfig.maxRandomnessOffset ?? 0) * (drawConfig.roughness ?? 0);
    final Rect rect = (offset & size).deflate(
      min(bleed, size.shortestSide / 2),
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

    canvas.drawRough(drawable, borderPaint, fillPaint);
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
