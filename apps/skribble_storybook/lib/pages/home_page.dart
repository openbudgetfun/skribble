import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:skribble/skribble.dart';
import 'package:skribble_emoji/skribble_emoji.dart';
import 'package:skribble_storybook/testing/chart_keys.dart';
import 'package:skribble_storybook/testing/map_keys.dart';

/// The storybook's front page: what skribble is, a few controls to play
/// with, and a door into every category.
class HomePage extends HookWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return WiredScaffold(
      appBar: WiredAppBar(title: const Text('Skribble Storybook')),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final columns = width >= 1040
              ? 3
              : width >= 640
              ? 2
              : 1;
          return ListView(
            padding: EdgeInsets.symmetric(
              horizontal: width >= 720 ? 32 : 16,
              vertical: 24,
            ),
            children: [
              const _Hero(),
              const SizedBox(height: 28),
              const _Playground(),
              const SizedBox(height: 36),
              const Text('Explore', style: _sectionTitle),
              const SizedBox(height: 12),
              _CategoryGrid(columns: columns),
            ],
          );
        },
      ),
    );
  }
}

const TextStyle _sectionTitle = TextStyle(
  fontSize: 22,
  fontWeight: FontWeight.bold,
);

class _Hero extends StatelessWidget {
  const _Hero();

  @override
  Widget build(BuildContext context) {
    final theme = WiredTheme.of(context);
    return Column(
      children: [
        const WiredLogo(size: 84),
        const SizedBox(height: 12),
        const Text(
          'Hand-drawn UI components for Flutter',
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Text(
            'Every line is inked by a pen and every emoji is drawn by hand. '
            'Change the ink, typeface, or paper above and watch it all '
            'redraw.',
            style: TextStyle(fontSize: 16, color: theme.disabledTextColor),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          children: [
            for (final emoji in const ['✏️', '❤️', '🎉', '👋', '🚀', '✨'])
              _HeroEmoji(emoji),
          ],
        ),
      ],
    );
  }
}

/// An emoji that plays twice on arrival, then again while it is hovered.
class _HeroEmoji extends HookWidget {
  const _HeroEmoji(this.emoji);

  final String emoji;

  @override
  Widget build(BuildContext context) {
    final hovered = useState(false);
    return MouseRegion(
      onEnter: (_) => hovered.value = true,
      onExit: (_) => hovered.value = false,
      child: WiredAnimatedEmoji(
        emoji,
        size: 40,
        loops: hovered.value ? null : 2,
      ),
    );
  }
}

/// A handful of live controls wired to each other, so the first thing a
/// visitor does is touch something.
class _Playground extends HookWidget {
  const _Playground();

  @override
  Widget build(BuildContext context) {
    final shipped = useState(0);
    final amount = useState(.4);
    final notify = useState(true);
    final remember = useState(false);

    Widget labelled(Widget control, String label) => Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        control,
        const SizedBox(width: 8),
        Flexible(child: Text(label)),
      ],
    );

    return WiredCard(
      height: null,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Have a go', style: _sectionTitle),
            const SizedBox(height: 16),
            Wrap(
              spacing: 24,
              runSpacing: 16,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                WiredButton(
                  onPressed: () => shipped.value++,
                  child: const WiredEmojiText('Ship it 🚀'),
                ),
                labelled(
                  WiredSwitch(
                    value: notify.value,
                    onChanged: (value) => notify.value = value,
                    semanticLabel: 'Notifications',
                  ),
                  'Notifications',
                ),
                labelled(
                  WiredCheckbox(
                    value: remember.value,
                    onChanged: (value) => remember.value = value ?? false,
                    semanticLabel: 'Remember me',
                  ),
                  'Remember me',
                ),
              ],
            ),
            const SizedBox(height: 16),
            WiredEmojiText(
              shipped.value == 0
                  ? 'Nothing shipped yet 🌱'
                  : 'Shipped ${shipped.value} '
                        '${shipped.value == 1 ? 'time' : 'times'} 🎉',
            ),
            const SizedBox(height: 20),
            WiredSlider(
              value: amount.value,
              semanticLabel: 'Progress',
              onChanged: (value) {
                amount.value = value;
                return true;
              },
            ),
            const SizedBox(height: 12),
            WiredProgress(value: amount.value, semanticLabel: 'Progress'),
          ],
        ),
      ),
    );
  }
}

class _CategoryGrid extends StatelessWidget {
  const _CategoryGrid({required this.columns});

  final int columns;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      const gap = 12.0;
      final width = (constraints.maxWidth - gap * (columns - 1)) / columns;
      return Wrap(
        spacing: gap,
        runSpacing: gap,
        children: [
          for (final category in _categories)
            SizedBox(
              width: width,
              child: _CategoryCard(category: category),
            ),
        ],
      );
    },
  );
}

/// One category: its emoji comes alive while the card is hovered or
/// focused.
class _CategoryCard extends HookWidget {
  const _CategoryCard({required this.category});

  final _Category category;

  @override
  Widget build(BuildContext context) {
    final theme = WiredTheme.of(context);
    final active = useState(false);
    return WiredCard(
      height: null,
      child: InkWell(
        key: switch (category.route) {
          '/charts' => ChartDemoKeys.category,
          '/maps' => MapDemoKeys.category,
          _ => null,
        },
        onTap: () => Navigator.pushNamed(context, category.route),
        onHover: (value) => active.value = value,
        onFocusChange: (value) => active.value = value,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              // The title names the category; the emoji is decoration.
              ExcludeSemantics(
                child: WiredAnimatedEmoji(
                  category.emoji,
                  size: 40,
                  animating: active.value,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      category.description,
                      style: TextStyle(
                        fontSize: 14,
                        color: theme.disabledTextColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Category {
  const _Category({
    required this.title,
    required this.description,
    required this.route,
    required this.emoji,
  });

  final String title;
  final String description;
  final String route;
  final String emoji;
}

const _categories = [
  _Category(
    title: 'The reel',
    description: 'skribble in 34 seconds, drawn with its own widgets.',
    route: '/promo',
    emoji: '🎞️',
  ),
  _Category(
    title: 'The sketchbook',
    description: 'A working notebook in morning paper and evening ink.',
    route: '/studio',
    emoji: '📓',
  ),
  _Category(
    title: 'Buttons',
    description: 'Filled, outlined, text, icon, and floating buttons.',
    route: '/buttons',
    emoji: '👆',
  ),
  _Category(
    title: 'Inputs',
    description: 'Text fields, checkboxes, radios, sliders, and switches.',
    route: '/inputs',
    emoji: '✍️',
  ),
  _Category(
    title: 'Navigation',
    description: 'App bars, tabs, drawers, and navigation rails.',
    route: '/navigation',
    emoji: '🧭',
  ),
  _Category(
    title: 'Selection',
    description: 'Chips, filters, and choice pickers.',
    route: '/selection',
    emoji: '✅',
  ),
  _Category(
    title: 'Feedback',
    description: 'Progress, dialogs, banners, and snack bars.',
    route: '/feedback',
    emoji: '💬',
  ),
  _Category(
    title: 'Layout',
    description: 'Cards, dividers, list tiles, and expansion tiles.',
    route: '/layout',
    emoji: '📐',
  ),
  _Category(
    title: 'Data Display',
    description: 'Calendars, date and time pickers, steppers, and tables.',
    route: '/data-display',
    emoji: '📅',
  ),
  _Category(
    title: 'Financial charts',
    description: 'Precise candles, inked indicators, and your own notes.',
    route: '/charts',
    emoji: '📈',
  ),
  _Category(
    title: 'Maps',
    description: 'Clear maps with hand-drawn routes, areas, and pins.',
    route: '/maps',
    emoji: '🗺️',
  ),
  _Category(
    title: 'Emoji',
    description: 'Every Unicode emoji, drawn for skribble and inked live.',
    route: '/emoji',
    emoji: '😀',
  ),
  _Category(
    title: 'Skribble Icons',
    description: 'Glyphs, Material, Lucide, Simple Icons, and more, inked.',
    route: '/skribble-icons',
    emoji: '⭐',
  ),
  _Category(
    title: 'Rough Icons',
    description: 'Every generated Material icon in one gallery.',
    route: '/rough-icons',
    emoji: '✏️',
  ),
  _Category(
    title: 'Ink in motion',
    description: 'Borders that draw themselves and ink that responds.',
    route: '/motion',
    emoji: '🎬',
  ),
  _Category(
    title: 'Loading and skeletons',
    description: 'Loaders, skeletons, and a sketched loading screen.',
    route: '/loading',
    emoji: '⏳',
  ),
  _Category(
    title: 'Doodles and fills',
    description: 'Hatching, cross-hatching, dots, and freehand doodles.',
    route: '/drawing',
    emoji: '🖍️',
  ),
  _Category(
    title: 'Font Specimen',
    description: 'Every glyph of the bundled hand-drawn typeface.',
    route: '/font-specimen',
    emoji: '🔤',
  ),
  _Category(
    title: 'Variable fonts',
    description: 'Casual, linear, and mono, on every axis.',
    route: '/variable-fonts',
    emoji: '🎚️',
  ),
];
