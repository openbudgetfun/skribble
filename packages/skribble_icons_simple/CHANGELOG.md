# Changelog

All notable changes to this project will be documented in this file.

This changelog is managed by [monochange](https://github.com/monochange/monochange).

## [0.3.1](https://github.com/openbudgetfun/skribble/releases/tag/v0.3.1) (2026-10-08)

### Changed

- **No package-specific changes were recorded; `skribble_icons_simple` was updated to 0.3.1 as part of group `main`.**

## [0.3.0](https://github.com/openbudgetfun/skribble/releases/tag/v0.3.0) (2026-10-08)

### Fixes

#### Draw icons with the pen and give them a weight

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #229](https://github.com/openbudgetfun/skribble/pull/229) · _Related issues:_ [#130](https://github.com/openbudgetfun/skribble/issues/130)

Icons now honour a `weight` from 100 to 700 on Flutter's icon weight scale, falling back to `IconTheme.weight`, and scale with the theme's `strokeWidth`. Stroke artwork is inked by the theme's `RoughPen`; silhouettes grow or shrink evenly, and `WiredIconFillStyle.none` draws them as inked outlines. `strokeWidth` and `sampleDistance` are removed from `WiredIcon` and `WiredSvgIcon`:

```dart
// Before
WiredIcon(icon: Icons.search, strokeWidth: 1.2);

// After
WiredIcon(icon: Icons.search, weight: 300);
SkribbleIcon(data: SkribbleGlyphs.sparkle, weight: 600);
```

The core package ships `SkribbleGlyphs`, 51 stroke drawings made for skribble, generated from SVGs in `packages/skribble/tool/glyphs` by `generate_glyphs.dart`, which replaces `generate_icons.dart`. They replace `skribble_icons_curated`, which is retired; `SkribbleIconSet.curated` becomes `SkribbleIconSet.glyphs`. Wired widgets draw their own chrome with the glyphs, and without a registered catalog `WiredIcon` draws the matching glyph for about sixty common Material icons instead of the font glyph.

## [0.2.1](https://github.com/openbudgetfun/skribble/releases/tag/v0.2.1) (2026-09-22)

### Fixes

#### Keep hand-drawn icons upright and rounded borders visibly irregular

Preserve authored icon endpoints while adding small bends along each stroke. Remove the shared displacement that made unrelated icon sets lean to the right, and regenerate the icon and emoji catalogs. Runtime icon drawing removes overall tilt, while wide rounded borders gain local variation with smooth corner joins.

Normalize insignificant floating-point drift so ARM and x64 generate identical icon and emoji coordinates.

The documentation and storybook activate the rough icon catalog at startup. The storybook bundles the current font package, exposes all six icon catalogs, and adds the missing loading, doodle, fill, typography, and table demonstrations.

_Owner:_ Ifiok Jr. · _Introduced in:_ [26f116a](https://github.com/openbudgetfun/skribble/commit/26f116ae5da5dcdfc1b29b90c341b62ba1fb17f4)

## [0.2.0](https://github.com/openbudgetfun/skribble/releases/tag/v0.2.0) (2026-09-14)

### Changed

#### No package-specific changes were recorded; `skribble_icons_simple` was updated to 0.2.0 as part of group `main`.
