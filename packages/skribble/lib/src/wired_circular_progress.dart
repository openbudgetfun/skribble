import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'canvas/wired_canvas.dart';
import 'const.dart';
import 'wired_base.dart';

/// A circular progress indicator with a hand-drawn arc.
class WiredCircularProgress extends HookWidget {
  final double? value;
  final double size;
  final double strokeWidth;

  const WiredCircularProgress({
    super.key,
    this.value,
    this.size = 48.0,
    this.strokeWidth = 3,
  });

  @override
  Widget build(BuildContext context) {
    final isIndeterminate = value == null;
    final controller = useAnimationController(
      duration: const Duration(seconds: 2),
    );

    useEffect(() {
      if (isIndeterminate) {
        unawaited(controller.repeat());
      }
      return null;
    }, [isIndeterminate]);

    final rotation = useAnimation(
      Tween<double>(begin: 0, end: 2 * pi).animate(controller),
    );

    return SizedBox(
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
            ),
          ),
        ],
      ),
    );
  }
}

class _ArcPainter extends CustomPainter {
  final double progress;
  final double rotation;
  final double strokeWidth;

  _ArcPainter({
    required this.progress,
    required this.rotation,
    required this.strokeWidth,
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
      progress != oldDelegate.progress || rotation != oldDelegate.rotation;
}
