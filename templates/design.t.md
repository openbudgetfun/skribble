<!-- The design direction for apps and pages built with skribble: vivid
     colour and lively motion by default. Shared by AGENTS.md (the rules
     agents load), the agents reference page, the "Vivid and alive" guide,
     and the package README. Edit it here, then run `mdt update`. -->

<!-- {@docsVividDesignRules} -->

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

<!-- {@docsVividThemeExample} -->

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
