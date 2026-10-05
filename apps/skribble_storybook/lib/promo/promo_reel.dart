import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:skribble/skribble.dart';
import 'package:skribble_emoji/skribble_emoji.dart';

/// How long the reel runs.
const Duration kPromoDuration = Duration(seconds: 34);

double _ease(double t) => Curves.easeInOutCubic.transform(t.clamp(0, 1));
double _out(double t) => Curves.easeOutBack.transform(t.clamp(0, 1));

/// 0→1 over [start, end] seconds of the reel.
double _span(double t, double start, double end) =>
    ((t - start) / (end - start)).clamp(0, 1).toDouble();

/// Fades a scene in over [fade] seconds at [start] and out before [end].
double _presence(double t, double start, double end, {double fade = .45}) {
  if (t < start || t > end) return 0;
  return math.min(_span(t, start, start + fade), 1 - _span(t, end - fade, end));
}

/// skribble's promotional reel: a scripted, 34-second tour of the design
/// system, drawn entirely with skribble's own widgets.
///
/// The reel is a pure function of [time], so it renders identically frame by
/// frame (`tool/render_promo_test.dart`, then `scripts/render_promo.sh`) and
/// plays live on the storybook's `/promo` route.
class PromoReel extends StatelessWidget {
  /// Draws the reel at [time] seconds from its start.
  const PromoReel({required this.time, super.key});

  /// Seconds since the reel began, from 0 to [kPromoDuration].
  final double time;

  @override
  Widget build(BuildContext context) {
    final t = time;
    final night = _span(t, 27.2, 28.2);
    final level = t < 13.6
        ? WiredRoughness.playful
        : t < 15.0
        ? WiredRoughness.gentle
        : t < 16.4
        ? WiredRoughness.playful
        : t < 17.4
        ? WiredRoughness.expressive
        : WiredRoughness.playful;
    final day = WiredThemeData.cuddly(roughnessLevel: level);
    final dark = WiredThemeData.cuddly(
      brightness: Brightness.dark,
      roughnessLevel: level,
    );
    final theme = night >= .5 && t < 30.6 ? dark : day;
    final paper = Color.lerp(
      day.fillColor,
      dark.fillColor,
      t < 30.6 ? night : 1 - _span(t, 30.4, 31),
    )!;
    return WiredMaterialApp(
      wiredTheme: theme,
      themeMode: ThemeMode.light,
      themeAnimationDuration: Duration.zero,
      home: ColoredBox(
        color: paper,
        child: DefaultTextStyle(
          style: TextStyle(
            fontFamily: theme.fontFamily,
            package: theme.fontPackage,
            color: theme.textColor,
            fontSize: 22,
            decoration: TextDecoration.none,
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              _scene(t, 0, 3.4, _Title(t)),
              _scene(t, 3, 6.8, _Tagline(t)),
              _scene(
                t,
                6.4,
                13.4,
                _Components(t, label: 'Every control, hand-drawn'),
              ),
              _scene(
                t,
                13.2,
                17.6,
                _Components(t, label: _levelLabel(level), still: true),
              ),
              _scene(t, 17.4, 23.2, _EmojiGrid(t)),
              _scene(t, 23, 27, _EmojiStage(t)),
              _scene(
                t,
                26.8,
                31,
                _Components(
                  t,
                  label: night < .5 ? 'Day paper' : 'Night paper',
                  still: true,
                ),
              ),
              _scene(t, 30.8, 34.2, _EndCard(t)),
            ],
          ),
        ),
      ),
    );
  }

  static String _levelLabel(WiredRoughness level) => switch (level) {
    WiredRoughness.gentle => 'Gentle ink',
    WiredRoughness.playful => 'Playful ink',
    WiredRoughness.expressive => 'Expressive ink',
  };

  Widget _scene(double t, double start, double end, Widget child) {
    final p = _presence(t, start, end);
    if (p <= 0) return const SizedBox.shrink();
    return Opacity(
      opacity: p,
      child: Transform.scale(scale: .96 + .04 * p, child: child),
    );
  }
}

class _Title extends StatelessWidget {
  const _Title(this.t);

  final double t;

  @override
  Widget build(BuildContext context) {
    final pop = _span(t, 0.2, 1);
    final word = _span(t, 0.8, 1.6);
    final line = _span(t, 1.4, 2.4);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Opacity(
            opacity: pop,
            child: Transform.scale(
              scale: .6 + .4 * _out(pop),
              child: const WiredLogo(size: 150),
            ),
          ),
          const SizedBox(height: 18),
          Opacity(
            opacity: word,
            child: Transform.translate(
              offset: Offset(0, 14 * (1 - _out(word))),
              child: const Text(
                'skribble',
                style: TextStyle(fontSize: 72, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          SizedBox(
            width: 260,
            child: WiredDrawTransition(
              progress: AlwaysStoppedAnimation(_ease(line)),
              child: const WiredDivider(),
            ),
          ),
        ],
      ),
    );
  }
}

class _Tagline extends StatelessWidget {
  const _Tagline(this.t);

  final double t;

  @override
  Widget build(BuildContext context) {
    final line = _span(t, 3.6, 4.6);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 36),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'A hand-drawn design system for Flutter',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.bold,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: 360,
              child: WiredDrawTransition(
                progress: AlwaysStoppedAnimation(_ease(line)),
                child: const WiredDivider(),
              ),
            ),
            const SizedBox(height: 14),
            Opacity(
              opacity: _span(t, 4.4, 5.2),
              child: const Text(
                'Every line inked by a pen.',
                style: TextStyle(fontSize: 22),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Components extends StatelessWidget {
  const _Components(this.t, {required this.label, this.still = false});

  final double t;
  final String label;
  final bool still;

  @override
  Widget build(BuildContext context) {
    final draw = still ? 1.0 : _ease(_span(t, 6.6, 8.2));
    final flip = still || t > 9.0;
    final slide = still ? .75 : .2 + .55 * _ease(_span(t, 9.4, 11));
    final chip = still || t > 11.4;
    final check = still || t > 12.0;
    final theme = WiredTheme.of(context);
    return Center(
      child: SizedBox(
        width: 440,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 18),
            WiredDrawTransition(
              progress: AlwaysStoppedAnimation(draw),
              child: WiredCard(
                height: null,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          WiredButton(
                            onPressed: () {},
                            child: const WiredEmojiText('Ship it 🚀'),
                          ),
                          const Spacer(),
                          WiredSwitch(value: flip, onChanged: (_) {}),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 8,
                        children: [
                          WiredChoiceChip(
                            label: const Text('Sketch'),
                            selected: !chip,
                            onSelected: (_) {},
                          ),
                          WiredChoiceChip(
                            label: const Text('Ink'),
                            selected: chip,
                            onSelected: (_) {},
                          ),
                          WiredChoiceChip(
                            label: const Text('Paint'),
                            onSelected: (_) {},
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      WiredSlider(value: slide, onChanged: (_) => true),
                      const SizedBox(height: 12),
                      WiredProgress(value: slide),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          WiredCheckbox(value: check, onChanged: (_) {}),
                          const SizedBox(width: 10),
                          Text(
                            'Made by hand',
                            style: TextStyle(color: theme.textColor),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

const List<String> _gridEmoji = [
  '😀',
  '😂',
  '🥰',
  '😎',
  '🤔',
  '😴',
  '🥳',
  '😭',
  '👋',
  '👍',
  '🙏',
  '💪',
  '👩🏽‍💻',
  '🧑🏿‍🎨',
  '👨🏻‍🍳',
  '🧙',
  '🐱',
  '🐶',
  '🦊',
  '🐼',
  '🦄',
  '🐙',
  '🌻',
  '🌵',
  '🍕',
  '🍣',
  '🥑',
  '🍩',
  '☕',
  '🍓',
  '🌮',
  '🧁',
  '🚀',
  '🚲',
  '🏝️',
  '🌈',
  '⛄',
  '🔥',
  '🎉',
  '🎸',
  '💡',
  '📚',
  '✏️',
  '🔑',
  '❤️',
  '✅',
  '🇯🇵',
  '🇳🇬',
];

class _EmojiGrid extends StatelessWidget {
  const _EmojiGrid(this.t);

  final double t;

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          '3,963 emoji, all drawn by hand',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: 456,
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final (index, emoji) in _gridEmoji.indexed)
                Transform.scale(
                  scale: _out(
                    _span(t, 17.8 + index * .045, 18.3 + index * .045),
                  ),
                  child: WiredAnimatedEmoji(emoji, size: 49),
                ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _EmojiStage extends StatelessWidget {
  const _EmojiStage(this.t);

  final double t;

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'and they move',
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 24),
        Wrap(
          spacing: 18,
          runSpacing: 18,
          alignment: WrapAlignment.center,
          children: [
            for (final emoji in const ['❤️', '😂', '👋', '🔥', '🎉', '🚀'])
              WiredAnimatedEmoji(emoji, size: 120),
          ],
        ),
      ],
    ),
  );
}

class _EndCard extends StatelessWidget {
  const _EndCard(this.t);

  final double t;

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const WiredLogo(size: 96),
        const SizedBox(height: 12),
        const Text(
          'skribble',
          style: TextStyle(fontSize: 60, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 18),
        Opacity(
          opacity: _span(t, 31.6, 32.2),
          child: const WiredCard(
            height: null,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
        ),
        const SizedBox(height: 14),
        Opacity(
          opacity: _span(t, 32, 32.6),
          child: const Text(
            'openbudgetfun.github.io/skribble',
            style: TextStyle(fontSize: 20),
          ),
        ),
      ],
    ),
  );
}
