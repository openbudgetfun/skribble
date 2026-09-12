import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:latlong2/latlong.dart' show LatLng;
import 'package:skribble/skribble.dart';
import 'package:skribble_maps/src/wired_map_camera.dart';

/// Translucent treatments for the direction in which the device faces.
enum WiredMapHeadingStyle {
  /// A soft blue wash fading towards the edge.
  wash,

  /// Spaced pencil strokes with open space between them.
  hatching,

  /// A lighter wash beneath sparse pencil strokes.
  washAndHatching,
}

/// A hand-drawn current-location dot with an optional direction fan.
///
/// The geographic anchor is always the center of the square, including when
/// [heading] changes. This decorative widget passes pointer events through.
/// It does not request device permissions or subscribe to sensors.
class WiredMapLocation extends HookWidget {
  /// Creates a location indicator with a stable, seedable outline.
  const WiredMapLocation({
    super.key,
    this.heading,
    this.headingStyle = WiredMapHeadingStyle.washAndHatching,
    this.size = 128,
    this.color = const Color(0xFF3478E5),
    this.seed = 37,
    this.semanticLabel = 'Current location',
  }) : assert(
         size > 0 && size < double.infinity,
         'size must be positive and finite',
       ),
       assert(
         heading == null ||
             (heading > -double.infinity && heading < double.infinity),
         'heading must be finite or null',
       );

  /// Clockwise degrees from true north. Null hides the fan.
  ///
  /// Values wrap at 360 degrees. Supply a true-north sensor heading, not the
  /// direction of travel. Updates are immediate, without rotation overshoot.
  final double? heading;

  /// The translucent treatment used for the fan.
  final WiredMapHeadingStyle headingStyle;

  /// Square extent in logical pixels. The dot diameter is one sixth of this.
  final double size;

  /// Blue ink by default. Its alpha also scales the fan's transparency.
  final Color color;

  /// Seed for the outline, stable across position and heading updates.
  final int seed;

  /// Localizable accessibility description; null omits the description.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    return buildWiredElement(
      child: Semantics(
        label: semanticLabel,
        child: IgnorePointer(
          child: SizedBox.square(
            dimension: size,
            child: WiredCanvas(
              drawConfig: DrawConfig.build(seed: seed),
              fillerType: RoughFilter.noFiller,
              painter: _LocationPainter(
                heading: heading,
                style: headingStyle,
                color: color,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Anchors the current location to a coordinate inside `WiredMap.children`.
///
/// Rebuild with sensor values supplied by the consuming application. Omit this
/// layer when a location fix is unavailable. The map remains north-up.
class WiredMapLocationLayer extends HookWidget {
  /// Creates a non-interactive location layer.
  const WiredMapLocationLayer({
    required this.point,
    super.key,
    this.heading,
    this.headingStyle = WiredMapHeadingStyle.washAndHatching,
    this.size = 128,
    this.color = const Color(0xFF3478E5),
    this.seed = 37,
    this.semanticLabel = 'Current location',
  }) : assert(
         size > 0 && size < double.infinity,
         'size must be positive and finite',
       ),
       assert(
         heading == null ||
             (heading > -double.infinity && heading < double.infinity),
         'heading must be finite or null',
       );

  /// Current geographic position, supplied by the app.
  final LatLng point;

  /// Clockwise degrees from true north; null hides the fan.
  final double? heading;

  /// The translucent treatment used for the fan.
  final WiredMapHeadingStyle headingStyle;

  /// Indicator extent in logical pixels, independent of map zoom.
  final double size;

  /// Ink color of the dot and fan.
  final Color color;

  /// Stable seed for the hand-drawn outline.
  final int seed;

  /// Localizable accessibility description; null omits the description.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final offset = wiredMapCameraOf(context).project(point);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          left: offset.dx - size / 2,
          top: offset.dy - size / 2,
          width: size,
          height: size,
          child: WiredMapLocation(
            heading: heading,
            headingStyle: headingStyle,
            size: size,
            color: color,
            seed: seed,
            semanticLabel: semanticLabel,
          ),
        ),
      ],
    );
  }
}

/// Paints in a fixed coordinate plane so tight constraints scale all ink.
class _LocationPainter extends WiredPainterBase {
  _LocationPainter({
    required this.heading,
    required this.style,
    required this.color,
  });

  final double? heading;
  final WiredMapHeadingStyle style;
  final Color color;

  @override
  void paintRough(
    Canvas canvas,
    Size size,
    DrawConfig drawConfig,
    Filler filler,
  ) {
    final scale = size.shortestSide / 128;
    final random = math.Random(drawConfig.seed);
    final lean = (random.nextDouble() - 0.5) * 1.6;
    final dot = Path()
      ..moveTo(0, -10.5)
      ..cubicTo(6 + lean, -11.4, 11.1, -5, 10.4, 0.5)
      ..cubicTo(10, 7, 4, 11.1, -1, 10.3)
      ..cubicTo(-7, 10, -11.2, 5, -10.5, -0.7)
      ..cubicTo(-10.1, -6, -5 + lean, -10.9, 0, -10.5)
      ..close();

    canvas
      ..save()
      ..translate(size.width / 2, size.height / 2)
      ..scale(scale);

    if (heading case final heading?) {
      canvas
        ..save()
        ..rotate((heading % 360) * math.pi / 180);
      _paintFan(canvas, lean);
      canvas.restore();
    }

    canvas
      ..drawPath(dot, Paint()..color = color)
      ..drawPath(
        dot,
        Paint()
          ..color = const Color(0xFFFFFFFF)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3,
      )
      ..drawPath(
        Path()
          ..moveTo(-7.6, -1)
          ..cubicTo(-8, -5.4, -4.3, -8.3, -0.5, -8.1),
        Paint()
          ..color = const Color(0xFFFFFFFF).withValues(alpha: 0.55)
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeWidth = 1.2,
      )
      ..restore();
  }

  void _paintFan(Canvas canvas, double lean) {
    final fan = Path()
      ..moveTo(0, 0)
      ..lineTo(-37, -43)
      ..cubicTo(-20, -59 + lean, 18, -60, 37, -43)
      ..close();
    final washAlpha = style == WiredMapHeadingStyle.wash ? 0.24 : 0.12;
    final wash = Paint()
      ..shader = RadialGradient(
        colors: [
          color.withValues(alpha: color.a * washAlpha),
          color.withValues(alpha: 0),
        ],
        stops: const [0.15, 1],
      ).createShader(const Rect.fromLTRB(-62, -62, 62, 62));
    final pencil = Paint()
      ..shader = LinearGradient(
        colors: [
          color.withValues(alpha: color.a * 0.32),
          color.withValues(alpha: 0.025 * color.a),
        ],
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
      ).createShader(const Rect.fromLTRB(-40, -59, 40, 0))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.15
      ..strokeCap = StrokeCap.round;

    if (style != WiredMapHeadingStyle.hatching) {
      canvas.drawPath(fan, wash);
    }

    if (style == WiredMapHeadingStyle.wash) return;

    canvas
      ..save()
      ..clipPath(fan);

    for (var y = -95.0; y < 35; y += 7) {
      canvas.drawPath(
        Path()
          ..moveTo(-42, y)
          ..quadraticBezierTo(lean, y - 17, 42, y - 37),
        pencil,
      );
    }

    canvas.restore();
  }
}
