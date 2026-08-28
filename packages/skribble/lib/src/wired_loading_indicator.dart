import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'wired_theme.dart';

/// A hand-drawn loading indicator with organic animation.
///
/// Displays a sketchy circular spinner that rotates with a slightly
/// irregular motion, fitting the Skribble hand-drawn aesthetic.
///
/// ## Example
///
/// ```dart
/// WiredLoadingIndicator(
///   size: 32,
///   color: Colors.blue,
/// )
/// ```
class WiredLoadingIndicator extends HookWidget {
  /// The size of the loading indicator in logical pixels.
  final double size;

  /// The color of the loading indicator. Defaults to theme border color.
  final Color? color;

  /// The stroke width of the hand-drawn circle.
  final double strokeWidth;

  /// Creates a hand-drawn loading indicator.
  const WiredLoadingIndicator({
    super.key,
    this.size = 24.0,
    this.color,
    this.strokeWidth = 2.0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = WiredTheme.of(context);
    final effectiveColor = color ?? theme.borderColor;

    final controller = useAnimationController(
      duration: const Duration(milliseconds: 1200),
    );

    useEffect(() {
      unawaited(controller.repeat());
      return null;
    }, []);

    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return SizedBox(
          width: size,
          height: size,
          child: CustomPaint(
            painter: _WiredSpinnerPainter(
              progress: controller.value,
              color: effectiveColor,
              strokeWidth: strokeWidth,
            ),
          ),
        );
      },
    );
  }
}

/// Painter for the hand-drawn loading spinner.
class _WiredSpinnerPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double strokeWidth;

  _WiredSpinnerPainter({
    required this.progress,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.shortestSide - strokeWidth) / 2;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // Draw incomplete circle with hand-drawn effect
    final path = Path();
    const segments = 12;
    const segmentAngle = 2 * math.pi / segments;
    final startAngle = progress * 2 * math.pi;
    const sweepAngle = math.pi * 1.5; // 270 degrees

    for (int i = 0; i <= segments; i++) {
      final angle = startAngle + (i * segmentAngle);
      if (angle > startAngle + sweepAngle) break;

      // Add slight jitter for hand-drawn feel
      final jitter = (i % 2 == 0 ? 1.0 : -1.0) * 1.5;
      final x = center.dx + (radius + jitter) * math.cos(angle);
      final y = center.dy + (radius + jitter) * math.sin(angle);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);

    // Draw small circle at the end for emphasis
    final endAngle = startAngle + sweepAngle;
    final endX = center.dx + radius * math.cos(endAngle);
    final endY = center.dy + radius * math.sin(endAngle);
    final endCenter = Offset(endX, endY);

    canvas.drawCircle(
      endCenter,
      strokeWidth * 1.5,
      Paint()
        ..color = color
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(_WiredSpinnerPainter oldDelegate) {
    return progress != oldDelegate.progress ||
        color != oldDelegate.color ||
        strokeWidth != oldDelegate.strokeWidth;
  }
}

/// A hand-drawn circular progress indicator.
///
/// Displays a sketchy circular progress that fills based on [value].
///
/// ## Example
///
/// ```dart
/// WiredCircularProgressIndicator(
///   value: 0.7, // 70% complete
///   size: 48,
/// )
/// ```
class WiredCircularProgressIndicator extends HookWidget {
  /// The progress value from 0.0 to 1.0, or null for indeterminate.
  final double? value;

  /// The size of the progress indicator in logical pixels.
  final double size;

  /// The color of the progress indicator. Defaults to theme border color.
  final Color? color;

  /// The background color of the track.
  final Color? backgroundColor;

  /// The stroke width of the hand-drawn circle.
  final double strokeWidth;

  /// Creates a hand-drawn circular progress indicator.
  const WiredCircularProgressIndicator({
    super.key,
    this.value,
    this.size = 48.0,
    this.color,
    this.backgroundColor,
    this.strokeWidth = 3.0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = WiredTheme.of(context);
    final effectiveColor = color ?? theme.borderColor;
    final effectiveBgColor = backgroundColor ?? theme.fillColor;

    final controller = useAnimationController(
      duration: const Duration(milliseconds: 1200),
    );

    useEffect(() {
      if (value == null) {
        unawaited(controller.repeat());
      }
      return null;
    }, [value]);

    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return SizedBox(
          width: size,
          height: size,
          child: CustomPaint(
            painter: _WiredCircularProgressPainter(
              value: value ?? controller.value,
              color: effectiveColor,
              backgroundColor: effectiveBgColor,
              strokeWidth: strokeWidth,
              isIndeterminate: value == null,
            ),
          ),
        );
      },
    );
  }
}

/// Painter for the hand-drawn circular progress indicator.
class _WiredCircularProgressPainter extends CustomPainter {
  final double value;
  final Color color;
  final Color backgroundColor;
  final double strokeWidth;
  final bool isIndeterminate;

  _WiredCircularProgressPainter({
    required this.value,
    required this.color,
    required this.backgroundColor,
    required this.strokeWidth,
    required this.isIndeterminate,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.shortestSide - strokeWidth) / 2;

    // Draw background track
    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawCircle(center, radius, bgPaint);

    // Draw progress arc with hand-drawn effect
    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final path = Path();
    const segments = 24;
    const segmentAngle = 2 * math.pi / segments;
    final sweepAngle = isIndeterminate ? math.pi * 1.5 : 2 * math.pi * value;
    final startAngle = isIndeterminate ? value * 2 * math.pi : -math.pi / 2;

    for (int i = 0; i <= segments; i++) {
      final angle = startAngle + (i * segmentAngle);
      if (angle > startAngle + sweepAngle) break;

      // Add slight jitter for hand-drawn feel
      final jitter = (i % 2 == 0 ? 1.0 : -1.0) * 1.0;
      final x = center.dx + (radius + jitter) * math.cos(angle);
      final y = center.dy + (radius + jitter) * math.sin(angle);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, progressPaint);
  }

  @override
  bool shouldRepaint(_WiredCircularProgressPainter oldDelegate) {
    return value != oldDelegate.value ||
        color != oldDelegate.color ||
        backgroundColor != oldDelegate.backgroundColor ||
        strokeWidth != oldDelegate.strokeWidth ||
        isIndeterminate != oldDelegate.isIndeterminate;
  }
}
