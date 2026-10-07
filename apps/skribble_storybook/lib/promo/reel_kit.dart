import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:skribble/skribble.dart';
import 'package:skribble_emoji/skribble_emoji.dart';

/// Eases in and out over 0→1.
double ease(double t) => Curves.easeInOutCubic.transform(t.clamp(0, 1));

/// Eases out over 0→1.
double easeOut(double t) => Curves.easeOutCubic.transform(t.clamp(0, 1));

/// Overshoots a little over 0→1, for things that pop into place.
double pop(double t) => Curves.easeOutBack.transform(t.clamp(0, 1));

/// 0→1 over [start, end] seconds.
double span(double t, double start, double end) =>
    ((t - start) / (end - start)).clamp(0, 1).toDouble();

/// Fades in over [fade] seconds from [start] and out before [end].
double presence(double t, double start, double end, {double fade = .4}) {
  if (t < start || t > end) return 0;
  return math.min(span(t, start, start + fade), 1 - span(t, end - fade, end));
}

/// Whether the reel is drawn for a tall screen.
bool isPortrait(BuildContext context) {
  final size = MediaQuery.sizeOf(context);
  return size.height > size.width;
}

/// The paper, theme, and default type every reel draws on.
class ReelStage extends StatelessWidget {
  /// Draws [child] on [paper] (default: the theme's fill) with [theme].
  const ReelStage({
    required this.theme,
    required this.child,
    this.paper,
    super.key,
  });

  /// The skribble theme.
  final WiredThemeData theme;

  /// The background, when it differs from the theme's fill colour.
  final Color? paper;

  /// The scenes.
  final Widget child;

  @override
  Widget build(BuildContext context) => WiredMaterialApp(
    wiredTheme: theme,
    themeMode: ThemeMode.light,
    themeAnimationDuration: Duration.zero,
    // Text fields and sliders still wrap Material widgets that expect a
    // Material ancestor.
    home: Material(
      type: MaterialType.transparency,
      child: ColoredBox(
        color: paper ?? theme.fillColor,
        child: DefaultTextStyle(
          style: TextStyle(
            fontFamily: theme.fontFamily,
            package: theme.fontPackage,
            color: theme.textColor,
            fontSize: 22,
            decoration: TextDecoration.none,
          ),
          child: child,
        ),
      ),
    ),
  );
}

/// A scene that fades and settles in over [start]→[end] seconds.
class Scene extends StatelessWidget {
  /// Shows [child] between [start] and [end] at reel time [t].
  const Scene(
    this.t,
    this.start,
    this.end, {
    required this.child,
    this.fade = .4,
    super.key,
  });

  /// Reel time in seconds.
  final double t;

  /// When the scene arrives.
  final double start;

  /// When it has gone.
  final double end;

  /// How long the fades take.
  final double fade;

  /// The scene.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final p = presence(t, start, end, fade: fade);
    if (p <= 0) return const SizedBox.shrink();
    return Opacity(
      opacity: p,
      child: Transform.scale(scale: .97 + .03 * p, child: child),
    );
  }
}

/// A word with a marker swipe behind it, drawn left to right as [progress]
/// goes from 0 to 1.
class MarkerWord extends StatelessWidget {
  /// Highlights [text].
  const MarkerWord(
    this.text, {
    required this.progress,
    this.style,
    this.color,
    super.key,
  });

  /// The word.
  final String text;

  /// How much of the swipe is drawn.
  final double progress;

  /// The word's style.
  final TextStyle? style;

  /// The marker, defaulting to the theme's marker colour.
  final Color? color;

  @override
  Widget build(BuildContext context) => CustomPaint(
    painter: _MarkerPainter(
      progress,
      color ?? WiredTheme.of(context).markerColor,
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(text, style: style),
    ),
  );
}

class _MarkerPainter extends CustomPainter {
  const _MarkerPainter(this.progress, this.color);

  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;
    final width = size.width * progress.clamp(0, 1);
    final top = size.height * .36;
    final bottom = size.height * .96;
    // A marker held at a slight slant, with a wobble along its edges.
    double wobble(double x, double phase) => math.sin(x / 13 + phase) * 1.6;
    final path = Path()..moveTo(0, top + 3);
    for (var x = 0.0; x <= width; x += 6) {
      path.lineTo(x, top + wobble(x, 0) - x * .015);
    }
    path.lineTo(width, bottom - width * .015);
    for (var x = width; x >= 0; x -= 6) {
      path.lineTo(x, bottom + wobble(x, 2) - x * .015);
    }
    path.close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_MarkerPainter old) =>
      old.progress != progress || old.color != color;
}

/// A big, centred caption whose pieces are plain text or [MarkerWord]s.
class Caption extends StatelessWidget {
  /// Lays out [pieces] as one centred paragraph.
  const Caption(this.pieces, {this.size = 46, this.color, super.key});

  /// Strings and widgets, in reading order.
  final List<Object> pieces;

  /// Font size.
  final double size;

  /// Text colour, defaulting to the surrounding style.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final style = DefaultTextStyle.of(context).style.copyWith(
      fontSize: size,
      fontWeight: FontWeight.w800,
      height: 1.18,
      color: color,
    );
    return Text.rich(
      TextSpan(
        style: style,
        children: [
          for (final piece in pieces)
            if (piece is String)
              TextSpan(text: piece)
            else
              WidgetSpan(
                alignment: PlaceholderAlignment.baseline,
                baseline: TextBaseline.alphabetic,
                child: DefaultTextStyle.merge(
                  style: style,
                  child: piece as Widget,
                ),
              ),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }
}

/// A pencil whose tip rests at [tip].
class Pencil extends StatelessWidget {
  /// Draws the pencil emoji with its tip at [tip] in the parent stack.
  const Pencil({required this.tip, this.size = 120, super.key});

  /// Where the tip touches the paper.
  final Offset tip;

  /// The emoji's size.
  final double size;

  @override
  Widget build(BuildContext context) => Positioned(
    // The drawn pencil points down and to the left.
    left: tip.dx - size * .1,
    top: tip.dy - size * .9,
    child: IgnorePointer(child: WiredEmoji('✏️', size: size)),
  );
}

/// The point [p] of the way around [rect]'s outline, clockwise from its top
/// left corner.
Offset aroundRect(Rect rect, double p) {
  final perimeter = 2 * (rect.width + rect.height);
  var d = p.clamp(0, 1) * perimeter;
  if (d <= rect.width) return rect.topLeft + Offset(d, 0);
  d -= rect.width;
  if (d <= rect.height) return rect.topRight + Offset(0, d);
  d -= rect.height;
  if (d <= rect.width) return rect.bottomRight - Offset(d, 0);
  d -= rect.width;
  return rect.bottomLeft - Offset(0, d);
}

/// The closing card every reel ends on: the logo drawing itself, the name,
/// the promise, and how to start.
class EndCard extends StatelessWidget {
  /// Shows the card from [start] seconds at reel time [t].
  const EndCard(this.t, this.start, {super.key});

  /// Reel time in seconds.
  final double t;

  /// When the card begins.
  final double start;

  @override
  Widget build(BuildContext context) {
    final local = t - start;
    final portrait = isPortrait(context);
    final theme = WiredTheme.of(context);
    final logo = WiredDrawTransition(
      progress: AlwaysStoppedAnimation(ease(span(local, 0, 1.3))),
      child: WiredLogo(size: portrait ? 200 : 180, semanticLabel: null),
    );
    final word = Opacity(
      opacity: span(local, .7, 1.2),
      child: Transform.translate(
        offset: Offset(0, 16 * (1 - pop(span(local, .7, 1.3)))),
        child: const Text(
          'skribble',
          style: TextStyle(
            fontSize: 84,
            fontWeight: FontWeight.w800,
            height: 1,
          ),
        ),
      ),
    );
    final promise = Opacity(
      opacity: span(local, 1.2, 1.6),
      child: Caption([
        'Put the ',
        MarkerWord('fun', progress: ease(span(local, 1.7, 2.3))),
        ' back in Flutter.',
      ], size: 30),
    );
    final install = Opacity(
      opacity: span(local, 2.3, 2.8),
      child: const WiredCard(
        height: null,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 22, vertical: 12),
          child: Text(
            'flutter pub add skribble',
            style: TextStyle(
              fontSize: 22,
              fontFamily: 'SkribbleMonoPlayful',
              package: 'skribble_font_recursive',
            ),
          ),
        ),
      ),
    );
    final url = Opacity(
      opacity: span(local, 2.7, 3.2),
      child: Text(
        'openbudgetfun.github.io/skribble',
        style: TextStyle(fontSize: 18, color: theme.disabledTextColor),
      ),
    );
    final words = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: portrait
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      children: [
        word,
        const SizedBox(height: 14),
        promise,
        const SizedBox(height: 22),
        install,
        const SizedBox(height: 12),
        url,
      ],
    );
    return Center(
      child: portrait
          ? Transform.scale(
              scale: 1.15,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [logo, const SizedBox(height: 18), words],
              ),
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [logo, const SizedBox(width: 40), words],
            ),
    );
  }
}

/// Emoji that burst out of [origin] at [at] seconds and float up and away.
class EmojiBurst extends StatelessWidget {
  /// Bursts [emoji] from [origin] at reel time [t].
  const EmojiBurst({
    required this.t,
    required this.at,
    required this.origin,
    required this.emoji,
    this.size = 56,
    super.key,
  });

  /// Reel time in seconds.
  final double t;

  /// When the burst starts.
  final double at;

  /// Where it starts, in the parent stack.
  final Offset origin;

  /// The emoji, in launch order.
  final List<String> emoji;

  /// Each emoji's size.
  final double size;

  @override
  Widget build(BuildContext context) {
    final local = t - at;
    if (local < 0 || local > 2.6) return const SizedBox.shrink();
    return Stack(
      clipBehavior: Clip.none,
      children: [
        for (final (i, e) in emoji.indexed)
          () {
            final p = span(local, i * .08, 2.2 + i * .08);
            final angle = -math.pi / 2 + (i - (emoji.length - 1) / 2) * .62;
            final reach = 120 + 300 * easeOut(p);
            final drift = Offset(math.cos(angle), math.sin(angle)) * reach;
            final fall = Offset(0, 120 * p * p);
            final point = origin + drift + fall;
            return Positioned(
              left: point.dx - size / 2,
              top: point.dy - size / 2,
              child: Opacity(
                opacity: (1 - span(p, .7, 1)) * span(p, 0, .08),
                child: Transform.scale(
                  scale: pop(span(p, 0, .25)),
                  child: WiredEmoji(e, size: size),
                ),
              ),
            );
          }(),
      ],
    );
  }
}
