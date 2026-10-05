import 'dart:collection';
import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:skribble/skribble.dart';

import 'package:skribble_emoji/src/emoji_catalog.dart';
import 'package:skribble_emoji/src/emoji_drawing.dart';
import 'package:skribble_emoji/src/emoji_palette.dart';

/// Draws an emoji by hand in skribble's own emoji style.
///
/// Pass the emoji itself, exactly as you would type it:
///
/// ```dart
/// const WiredEmoji('🎉')
/// const WiredEmoji('👩🏽‍💻', size: 48)
/// ```
///
/// Every fully-qualified Unicode 18 emoji is drawn, including skin tones,
/// gendered variants, keycaps, and flags. Outlines are inked by the theme's
/// pen and waver with its roughness level, so emoji match the rest of the
/// interface. Text that is not a known emoji is shown as plain text.
class WiredEmoji extends StatelessWidget {
  /// Draws [emoji], such as `'😀'` or `'🇯🇵'`.
  const WiredEmoji(
    this.emoji, {
    super.key,
    this.size = 24,
    this.semanticLabel,
    this.palette = EmojiPalette.skribble,
    this.weight,
    this.drawConfig,
  });

  /// Draws the emoji with Unicode short name [identifier] in snake case,
  /// such as `'party_popper'`. Unknown names draw nothing.
  WiredEmoji.named(
    String identifier, {
    Key? key,
    double size = 24,
    String? semanticLabel,
    EmojiPalette palette = EmojiPalette.skribble,
    double? weight,
    DrawConfig? drawConfig,
  }) : this(
         SkribbleEmoji.named(identifier)?.emoji ?? '',
         key: key,
         size: size,
         semanticLabel: semanticLabel,
         palette: palette,
         weight: weight,
         drawConfig: drawConfig,
       );

  /// The emoji to draw.
  final String emoji;

  /// The side of the square the emoji fills, in logical pixels.
  final double size;

  /// Accessible description. Defaults to the emoji's Unicode name.
  final String? semanticLabel;

  /// The colours the emoji is drawn with.
  final EmojiPalette palette;

  /// Pen weight from 100 to 700, as for icons. Defaults to
  /// [IconThemeData.weight], then 400.
  final double? weight;

  /// Overrides the theme's wavering and pen.
  final DrawConfig? drawConfig;

  @override
  Widget build(BuildContext context) {
    final entry = SkribbleEmoji.lookup(emoji);
    if (entry == null) {
      return SizedBox.square(
        dimension: size,
        child: FittedBox(child: Text(emoji)),
      );
    }
    final theme = WiredTheme.of(context);
    final drawing = emojiDrawingFor(
      entry,
      size: size,
      config: drawConfig ?? emojiDrawConfig(theme, size),
      palette: palette,
      weight:
          wiredIconWeightFactor(weight ?? IconTheme.of(context).weight ?? 400) *
          theme.strokeWidth /
          2.4,
    );
    return Semantics(
      label: semanticLabel ?? entry.name,
      image: true,
      child: SizedBox.square(
        dimension: size,
        child: RepaintBoundary(
          child: CustomPaint(painter: _EmojiPainter(drawing)),
        ),
      ),
    );
  }
}

/// The wavering and pen emoji use under [theme] at [size].
///
/// Small drawings need more separation between roughness levels than
/// borders do, the same treatment icons receive.
DrawConfig emojiDrawConfig(WiredThemeData theme, double size) {
  final config = theme.drawConfig;
  return DrawConfig.build(
    maxRandomnessOffset:
        config.maxRandomnessOffset *
        (1 + 1.5 * config.lineWobble) *
        math.min(2.0, size / 24),
    roughness: config.roughness,
    lineWobble: config.lineWobble,
    seed: config.seed,
    pen: config.pen,
  );
}

/// A prepared drawing for [entry], shared with every other widget asking for
/// the same emoji, size, configuration, palette, and weight.
///
/// Preparing an emoji parses, wavers, and inks every shape, so pickers and
/// chat lists reuse recent drawings from a small least-recently-used cache.
EmojiDrawing emojiDrawingFor(
  EmojiEntry entry, {
  required double size,
  required DrawConfig config,
  EmojiPalette palette = EmojiPalette.skribble,
  double weight = 1,
}) {
  final key = (entry.emoji, size, config, palette, weight);
  final cached = _cache.remove(key);
  if (cached != null) {
    _cache[key] = cached;
    return cached;
  }
  final drawing = EmojiDrawing(
    entry,
    size: size,
    config: config,
    palette: palette,
    weight: weight,
  );
  _cache[key] = drawing;
  if (_cache.length > _cacheSize) _cache.remove(_cache.keys.first);
  return drawing;
}

const int _cacheSize = 512;

final LinkedHashMap<Object, EmojiDrawing> _cache =
    LinkedHashMap<Object, EmojiDrawing>();

class _EmojiPainter extends CustomPainter {
  _EmojiPainter(this.drawing);

  final EmojiDrawing drawing;

  @override
  void paint(Canvas canvas, Size size) => drawing.paint(canvas);

  @override
  bool shouldRepaint(_EmojiPainter oldDelegate) =>
      !identical(oldDelegate.drawing, drawing);
}
