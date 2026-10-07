import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:skribble/skribble.dart';
import 'package:skribble_emoji/skribble_emoji.dart';

import '../reel_kit.dart';

/// "Emoji party": big emoji on the beat, a wall of thousands, every skin
/// tone, and emoji in a chat. 20 seconds.
class EmojiPartyReel extends StatelessWidget {
  /// Draws the reel at [time] seconds.
  const EmojiPartyReel({required this.time, super.key});

  /// Seconds since the reel began.
  final double time;

  /// How long the reel runs.
  static const Duration duration = Duration(seconds: 20);

  @override
  Widget build(BuildContext context) {
    final t = time;
    return ReelStage(
      theme: WiredThemeData.cuddly(),
      child: Builder(
        builder: (context) {
          final portrait = isPortrait(context);
          return Stack(
            fit: StackFit.expand,
            children: [
              Scene(t, 0, 5.8, fade: .2, child: _Beats(t, portrait: portrait)),
              Scene(t, 5.6, 10.6, child: _Wall(t, portrait: portrait)),
              Scene(t, 10.4, 13.6, child: _Tones(t, portrait: portrait)),
              Scene(t, 13.4, 16.9, child: _Chat(t, portrait: portrait)),
              Scene(t, 16.8, 20.4, child: EndCard(t, 16.9)),
            ],
          );
        },
      ),
    );
  }
}

const List<String> _beats = [
  '😀',
  '❤️',
  '😂',
  '👋',
  '🔥',
  '🎉',
  '🦄',
  '🍕',
  '🚀',
  '✨',
];

const List<Color> _spots = [
  WiredPalette.lilac,
  WiredPalette.peach,
  WiredPalette.sage,
  WiredPalette.butter,
];

/// Big emoji, one on each beat, over a marker spot.
class _Beats extends StatelessWidget {
  const _Beats(this.t, {required this.portrait});

  final double t;
  final bool portrait;

  @override
  Widget build(BuildContext context) {
    const beat = .52;
    final index = ((t - .2) / beat).floor().clamp(0, _beats.length - 1);
    final local = t - .2 - index * beat;
    final size = portrait ? 300.0 : 250.0;
    final arrive = pop(span(local, 0, .22));
    final words = index < 4
        ? Caption(const ['Hand-drawn'], size: 64)
        : index < 7
        ? Caption(const ['emoji'], size: 64)
        : Caption([
            'that ',
            MarkerWord('move.', progress: ease(span(t, 4, 4.5))),
          ], size: 64);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox.square(
            dimension: size * 1.25,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Transform.scale(
                  scale: .7 + .3 * arrive,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: _spots[index % _spots.length],
                      shape: BoxShape.circle,
                    ),
                    child: SizedBox.square(dimension: size * 1.1),
                  ),
                ),
                Transform.rotate(
                  angle: (index.isEven ? 1 : -1) * .08 * (1 - arrive),
                  child: Transform.scale(
                    scale: .55 + .45 * arrive,
                    child: WiredAnimatedEmoji(
                      _beats[index],
                      key: ValueKey(index),
                      size: size,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: portrait ? 40 : 18),
          words,
        ],
      ),
    );
  }
}

/// A spread of everyday emoji from across the catalogue.
final List<String> _wallEmoji = () {
  final everyday = [
    for (final entry in SkribbleEmoji.all)
      if (entry.tone == EmojiSkinTone.none &&
          entry.group != EmojiGroup.flags &&
          entry.group != EmojiGroup.component)
        entry.emoji,
  ];
  const count = 160;
  final step = everyday.length / count;
  return [for (var i = 0; i < count; i++) everyday[(i * step).floor()]];
}();

String _thousands(int value) => value.toString().replaceAllMapped(
  RegExp(r'\B(?=(\d{3})+(?!\d))'),
  (_) => ',',
);

/// The wall: emoji cascade out from the centre around a running count.
class _Wall extends StatelessWidget {
  const _Wall(this.t, {required this.portrait});

  final double t;
  final bool portrait;

  @override
  Widget build(BuildContext context) {
    const cell = 60.0;
    final columns = portrait ? 9 : 16;
    final rows = portrait ? 16 : 9;
    final count = (3963 * easeOut(span(t, 6.3, 8.2))).round();
    final theme = WiredTheme.of(context);
    return Stack(
      alignment: Alignment.center,
      children: [
        Center(
          child: SizedBox(
            width: columns * cell,
            height: rows * cell,
            child: Stack(
              children: [
                for (var row = 0; row < rows; row++)
                  for (var column = 0; column < columns; column++)
                    () {
                      final dx = column - (columns - 1) / 2;
                      final dy = row - (rows - 1) / 2;
                      final distance = math.sqrt(dx * dx + dy * dy);
                      final appear = pop(
                        span(t, 5.7 + distance * .07, 6.1 + distance * .07),
                      );
                      final bob = math.sin(t * 3 + distance) * 2;
                      return Positioned(
                        left: column * cell,
                        top: row * cell + bob,
                        child: Transform.scale(
                          scale: appear,
                          child: SizedBox.square(
                            dimension: cell,
                            child: Center(
                              child: WiredEmoji(
                                _wallEmoji[(row * columns + column) %
                                    _wallEmoji.length],
                                size: cell * .78,
                              ),
                            ),
                          ),
                        ),
                      );
                    }(),
              ],
            ),
          ),
        ),
        Opacity(
          opacity: span(t, 6.2, 6.6),
          child: Transform.scale(
            scale: .9 + .1 * pop(span(t, 6.2, 6.7)),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: theme.fillColor,
                borderRadius: BorderRadius.circular(18),
              ),
              child: WiredCard(
                height: null,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 34,
                    vertical: 22,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _thousands(count),
                        style: const TextStyle(
                          fontSize: 96,
                          fontWeight: FontWeight.w800,
                          height: 1,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Caption([
                        'emoji, every one\n',
                        MarkerWord(
                          'drawn by hand',
                          progress: ease(span(t, 8.2, 8.8)),
                        ),
                      ], size: 28),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Every skin tone, popping in hand by hand.
class _Tones extends StatelessWidget {
  const _Tones(this.t, {required this.portrait});

  final double t;
  final bool portrait;

  @override
  Widget build(BuildContext context) {
    final size = portrait ? 72.0 : 84.0;
    Widget row(String base, double start) {
      final entry = SkribbleEmoji.lookup(base)!;
      return Wrap(
        spacing: 8,
        children: [
          for (final (index, tone) in EmojiSkinTone.values.indexed)
            Transform.scale(
              scale: pop(
                span(t, start + index * .12, start + .3 + index * .12),
              ),
              child: WiredAnimatedEmoji(
                SkribbleEmoji.withTone(entry, tone)!.emoji,
                size: size,
              ),
            ),
        ],
      );
    }

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Caption([
            'In every ',
            MarkerWord('skin tone.', progress: ease(span(t, 11, 11.6))),
          ], size: portrait ? 48 : 54),
          const SizedBox(height: 36),
          row('👋', 10.6),
          const SizedBox(height: 18),
          row('🧑‍💻', 11.2),
          const SizedBox(height: 18),
          row('👍', 11.8),
        ],
      ),
    );
  }
}

/// Emoji right in ordinary Flutter text: a little chat.
class _Chat extends StatelessWidget {
  const _Chat(this.t, {required this.portrait});

  final double t;
  final bool portrait;

  @override
  Widget build(BuildContext context) {
    Widget bubble(String text, double at, {required bool mine}) {
      final p = pop(span(t, at, at + .35));
      return Align(
        alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
        child: Opacity(
          opacity: span(t, at, at + .15),
          child: Transform.scale(
            scale: .6 + .4 * p,
            alignment: mine ? Alignment.bottomRight : Alignment.bottomLeft,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: WiredCard(
                height: null,
                fill: mine,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                  child: WiredEmojiText(
                    text,
                    style: const TextStyle(fontSize: 26),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Center(
      child: SizedBox(
        width: portrait ? 460 : 620,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Caption([
              'Right in your\n',
              MarkerWord('Flutter text.', progress: ease(span(t, 14, 14.6))),
            ], size: portrait ? 46 : 50),
            const SizedBox(height: 30),
            bubble('Shipped the new build 🚀', 13.8, mine: true),
            bubble('It looks so good 😍', 14.6, mine: false),
            bubble('Hand-drawn?! 🤯', 15.3, mine: false),
            bubble('Every line ✏️🎉', 16, mine: true),
          ],
        ),
      ),
    );
  }
}
