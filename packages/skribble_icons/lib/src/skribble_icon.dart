import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:skribble/skribble.dart';

/// Renders a pre-computed roughened SVG icon efficiently.
///
/// Unlike [WiredSvgIcon], which applies the rough engine at runtime, this
/// widget simply paints pre-baked rough paths — making it faster and more
/// predictable.
///
/// ```dart
/// SkribbleIcon(data: kSkribbleCustomIconsRough[0xf001]!)
/// ```
class SkribbleIcon extends HookWidget {
  const SkribbleIcon({
    required this.data,
    super.key,
    this.size,
    this.color,
    this.semanticLabel,
  });

  /// Pre-computed icon data containing roughened SVG paths.
  final WiredSvgIconData data;

  /// Desired icon size in logical pixels. Falls back to [IconThemeData.size]
  /// or 24.
  final double? size;

  /// Icon color. Falls back to [IconThemeData.color] or the current
  /// [WiredThemeData.textColor].
  final Color? color;

  /// Semantic label for accessibility.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final iconTheme = IconTheme.of(context);
    final wiredTheme = WiredTheme.of(context);
    final effectiveSize = size ?? iconTheme.size ?? 24;
    final effectiveColor = color ?? iconTheme.color ?? wiredTheme.textColor;

    final primitives = useMemoized(
      () => _preparePrimitives(data: data, iconSize: effectiveSize),
      <Object?>[data, effectiveSize],
    );

    Widget child = RepaintBoundary(
      child: SizedBox.square(
        dimension: effectiveSize,
        child: CustomPaint(
          painter: _SkribbleIconPainter(
            primitives: primitives,
            color: effectiveColor,
            size: effectiveSize,
          ),
        ),
      ),
    );

    if (semanticLabel != null && semanticLabel!.isNotEmpty) {
      child = Semantics(label: semanticLabel, image: true, child: child);
    }

    return child;
  }
}

List<_PreparedPrimitive> _preparePrimitives({
  required WiredSvgIconData data,
  required double iconSize,
}) {
  final scale = math.min(iconSize / data.width, iconSize / data.height);
  final translatedWidth = data.width * scale;
  final translatedHeight = data.height * scale;
  final dx = (iconSize - translatedWidth) / 2;
  final dy = (iconSize - translatedHeight) / 2;

  final transform = Float64List.fromList(<double>[
    scale,
    0,
    0,
    0,
    0,
    scale,
    0,
    0,
    0,
    0,
    1,
    0,
    dx,
    dy,
    0,
    1,
  ]);

  return data.primitives
      .map(
        (primitive) =>
            _PreparedPrimitive(path: primitive.buildPath().transform(transform)),
      )
      .toList(growable: false);
}

final class _PreparedPrimitive {
  const _PreparedPrimitive({required this.path});

  final Path path;
}

final class _SkribbleIconPainter extends CustomPainter {
  const _SkribbleIconPainter({
    required this.primitives,
    required this.color,
    required this.size,
  });

  final List<_PreparedPrimitive> primitives;
  final Color color;
  final double size;

  @override
  void paint(Canvas canvas, Size canvasSize) {
    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final outlinePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(0.5, size / 32)
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;

    for (final primitive in primitives) {
      canvas
        ..drawPath(primitive.path, fillPaint)
        ..drawPath(primitive.path, outlinePaint);
    }
  }

  @override
  bool shouldRepaint(_SkribbleIconPainter oldDelegate) {
    return oldDelegate.primitives != primitives ||
        oldDelegate.color != color ||
        oldDelegate.size != size;
  }
}
