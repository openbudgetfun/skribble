import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:skribble/skribble.dart' show WiredSvgIcon;
import 'package:skribble_emoji/skribble_emoji.dart';

/// Renders a hand-drawn emoji from [WiredSvgIconData].
///
/// When [data] is `null` (e.g. the requested emoji has not been generated yet),
/// a placeholder is rendered: a "?" character inside a hand-drawn circle.
///
/// Named constructors [WiredEmoji.fromName] and [WiredEmoji.fromUnicode]
/// provide convenient lookup-based construction.
class WiredEmoji extends HookWidget {
  /// Creates a [WiredEmoji] from explicit [data].
  ///
  /// If [data] is `null`, a placeholder is shown.
  const WiredEmoji({
    super.key,
    this.data,
    this.size = 24.0,
  });

  /// Creates a [WiredEmoji] by looking up the emoji [name] in
  /// [kSkribbleEmojiCodePoints].
  ///
  /// If the name is not found, a placeholder is rendered.
  WiredEmoji.fromName(
    String name, {
    super.key,
    this.size = 24.0,
  }) : data = lookupSkribbleEmojiByName(name);

  /// Creates a [WiredEmoji] by looking up the Unicode [codePoint] in
  /// [kSkribbleEmoji].
  ///
  /// If the codepoint is not found, a placeholder is rendered.
  WiredEmoji.fromUnicode(
    int codePoint, {
    super.key,
    this.size = 24.0,
  }) : data = lookupSkribbleEmojiByUnicode(codePoint);

  /// The emoji icon data to render, or `null` to show a placeholder.
  final WiredSvgIconData? data;

  /// The logical size of the emoji. Defaults to 24.0.
  final double size;

  @override
  Widget build(BuildContext context) {
    final effectiveData = data;

    if (effectiveData != null) {
      return WiredSvgIcon(
        data: effectiveData,
        size: size,
      );
    }

    // Placeholder: hand-drawn circle with "?" text.
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(
        painter: _PlaceholderCirclePainter(
          color: IconTheme.of(context).color ?? Colors.grey,
        ),
        child: Center(
          child: Text(
            '?',
            style: TextStyle(
              fontSize: size * 0.5,
              fontWeight: FontWeight.bold,
              color: IconTheme.of(context).color ?? Colors.grey,
            ),
          ),
        ),
      ),
    );
  }
}

/// Paints a rough circle outline for the emoji placeholder.
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
