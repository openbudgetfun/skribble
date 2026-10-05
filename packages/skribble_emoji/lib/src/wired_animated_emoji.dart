import 'package:flutter/widgets.dart';
import 'package:skribble/skribble.dart';

import 'package:skribble_emoji/src/emoji_catalog.dart';
import 'package:skribble_emoji/src/emoji_drawing.dart';
import 'package:skribble_emoji/src/emoji_motion.dart';
import 'package:skribble_emoji/src/emoji_motions.dart';
import 'package:skribble_emoji/src/emoji_palette.dart';
import 'package:skribble_emoji/src/wired_emoji.dart';

/// How many times a second boiling lines are retraced: "on threes" at 24
/// frames a second, the pace of hand-drawn line boil.
const double _boilRate = 8;

/// How many inkings a boiling emoji cycles through.
const int _boilInkings = 3;

/// An emoji that comes alive: its parts move, and its lines boil.
///
/// ```dart
/// const WiredAnimatedEmoji('❤️', size: 48)
/// ```
///
/// Popular emoji have their own motion (a heart beats, a hand waves, a flame
/// flickers, faces blink); the rest move with their family, and [motion]
/// sets your own. Boiling retraces the lines a few times a second by a fresh
/// hand, like a hand-drawn cartoon, so even still emoji feel drawn.
///
/// Motion follows skribble's policy: a disabled [WiredMotion] ancestor, the
/// platform's reduced-motion setting, or a muted [TickerMode] shows the emoji
/// at rest, exactly as [WiredEmoji] draws it.
class WiredAnimatedEmoji extends StatefulWidget {
  /// Animates [emoji], such as `'🔥'`.
  const WiredAnimatedEmoji(
    this.emoji, {
    super.key,
    this.size = 24,
    this.semanticLabel,
    this.palette = EmojiPalette.skribble,
    this.weight,
    this.drawConfig,
    this.motion,
    this.boil = true,
    this.animating = true,
    this.progress,
  });

  /// The emoji to animate.
  final String emoji;

  /// The side of the square the emoji fills, in logical pixels.
  final double size;

  /// Accessible description. Defaults to the emoji's Unicode name.
  final String? semanticLabel;

  /// The colours the emoji is drawn with.
  final EmojiPalette palette;

  /// Pen weight from 100 to 700, as for [WiredEmoji].
  final double? weight;

  /// Overrides the theme's wavering and pen.
  final DrawConfig? drawConfig;

  /// How the emoji's parts move. Defaults to [EmojiMotions.of], which may
  /// have no motion for the emoji, leaving only the boil.
  final EmojiMotion? motion;

  /// Whether the lines are retraced a few times a second.
  final bool boil;

  /// Whether the emoji animates at all. False shows it at rest.
  final bool animating;

  /// Drives the loop instead of the widget's own clock, from 0 to 1.
  ///
  /// The widget borrows the animation: it never starts, stops, or disposes
  /// it. Repeat a controller over the motion's duration to loop.
  final Animation<double>? progress;

  @override
  State<WiredAnimatedEmoji> createState() => _WiredAnimatedEmojiState();
}

class _WiredAnimatedEmojiState extends State<WiredAnimatedEmoji>
    with SingleTickerProviderStateMixin {
  late final AnimationController _clock = AnimationController(vsync: this);
  EmojiEntry? _entry;
  EmojiMotion? _motion;
  bool _enabled = false;

  void _sync() {
    final entry = _entry = SkribbleEmoji.lookup(widget.emoji);
    final motion = _motion =
        widget.motion ?? (entry == null ? null : EmojiMotions.of(entry));
    _enabled =
        entry != null &&
        (motion != null || widget.boil) &&
        widget.animating &&
        WiredMotion.enabledOf(context) &&
        TickerMode.valuesOf(context).enabled;
    _clock.duration = motion?.duration ?? const Duration(seconds: 2);
    if (_enabled && widget.progress == null) {
      if (!_clock.isAnimating) _clock.repeat();
    } else {
      _clock.stop();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sync();
  }

  @override
  void didUpdateWidget(WiredAnimatedEmoji oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.emoji != widget.emoji || oldWidget.motion != widget.motion) {
      _clock.stop();
    }
    _sync();
  }

  @override
  void dispose() {
    _clock.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final entry = _entry;
    if (entry == null || !_enabled) {
      return WiredEmoji(
        widget.emoji,
        size: widget.size,
        semanticLabel: widget.semanticLabel,
        palette: widget.palette,
        weight: widget.weight,
        drawConfig: widget.drawConfig,
      );
    }
    final theme = WiredTheme.of(context);
    final config = widget.drawConfig ?? emojiDrawConfig(theme, widget.size);
    final weight = emojiPenWeight(context, theme, widget.weight);
    final inkings = [
      for (var inking = 0; inking < (widget.boil ? _boilInkings : 1); inking++)
        emojiDrawingFor(
          entry,
          size: widget.size,
          config: config,
          palette: widget.palette,
          weight: weight,
          inking: inking,
        ),
    ];
    return Semantics(
      label: widget.semanticLabel ?? entry.name,
      image: true,
      child: SizedBox.square(
        dimension: widget.size,
        child: RepaintBoundary(
          child: CustomPaint(
            painter: _AnimatedEmojiPainter(
              inkings: inkings,
              motion: _motion,
              loop: widget.progress ?? _clock,
              loopLength: _clock.duration!,
            ),
          ),
        ),
      ),
    );
  }
}

class _AnimatedEmojiPainter extends CustomPainter {
  _AnimatedEmojiPainter({
    required this.inkings,
    required this.motion,
    required this.loop,
    required this.loopLength,
  }) : super(repaint: loop);

  final List<EmojiDrawing> inkings;
  final EmojiMotion? motion;
  final Animation<double> loop;
  final Duration loopLength;

  @override
  void paint(Canvas canvas, Size size) {
    final value = loop.value;
    // A loop at its end is the loop at its start.
    final t = value.isFinite ? value.clamp(0.0, 1.0) % 1.0 : 0.0;
    final seconds =
        t * loopLength.inMicroseconds / Duration.microsecondsPerSecond;
    final drawing = inkings[(seconds * _boilRate).floor() % inkings.length];
    switch (motion) {
      case final motion?:
        motion.paint(canvas, drawing, t);
      case null:
        drawing.paint(canvas);
    }
  }

  @override
  bool shouldRepaint(_AnimatedEmojiPainter oldDelegate) =>
      oldDelegate.loop != loop ||
      oldDelegate.motion != motion ||
      oldDelegate.loopLength != loopLength ||
      !_identicalLists(oldDelegate.inkings, inkings);

  static bool _identicalLists(List<EmojiDrawing> a, List<EmojiDrawing> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (!identical(a[i], b[i])) return false;
    }
    return true;
  }
}
