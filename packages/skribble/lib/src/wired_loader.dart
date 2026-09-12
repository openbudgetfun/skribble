import 'dart:math' as math;
import 'dart:ui' show PathMetric;

import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'doodles/doodle_geometry.dart';
import 'motion/loading_cycle.dart';
import 'wired_doodle_kind.dart';
import 'wired_theme.dart';

/// Indeterminate ink rhythms, including two drawings from [WiredDoodleKind].
enum WiredLoaderStyle {
  /// An uneven ring with a travelling pen tip.
  orbit,

  /// Three ink dots taking turns to hop.
  dots,

  /// Five bowed pencil strokes rising and falling.
  bars,

  /// Soft, expanding contour rings.
  ripple,

  /// The existing five-petal doodle turning slowly.
  flower,

  /// The existing looping flourish drawing and erasing itself.
  scribble,
}

/// An indeterminate hand-drawn loader with stable, cached curves.
///
/// Motion settles when [animating] is false, [TickerMode] is muted, or
/// reduced motion is requested. A settled drawing stays visible. Remove the
/// widget when loading finishes. Ticks repaint without rebuilding the widget.
class WiredLoader extends HookWidget {
  /// Creates a loader. [duration] is one complete loop and must be positive.
  const WiredLoader({
    super.key,
    this.style = WiredLoaderStyle.orbit,
    this.size = 48,
    this.color,
    this.strokeWidth = 2,
    this.seed = 1,
    this.duration = const Duration(milliseconds: 1800),
    this.animating = true,
    this.progress,
    this.semanticLabel = 'Loading',
  }) : assert(size >= 0 && size < double.infinity),
       assert(strokeWidth > 0 && strokeWidth < double.infinity);

  /// The ink rhythm to display.
  final WiredLoaderStyle style;

  /// Preferred square size. Smaller constraints scale the entire drawing.
  final double size;

  /// Ink color, defaulting to the theme's text color.
  final Color? color;

  /// Stroke width at the requested [size], scaled with the drawing.
  final double strokeWidth;

  /// Stable shape variation; animation never changes this seed.
  final int seed;

  /// Time for one complete loop when using the built-in clock.
  final Duration duration;

  /// Whether motion is allowed. False keeps a quiet, visible drawing.
  final bool animating;

  /// Optional caller-owned phase from zero to one. This widget never starts,
  /// stops, or disposes it. Motion preferences still take precedence.
  final Animation<double>? progress;

  /// Localizable status announcement. Null makes the drawing decorative.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    assert(duration > Duration.zero, 'duration must be positive');
    final theme = WiredTheme.of(context);
    final geometry = useMemoized(
      () =>
          _LoaderGeometry(style, seed, theme.roughness.clamp(0, 3).toDouble()),
      [style, seed, theme.roughness],
    );
    final drawing = RepaintBoundary(
      child: WiredLoadingCycle(
        duration: duration,
        animating: animating,
        progress: progress,
        builder: (context, phase) => SizedBox.square(
          dimension: size,
          child: CustomPaint(
            painter: _LoaderPainter(
              phase: phase,
              geometry: geometry,
              color: color ?? theme.textColor,
              pen: size == 0 ? 0 : strokeWidth * 100 / size,
            ),
          ),
        ),
      ),
    );

    return IgnorePointer(
      child: semanticLabel == null
          ? ExcludeSemantics(child: drawing)
          : Semantics(
              container: true,
              liveRegion: true,
              label: semanticLabel,
              child: ExcludeSemantics(child: drawing),
            ),
    );
  }
}

class _LoaderGeometry {
  _LoaderGeometry(this.style, int seed, double roughness) {
    final kind = switch (style) {
      WiredLoaderStyle.flower => WiredDoodleKind.flower,
      WiredLoaderStyle.scribble => WiredDoodleKind.scribble,
      _ => null,
    };

    if (kind != null) {
      for (final stroke in doodleGeometry(
        kind,
        seed: seed,
        amplitude: roughness,
      )) {
        final path = Path()..moveTo(stroke.start.x, stroke.start.y);

        for (final curve in stroke.curves) {
          path.cubicTo(
            curve.first.x,
            curve.first.y,
            curve.second.x,
            curve.second.y,
            curve.end.x,
            curve.end.y,
          );
        }
        paths.add(path);
      }
    } else {
      final wobble = roughness * math.sin(seed * .7);
      paths.add(
        Path()
          ..moveTo(50, 18)
          ..cubicTo(92 + wobble, 14, 94, 82, 51, 82)
          ..cubicTo(7, 86, 9 - wobble, 16, 50, 18),
      );
    }
    metrics = paths.expand((path) => path.computeMetrics()).toList();
    length = metrics.fold(0, (sum, metric) => sum + metric.length);
  }

  final WiredLoaderStyle style;
  final paths = <Path>[];
  late final List<PathMetric> metrics;
  late final double length;
}

class _LoaderPainter extends CustomPainter {
  _LoaderPainter({
    required this.phase,
    required this.geometry,
    required this.color,
    required this.pen,
  }) : super(repaint: phase);

  final Animation<double> phase;
  final _LoaderGeometry geometry;
  final Color color;
  final double pen;

  @override
  void paint(Canvas canvas, Size size) {
    final side = size.shortestSide;
    if (side <= 0 || pen <= 0) return;
    final t = phase.value.clamp(0.0, 1.0);
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = pen
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.save();
    canvas.translate((size.width - side) / 2, (size.height - side) / 2);
    canvas.scale(side / 100);
    canvas.clipRect(const Rect.fromLTWH(0, 0, 100, 100));

    switch (geometry.style) {
      case WiredLoaderStyle.orbit:
        canvas.translate(50, 50);
        canvas.rotate(t * math.pi * 2);
        canvas.translate(-50, -50);
        final metric = geometry.metrics.single;
        canvas.drawPath(metric.extractPath(0, metric.length * .76), paint);
        final tip = metric.getTangentForOffset(metric.length * .76)!.position;
        canvas.drawCircle(tip, pen * 1.4, Paint()..color = color);
      case WiredLoaderStyle.dots:
        for (var i = 0; i < 3; i++) {
          final hop = math.max(0.0, math.sin((t - i * .16) * math.pi * 2));
          canvas.save();
          canvas.translate(7 + i * 30, 34 - hop * 15);
          canvas.scale(.26);
          canvas.drawPath(
            geometry.paths.single,
            Paint()
              ..color = color.withValues(alpha: color.a * (.45 + .55 * hop)),
          );
          canvas.restore();
        }
      case WiredLoaderStyle.bars:
        for (var i = 0; i < 5; i++) {
          final height =
              12 + 42 * (.5 + .5 * math.sin(t * math.pi * 2 - i * .7));
          final x = 18.0 + i * 16;
          canvas.drawPath(
            Path()
              ..moveTo(x, 50 + height / 2)
              ..quadraticBezierTo(x + 3, 50, x - 1, 50 - height / 2),
            paint..strokeWidth = pen * 1.8,
          );
        }
      case WiredLoaderStyle.ripple:
        for (var i = 0; i < 3; i++) {
          final p = (t + i / 3) % 1;
          final scale = .15 + .95 * p;
          canvas.save();
          canvas.translate(50 * (1 - scale), 50 * (1 - scale));
          canvas.scale(scale);
          canvas.drawPath(
            geometry.paths.single,
            paint
              ..strokeWidth = pen / scale
              ..color = color.withValues(alpha: color.a * (1 - p) * .75),
          );
          canvas.restore();
        }
      case WiredLoaderStyle.flower:
        canvas.translate(50, 50);
        canvas.rotate(t * math.pi * 2);
        canvas.scale(.82);
        canvas.translate(-50, -50);
        for (final path in geometry.paths) {
          canvas.drawPath(
            path,
            Paint()..color = color.withValues(alpha: color.a * .10),
          );
          canvas.drawPath(path, paint);
        }
      case WiredLoaderStyle.scribble:
        final amount = .12 + .88 * (.5 - .5 * math.cos(t * math.pi * 2));
        var remaining = geometry.length * amount;
        for (final metric in geometry.metrics) {
          canvas.drawPath(
            metric.extractPath(0, remaining.clamp(0, metric.length)),
            paint,
          );
          remaining = math.max(0, remaining - metric.length);
        }
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_LoaderPainter oldDelegate) =>
      phase != oldDelegate.phase ||
      geometry != oldDelegate.geometry ||
      color != oldDelegate.color ||
      pen != oldDelegate.pen;
}
