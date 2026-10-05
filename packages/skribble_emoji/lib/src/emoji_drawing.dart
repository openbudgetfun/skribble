import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/foundation.dart' show immutable;
import 'package:flutter/widgets.dart' show Matrix4;
import 'package:path_parsing/path_parsing.dart';
import 'package:skribble/skribble.dart';

import 'package:skribble_emoji/src/emoji_art.dart';
import 'package:skribble_emoji/src/emoji_catalog.dart';
import 'package:skribble_emoji/src/emoji_palette.dart';

/// The side of the 36-unit square emoji art is drawn in.
const double kEmojiArtSize = 36;

/// An emoji prepared for painting: wavered fills and pen-inked outlines.
///
/// Preparation parses, wavers, and inks every shape once; [paint] only draws
/// cached paths, so a drawing can repaint every animation frame cheaply.
/// Shapes are kept in paint order and remember their part, so [paint] can
/// move parts as rigid groups.
final class EmojiDrawing {
  /// Prepares [entry] at [size] logical pixels.
  ///
  /// [config] supplies the wavering, seed, and pen; [weight] multiplies the
  /// pen width; [palette] resolves the art's colour tokens for the entry's
  /// skin tones.
  factory EmojiDrawing(
    EmojiEntry entry, {
    required double size,
    required DrawConfig config,
    EmojiPalette palette = EmojiPalette.skribble,
    double weight = 1,
    int inking = 0,
  }) => EmojiDrawing.art(
    entry.drawing,
    size: size,
    config: config,
    palette: palette,
    weight: weight,
    tone: entry.tone,
    tone2: entry.tone2,
    variant: entry.variant ?? EmojiVariant.person,
    mirrored: entry.mirrored,
    seed: entry.art.hashCode,
    inking: inking,
  );

  /// Prepares any [art] in skribble's emoji style, including your own.
  ///
  /// [tone] and [tone2] resolve the person tokens, [variant] picks which
  /// hair variant to draw, and [mirrored] flips the art horizontally. [seed]
  /// varies the marker registration between drawings that share a config.
  ///
  /// [inking] retraces the same wavering shapes by a fresh hand: the pen's
  /// pressure and the marker's registration change, the shapes do not.
  /// Cycling a few inkings is the "boil" of hand-drawn animation.
  factory EmojiDrawing.art(
    EmojiArt art, {
    required double size,
    required DrawConfig config,
    EmojiPalette palette = EmojiPalette.skribble,
    double weight = 1,
    EmojiSkinTone tone = EmojiSkinTone.none,
    EmojiSkinTone tone2 = EmojiSkinTone.none,
    EmojiVariant variant = EmojiVariant.person,
    bool mirrored = false,
    int seed = 0,
    int inking = 0,
  }) => EmojiDrawing._(
    size,
    _prepare(
      art,
      output: const _PathOutput(),
      size: size,
      config: config,
      palette: palette,
      weight: weight,
      tone: tone,
      tone2: tone2,
      variant: variant,
      mirrored: mirrored,
      seed: seed,
      inking: inking,
    ),
  );

  EmojiDrawing._(this.size, this._shapes);

  /// The side of the square this drawing fills, in logical pixels.
  final double size;

  final List<_Prepared<Path>> _shapes;

  /// The bounds of [part] in this drawing, or null when it has no such part.
  Rect? boundsOf(String part) => _bounds.putIfAbsent(part, () {
    Rect? bounds;
    for (final shape in _shapes) {
      if (shape.part != part) continue;
      for (final path in [?shape.fill, ?shape.ink]) {
        final rect = path.getBounds();
        bounds = bounds == null ? rect : bounds.expandToInclude(rect);
      }
    }
    return bounds;
  });

  final Map<String, Rect?> _bounds = {};

  /// The distinct parts in this drawing, in paint order.
  late final List<String> parts = [
    for (final part in {for (final shape in _shapes) ?shape.part}) part,
  ];

  /// Paints the drawing with its top-left corner at the canvas origin.
  ///
  /// [pose] moves named parts as rigid groups, and [opacity] fades them;
  /// parts neither mentions stay at rest.
  void paint(
    Canvas canvas, {
    Map<String, Matrix4> pose = const {},
    Map<String, double> opacity = const {},
  }) {
    for (final shape in _shapes) {
      final part = shape.part;
      final transform = part == null ? null : pose[part];
      final alpha = part == null ? 1.0 : (opacity[part] ?? 1.0);
      if (alpha <= 0) continue;
      final clip = shape.clip;
      if (transform != null || clip != null) canvas.save();
      if (transform != null) canvas.transform(transform.storage);
      if (clip != null) canvas.clipPath(clip);
      if (shape.fill case final fill?) {
        canvas.drawPath(fill, Paint()..color = _faded(shape.fillColor!, alpha));
      }
      if (shape.ink case final ink?) {
        canvas.drawPath(ink, Paint()..color = _faded(shape.inkColor!, alpha));
      }
      if (transform != null || clip != null) canvas.restore();
    }
  }

  static Color _faded(Color color, double alpha) =>
      alpha >= 1 ? color : color.withValues(alpha: color.a * alpha);
}

/// An emoji's prepared geometry as SVG path data, for renderers outside
/// Flutter: SVG files, Lottie animations, and design tools.
///
/// The shapes are exactly those [EmojiDrawing] paints for the same arguments:
/// wavered fills and pen-inked outlines (as filled shapes), in paint order,
/// with their parts.
final class EmojiVector {
  /// Prepares [entry] at [size], as [EmojiDrawing.new] does.
  factory EmojiVector(
    EmojiEntry entry, {
    required double size,
    required DrawConfig config,
    EmojiPalette palette = EmojiPalette.skribble,
    double weight = 1,
    int inking = 0,
  }) => EmojiVector.art(
    entry.drawing,
    size: size,
    config: config,
    palette: palette,
    weight: weight,
    tone: entry.tone,
    tone2: entry.tone2,
    variant: entry.variant ?? EmojiVariant.person,
    mirrored: entry.mirrored,
    seed: entry.art.hashCode,
    inking: inking,
  );

  /// Prepares any [art], as [EmojiDrawing.art] does.
  factory EmojiVector.art(
    EmojiArt art, {
    required double size,
    required DrawConfig config,
    EmojiPalette palette = EmojiPalette.skribble,
    double weight = 1,
    EmojiSkinTone tone = EmojiSkinTone.none,
    EmojiSkinTone tone2 = EmojiSkinTone.none,
    EmojiVariant variant = EmojiVariant.person,
    bool mirrored = false,
    int seed = 0,
    int inking = 0,
  }) => EmojiVector._(size, [
    for (final shape in _prepare(
      art,
      output: const _SvgOutput(),
      size: size,
      config: config,
      palette: palette,
      weight: weight,
      tone: tone,
      tone2: tone2,
      variant: variant,
      mirrored: mirrored,
      seed: seed,
      inking: inking,
    ))
      EmojiVectorShape(
        part: shape.part,
        fill: shape.fill,
        fillColor: shape.fillColor,
        evenOdd: shape.evenOdd,
        ink: shape.ink,
        inkColor: shape.inkColor,
        clip: shape.clip,
      ),
  ]);

  const EmojiVector._(this.size, this.shapes);

  /// The side of the square the shapes fill.
  final double size;

  /// The shapes, in paint order.
  final List<EmojiVectorShape> shapes;

  /// A standalone SVG document of the emoji.
  ///
  /// Each shape is a `<g>` with a `data-part` attribute when it belongs to a
  /// part, so CSS or script can animate parts on the web.
  String toSvg() {
    final side = _number(size);
    final svg = StringBuffer(
      '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 $side $side" '
      'width="$side" height="$side">',
    );
    final clips = <String>[];
    final body = StringBuffer();
    for (final shape in shapes) {
      body.write('<g');
      if (shape.part case final part?) body.write(' data-part="$part"');
      if (shape.clip case final clip?) {
        body.write(' clip-path="url(#c${clips.length})"');
        clips.add(clip);
      }
      body.write('>');
      if (shape.fill case final fill?) {
        body.write('<path d="$fill"${_paint(shape.fillColor!)}');
        if (shape.evenOdd) body.write(' fill-rule="evenodd"');
        body.write('/>');
      }
      if (shape.ink case final ink?) {
        body.write('<path d="$ink"${_paint(shape.inkColor!)}/>');
      }
      body.write('</g>');
    }
    if (clips.isNotEmpty) {
      svg.write('<defs>');
      for (final (index, clip) in clips.indexed) {
        svg.write('<clipPath id="c$index"><path d="$clip"/></clipPath>');
      }
      svg.write('</defs>');
    }
    return (svg
          ..write(body)
          ..write('</svg>'))
        .toString();
  }

  static String _paint(Color color) {
    final rgb = (color.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0');
    return color.a >= 1
        ? ' fill="#$rgb"'
        : ' fill="#$rgb" fill-opacity="${_number(color.a)}"';
  }
}

/// One shape of an [EmojiVector]: SVG path data for its fill and its inked
/// outline, which is itself a filled shape.
@immutable
final class EmojiVectorShape {
  /// Creates a shape.
  const EmojiVectorShape({
    this.part,
    this.fill,
    this.fillColor,
    this.evenOdd = false,
    this.ink,
    this.inkColor,
    this.clip,
  });

  /// The part the shape belongs to, or null.
  final String? part;

  /// Path data for the marker fill, or null.
  final String? fill;

  /// The fill's colour.
  final Color? fillColor;

  /// Whether the fill uses the even-odd rule.
  final bool evenOdd;

  /// Path data for the inked outline, filled with [inkColor], or null.
  final String? ink;

  /// The ink's colour.
  final Color? inkColor;

  /// Path data the shape is clipped to, or null.
  final String? clip;
}

/// One prepared shape, with geometry in an output's own form.
final class _Prepared<P> {
  const _Prepared({
    required this.part,
    required this.fill,
    required this.fillColor,
    required this.ink,
    required this.inkColor,
    required this.clip,
    required this.evenOdd,
  });

  final String? part;
  final P? fill;
  final Color? fillColor;
  final P? ink;
  final Color? inkColor;
  final P? clip;
  final bool evenOdd;
}

/// Where prepared geometry goes: Flutter paths to paint, or SVG path data to
/// export. Both receive exactly the same wavered and inked shapes.
abstract interface class _Output<P> {
  /// [contours] as polygons, moved by [shift].
  P polygons(
    List<WaveredContour> contours, {
    required bool evenOdd,
    Offset shift = Offset.zero,
  });

  /// The outline [write] inks.
  P ink(void Function(InkOutlineSink sink) write);
}

final class _PathOutput implements _Output<Path> {
  const _PathOutput();

  @override
  Path polygons(
    List<WaveredContour> contours, {
    required bool evenOdd,
    Offset shift = Offset.zero,
  }) {
    final path = waveredPolygons(
      contours,
      fillType: evenOdd ? PathFillType.evenOdd : PathFillType.nonZero,
    );
    return shift == Offset.zero ? path : path.shift(shift);
  }

  @override
  Path ink(void Function(InkOutlineSink sink) write) {
    final sink = PathInkOutline();
    write(sink);
    return sink.path;
  }
}

final class _SvgOutput implements _Output<String> {
  const _SvgOutput();

  @override
  String polygons(
    List<WaveredContour> contours, {
    required bool evenOdd,
    Offset shift = Offset.zero,
  }) {
    final data = StringBuffer();
    for (final contour in contours) {
      for (final (index, point) in contour.points.indexed) {
        data
          ..write(index == 0 ? 'M' : 'L')
          ..write(_number(point.dx + shift.dx))
          ..write(' ')
          ..write(_number(point.dy + shift.dy));
      }
      if (contour.closed) data.write('Z');
    }
    return data.toString();
  }

  @override
  String ink(void Function(InkOutlineSink sink) write) {
    final sink = SvgInkOutline();
    write(sink);
    return sink.toString();
  }
}

/// [value] with at most two decimals and no trailing zeros.
String _number(double value) {
  final fixed = value.toStringAsFixed(2);
  final trimmed = fixed.contains('.')
      ? fixed.replaceFirst(RegExp(r'\.?0+$'), '')
      : fixed;
  return trimmed == '-0' ? '0' : trimmed;
}

/// Wavers and inks every shape of [art] into [output].
List<_Prepared<P>> _prepare<P>(
  EmojiArt art, {
  required _Output<P> output,
  required double size,
  required DrawConfig config,
  required EmojiPalette palette,
  required double weight,
  required EmojiSkinTone tone,
  required EmojiSkinTone tone2,
  required EmojiVariant variant,
  required bool mirrored,
  required int seed,
  required int inking,
}) {
  final scale = size / kEmojiArtSize;
  final matrix = Float64List(16)
    ..[0] = mirrored ? -scale : scale
    ..[5] = scale
    ..[10] = 1
    ..[12] = mirrored ? size : 0
    ..[15] = 1;
  final bounds = Offset.zero & Size.square(size);
  final random = math.Random(config.seed * 31 + seed + inking * 7);
  // Marker fills sit a little off the line, all in one direction, like a
  // second pass that never quite registers with the first.
  final angle = random.nextDouble() * math.pi * 2;
  final drift = Offset(math.cos(angle), math.sin(angle)) * (0.55 * scale);

  Path parse(String data) {
    final path = Path();
    writeSvgPathDataToPath(data, _PathProxy(path));
    return path.transform(matrix);
  }

  final shapes = <_Prepared<P>>[];
  var index = 0;
  for (final shape in art.shapes) {
    if (shape.variant != null && shape.variant != variant) continue;
    final contours = waverPath(parse(shape.d), config, bounds: bounds);
    final shapeIndex = index;
    shapes.add(
      _Prepared(
        part: shape.part,
        fill: shape.fill == null
            ? null
            : output.polygons(contours, evenOdd: shape.evenOdd, shift: drift),
        fillColor: shape.fill?.resolve(palette, tone: tone, tone2: tone2),
        ink: shape.stroke == null
            ? null
            : output.ink((sink) {
                for (final (contourIndex, contour) in contours.indexed) {
                  InkStroke(
                    contour.toOps(),
                    width: shape.width * scale * weight,
                    pen: config.pen,
                    seed:
                        config.seed * 7919 +
                        inking * 104729 +
                        shapeIndex * 131 +
                        contourIndex,
                  ).writeOutline(sink);
                }
              }),
        inkColor: shape.stroke?.resolve(palette, tone: tone, tone2: tone2),
        clip: switch (shape.clip) {
          null => null,
          final clip => output.polygons(
            waverPath(parse(clip), config, bounds: bounds),
            evenOdd: false,
          ),
        },
        evenOdd: shape.evenOdd,
      ),
    );
    index++;
  }
  return shapes;
}

final class _PathProxy extends PathProxy {
  _PathProxy(this.path);

  final Path path;

  @override
  void close() => path.close();

  @override
  void cubicTo(
    double x1,
    double y1,
    double x2,
    double y2,
    double x3,
    double y3,
  ) => path.cubicTo(x1, y1, x2, y2, x3, y3);

  @override
  void lineTo(double x, double y) => path.lineTo(x, y);

  @override
  void moveTo(double x, double y) => path.moveTo(x, y);
}
