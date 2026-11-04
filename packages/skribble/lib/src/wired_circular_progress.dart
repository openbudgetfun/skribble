import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'canvas/wired_canvas.dart';
import 'wired_base.dart';
import 'wired_theme.dart';

/// A circular progress indicator with a hand-drawn arc.
///
/// Give [value] from 0 to 1 to show how far along something is; leave it
/// null while the amount is unknown and the arc spins instead. The spin
/// stops as soon as a value arrives.
class WiredCircularProgress extends HookWidget {
  /// How far along, from 0 to 1, or null when unknown.
  final double? value;

  /// The width and height of the indicator.
  final double size;

  /// The width of the progress arc.
  final double strokeWidth;

  /// Accessible description, such as "Uploading photos".
  final String? semanticLabel;

  const WiredCircularProgress({
    super.key,
    this.value,
    this.size = 48.0,
    this.strokeWidth = 3,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = WiredTheme.of(context);
    final isIndeterminate = value == null;
    final controller = useAnimationController(
      duration: const Duration(seconds: 2),
    );

    useEffect(() {
      // A determinate arc holds still: a spinner left running would keep
      // scheduling frames for a value that no longer changes.
      if (isIndeterminate) {
        controller.repeat();
      } else {
        controller.stop();
      }
      return null;
    }, [isIndeterminate]);

    final rotation = useAnimation(controller) * 2 * pi;

    return Semantics(
      label: semanticLabel,
      value: isIndeterminate ? null : '${(value!.clamp(0, 1) * 100).round()}%',
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Background circle
            WiredCanvas(
              painter: WiredCircleBase(
                diameterRatio: 0.9,
                strokeWidth: strokeWidth * 0.5,
                borderColor: theme.borderColor,
              ),
              fillerType: RoughFilter.noFiller,
            ),
            // Progress arc
            CustomPaint(
              size: Size(size, size),
              painter: _ArcPainter(
                progress: isIndeterminate ? 0.7 : value!.clamp(0, 1),
                rotation: isIndeterminate ? rotation : 0,
                strokeWidth: strokeWidth,
                borderColor: theme.borderColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ArcPainter extends CustomPainter {
  final double progress;
  final double rotation;
  final double strokeWidth;
  final Color borderColor;

  _ArcPainter({
    required this.progress,
    required this.rotation,
    required this.strokeWidth,
    required this.borderColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (min(size.width, size.height) / 2) * 0.85;
    final rect = Rect.fromCircle(center: center, radius: radius);
    final paint = Paint()
      ..color = borderColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final startAngle = -pi / 2 + rotation;
    final sweepAngle = 2 * pi * progress;

    canvas.drawArc(rect, startAngle, sweepAngle, false, paint);
  }

  @override
  bool shouldRepaint(_ArcPainter oldDelegate) =>
      progress != oldDelegate.progress ||
      rotation != oldDelegate.rotation ||
      strokeWidth != oldDelegate.strokeWidth ||
      borderColor != oldDelegate.borderColor;
}
