import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui';

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

    Path parse(String data, {bool evenOdd = false}) {
      final path = Path()
        ..fillType = evenOdd ? PathFillType.evenOdd : PathFillType.nonZero;
      writeSvgPathDataToPath(data, _PathProxy(path));
      return path.transform(matrix);
    }

    final shapes = <_PreparedShape>[];
    var index = 0;
    for (final shape in art.shapes) {
      if (shape.variant != null && shape.variant != variant) continue;
      final source = parse(shape.d, evenOdd: shape.evenOdd);
      final contours = waverPath(source, config, bounds: bounds);
      Path? fill;
      if (shape.fill != null) {
        fill = waveredPolygons(
          contours,
          fillType: source.fillType,
        ).shift(drift);
      }
      Path? ink;
      if (shape.stroke != null) {
        final sink = PathInkOutline();
        for (final (contourIndex, contour) in contours.indexed) {
          InkStroke(
            contour.toOps(),
            width: shape.width * scale * weight,
            pen: config.pen,
            seed:
                config.seed * 7919 +
                inking * 104729 +
                index * 131 +
                contourIndex,
          ).writeOutline(sink);
        }
        ink = sink.path;
      }
      Path? clip;
      if (shape.clip case final clipData?) {
        clip = waveredPolygons(
          waverPath(parse(clipData), config, bounds: bounds),
        );
      }
      shapes.add(
        _PreparedShape(
          part: shape.part,
          fill: fill,
          fillColor: shape.fill?.resolve(palette, tone: tone, tone2: tone2),
          ink: ink,
          inkColor: shape.stroke?.resolve(palette, tone: tone, tone2: tone2),
          clip: clip,
        ),
      );
      index++;
    }
    return EmojiDrawing._(size, shapes);
  }

  EmojiDrawing._(this.size, this._shapes);

  /// The side of the square this drawing fills, in logical pixels.
  final double size;

  final List<_PreparedShape> _shapes;

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

final class _PreparedShape {
  const _PreparedShape({
    required this.part,
    required this.fill,
    required this.fillColor,
    required this.ink,
    required this.inkColor,
    required this.clip,
  });

  final String? part;
  final Path? fill;
  final Color? fillColor;
  final Path? ink;
  final Color? inkColor;
  final Path? clip;
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
