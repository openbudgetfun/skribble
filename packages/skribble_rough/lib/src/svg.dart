import 'core.dart';
import 'entities.dart';
import 'filler.dart';

/// Converts the operations in [set] into SVG path data (the `d` attribute).
///
/// Moves become `M`, straight segments `L`, and cubic segments `C`. A solid
/// fill ([OpSetType.fillPath]) is closed with `Z`, matching how the Flutter
/// painter closes the same polygon before filling it. Coordinates keep two
/// decimals, so the same set always produces the same string and server
/// rendered markup stays byte-stable between builds.
///
/// Returns an empty string when [set] has no operations.
String opSetToSvgPath(OpSet set) {
  final ops = set.ops;

  if (ops.isEmpty) {
    return '';
  }

  final data = StringBuffer();

  for (final op in ops) {
    data.write(switch (op.op) {
      OpType.move => 'M',
      OpType.lineTo => 'L',
      OpType.curveTo => 'C',
    });
    data.write(
      op.data
          .map((point) => '${_number(point.x)} ${_number(point.y)}')
          .join(
            ' ',
          ),
    );
  }

  if (set.type == OpSetType.fillPath) {
    data.write('Z');
  }

  return data.toString();
}

/// How a closed rough shape is filled.
///
/// Each style maps to one of the engine's [Filler]s through [filler]. The
/// names match rough.js, so designs and docs written for either read the
/// same.
enum RoughFillStyle {
  /// No fill; only the outline is drawn.
  none,

  /// Parallel sketched lines at the hachure angle.
  hachure,

  /// Two hachure passes at right angles.
  crossHatch,

  /// One continuous zig-zag stroke across the shape.
  zigzag,

  /// Hachure lines broken into short dashes.
  dashed,

  /// Small rough dots laid along hachure lines.
  dots,

  /// A solid polygon whose corners wander slightly.
  solid;

  /// Creates the filler for this style, drawing with [config].
  ///
  /// [config] is required because the shared [FillerConfig.defaultConfig]
  /// advances one random stream across every shape that uses it. Passing a
  /// fresh configuration built from a seed keeps each fill reproducible.
  Filler filler(FillerConfig config) => switch (this) {
    RoughFillStyle.none => NoFiller(config),
    RoughFillStyle.hachure => HachureFiller(config),
    RoughFillStyle.crossHatch => HatchFiller(config),
    RoughFillStyle.zigzag => ZigZagFiller(config),
    RoughFillStyle.dashed => DashedFiller(config),
    RoughFillStyle.dots => DotFiller(config),
    RoughFillStyle.solid => SolidFiller(config),
  };
}

/// A [Drawable] as SVG path data, split the way the Flutter painter paints it.
///
/// The painter strokes outlines with the border paint, strokes sketched
/// fills with the fill paint, and fills solid polygons with the fill paint.
/// [RoughSvg] keeps those three groups apart so each can carry its own
/// colour and stroke width, and joins every op set of a group into a single
/// path so a shape costs at most three SVG elements.
///
/// These are plain centrelines, independent of the drawable's `RoughPen`.
/// They suit scalable output such as HTML overlays that stretch with their
/// element and use `vector-effect: non-scaling-stroke`. Use
/// `DrawableInk.svgPaths` instead when exported ink must reproduce the pen's
/// tapered widths at a fixed size.
final class RoughSvg {
  const RoughSvg._({
    required this.outline,
    required this.sketch,
    required this.solid,
  });

  /// Splits [drawable]'s op sets into outline, sketch, and solid path data.
  factory RoughSvg.fromDrawable(Drawable drawable) {
    final outline = StringBuffer();
    final sketch = StringBuffer();
    final solid = StringBuffer();

    for (final set in drawable.sets) {
      final target = switch (set.type) {
        OpSetType.path => outline,
        OpSetType.fillSketch => sketch,
        OpSetType.fillPath => solid,
      };
      target.write(opSetToSvgPath(set));
    }

    return RoughSvg._(
      outline: outline.toString(),
      sketch: sketch.toString(),
      solid: solid.toString(),
    );
  }

  /// Path data for the shape's outline, stroked with the ink colour.
  final String outline;

  /// Path data for sketched fills (hachure, zig-zag, dots), stroked with the
  /// fill colour.
  final String sketch;

  /// Path data for solid fills, filled with the fill colour.
  final String solid;

  /// Whether every group is empty.
  bool get isEmpty => outline.isEmpty && sketch.isEmpty && solid.isEmpty;

  /// Renders the non-empty groups as SVG `<path>` elements, in paint order:
  /// solid fill, sketched fill, then outline.
  ///
  /// [stroke] colours the outline and [fill] colours both fill groups; both
  /// accept any SVG paint value and are attribute-escaped. Set
  /// [nonScalingStroke] when the surrounding `<svg>` stretches, so strokes
  /// keep their width on screen.
  String toPathElements({
    String stroke = 'currentColor',
    String fill = 'currentColor',
    double strokeWidth = 1.5,
    double sketchWidth = 1,
    bool nonScalingStroke = false,
  }) {
    final effect = nonScalingStroke
        ? ' vector-effect="non-scaling-stroke"'
        : '';
    final ink = _escapeAttribute(stroke);
    final paint = _escapeAttribute(fill);
    final elements = StringBuffer();

    if (solid.isNotEmpty) {
      elements.write('<path d="$solid" fill="$paint" stroke="none"/>');
    }

    if (sketch.isNotEmpty) {
      elements.write(
        '<path d="$sketch" fill="none" stroke="$paint" '
        'stroke-width="${_number(sketchWidth)}" stroke-linecap="round" '
        'stroke-linejoin="round"$effect/>',
      );
    }

    if (outline.isNotEmpty) {
      elements.write(
        '<path d="$outline" fill="none" stroke="$ink" '
        'stroke-width="${_number(strokeWidth)}" stroke-linecap="round" '
        'stroke-linejoin="round"$effect/>',
      );
    }

    return elements.toString();
  }
}

/// Formats [value] with at most two decimals and no trailing zeros.
String _number(double value) {
  final fixed = value.toStringAsFixed(2);
  final trimmed = fixed.contains('.')
      ? fixed.replaceFirst(RegExp(r'\.?0+$'), '')
      : fixed;

  return trimmed == '-0' ? '0' : trimmed;
}

/// Escapes [value] for use inside a double-quoted XML attribute.
String _escapeAttribute(String value) => value
    .replaceAll('&', '&amp;')
    .replaceAll('"', '&quot;')
    .replaceAll('<', '&lt;')
    .replaceAll('>', '&gt;');
