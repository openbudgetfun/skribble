import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:skribble/skribble.dart';
import 'package:skribble_emoji/skribble_emoji.dart';

import '../reel_kit.dart';

/// "Fun again": a grey, generic app is scribbled out by a pencil and redrawn
/// by hand, then it comes alive. 23 seconds.
class FunAgainReel extends StatelessWidget {
  /// Draws the reel at [time] seconds.
  const FunAgainReel({required this.time, super.key});

  /// Seconds since the reel began.
  final double time;

  /// How long the reel runs.
  static const Duration duration = Duration(seconds: 23);

  @override
  Widget build(BuildContext context) {
    final t = time;
    return ReelStage(
      theme: WiredThemeData.cuddly(),
      child: Builder(
        builder: (context) {
          final portrait = isPortrait(context);
          final caption = Stack(
            alignment: Alignment.center,
            children: [
              Scene(t, .6, 5.8, child: _BoringCaption(t)),
              Scene(
                t,
                7.8,
                13.6,
                child: Caption([
                  'Let’s make apps ',
                  MarkerWord('fun', progress: ease(span(t, 8.6, 9.2))),
                  ' again.',
                ], size: portrait ? 50 : 54),
              ),
              Scene(
                t,
                13.4,
                16.8,
                child: Caption([
                  'Hand-drawn. Alive.\n',
                  MarkerWord(
                    'Still Flutter.',
                    progress: ease(span(t, 14.2, 14.9)),
                  ),
                ], size: portrait ? 46 : 50),
              ),
            ],
          );
          final visual = LayoutBuilder(
            builder: (context, constraints) {
              final center = constraints.biggest.center(Offset.zero);
              final wipe = span(t, 5.8, 7.2);
              final wiping = t > 5.6 && t < 7.9;
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  Center(
                    child: Scene(
                      t,
                      .3,
                      7.6,
                      fade: .5,
                      child: const _BoringApp(),
                    ),
                  ),
                  if (t > 4.2 && t < 7.2)
                    Positioned(
                      left: center.dx + 120,
                      top: center.dy - 215,
                      child: Opacity(
                        opacity: 1 - span(t, 6.4, 7),
                        child: Transform.scale(
                          scale: pop(span(t, 4.2, 4.6)),
                          child: const WiredAnimatedEmoji('🥱', size: 92),
                        ),
                      ),
                    ),
                  if (wiping) ...[
                    Positioned.fill(
                      child: Opacity(
                        opacity: 1 - span(t, 7.3, 7.9),
                        child: CustomPaint(
                          painter: _ScribbleWipe(
                            progress: ease(wipe),
                            center: center,
                          ),
                        ),
                      ),
                    ),
                    if (t < 7.4)
                      Pencil(
                        tip: _wipePoint(center, ease(wipe)),
                        size: 140,
                      ),
                  ],
                  Center(
                    child: Scene(
                      t,
                      8,
                      16.8,
                      child: WiredDrawTransition(
                        progress: AlwaysStoppedAnimation(
                          ease(span(t, 8.2, 10.2)),
                        ),
                        child: _PlansCard(t),
                      ),
                    ),
                  ),
                  if (t > 13.6 && t < 16.8)
                    EmojiBurst(
                      t: t,
                      at: 13.7,
                      origin: center + const Offset(0, 160),
                      emoji: const ['🎉', '❤️', '😂', '✨', '🔥', '🥳'],
                      size: 64,
                    ),
                ],
              );
            },
          );
          return Stack(
            fit: StackFit.expand,
            children: [
              if (t < 17.2)
                Padding(
                  padding: portrait
                      ? const EdgeInsets.fromLTRB(36, 90, 36, 40)
                      : const EdgeInsets.fromLTRB(56, 40, 40, 40),
                  child: portrait
                      ? Column(
                          children: [
                            SizedBox(height: 250, child: caption),
                            Expanded(
                              child: Transform.scale(
                                scale: 1.22,
                                child: visual,
                              ),
                            ),
                          ],
                        )
                      : Row(
                          children: [
                            SizedBox(width: 420, child: caption),
                            const SizedBox(width: 24),
                            Expanded(child: visual),
                          ],
                        ),
                ),
              Scene(t, 16.8, 23.4, child: EndCard(t, 16.9)),
            ],
          );
        },
      ),
    );
  }
}

/// Where the pencil is at [p] of the wipe: a fast zigzag down the app.
Offset _wipePoint(Offset center, double p) => Offset(
  center.dx + 150 * math.sin(p * math.pi * 9),
  center.dy - 210 + 420 * p,
);

class _ScribbleWipe extends CustomPainter {
  _ScribbleWipe({required this.progress, required this.center});

  final double progress;
  final Offset center;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();
    const steps = 240;
    for (var i = 0; i <= steps; i++) {
      final point = _wipePoint(center, i / steps);
      i == 0
          ? path.moveTo(point.dx, point.dy)
          : path.lineTo(point.dx, point.dy);
    }
    final drawn = Path();
    for (final metric in path.computeMetrics()) {
      drawn.addPath(
        metric.extractPath(0, metric.length * progress),
        Offset.zero,
      );
    }
    canvas.drawPath(
      drawn,
      Paint()
        ..color = WiredPalette.ink
        ..style = PaintingStyle.stroke
        ..strokeWidth = 16
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(_ScribbleWipe old) => old.progress != progress;
}

const _plain = TextStyle(
  fontFamily: 'SkribbleLinearGentle',
  package: 'skribble_font_recursive',
  color: Color(0xFF6F6F6F),
);

/// The first caption, set in a plain sans like the app it describes.
class _BoringCaption extends StatelessWidget {
  const _BoringCaption(this.t);

  final double t;

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(
        'Every app\nlooks the same.',
        textAlign: TextAlign.center,
        style: _plain.copyWith(
          fontSize: 46,
          height: 1.15,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF4A4A4A),
        ),
      ),
      const SizedBox(height: 18),
      Opacity(
        opacity: span(t, 2.4, 3),
        child: Text(
          'Grey boxes. Straight lines.\nNo personality.',
          textAlign: TextAlign.center,
          style: _plain.copyWith(fontSize: 24, height: 1.35),
        ),
      ),
    ],
  );
}

/// A generic app: grey boxes, hairlines, and a shouting button.
class _BoringApp extends StatelessWidget {
  const _BoringApp();

  @override
  Widget build(BuildContext context) {
    const line = Color(0xFFE0E0E0);
    Widget row(String label) => Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: line)),
      ),
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFBDBDBD), width: 2),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(width: 14),
          Text(label, style: _plain.copyWith(fontSize: 18)),
        ],
      ),
    );
    return Container(
      width: 360,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: line),
        borderRadius: BorderRadius.circular(10),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 60,
            color: const Color(0xFFEEEEEE),
            padding: const EdgeInsets.symmetric(horizontal: 18),
            alignment: Alignment.centerLeft,
            child: Text(
              'Tasks',
              style: _plain.copyWith(fontSize: 22, fontWeight: FontWeight.w600),
            ),
          ),
          row('Item 1'),
          row('Item 2'),
          row('Item 3'),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                Text('Notifications', style: _plain.copyWith(fontSize: 18)),
                const Spacer(),
                Container(
                  width: 44,
                  height: 24,
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFBDBDBD),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.centerLeft,
                  child: const DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: SizedBox.square(dimension: 18),
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 48,
            margin: const EdgeInsets.fromLTRB(18, 0, 18, 18),
            decoration: BoxDecoration(
              color: const Color(0xFF9E9E9E),
              borderRadius: BorderRadius.circular(4),
            ),
            alignment: Alignment.center,
            child: Text(
              'SUBMIT',
              style: _plain.copyWith(
                fontSize: 17,
                color: Colors.white,
                letterSpacing: 1.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// The same app, drawn by hand, and then used.
class _PlansCard extends StatelessWidget {
  const _PlansCard(this.t);

  final double t;

  @override
  Widget build(BuildContext context) {
    const items = [
      ('🌻', 'Plant sunflowers', 11.0),
      ('🍕', 'Pizza night', 11.6),
      ('🎸', 'Learn one song', 12.2),
    ];
    final done = items.where((item) => t > item.$3).length;
    final press = t > 13.5 && t < 13.75 ? .94 : 1.0;
    return SizedBox(
      width: 380,
      child: WiredCard(
        height: null,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 20, 22, 22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Text(
                    'Weekend plans',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
                  ),
                  SizedBox(width: 10),
                  WiredEmoji('🌈', size: 32),
                ],
              ),
              const SizedBox(height: 14),
              for (final (emoji, label, at) in items)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Row(
                    children: [
                      WiredCheckbox(value: t > at, onChanged: (_) {}),
                      const SizedBox(width: 12),
                      WiredEmojiText(
                        '$emoji  $label',
                        style: const TextStyle(fontSize: 21),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 12),
              WiredProgress(value: done / items.length),
              const SizedBox(height: 16),
              Row(
                children: [
                  const WiredEmojiText(
                    'Remind me 🔔',
                    style: TextStyle(fontSize: 20),
                  ),
                  const Spacer(),
                  WiredSwitch(value: t > 12.8, onChanged: (_) {}),
                ],
              ),
              const SizedBox(height: 18),
              Center(
                child: Transform.scale(
                  scale: press,
                  child: WiredButton(
                    onPressed: () {},
                    child: const WiredEmojiText(
                      'Let’s go 🚀',
                      style: TextStyle(fontSize: 21),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
