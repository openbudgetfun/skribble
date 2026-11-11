import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'motion/wired_boil.dart';
import 'motion/wired_curves.dart';
import 'motion/wired_draw.dart';
import 'motion/wired_motion.dart';
import 'wired_theme.dart';
import 'wired_theme_scope.dart';

/// How a [WiredHighlight] marks its child.
enum WiredHighlightStyle {
  /// Two broad, overlapping highlighter strokes behind the whole child.
  marker,

  /// One confident pen stroke under the child.
  underline,
}

/// Marks a word or phrase with a hand-drawn highlighter swipe or underline
/// that draws itself on, left to right (right to left in RTL text).
///
/// ```dart
/// Text.rich(TextSpan(children: [
///   TextSpan(text: 'Make it '),
///   WidgetSpan(child: WiredHighlight(child: Text('pop'))),
/// ]))
/// ```
///
/// The swipe is the theme's `markerColor` unless [color] is set; use
/// `theme.accentAt(i)` for a run of colourful highlights. On a marker swipe
/// the child is inked with [WiredThemeData.inkOn], so it stays legible on
/// any colour. With [animate] it draws on once when mounted, after [delay];
/// otherwise it follows an enclosing `WiredDraw` or `WiredEntrance`, and is
/// simply drawn without one. With motion off it is drawn at once.
class WiredHighlight extends HookWidget {
  /// Creates a highlight around [child].
  const WiredHighlight({
    super.key,
    required this.child,
    this.color,
    this.style = WiredHighlightStyle.marker,
    this.animate = true,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 560),
    this.padding = const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
    this.seed = 1,
  });

  /// The highlighted content, usually a [Text].
  final Widget child;

  /// The highlighter's colour. Defaults to the theme's `markerColor` for
  /// [WiredHighlightStyle.marker] and its `accentColor` for
  /// [WiredHighlightStyle.underline].
  final Color? color;

  /// A broad marker swipe, or an underline.
  final WiredHighlightStyle style;

  /// Whether the highlight draws itself on when mounted.
  final bool animate;

  /// How long to wait before drawing, with [animate].
  final Duration delay;

  /// How long the stroke takes to draw, with [animate].
  final Duration duration;

  /// Space between the child and the edge of the swipe.
  final EdgeInsetsGeometry padding;

  /// Varies the hand behind the strokes.
  final int seed;

  @override
  Widget build(BuildContext context) {
    final theme = WiredTheme.of(context);
    final motion = WiredMotion.enabledOf(context);
    final ambient = WiredDrawTransition.progressOf(context);
    final controller = useAnimationController(
      duration: delay + duration,
      initialValue: animate && motion ? 0 : 1,
    );
    useEffect(() {
      if (!animate || !motion) {
        controller.value = 1;
      } else if (controller.value == 0) {
        controller.forward();
      }
      return null;
    }, [animate, motion]);
    final total = (delay + duration).inMicroseconds;
    final own = useMemoized(
      () => controller.drive(
        CurveTween(
          curve: Interval(
            total == 0 ? 0 : delay.inMicroseconds / total,
            1,
            curve: WiredCurves.pen,
          ),
        ),
      ),
      [controller, delay, duration],
    );
    final Animation<double> progress = !animate && ambient != null
        ? ambient
        : own;
    final swipe =
        color ??
        (style == WiredHighlightStyle.marker
            ? theme.markerColor
            : theme.accentColor);
    final rtl = Directionality.maybeOf(context) == TextDirection.rtl;
    Widget content = Padding(padding: padding, child: child);
    if (style == WiredHighlightStyle.marker) {
      final ink = theme.inkOn(swipe);
      if (!identical(ink, theme)) {
        content = WiredThemeScope(data: ink, child: content);
      }
    }
    return CustomPaint(
      painter: _HighlightPainter(
        progress: progress,
        color: swipe,
        style: style,
        seed: seed + WiredBoil.seedOffsetOf(context),
        strokeWidth: theme.strokeWidth,
        rtl: rtl,
      ),
      child: content,
    );
  }
}

class _HighlightPainter extends CustomPainter {
  _HighlightPainter({
    required this.progress,
    required this.color,
    required this.style,
    required this.seed,
    required this.strokeWidth,
    required this.rtl,
  }) : super(repaint: progress);

  final Animation<double> progress;
  final Color color;
  final WiredHighlightStyle style;
  final int seed;
  final double strokeWidth;
  final bool rtl;

  @override
  void paint(Canvas canvas, Size size) {
    final t = progress.value.clamp(0.0, 1.0);
    if (t == 0 || size.isEmpty) return;
    final random = math.Random(seed);
    double jitter(double amount) => (random.nextDouble() * 2 - 1) * amount;

    canvas.save();
    final reveal = size.width * t + 8;
    canvas.clipRect(
      rtl
          ? Rect.fromLTRB(
              size.width - reveal,
              -size.height,
              size.width + 8,
              size.height * 2,
            )
          : Rect.fromLTRB(-8, -size.height, reveal, size.height * 2),
    );
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    if (style == WiredHighlightStyle.marker) {
      // Two overlapping passes of a broad chisel marker, each a little
      // tilted, cover the child the way a hurried highlighter does.
      final band = size.height * 0.62;
      paint.strokeWidth = band;
      for (final (index, centre) in [0.36, 0.64].indexed) {
        final y = size.height * centre;
        final tilt = jitter(size.height * 0.08);
        final path = Path()
          ..moveTo(band * 0.25 + jitter(2), y - tilt + jitter(1.5));
        final steps = math.max(2, (size.width / 40).ceil());
        for (var i = 1; i <= steps; i++) {
          final x = band * 0.25 + (size.width - band * 0.5) * i / steps;
          path.lineTo(
            x + jitter(1.5),
            y + tilt * (2 * i / steps - 1) + jitter(1.5),
          );
        }
        paint.color = color.withValues(alpha: index == 0 ? 0.92 : 0.8);
        canvas.drawPath(path, paint);
      }
    } else {
      paint.strokeWidth = math.max(strokeWidth * 2, size.height * 0.08);
      final y = size.height - paint.strokeWidth / 2;
      final path = Path()..moveTo(2 + jitter(2), y + jitter(1.5));
      path.cubicTo(
        size.width * 0.3,
        y - 2 + jitter(2),
        size.width * 0.65,
        y + 1 + jitter(2),
        size.width - 2 + jitter(2),
        y - 3 + jitter(1.5),
      );
      canvas.drawPath(path, paint);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_HighlightPainter oldDelegate) =>
      progress != oldDelegate.progress ||
      color != oldDelegate.color ||
      style != oldDelegate.style ||
      seed != oldDelegate.seed ||
      strokeWidth != oldDelegate.strokeWidth ||
      rtl != oldDelegate.rtl;
}
