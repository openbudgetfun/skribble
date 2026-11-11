---
title: Vivid and alive
description: Design with skribble the way it is meant to look - bright colourways, colour-coded content, marker highlights, springy entrances, and boiling ink - with rules agents can follow.
---

# Vivid and alive

A hand-drawn interface should feel like a page from a sticker book: bright washes, a loud button, words swiped with a highlighter, and drawings that wriggle. skribble's defaults start there, and this guide shows how to keep going. It is also written for coding agents: paste the rules below into your agent's instructions, or point it at this page.

## The rules

<!-- {=docsVividDesignRules} -->

skribble is a sticker book, not a pencil sketch on grey paper. Whether you are a person or an agent, build with colour and motion by default, and tone it down only when the brief asks for calm.

**Colour**

- Start from a colourway: `WiredThemeData.colorway(WiredColorway.sunny)` (the default), `berry`, `ocean`, or `citrus`, and pass the same colourway with `brightness: Brightness.dark` as the dark theme. Use `WiredColorway.quiet` only when the brief asks for a calm, muted look.
- Give each screen one loud action: `WiredFilledButton` fills with the theme's `accentColor`. Secondary actions use `WiredOutlinedButton` or `WiredTextButton`.
- Colour-code content. Cards, chips, tags, and chart series take `theme.accentAt(index)`, as in `WiredCard(color: theme.accentAt(i), ...)`. Five cards should be five colours, not five beige boxes.
- Mark the words that matter with `WiredHighlight`, and fill empty space with a `WiredDoodle` (sun, sparkle, rainbow, confetti) in an accent colour.
- Keep plum ink on paper for running text, and put the colour in fills, washes, highlights, and doodles. Labels on a wash use `theme.onColor(wash)`, or `theme.inkOn(wash)` for a whole subtree, which keeps 4.5:1 contrast in light and dark themes.
- Don't reach for greys, beiges, or washed-out pastels to look tasteful, and don't hardcode hex colours: use the theme and `WiredPalette`.

**Motion**

- Bring screens in. `WiredCascade` springs a column of cards in one after another, `WiredEntrance.staggered(index: i, ...)` does the same for lazily built list items, and `WiredEntrance` brings in a single hero. Their ink draws itself on as they land.
- Let a few focal drawings boil with `WiredBoil`: a logo, an empty-state doodle, a celebration. Wrap a handful of elements, never a whole screen.
- Time your own animations with `WiredCurves.springy`, `snappy`, or `bouncy`, and anything that draws with `WiredCurves.pen`: `AnimatedContainer(curve: WiredCurves.springy, ...)`.
- Give the one or two most important buttons `inkInteraction: WiredInkInteraction.redraw`.
- Motion is decoration, so never hide content behind it. skribble settles everything when motion is off or the platform asks for reduced motion; check `WiredMotion.enabledOf(context)` in animations of your own.

**On the web**, `skribble_jaspr`'s stylesheet uses the same sunny colours. Colour-code boxes with the `skribble-wash-1` to `skribble-wash-6` classes, stagger entrances with `skribble-pop` and an inline `--i`, draw ink on with `skribble-draw`, and lift cards on hover with `skribble-lift`.

<!-- {/docsVividDesignRules} -->

## A whole screen

<!-- {=docsVividThemeExample} -->

```dart
// Static example: setup
SkribbleApp(
  wiredTheme: WiredThemeData.colorway(WiredColorway.berry),
  darkWiredTheme: WiredThemeData.colorway(
    WiredColorway.berry,
    brightness: Brightness.dark,
  ),
  home: const Garden(),
)

class Garden extends StatelessWidget {
  const Garden({super.key});

  static const plants = ['Fern', 'Cactus', 'Basil', 'Monstera'];

  @override
  Widget build(BuildContext context) {
    final theme = WiredTheme.of(context);
    return WiredScaffold(
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          WiredEntrance(
            child: Text.rich(
              TextSpan(
                children: [
                  const TextSpan(text: 'Your garden is '),
                  WidgetSpan(child: WiredHighlight(child: Text('thriving'))),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          WiredCascade(
            spacing: 12,
            children: [
              for (final (i, plant) in plants.indexed)
                WiredCard(
                  height: null,
                  color: theme.accentAt(i),
                  child: Text(plant),
                ),
            ],
          ),
          const SizedBox(height: 16),
          WiredFilledButton(
            inkInteraction: WiredInkInteraction.redraw,
            onPressed: () {},
            child: const Text('Water everything'),
          ),
        ],
      ),
    );
  }
}
```

<!-- {/docsVividThemeExample} -->

## Colour-code a list

`theme.accentAt(index)` cycles through the colourway's washes, so a list of any length stays colourful. A card with a `color` inks its content with `theme.inkOn(color)`, so the text stays dark on the wash even on night paper.

```dart
// Live example: entrance-cascade
HookBuilder(
  builder: (context) {
    final replay = useState(0);
    final theme = WiredTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        WiredCascade(
          key: ValueKey(replay.value),
          spacing: 12,
          children: [
            for (final (i, plant) in const ['Fern', 'Cactus', 'Basil'].indexed)
              WiredCard(
                height: null,
                color: theme.accentAt(i),
                child: Text(plant),
              ),
          ],
        ),
        const SizedBox(height: 16),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: WiredOutlinedButton(
            onPressed: () => replay.value++,
            child: const Text('Again!'),
          ),
        ),
      ],
    );
  },
)
```

## Highlight what matters

```dart
// Live example: highlight-marker
Builder(
  builder: (context) {
    final theme = WiredTheme.of(context);
    return Text.rich(
      TextSpan(
        children: [
          const TextSpan(text: 'Ink that '),
          const WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: WiredHighlight(child: Text('pops')),
          ),
          const TextSpan(text: ' off the '),
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: WiredHighlight(
              style: WiredHighlightStyle.underline,
              color: theme.accentAt(1),
              delay: const Duration(milliseconds: 400),
              child: const Text('page'),
            ),
          ),
        ],
      ),
      style: const TextStyle(fontSize: 24),
    );
  },
)
```

`WiredHighlight` swipes the theme's marker behind its child, or draws an underline in the accent, and draws itself on when it appears. Inside a `WiredEntrance` or `WiredDraw`, pass `animate: false` to follow their timing instead.

## Choose a colourway

| Colourway | Marker      | Accent      | Mood                         |
| --------- | ----------- | ----------- | ---------------------------- |
| `sunny`   | `sunshine`  | `tomato`    | The default: bright and warm |
| `berry`   | `bubblegum` | `grape`     | Sweet and playful            |
| `ocean`   | `aqua`      | `cobalt`    | Fresh and cool               |
| `citrus`  | `lime`      | `tangerine` | Loud and zesty               |
| `quiet`   | `lilac`     | `lilac`     | Calm: the earlier default    |

The full list of washes is on the [theme system](/core/theme-system#colourways) page. To brand a colourway, start from it and replace what you need: `WiredThemeData.colorway(WiredColorway.ocean).copyWith(accentColor: brand)`. Pick a brand colour that reads with plum ink, or `onAccentColor` switches the label to paper.

## Make it move

The [Ink motion](/core/motion) page covers every motion tool. In short:

| You want                         | Use                                                  |
| -------------------------------- | ---------------------------------------------------- |
| A screen of cards to arrive      | `WiredCascade`                                       |
| A long list to arrive            | `WiredEntrance.staggered(index: i, ...)` per item    |
| One element to arrive            | `WiredEntrance`                                      |
| Ink to draw itself on, in place  | `WiredDraw`                                          |
| A drawing that never sits still  | `WiredBoil`                                          |
| Your own animation to feel alive | `WiredCurves.springy`, `snappy`, `bouncy`, and `pen` |
| A button that redraws on press   | `inkInteraction: WiredInkInteraction.redraw`         |

All of it settles at once when `WiredMotion` is off, `WiredThemeData.motionEnabled` is false, or the platform asks for reduced motion.

## For agents

Agents tend to play safe with colour, and a safe hand-drawn app looks like a photocopy. If you drive skribble with a coding agent, put the rules above into its instructions (`AGENTS.md`, `CLAUDE.md`, or your tool's equivalent) together with a link to this page. The skribble repository's own `AGENTS.md` carries the same rules for the storybook, the example app, and the sites.
