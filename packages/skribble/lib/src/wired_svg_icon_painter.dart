import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/widgets.dart';

import 'canvas/wired_waver.dart';
import 'rough/skribble_rough.dart';
import 'wired_svg_icon_data.dart';

/// Fill strategy used by `WiredSvgIcon` and `WiredIcon`.
///
/// Applies to silhouettes drawn in the ambient icon colour. Artwork with its
/// own colours, and icons drawn as strokes, keep their authored paint.
enum WiredIconFillStyle {
  /// The silhouette's outline only, inked with the theme pen.
  none,

  /// A solid silhouette.
  solid,

  /// Parallel pen strokes inside the silhouette, plus its outline.
  hachure,

  /// Two crossing sets of pen strokes inside the silhouette, plus its outline.
  crossHatch,
}

/// Converts a Flutter icon weight (100–700, normal 400) into a pen multiplier.
///
/// Normal is 1. Thin (100) halves the pen and bold (700) draws it 1.75 times
/// as wide, so the extremes stay legible at 24 logical pixels.
double wiredIconWeightFactor(double weight) {
  final w = weight.clamp(100.0, 900.0);
  return w <= 400 ? 0.5 + 0.5 * (w - 100) / 300 : 1 + 0.75 * (w - 400) / 300;
}

/// Pen width of an ambient silhouette's outline and weight adjustments, in
/// source units. Silhouette icons are drawn as if their strokes were this
/// wide, which is what most 24-unit icon grids use.
const double _silhouettePen = 2;

/// Icon geometry scaled into a square of the rendered size.
final class PreparedIconPrimitive {
  PreparedIconPrimitive._({
    required this.path,
    required this.strokePath,
    required this.clips,
    required this.fillColor,
    required this.strokeColor,
    required this.fillIsAmbient,
    required this.strokeIsAmbient,
    required this.strokeWidth,
    required this.scale,
  });

  /// The closed shape, in rendered coordinates.
  final Path path;

  /// The stroke centreline, with dashes expanded, in rendered coordinates.
  final Path strokePath;

  /// Clip shapes, in rendered coordinates.
  final List<Path> clips;

  /// Resolved fill colour, or null when the source specified no plain colour.
  final Color? fillColor;

  /// Resolved stroke colour, or null when the source specified no plain colour.
  final Color? strokeColor;

  /// Whether the source asked for `currentColor` on the fill.
  final bool fillIsAmbient;

  /// Whether the source asked for `currentColor` on the stroke.
  final bool strokeIsAmbient;

  /// Authored stroke width, in rendered coordinates.
  final double strokeWidth;

  /// Rendered pixels per source unit.
  final double scale;

  /// Whether the source draws a stroke at all.
  bool get strokes => strokeColor != null || strokeIsAmbient;

  /// Whether the source fills the shape with its own paint.
  bool get fills => fillColor != null || fillIsAmbient;

  /// Whether this primitive carries any paint of its own. Primitives without
  /// paint are silhouettes drawn in the ambient colour with a fill style.
  bool get hasOwnPaint => strokes || fills;
}

/// Scales [data] into a [size]-pixel square, mirroring it when [flip] is set.
List<PreparedIconPrimitive> prepareIconPrimitives(
  WiredSvgIconData data,
  double size, {
  bool flip = false,
}) {
  final scale = math.min(size / data.width, size / data.height);
  final width = data.width * scale;
  final dx = (size - width) / 2;
  final dy = (size - data.height * scale) / 2;
  final transform = Float64List(16)
    ..[0] = flip ? -scale : scale
    ..[5] = scale
    ..[10] = 1
    ..[12] = flip ? dx + width : dx
    ..[13] = dy
    ..[15] = 1;

  return [
    for (final primitive in data.primitives)
      PreparedIconPrimitive._(
        path: primitive.buildPath().transform(transform),
        strokePath: primitive.buildStrokePath().transform(transform),
        clips: [
          for (final clip in primitive.clipPaths)
            WiredSvgPrimitive.path(clip).buildPath().transform(transform),
        ],
        fillColor: _parseSvgColor(primitive.fillColor),
        strokeColor: _parseSvgColor(primitive.strokeColor),
        fillIsAmbient: primitive.fillColor == 'currentColor',
        strokeIsAmbient: primitive.strokeColor == 'currentColor',
        strokeWidth: primitive.strokeWidth * scale,
        scale: scale,
      ),
  ];
}

/// Parses an SVG paint colour (`#RGB`, `#RRGGBB`, `#RRGGBBAA`) into a [Color].
///
/// Returns null for anything that is not a plain colour, including `none`,
/// `currentColor`, and `url(...)` references.
Color? _parseSvgColor(String? value) {
  if (value == null) return null;
  var hex = value.trim();
  if (!hex.startsWith('#')) return null;
  hex = hex.substring(1);
  if (hex.length == 3) hex = hex.split('').map((c) => c + c).join();
  if (hex.length == 8) {
    final rgba = int.tryParse(hex, radix: 16);
    return rgba == null ? null : Color(((rgba & 255) << 24) | (rgba >> 8));
  }
  if (hex.length != 6) return null;
  final rgb = int.tryParse(hex, radix: 16);
  return rgb == null ? null : Color(0xFF000000 | rgb);
}

/// Paints prepared icon geometry with a smooth wavering field and the pen.
///
/// Every derived shape is built once per painter and cached: rebuild the
/// painter (not the canvas) when any input changes.
final class WiredSvgIconPainter extends CustomPainter {
  /// Creates a painter for [primitives] in [color] at pen [weight].
  WiredSvgIconPainter({
    required this.primitives,
    required this.color,
    required this.fillStyle,
    required this.weight,
    required this.drawConfig,
    required this.hachureGap,
    required this.hachureAngle,
  });

  /// Geometry from [prepareIconPrimitives].
  final List<PreparedIconPrimitive> primitives;

  /// The ambient icon colour.
  final Color color;

  /// How ambient silhouettes are filled.
  final WiredIconFillStyle fillStyle;

  /// Pen multiplier from [wiredIconWeightFactor] and the theme's ink weight.
  final double weight;

  /// Wavering amplitude, seed, and pen.
  final DrawConfig drawConfig;

  /// Distance between hachure strokes, in logical pixels.
  final double hachureGap;

  /// Angle of hachure strokes, in degrees.
  final double hachureAngle;

  late final List<_PrimitiveInk> _ink = [
    for (final (index, primitive) in primitives.indexed)
      _PrimitiveInk(primitive, this, index),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    for (final ink in _ink) {
      ink.paint(canvas);
    }
  }

  @override
  bool shouldRepaint(WiredSvgIconPainter oldDelegate) =>
      oldDelegate.primitives != primitives ||
      oldDelegate.color != color ||
      oldDelegate.fillStyle != fillStyle ||
      oldDelegate.weight != weight ||
      oldDelegate.drawConfig != drawConfig ||
      oldDelegate.hachureGap != hachureGap ||
      oldDelegate.hachureAngle != hachureAngle;
}

/// The cached ink for one primitive.
final class _PrimitiveInk {
  _PrimitiveInk(this.primitive, this.painter, this.index);

  final PreparedIconPrimitive primitive;
  final WiredSvgIconPainter painter;
  final int index;

  DrawConfig get _config => painter.drawConfig;

  /// The pen width a silhouette is drawn as if it had, at this weight.
  double get _silhouetteWidth =>
      _silhouettePen * primitive.scale * painter.weight;

  late final List<WaveredContour> _fillContours = waverPath(
    primitive.path,
    _config,
  );

  late final Path _fill = waveredPolygons(
    _fillContours,
    fillType: primitive.path.fillType,
  );

  late final List<WaveredContour> _strokeContours = waverPath(
    primitive.strokePath,
    _config,
    bounds: primitive.path.getBounds(),
  );

  /// Pen ink along the authored stroke.
  late final Path _strokeInk = _ink(
    _strokeContours,
    primitive.strokeWidth * painter.weight,
  );

  /// Pen ink along the silhouette's outline.
  late final Path _outlineInk = _ink(
    _fillContours,
    _silhouetteWidth *
        (painter.fillStyle == WiredIconFillStyle.none ? 0.8 : 0.5),
  );

  late final Path _hachure = _hachureInk(painter.hachureAngle);
  late final Path _crossHatch = _hachureInk(painter.hachureAngle + 90);

  void paint(Canvas canvas) {
    canvas.save();
    primitive.clips.forEach(canvas.clipPath);
    final ambient = painter.color;

    if (primitive.hasOwnPaint) {
      // Per-primitive colours (from source artwork) override the ambient
      // colour. `currentColor` means "use whatever colour the caller asked
      // for", which is how outline sets like Lucide stay themeable.
      if (primitive.fills) {
        final fill = primitive.fillColor ?? ambient;
        if (primitive.fillIsAmbient && !primitive.strokes) {
          _paintWeightedFill(canvas, fill);
        } else {
          canvas.drawPath(_fill, _solid(fill));
        }
      }
      if (primitive.strokes) {
        canvas.drawPath(_strokeInk, _solid(primitive.strokeColor ?? ambient));
      }
      canvas.restore();
      return;
    }

    switch (painter.fillStyle) {
      case WiredIconFillStyle.none:
        canvas.drawPath(_outlineInk, _solid(ambient));
      case WiredIconFillStyle.solid:
        _paintWeightedFill(canvas, ambient);
      case WiredIconFillStyle.hachure:
        canvas
          ..save()
          ..clipPath(_fill)
          ..drawPath(_hachure, _solid(ambient))
          ..restore()
          ..drawPath(_outlineInk, _solid(ambient));
      case WiredIconFillStyle.crossHatch:
        canvas
          ..save()
          ..clipPath(_fill)
          ..drawPath(_hachure, _solid(ambient))
          ..drawPath(_crossHatch, _solid(ambient))
          ..restore()
          ..drawPath(_outlineInk, _solid(ambient));
    }
    canvas.restore();
  }

  /// Fills the silhouette, growing or shrinking it to the requested weight.
  ///
  /// A stroke along the outline in the same colour grows every edge evenly.
  /// Shrinking erases the same band from inside a layer, which keeps narrow
  /// counters open instead of filling them.
  void _paintWeightedFill(Canvas canvas, Color fill) {
    final change = _silhouettePen * primitive.scale * (painter.weight - 1);
    if (change.abs() < 0.05) {
      canvas.drawPath(_fill, _solid(fill));
      return;
    }
    if (change > 0) {
      canvas
        ..drawPath(_fill, _solid(fill))
        ..drawPath(_fill, _edge(fill, change));
      return;
    }
    canvas
      ..saveLayer(_fill.getBounds().inflate(2), Paint())
      ..drawPath(_fill, _solid(fill))
      ..drawPath(
        _fill,
        _edge(const Color(0xff000000), -change)..blendMode = BlendMode.dstOut,
      )
      ..restore();
  }

  static Paint _solid(Color color) => Paint()
    ..color = color
    ..style = PaintingStyle.fill
    ..isAntiAlias = true;

  static Paint _edge(Color color, double width) => Paint()
    ..color = color
    ..style = PaintingStyle.stroke
    ..strokeWidth = width
    ..strokeJoin = StrokeJoin.round
    ..strokeCap = StrokeCap.round
    ..isAntiAlias = true;

  Path _ink(List<WaveredContour> contours, double width) {
    final sink = PathInkOutline();
    for (final (index, contour) in contours.indexed) {
      if (contour.points.length < 2) continue;
      InkStroke(
        contour.toOps(),
        width: width,
        pen: _config.pen,
        seed: _config.seed * 7919 + this.index * 131 + index,
      ).writeOutline(sink);
    }
    return sink.path;
  }

  Path _hachureInk(double angleDegrees) {
    final bounds = _fill.getBounds();
    if (bounds.isEmpty) return Path();
    final gap = painter.hachureGap;
    final radians = angleDegrees * (math.pi / 180);
    final direction = Offset(math.cos(radians), math.sin(radians));
    final normal = Offset(-direction.dy, direction.dx);
    final reach = bounds.longestSide;
    final span =
        bounds.width * normal.dx.abs() + bounds.height * normal.dy.abs();
    final count = (span / gap / 2).ceil() + 1;
    final sink = PathInkOutline();
    final generator = Generator(_config, NoFiller());
    final width = math.max(0.6, _silhouetteWidth * 0.4);
    for (var i = -count; i <= count; i++) {
      final base = bounds.center + normal * (gap * i);
      final start = base - direction * reach;
      final end = base + direction * reach;
      final ink = DrawableInk(
        generator.line(start.dx, start.dy, end.dx, end.dy),
        outlineWidth: width,
        sketchWidth: 0,
        inkUniform: true,
      );
      for (final set in ink.sets) {
        for (final stroke in set.strokes ?? const <InkStroke>[]) {
          stroke.writeOutline(sink);
        }
      }
    }
    // Painting clips this to the silhouette.
    return sink.path;
  }
}
