import 'dart:math';

import 'package:flutter/material.dart';

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

  const RoughBoxDecoration({
    this.borderStyle,
    this.drawConfig,
    this.fillStyle,
    this.shape = RoughBoxShape.rectangle,
    this.filler,
    this.borderRadius,
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
        roughDecoration.drawConfig ?? DrawConfig.defaultValues;
    final Filler filler = roughDecoration.filler ?? NoFiller();
    final Generator generator = Generator(drawConfig, filler);
    final Rect rect = offset & configuration.size!;

    final Paint borderPaint = _buildDrawPaint(
      roughDecoration.borderStyle!,
      rect,
    );

    final Paint fillPaint = roughDecoration.fillStyle == null
        ? borderPaint
        : _buildDrawPaint(roughDecoration.fillStyle!, rect);

    Drawable drawable;
    switch (roughDecoration.shape) {
      case RoughBoxShape.rectangle:
        drawable = generator.rectangle(
          offset.dx,
          offset.dy,
          configuration.size!.width,
          configuration.size!.height,
        );
      case RoughBoxShape.roundedRectangle:
        final br = roughDecoration.borderRadius ?? BorderRadius.zero;
        drawable = generator.roundedRectangle(
          offset.dx,
          offset.dy,
          configuration.size!.width,
          configuration.size!.height,
          br.topLeft.x,
          br.topRight.x,
          br.bottomRight.x,
          br.bottomLeft.x,
        );
      case RoughBoxShape.circle:
        final double centerX = offset.dx + configuration.size!.width / 2;
        final double centerY = offset.dy + configuration.size!.height / 2;
        final double diameter = configuration.size!.shortestSide;
        drawable = generator.circle(centerX, centerY, diameter);
      case RoughBoxShape.ellipse:
        final double centerX = offset.dx + configuration.size!.width / 2;
        final double centerY = offset.dy + configuration.size!.height / 2;
        drawable = generator.ellipse(
          centerX,
          centerY,
          configuration.size!.width,
          configuration.size!.height,
        );
    }

    canvas.drawRough(drawable, borderPaint, fillPaint);
  }

  Paint _buildDrawPaint(RoughDrawingStyle roughDrawDecoration, Rect rect) {
    const defaultColor = Color(0x00000000);
    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..isAntiAlias = true
      ..strokeCap = StrokeCap.square
      ..strokeWidth = roughDrawDecoration.width ?? 0.1
      ..color = roughDrawDecoration.color ?? defaultColor
      ..shader = roughDrawDecoration.gradient?.createShader(rect);
    if (roughDrawDecoration.blendMode != null) {
      paint.blendMode = roughDrawDecoration.blendMode!;
    }
    return paint;
  }
}
