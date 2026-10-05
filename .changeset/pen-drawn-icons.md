---
skribble: major
skribble_icons: major
skribble_icons_material: patch
skribble_icons_lucide: patch
skribble_icons_bxs: patch
skribble_icons_cib: patch
skribble_icons_simple: patch
skribble_emoji_gen: major
skribble_maps: patch
---

# Draw icons with the pen and give them a weight

Icons now honour a `weight` from 100 to 700 on Flutter's icon weight scale, falling back to `IconTheme.weight`, and scale with the theme's `strokeWidth`. Stroke artwork is inked by the theme's `RoughPen`; silhouettes grow or shrink evenly, and `WiredIconFillStyle.none` draws them as inked outlines. `strokeWidth` and `sampleDistance` are removed from `WiredIcon` and `WiredSvgIcon`:

```dart
// Before
WiredIcon(icon: Icons.search, strokeWidth: 1.2);

// After
WiredIcon(icon: Icons.search, weight: 300);
SkribbleIcon(data: SkribbleGlyphs.sparkle, weight: 600);
```

The core package ships `SkribbleGlyphs`, 51 stroke drawings made for skribble, generated from SVGs in `packages/skribble/tool/glyphs` by `generate_glyphs.dart`, which replaces `generate_icons.dart`. They replace `skribble_icons_curated`, which is retired; `SkribbleIconSet.curated` becomes `SkribbleIconSet.glyphs`. Wired widgets draw their own chrome with the glyphs, and without a registered catalog `WiredIcon` draws the matching glyph for about sixty common Material icons instead of the font glyph.
