import 'dart:math' as math;

import 'package:jaspr/jaspr.dart';
import 'package:skribble_jaspr/src/ink.dart';
import 'package:skribble_rough/skribble_rough.dart';

/// A point in a [WiredSketch]'s coordinate space, from its top-left corner.
typedef SketchPoint = (num x, num y);

/// A standalone hand-drawn doodle at an explicit size.
///
/// Each constructor draws one shape into an `<svg>` [width] by [height]
/// units across, using those units as its intrinsic size and `viewBox`.
/// Use it for arrows, scribbles, and annotations that the layout components
/// do not cover. CSS can resize it; strokes keep their width.
///
/// A sketch is decorative and hidden from assistive technology unless it
/// has a [label], which gives it `role="img"`.
///
/// ```dart
/// WiredSketch.curve(
///   width: 120,
///   height: 60,
///   points: [(4, 50), (40, 10), (80, 40), (116, 12)],
///   arrowhead: true,
///   label: 'Points to the sign-up form',
/// )
/// ```
class WiredSketch extends StatelessComponent {
  const WiredSketch._(
    this._draw, {
    required this.width,
    required this.height,
    this.seed = 1,
    this.roughness = 1,
    this.fill,
    this.fillStyle = RoughFillStyle.none,
    this.color,
    this.label,
    this.classes,
    super.key,
  });

  /// A rough rectangle inset [inset] units from the sketch's edges.
  factory WiredSketch.rectangle({
    required double width,
    required double height,
    double inset = 3,
    int seed = 1,
    double roughness = 1,
    String? fill,
    RoughFillStyle fillStyle = RoughFillStyle.none,
    String? color,
    String? label,
    String? classes,
    Key? key,
  }) => WiredSketch._(
    (generator) => generator.rectangle(
      inset,
      inset,
      width - inset * 2,
      height - inset * 2,
    ),
    width: width,
    height: height,
    seed: seed,
    roughness: roughness,
    fill: fill,
    fillStyle: fillStyle,
    color: color,
    label: label,
    classes: classes,
    key: key,
  );

  /// A rough ellipse inset [inset] units from the sketch's edges.
  factory WiredSketch.ellipse({
    required double width,
    required double height,
    double inset = 3,
    int seed = 1,
    double roughness = 1,
    String? fill,
    RoughFillStyle fillStyle = RoughFillStyle.none,
    String? color,
    String? label,
    String? classes,
    Key? key,
  }) => WiredSketch._(
    (generator) => generator.ellipse(
      width / 2,
      height / 2,
      width - inset * 2,
      height - inset * 2,
    ),
    width: width,
    height: height,
    seed: seed,
    roughness: roughness,
    fill: fill,
    fillStyle: fillStyle,
    color: color,
    label: label,
    classes: classes,
    key: key,
  );

  /// A rough straight line from [from] to [to], optionally ending in an
  /// [arrowhead].
  factory WiredSketch.line({
    required double width,
    required double height,
    required SketchPoint from,
    required SketchPoint to,
    bool arrowhead = false,
    int seed = 1,
    double roughness = 1,
    String? color,
    String? label,
    String? classes,
    Key? key,
  }) => WiredSketch._(
    (generator) {
      final start = _point(from);
      final end = _point(to);
      final line = generator.line(start.x, start.y, end.x, end.y);

      return arrowhead ? _withArrowhead(generator, line, start, end) : line;
    },
    width: width,
    height: height,
    seed: seed,
    roughness: roughness,
    color: color,
    label: label,
    classes: classes,
    key: key,
  );

  /// A rough closed polygon through [points].
  factory WiredSketch.polygon({
    required double width,
    required double height,
    required List<SketchPoint> points,
    int seed = 1,
    double roughness = 1,
    String? fill,
    RoughFillStyle fillStyle = RoughFillStyle.none,
    String? color,
    String? label,
    String? classes,
    Key? key,
  }) => WiredSketch._(
    (generator) => generator.polygon(points.map(_point).toList()),
    width: width,
    height: height,
    seed: seed,
    roughness: roughness,
    fill: fill,
    fillStyle: fillStyle,
    color: color,
    label: label,
    classes: classes,
    key: key,
  );

  /// A smooth rough curve through [points], optionally ending in an
  /// [arrowhead] that follows the last segment.
  ///
  /// Needs at least two points.
  factory WiredSketch.curve({
    required double width,
    required double height,
    required List<SketchPoint> points,
    bool arrowhead = false,
    int seed = 1,
    double roughness = 1,
    String? color,
    String? label,
    String? classes,
    Key? key,
  }) {
    if (points.length < 2) {
      throw ArgumentError.value(points, 'points', 'needs at least two points');
    }

    return WiredSketch._(
      (generator) {
        final path = points.map(_point).toList();
        final curve = generator.curvePath(path);

        if (!arrowhead) {
          return curve;
        }

        return _withArrowhead(
          generator,
          curve,
          path[path.length - 2],
          path.last,
        );
      },
      width: width,
      height: height,
      seed: seed,
      roughness: roughness,
      color: color,
      label: label,
      classes: classes,
      key: key,
    );
  }

  /// Intrinsic width and `viewBox` width, in CSS pixels.
  final double width;

  /// Intrinsic height and `viewBox` height, in CSS pixels.
  final double height;

  /// Chooses the wobble. The same seed always draws the same doodle.
  final int seed;

  /// How far the hand wanders from the ideal shape.
  final double roughness;

  /// The fill colour, as any CSS colour. Only closed shapes are filled.
  final String? fill;

  /// The fill pattern for closed shapes.
  final RoughFillStyle fillStyle;

  /// The ink colour, as any CSS colour. Defaults to `--skribble-ink`.
  final String? color;

  /// An accessible description. When null the sketch is decorative.
  final String? label;

  /// Extra CSS classes, added after `skribble-sketch`.
  final String? classes;

  final Drawable Function(Generator generator) _draw;

  @override
  Component build(BuildContext context) {
    final canvas = InkCanvas(width, height);
    final generator = inkGenerator(
      seed: seed,
      roughness: roughness,
      fillStyle: fillStyle,
    );
    final label = this.label;
    final style = [
      if (color case final color?) '--skribble-ink: $color',
      if (fill case final fill?) '--skribble-fill: $fill',
    ].join('; ');

    return inkSvg(
      RoughSvg.fromDrawable(_draw(generator)),
      canvas,
      classes: joinClasses(['skribble-sketch', classes]),
      stretch: false,
      decorative: label == null,
      attributes: {
        if (style.isNotEmpty) 'style': style,
        if (label != null) ...{'role': 'img', 'aria-label': label},
      },
    );
  }
}

PointD _point(SketchPoint point) =>
    PointD(point.$1.toDouble(), point.$2.toDouble());

/// Adds two short barbs at [tip], angled back along the [from] direction.
Drawable _withArrowhead(
  Generator generator,
  Drawable shaft,
  PointD from,
  PointD tip,
) {
  const spread = math.pi / 7;
  final angle = math.atan2(tip.y - from.y, tip.x - from.x);
  final length = math.min(14, from.distanceTo(tip) * 0.6);
  final barbs = [
    for (final side in [-spread, spread])
      generator.line(
        tip.x,
        tip.y,
        tip.x - length * math.cos(angle + side),
        tip.y - length * math.sin(angle + side),
      ),
  ];

  return Drawable(
    options: shaft.options,
    sets: [
      ...shaft.sets,
      for (final barb in barbs) ...barb.sets,
    ],
  );
}
