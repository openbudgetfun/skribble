import 'dart:math' as math;

import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:skribble_rough/skribble_rough.dart';

/// The three roughness presets skribble's Flutter themes ship with.
///
/// Values mirror `WiredThemeData`'s gentle, playful, and expressive pens so
/// the landing page draws with the same hand as the widgets it advertises.
enum Pen {
  /// Calm lines for dense, readable screens.
  gentle(roughness: 1.25, maxRandomnessOffset: 1.2, lineWobble: 0),

  /// The default: lively but tidy.
  playful(roughness: 1.5, maxRandomnessOffset: 1.6, lineWobble: 0.65),

  /// Loose, energetic lines for splash screens and games.
  expressive(roughness: 1.8, maxRandomnessOffset: 2, lineWobble: 1);

  const Pen({
    required this.roughness,
    required this.maxRandomnessOffset,
    required this.lineWobble,
  });

  /// How far the hand wanders from the ideal line.
  final double roughness;

  /// The largest random nudge applied to a point.
  final double maxRandomnessOffset;

  /// Low-frequency drift along long strokes.
  final double lineWobble;

  /// A draw configuration for this pen that replays from [seed].
  DrawConfig config(int seed) => DrawConfig.build(
    seed: seed,
    roughness: roughness,
    maxRandomnessOffset: maxRandomnessOffset,
    lineWobble: lineWobble,
  );

  /// A generator for this pen whose outline and fill both replay from [seed].
  Generator generator(
    int seed, {
    RoughFillStyle fill = RoughFillStyle.none,
    double gap = 8,
    double angle = 320,
  }) {
    return Generator(
      config(seed),
      fill.filler(
        FillerConfig.build(
          drawConfig: config(seed),
          hachureGap: gap,
          hachureAngle: angle,
          dashOffset: gap,
          zigzagOffset: gap * 0.6,
        ),
      ),
    );
  }
}

/// A named colour from the site palette, used as an SVG paint.
enum Tone {
  /// Plum ink: outlines and lettering.
  ink,

  /// Secondary copy and quiet rules.
  quiet,

  /// The filled-action accent.
  coral,

  /// Marker yellow.
  sun,

  /// Pale purple.
  lilac,

  /// Pale green.
  mint,

  /// Pale blue.
  sky,

  /// Bubblegum pink.
  pink,

  /// The page's paper colour.
  paper,

  /// Quiet rules: chart grids and volume bars.
  rule,

  /// A rising candle's green.
  rise,

  /// A falling candle's red.
  fall;

  /// The CSS custom property holding this tone.
  String get paint => 'var(--$name)';
}

/// One rough shape inside a [doodle], with the tones it is painted in.
final class Mark {
  /// Creates a mark from a generated [drawable].
  const Mark(
    this.drawable, {
    this.stroke = Tone.ink,
    this.fill = Tone.coral,
    this.width = 2,
    this.fillWidth = 1.4,
    this.classes,
  });

  /// The shape, as produced by a [Generator].
  final Drawable drawable;

  /// Paint for the outline.
  final Tone stroke;

  /// Paint for sketched and solid fills.
  final Tone fill;

  /// Outline width in the doodle's own units.
  final double width;

  /// Width of sketched fill lines.
  final double fillWidth;

  /// Extra classes on this mark's `<g>`, for targeted animation.
  final String? classes;
}

/// Renders [marks] as an inline SVG that can draw itself on.
///
/// Every stroked path gets `pathLength="1"`, so the stylesheet can animate
/// `stroke-dashoffset` from 1 to 0 regardless of the path's real length.
/// Each mark is staggered through the `--i` custom property. When [label]
/// is null the drawing is decorative and hidden from assistive technology.
///
/// With [stretch] the SVG fills its positioned parent; keep the parent close
/// to [width] by [height] so strokes are not visibly squashed.
Component doodle({
  required double width,
  required double height,
  required List<Mark> marks,
  String? classes,
  String? label,
  bool stretch = false,
  Map<String, String> attributes = const {},
}) {
  final svg = StringBuffer()
    ..write('<svg xmlns="http://www.w3.org/2000/svg" ')
    ..write(
      'class="${['ink', if (stretch) 'ink--stretch', ?classes].join(' ')}" ',
    )
    ..write('viewBox="0 0 ${_n(width)} ${_n(height)}" ');

  if (stretch) {
    svg.write('preserveAspectRatio="none" ');
  } else {
    svg.write('width="${_n(width)}" height="${_n(height)}" ');
  }

  if (label == null) {
    svg.write('aria-hidden="true" focusable="false"');
  } else {
    svg.write('role="img" aria-label="${_escape(label)}"');
  }

  for (final MapEntry(:key, :value) in attributes.entries) {
    svg.write(' $key="${_escape(value)}"');
  }

  svg.write('>');

  for (final (index, mark) in marks.indexed) {
    final ink = RoughSvg.fromDrawable(mark.drawable);
    final solid = _compact(ink.solid);
    final sketch = _compact(ink.sketch);
    final outline = _compact(ink.outline);
    final group = ['mark', ?mark.classes].join(' ');
    svg.write('<g class="$group" style="--i:$index">');

    if (solid.isNotEmpty) {
      svg.write(
        '<path class="ink-solid" d="$solid" '
        'fill="${mark.fill.paint}" stroke="none"/>',
      );
    }

    if (sketch.isNotEmpty) {
      svg.write(
        '<path class="ink-hatch" d="$sketch" pathLength="1" '
        'fill="none" stroke="${mark.fill.paint}" '
        'stroke-width="${_n(mark.fillWidth)}" '
        'stroke-linecap="round" stroke-linejoin="round"/>',
      );
    }

    if (outline.isNotEmpty) {
      svg.write(
        '<path class="ink-line" d="$outline" pathLength="1" '
        'fill="none" stroke="${mark.stroke.paint}" '
        'stroke-width="${_n(mark.width)}" '
        'stroke-linecap="round" stroke-linejoin="round"/>',
      );
    }

    svg.write('</g>');
  }

  svg.write('</svg>');

  return RawText(svg.toString());
}

/// Renders one drawing once per pen in [pens].
///
/// With several pens, each copy carries `pen pen--<name>` classes so the
/// stylesheet can show whichever pen the nearest `data-pen` attribute
/// selects. With a single pen the drawing renders once, unclassed.
Component penDoodle({
  required double width,
  required double height,
  required List<Mark> Function(Pen pen) marks,
  List<Pen> pens = Pen.values,
  String? classes,
  bool stretch = false,
}) {
  if (pens.length == 1) {
    return doodle(
      width: width,
      height: height,
      stretch: stretch,
      classes: classes,
      marks: marks(pens.single),
    );
  }

  return Component.fragment([
    for (final pen in pens)
      doodle(
        width: width,
        height: height,
        stretch: stretch,
        classes: ['pen', 'pen--${pen.name}', ?classes].join(' '),
        marks: marks(pen),
      ),
  ]);
}

/// A rough rectangle inset by [inset] inside a [width] by [height] canvas.
Drawable roughBox(
  Generator g,
  double width,
  double height, {
  double inset = 3,
}) => g.rectangle(inset, inset, width - inset * 2, height - inset * 2);

/// A rough ellipse inset by [inset] inside a [width] by [height] canvas.
Drawable roughOval(
  Generator g,
  double width,
  double height, {
  double inset = 3,
}) => g.ellipse(width / 2, height / 2, width - inset * 2, height - inset * 2);

/// A smooth rough curve through [points].
Drawable roughCurve(Generator g, List<(num, num)> points) => g.curvePath([
  for (final (x, y) in points) PointD(x.toDouble(), y.toDouble()),
]);

/// A rough curve through [points] ending in two arrowhead barbs.
List<Drawable> roughArrow(Generator g, List<(num, num)> points) {
  final path = [
    for (final (x, y) in points) PointD(x.toDouble(), y.toDouble()),
  ];
  final tip = path.last;
  final from = path[path.length - 2];
  final angle = math.atan2(tip.y - from.y, tip.x - from.x);
  const spread = math.pi / 6;
  const length = 13.0;

  return [
    g.curvePath(path),
    for (final side in [-1, 1])
      g.line(
        tip.x,
        tip.y,
        tip.x - length * math.cos(angle + side * spread),
        tip.y - length * math.sin(angle + side * spread),
      ),
  ];
}

/// A five-pointed star centred on ([cx], [cy]).
Drawable roughStar(Generator g, double cx, double cy, double radius) {
  return g.polygon([
    for (var i = 0; i < 10; i++)
      PointD(
        cx +
            (i.isEven ? radius : radius * 0.45) *
                math.cos(-math.pi / 2 + i * math.pi / 5),
        cy +
            (i.isEven ? radius : radius * 0.45) *
                math.sin(-math.pi / 2 + i * math.pi / 5),
      ),
  ]);
}

/// A heart that fits a [size] square at ([x], [y]).
Drawable roughHeart(Generator g, double x, double y, double size) {
  return g.curvePath([
    PointD(x + size / 2, y + size * 0.95),
    PointD(x + size * 0.08, y + size * 0.5),
    PointD(x + size * 0.12, y + size * 0.15),
    PointD(x + size * 0.38, y + size * 0.08),
    PointD(x + size / 2, y + size * 0.3),
    PointD(x + size * 0.62, y + size * 0.08),
    PointD(x + size * 0.88, y + size * 0.15),
    PointD(x + size * 0.92, y + size * 0.5),
    PointD(x + size / 2, y + size * 0.95),
  ]);
}

/// A loopy squiggle across a [width] by [height] canvas.
Drawable roughSquiggle(
  Generator g,
  double width,
  double height, {
  int loops = 4,
}) {
  final step = width / (loops * 2);

  return g.curvePath([
    for (var i = 0; i <= loops * 2; i++)
      PointD(4 + i * step * 0.96, i.isEven ? height * 0.7 : height * 0.3),
  ]);
}

/// Rounds path coordinates to one decimal place. Doodles are drawn at
/// roughly their on-screen size, so tenths of a pixel are invisible, and
/// the page ships a third less markup.
String _compact(String path) => path.replaceAllMapped(
  _longNumber,
  (match) =>
      double.parse(match[0]!).toStringAsFixed(1).replaceFirst(_zeroTenth, ''),
);

final _longNumber = RegExp(r'-?\d+\.\d{2,}');
final _zeroTenth = RegExp(r'\.0$');

String _n(double value) => value == value.roundToDouble()
    ? '${value.toInt()}'
    : value.toStringAsFixed(2);

String _escape(String value) => value
    .replaceAll('&', '&amp;')
    .replaceAll('"', '&quot;')
    .replaceAll('<', '&lt;')
    .replaceAll('>', '&gt;');
