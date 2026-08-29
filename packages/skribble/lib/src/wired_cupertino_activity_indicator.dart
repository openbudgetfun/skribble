import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'wired_theme.dart';

/// A hand-drawn activity indicator corresponding to the iOS spinner.
///
/// Displays `segmentCount` radial segments arranged like the classic
/// Cupertino sunburst spinner, each drawn with slightly irregular
/// hand-drawn strokes that fade out behind the leading segment.
///
/// Set [animating] to false to freeze the spinner (all segments render
/// statically), which is also how the storybook demo keeps pages
/// idle-safe.
///
/// ## Example
///
/// ```dart
/// WiredCupertinoActivityIndicator(
///   radius: 14,
///   animating: true,
/// )
/// ```
class WiredCupertinoActivityIndicator extends HookWidget {
  /// Whether the indicator is spinning.
  ///
  /// When false, the segments are drawn statically at full opacity,
  /// mirroring `CupertinoActivityIndicator.animating`.
  final bool animating;

  /// The radius of the spinner in logical pixels. The widget occupies a
  /// square just larger than this radius.
  final double radius;

  /// The color of the leading segments. Defaults to the theme border
  /// color; trailing segments fade out to fully transparent.
  final Color? color;

  /// The stroke width of each hand-drawn segment tick.
  final double strokeWidth;

  /// The number of segments around the circle.
  ///
  /// Defaults to 12 like the iOS spinner. Must be at least 2.
  final int segmentCount;

  /// Optional semantic label for accessibility, e.g. "Loading".
  final String? semanticLabel;

  static const Duration _rotationDuration = Duration(milliseconds: 1100);

  /// Creates a hand-drawn Cupertino-style activity indicator.
  const WiredCupertinoActivityIndicator({
    super.key,
    this.animating = true,
    this.radius = 10,
    this.color,
    this.strokeWidth = 2,
    this.segmentCount = 12,
    this.semanticLabel,
  }) : assert(radius > 0, 'radius must be positive'),
       assert(strokeWidth > 0, 'strokeWidth must be positive'),
       assert(
         segmentCount >= 2,
         'segmentCount must be at least 2',
       );

  @override
  Widget build(BuildContext context) {
    final theme = WiredTheme.of(context);
    final effectiveColor = color ?? theme.borderColor;

    final controller = useAnimationController(duration: _rotationDuration);

    useEffect(() {
      if (animating) {
        controller.repeat();
      } else {
        controller.stop();
      }
      return null;
    }, [animating]);

    final spinner = AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return SizedBox(
          width: radius * 2,
          height: radius * 2,
          child: CustomPaint(
            painter: _ActivityIndicatorPainter(
              progress: animating ? controller.value : 0,
              color: effectiveColor,
              radius: radius,
              strokeWidth: strokeWidth,
              segmentCount: segmentCount,
            ),
          ),
        );
      },
    );

    if (semanticLabel == null) {
      return RepaintBoundary(child: spinner);
    }
    return Semantics(
      label: semanticLabel,
      child: RepaintBoundary(child: spinner),
    );
  }
}

/// Painter that draws the fading radial segments.
class _ActivityIndicatorPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double radius;
  final double strokeWidth;
  final int segmentCount;

  _ActivityIndicatorPainter({
    required this.progress,
    required this.color,
    required this.radius,
    required this.strokeWidth,
    required this.segmentCount,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final segmentAngle = 2 * math.pi / segmentCount;
    // Start slightly before the top like the iOS spinner, and rotate
    // counterclockwise.
    final headAngle = -math.pi / 2 - progress * 2 * math.pi;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    for (var i = 0; i < segmentCount; i++) {
      final fade = (1 - i / segmentCount).clamp(0.0, 1.0);
      if (fade <= 0.05) continue;

      paint.color = color.withValues(alpha: fade);

      // Add deterministic jitter so each tick looks hand-drawn.
      final jitter = (i % 3 - 1) * strokeWidth * 0.2;
      final inner = radius * 0.55;
      final outer = radius - strokeWidth / 2 - 0.5 + jitter;

      final a = headAngle + i * segmentAngle;
      final dir = Offset(math.cos(a), math.sin(a));
      canvas.drawLine(
        center + dir * inner,
        center + dir * outer,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_ActivityIndicatorPainter oldDelegate) =>
      progress != oldDelegate.progress ||
      color != oldDelegate.color ||
      radius != oldDelegate.radius ||
      strokeWidth != oldDelegate.strokeWidth ||
      segmentCount != oldDelegate.segmentCount;
}
