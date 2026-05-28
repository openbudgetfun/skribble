import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../rough/skribble_rough.dart';
import '../wired_theme.dart';

/// A hand-drawn ink splash effect for Skribble widgets.
///
/// This creates a sketchy, organic splash animation that fits the
/// hand-drawn aesthetic of the Skribble design system.
///
/// Use with [InkWell] or [InkResponse] by setting the [splashFactory]:
///
/// ```dart
/// ThemeData(
///   splashFactory: WiredInkSplashFactory(),
/// )
/// ```
class WiredInkSplashFactory extends InteractiveInkFeatureFactory {
  /// Creates a hand-drawn ink splash factory.
  const WiredInkSplashFactory();

  @override
  InteractiveInkFeature create({
    required MaterialInkController controller,
    required RenderBox referenceBox,
    required Offset position,
    required Color color,
    required TextDirection textDirection,
    bool containedInkWell = false,
    RectCallback? rectCallback,
    BorderRadius? borderRadius,
    ShapeBorder? customBorder,
    double? radius,
    VoidCallback? onRemoved,
  }) {
    return WiredInkSplash(
      controller: controller,
      referenceBox: referenceBox,
      position: position,
      color: color,
      onRemoved: onRemoved,
      radius: radius,
    );
  }
}

/// A hand-drawn ink splash that creates a sketchy ripple effect.
///
/// The splash draws rough circles that expand and fade out, creating
/// an organic, hand-drawn feel.
class WiredInkSplash extends InteractiveInkFeature {
  /// Creates a hand-drawn ink splash.
  WiredInkSplash({
    required super.controller,
    required super.referenceBox,
    required super.position,
    required super.color,
    super.onRemoved,
    double? radius,
  })  : _radius = radius {
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: controller.vsync,
    )
      ..addListener(_handleAnimationUpdate)
      ..addStatusListener(_handleAnimationStatus)
      ..forward();

    _radiusController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: controller.vsync,
    )..forward();

    _alphaController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: controller.vsync,
    )..forward();
  }

  late final AnimationController _controller;
  late final AnimationController _radiusController;
  late final AnimationController _alphaController;

  /// The optional radius configuration.
  final double? _radius;

  /// The maximum radius of the splash.
  double get _targetRadius {
    if (_radius != null) {
      return _radius!;
    }

    final Size size = referenceBox.size;
    final double d = math.max(
      size.width,
      size.height,
    );
    return d / 2.0;
  }

  void _handleAnimationUpdate() {
    controller.markNeedsPaint();
  }

  void _handleAnimationStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      dispose();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _radiusController.dispose();
    _alphaController.dispose();
    super.dispose();
  }

  @override
  void paintFeature(Canvas canvas, Matrix4 transform) {
    final Paint paint = Paint()..color = color.withValues(alpha: 0.2);

    final double progress = _controller.value;
    final double radius = _targetRadius * progress;
    final int alpha = (255 * (1.0 - progress)).round();

    paint.color = color.withValues(alpha: alpha / 255.0);

    // Draw rough circles for hand-drawn effect
    final Offset center = position;
    final int segments = 8;
    final double segmentAngle = 2 * math.pi / segments;

    canvas.save();
    canvas.transform(transform.storage);

    // Draw multiple rough circles for organic feel
    for (int i = 0; i < 3; i++) {
      final double layerRadius = radius * (1.0 - i * 0.1);
      final double layerAlpha = alpha * (1.0 - i * 0.3);
      paint.color = color.withValues(alpha: layerAlpha / 255.0);

      final Path path = Path();
      for (int j = 0; j <= segments; j++) {
        final double angle = j * segmentAngle;
        // Add slight randomness for hand-drawn effect
        final double jitter = (j % 2 == 0 ? 1.0 : -1.0) * 2.0;
        final double x = center.dx + (layerRadius + jitter) * math.cos(angle);
        final double y = center.dy + (layerRadius + jitter) * math.sin(angle);

        if (j == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      path.close();

      canvas.drawPath(path, paint);
    }

    canvas.restore();
  }
}
