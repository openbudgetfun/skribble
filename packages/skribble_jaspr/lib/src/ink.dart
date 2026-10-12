import 'package:jaspr/jaspr.dart';
import 'package:skribble_rough/skribble_rough.dart';

/// The closed shapes the stretched ink overlays can draw.
enum InkShape {
  /// A rough rectangle.
  rectangle,

  /// A rough ellipse touching the middle of each side.
  ellipse,
}

/// A coordinate system for ink that is later stretched to its element.
///
/// Server rendering cannot measure elements, so shapes are drawn into a
/// nominal [width] by [height] box and the `<svg>` stretches with
/// `preserveAspectRatio="none"`. Choosing a nominal size near the element's
/// usual proportions keeps the wobble from looking squashed.
final class InkCanvas {
  /// Creates a nominal canvas.
  const InkCanvas(this.width, this.height, {this.inset = 3, this.gap = 8});

  /// Nominal width, in SVG user units.
  final double width;

  /// Nominal height, in SVG user units.
  final double height;

  /// Distance from the canvas edge to the ideal outline, which leaves room
  /// for the wobble.
  final double inset;

  /// Distance between sketched fill lines.
  final double gap;

  /// The `viewBox` attribute for this canvas.
  String get viewBox => '0 0 ${_number(width)} ${_number(height)}';
}

/// Creates a generator whose outline and fill both replay from [seed].
///
/// The fill gets its own configuration because fillers that share
/// [FillerConfig.defaultConfig] advance one global random stream.
Generator inkGenerator({
  required int seed,
  double roughness = 1,
  RoughFillStyle fillStyle = RoughFillStyle.none,
  double gap = 8,
}) {
  return Generator(
    DrawConfig.build(seed: seed, roughness: roughness),
    fillStyle.filler(
      FillerConfig.build(
        drawConfig: DrawConfig.build(seed: seed, roughness: roughness),
        hachureGap: gap,
      ),
    ),
  );
}

/// Draws [shape] inset inside [canvas].
RoughSvg drawInkShape(
  InkShape shape,
  InkCanvas canvas, {
  required int seed,
  double roughness = 1,
  RoughFillStyle fillStyle = RoughFillStyle.none,
}) {
  final generator = inkGenerator(
    seed: seed,
    roughness: roughness,
    fillStyle: fillStyle,
    gap: canvas.gap,
  );
  final inset = canvas.inset;
  final width = canvas.width - inset * 2;
  final height = canvas.height - inset * 2;
  final drawable = switch (shape) {
    InkShape.rectangle => generator.rectangle(inset, inset, width, height),
    InkShape.ellipse => generator.ellipse(
      canvas.width / 2,
      canvas.height / 2,
      width,
      height,
    ),
  };

  return RoughSvg.fromDrawable(drawable);
}

/// Renders [ink] as a decorative `<svg>`.
///
/// With [stretch] the SVG fills its positioned parent and distorts to fit,
/// while `vector-effect="non-scaling-stroke"` keeps every stroke at its CSS
/// width. Without it, the SVG keeps [canvas] as its intrinsic size.
///
/// The paths carry `currentColor` presentation attributes so they still draw
/// without `skribbleCss`; the stylesheet then maps them to the theme's
/// custom properties.
Component inkSvg(
  RoughSvg ink,
  InkCanvas canvas, {
  String classes = 'skribble-ink',
  bool stretch = true,
  bool decorative = true,
  Map<String, String> attributes = const {},
}) {
  final svgAttributes = <String, String>{
    'viewBox': canvas.viewBox,
    if (stretch) 'preserveAspectRatio': 'none',
    if (!stretch) 'width': _number(canvas.width),
    if (!stretch) 'height': _number(canvas.height),
    if (decorative) 'aria-hidden': 'true',
    'focusable': 'false',
    ...attributes,
  };

  return Component.element(
    tag: 'svg',
    classes: classes,
    attributes: svgAttributes,
    children: [
      if (ink.solid.isNotEmpty)
        _path('skribble-ink-solid', ink.solid, fill: 'currentColor'),
      if (ink.sketch.isNotEmpty)
        _path('skribble-ink-hatch', ink.sketch, stroke: 'currentColor'),
      if (ink.outline.isNotEmpty)
        _path('skribble-ink-outline', ink.outline, stroke: 'currentColor'),
    ],
  );
}

/// Joins [classes] into one attribute value, skipping null and empty entries.
String joinClasses(Iterable<String?> classes) => classes
    .whereType<String>()
    .where((value) => value.trim().isNotEmpty)
    .join(' ');

Component _path(
  String classes,
  String data, {
  String fill = 'none',
  String stroke = 'none',
}) {
  final stroked = stroke != 'none';

  return Component.element(
    tag: 'path',
    classes: classes,
    attributes: {
      'd': data,
      'fill': fill,
      'stroke': stroke,
      if (stroked) 'stroke-width': '2',
      if (stroked) 'stroke-linecap': 'round',
      if (stroked) 'stroke-linejoin': 'round',
      if (stroked) 'vector-effect': 'non-scaling-stroke',
    },
  );
}

String _number(double value) =>
    value == value.roundToDouble() ? '${value.toInt()}' : '$value';
