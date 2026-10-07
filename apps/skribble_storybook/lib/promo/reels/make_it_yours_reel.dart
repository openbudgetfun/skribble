import 'package:flutter/material.dart';
import 'package:skribble/skribble.dart';
import 'package:skribble_emoji/skribble_emoji.dart';

import '../reel_kit.dart';

/// "Make it yours": one app, restyled live by its theme: the ink, the
/// handwriting, the marker, and the paper. 22 seconds.
class MakeItYoursReel extends StatelessWidget {
  /// Draws the reel at [time] seconds.
  const MakeItYoursReel({required this.time, super.key});

  /// Seconds since the reel began.
  final double time;

  /// How long the reel runs.
  static const Duration duration = Duration(seconds: 22);

  @override
  Widget build(BuildContext context) {
    final t = time;
    final style = _Style.at(t);
    final night = t < 17.2 ? span(t, 14.2, 14.8) : 1 - span(t, 17, 17.6);
    final dayPaper = WiredThemeData.cuddly().fillColor;
    final nightPaper = WiredThemeData.cuddly(
      brightness: Brightness.dark,
    ).fillColor;
    return ReelStage(
      theme: style.theme,
      paper: Color.lerp(dayPaper, nightPaper, night),
      child: Builder(
        builder: (context) {
          final portrait = isPortrait(context);
          final size = portrait ? 56.0 : 54.0;
          final caption = Stack(
            alignment: Alignment.center,
            children: [
              Scene(t, .3, 2.9, child: Caption(['One app.'], size: size)),
              Scene(
                t,
                2.8,
                7.3,
                child: Caption([
                  'Your ',
                  MarkerWord('ink.', progress: ease(span(t, 3.2, 3.7))),
                ], size: size),
              ),
              Scene(
                t,
                7.2,
                10.7,
                child: Caption([
                  'Your ',
                  MarkerWord('handwriting.', progress: ease(span(t, 7.6, 8.1))),
                ], size: size),
              ),
              Scene(
                t,
                10.6,
                14.1,
                child: Caption([
                  'Your ',
                  MarkerWord('marker.', progress: ease(span(t, 11, 11.5))),
                ], size: size),
              ),
              Scene(
                t,
                14,
                17.7,
                child: Caption([
                  'Your ',
                  MarkerWord('paper.', progress: ease(span(t, 14.4, 14.9))),
                ], size: size),
              ),
            ],
          );
          final card = WiredDrawTransition(
            progress: AlwaysStoppedAnimation(ease(span(t, .5, 2.3))),
            child: _DemoCard(style),
          );
          final controls = Opacity(
            opacity: span(t, 2.2, 2.8),
            child: _Controls(style),
          );
          return Stack(
            fit: StackFit.expand,
            children: [
              if (t < 17.9)
                Opacity(
                  opacity: 1 - span(t, 17.5, 17.9),
                  child: Padding(
                    padding: portrait
                        ? const EdgeInsets.fromLTRB(30, 80, 30, 50)
                        : const EdgeInsets.fromLTRB(40, 30, 40, 30),
                    child: Column(
                      children: [
                        SizedBox(height: portrait ? 150 : 100, child: caption),
                        const SizedBox(height: 10),
                        Expanded(
                          child: FittedBox(
                            child: portrait
                                ? Column(
                                    children: [
                                      card,
                                      const SizedBox(height: 34),
                                      controls,
                                    ],
                                  )
                                : Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      card,
                                      const SizedBox(width: 40),
                                      controls,
                                    ],
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              Scene(t, 17.7, 22.4, child: EndCard(t, 17.8)),
            ],
          );
        },
      ),
    );
  }
}

/// The theme choices at a moment of the reel.
final class _Style {
  const _Style({
    required this.level,
    required this.font,
    required this.marker,
    required this.night,
  });

  /// The choices the reel shows at [t] seconds.
  factory _Style.at(double t) => _Style(
    level: t >= 3.4 && t < 4.8
        ? WiredRoughness.gentle
        : t >= 4.8 && t < 6.2
        ? WiredRoughness.expressive
        : WiredRoughness.playful,
    font: t >= 8.2 && t < 9.4
        ? WiredFont.linear
        : t >= 9.4 && t < 10.4
        ? WiredFont.mono
        : WiredFont.casual,
    marker: t >= 11.4 && t < 12.2
        ? 1
        : t >= 12.2 && t < 13.0
        ? 2
        : t >= 13.0 && t < 13.8
        ? 3
        : 0,
    night: t >= 14.5 && t < 17.3,
  );

  final WiredRoughness level;
  final WiredFont font;
  final int marker;
  final bool night;

  static const List<(String, Color)> markers = [
    ('Lilac', WiredPalette.lilac),
    ('Peach', WiredPalette.peach),
    ('Sage', WiredPalette.sage),
    ('Butter', WiredPalette.butter),
  ];

  WiredThemeData get theme =>
      WiredThemeData.cuddly(
        brightness: night ? Brightness.dark : Brightness.light,
        roughnessLevel: level,
      ).copyWith(
        font: font,
        markerColor: night ? WiredPalette.dusk : markers[marker].$2,
      );
}

/// The app being restyled.
class _DemoCard extends StatelessWidget {
  const _DemoCard(this.style);

  final _Style style;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 420,
    child: WiredCard(
      height: null,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 22, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Text(
                  'Morning pages',
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800),
                ),
                SizedBox(width: 10),
                WiredEmoji('☕', size: 34),
              ],
            ),
            const SizedBox(height: 14),
            for (final (emoji, label, done) in const [
              ('✍️', 'Three pages', true),
              ('🌿', 'Water the plants', true),
              ('🎧', 'One new album', false),
            ])
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Row(
                  children: [
                    WiredCheckbox(value: done, onChanged: (_) {}),
                    const SizedBox(width: 12),
                    WiredEmojiText(
                      '$emoji  $label',
                      style: const TextStyle(fontSize: 22),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 14),
            const Text('Focus', style: TextStyle(fontSize: 18)),
            WiredSlider(value: .68, onChanged: (_) => true),
            const SizedBox(height: 6),
            Row(
              children: [
                const WiredEmojiText(
                  'Quiet mode 🌙',
                  style: TextStyle(fontSize: 21),
                ),
                const Spacer(),
                WiredSwitch(value: true, onChanged: (_) {}),
              ],
            ),
            const SizedBox(height: 18),
            WiredButton(
              onPressed: () {},
              child: const WiredEmojiText(
                'Save ✨',
                style: TextStyle(fontSize: 22),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

/// The theme's knobs, showing what the reel has chosen.
class _Controls extends StatelessWidget {
  const _Controls(this.style);

  final _Style style;

  @override
  Widget build(BuildContext context) {
    final theme = WiredTheme.of(context);
    Widget group(String label, List<Widget> chips) => Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 15,
              letterSpacing: 2,
              color: theme.disabledTextColor,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(spacing: 8, runSpacing: 8, children: chips),
        ],
      ),
    );
    Widget chip(String label, {required bool selected}) => WiredChoiceChip(
      label: Text(label, style: const TextStyle(fontSize: 19)),
      selected: selected,
      onSelected: (_) {},
    );
    return SizedBox(
      width: 420,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          group('Ink', [
            for (final level in WiredRoughness.values)
              chip(switch (level) {
                WiredRoughness.gentle => 'Gentle',
                WiredRoughness.playful => 'Playful',
                WiredRoughness.expressive => 'Expressive',
              }, selected: style.level == level),
          ]),
          group('Handwriting', [
            for (final font in WiredFont.values)
              chip(switch (font) {
                WiredFont.casual => 'Casual',
                WiredFont.linear => 'Linear',
                WiredFont.mono => 'Mono',
              }, selected: style.font == font),
          ]),
          group('Marker', [
            for (final (index, (name, colour)) in _Style.markers.indexed)
              WiredChoiceChip(
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: colour,
                        shape: BoxShape.circle,
                        border: Border.all(color: theme.borderColor),
                      ),
                      child: const SizedBox.square(dimension: 16),
                    ),
                    const SizedBox(width: 6),
                    Text(name, style: const TextStyle(fontSize: 19)),
                  ],
                ),
                selected: !style.night && style.marker == index,
                onSelected: (_) {},
              ),
          ]),
          group('Paper', [
            chip('Day', selected: !style.night),
            chip('Night', selected: style.night),
          ]),
        ],
      ),
    );
  }
}
