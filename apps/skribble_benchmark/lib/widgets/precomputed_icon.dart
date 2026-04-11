import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:skribble/skribble.dart';

/// A simple widget that draws pre-parsed SVG paths directly, without any
/// rough-engine computation. This represents the performance ceiling of
/// pre-computed paths.
class PrecomputedIcon extends HookWidget {
  const PrecomputedIcon({
    required this.data,
    super.key,
    this.size = 24,
    this.color,
  });

  final WiredSvgIconData data;
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final iconTheme = IconTheme.of(context);
    final effectiveColor = color ?? iconTheme.color ?? Colors.black;

    final preparedPaths = useMemoized(
      () => _preparePaths(data: data, iconSize: size),
      <Object?>[data, size],
    );

    return SizedBox.square(
      dimension: size,
      child: RepaintBoundary(
        child: CustomPaint(
          painter: _PrecomputedIconPainter(
            paths: preparedPaths,
            color: effectiveColor,
          ),
        ),
      ),
    );
  }
}

List<Path> _preparePaths({
  required WiredSvgIconData data,
  required double iconSize,
}) {
  final scale = math.min(iconSize / data.width, iconSize / data.height);
  final translatedWidth = data.width * scale;
  final translatedHeight = data.height * scale;
  final dx = (iconSize - translatedWidth) / 2;
  final dy = (iconSize - translatedHeight) / 2;

  final transform = Float64List.fromList(<double>[
    scale, 0, 0, 0, //
    0, scale, 0, 0,
    0, 0, 1, 0,
    dx, dy, 0, 1,
  ]);

  return data.primitives
      .map((primitive) => primitive.buildPath().transform(transform))
      .toList(growable: false);
}

final class _PrecomputedIconPainter extends CustomPainter {
  const _PrecomputedIconPainter({
    required this.paths,
    required this.color,
  });

  final List<Path> paths;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final outlinePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;

    for (final path in paths) {
      canvas
        ..drawPath(path, fillPaint)
        ..drawPath(path, outlinePaint);
    }
  }

  @override
  bool shouldRepaint(_PrecomputedIconPainter oldDelegate) {
    return oldDelegate.paths != paths || oldDelegate.color != color;
  }
}
