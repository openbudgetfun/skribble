import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:skribble_emoji/skribble_emoji.dart';

/// Renders emoji by drawing pre-parsed SVG paths directly — no rough engine.
///
/// This is the fast rendering path for performance-critical screens. For
/// runtime roughening with the Skribble rough engine, use [WiredEmoji] instead.
///
/// ```dart
/// PrecomputedEmoji(data: kSkribbleEmoji[0x1f600]!)
/// PrecomputedEmoji.fromName('grinning_face')
/// PrecomputedEmoji.fromUnicode(0x1f600)
/// ```
class PrecomputedEmoji extends HookWidget {
  /// Creates a [PrecomputedEmoji] from explicit [data].
  ///
  /// If [data] is `null`, a placeholder is shown.
  const PrecomputedEmoji({
    super.key,
    this.data,
    this.size = 24.0,
    this.color,
    this.semanticLabel,
  });

  /// Creates a [PrecomputedEmoji] by looking up the emoji [name].
  PrecomputedEmoji.fromName(
    String name, {
    super.key,
    this.size = 24.0,
    this.color,
    this.semanticLabel,
  }) : data = lookupSkribbleEmojiByName(name);

  /// Creates a [PrecomputedEmoji] by looking up the Unicode [codePoint].
  PrecomputedEmoji.fromUnicode(
    int codePoint, {
    super.key,
    this.size = 24.0,
    this.color,
    this.semanticLabel,
  }) : data = lookupSkribbleEmojiByUnicode(codePoint);

  /// The emoji data to render, or `null` to show a placeholder.
  final WiredSvgIconData? data;

  /// The logical size of the emoji. Defaults to 24.0.
  final double size;

  /// Emoji color. Falls back to [IconThemeData.color] or grey.
  final Color? color;

  /// Semantic label for accessibility.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final effectiveData = data;
    final effectiveColor =
        color ?? IconTheme.of(context).color ?? Colors.grey.shade700;

    if (effectiveData == null) {
      return _buildPlaceholder(context, effectiveColor);
    }

    final primitives = useMemoized(
      () => _preparePrimitives(data: effectiveData, emojiSize: size),
      <Object?>[effectiveData, size],
    );

    Widget child = RepaintBoundary(
      child: SizedBox.square(
        dimension: size,
        child: CustomPaint(
          painter: _PrecomputedEmojiPainter(
            primitives: primitives,
            color: effectiveColor,
            size: size,
          ),
        ),
      ),
    );

    if (semanticLabel != null && semanticLabel!.isNotEmpty) {
      child = Semantics(label: semanticLabel, image: true, child: child);
    }

    return child;
  }

  Widget _buildPlaceholder(BuildContext context, Color color) {
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(
        painter: _PlaceholderCirclePainter(color: color),
        child: Center(
          child: Text(
            '?',
            style: TextStyle(
              fontSize: size * 0.5,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
      ),
    );
  }
}

List<_PreparedPrimitive> _preparePrimitives({
  required WiredSvgIconData data,
  required double emojiSize,
}) {
  final scale = math.min(emojiSize / data.width, emojiSize / data.height);
  final translatedWidth = data.width * scale;
  final translatedHeight = data.height * scale;
  final dx = (emojiSize - translatedWidth) / 2;
  final dy = (emojiSize - translatedHeight) / 2;

  final transform = Float64List.fromList(<double>[
    scale, 0, 0, 0, //
    0, scale, 0, 0,
    0, 0, 1, 0,
    dx, dy, 0, 1,
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

final class _PrecomputedEmojiPainter extends CustomPainter {
  const _PrecomputedEmojiPainter({
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
      ..strokeWidth = math.max(0.5, size / 48)
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;

    for (final primitive in primitives) {
      canvas
        ..drawPath(primitive.path, fillPaint)
        ..drawPath(primitive.path, outlinePaint);
    }
  }

  @override
  bool shouldRepaint(_PrecomputedEmojiPainter oldDelegate) {
    return oldDelegate.primitives != primitives ||
        oldDelegate.color != color ||
        oldDelegate.size != size;
  }
}

class _PlaceholderCirclePainter extends CustomPainter {
  const _PlaceholderCirclePainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.shortestSide / 2) - 1.5;
    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(_PlaceholderCirclePainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
