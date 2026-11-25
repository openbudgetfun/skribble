# Changelog

All notable changes to this project will be documented in this file.

This changelog is managed by [monochange](https://github.com/monochange/monochange).

## rust [0.1.1](https://github.com/openbudgetfun/skribble/releases/tag/rust/v0.1.1) (2026-11-25)

### Features

#### skribble_core: skribble's design system for Rust, free of any UI framework

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #287](https://github.com/openbudgetfun/skribble/pull/287)

The Rust crates no longer build leptoskit components. `skribble_leptoskit`, `skribble_leptoskit_charts`, and `skribble_leptoskit_maps` are gone from this repository, and their framework-free parts now live in one new crate, `skribble_core`, which depends on nothing but `skribble_rough`. leptoskit changes faster than skribble can track, so the leptoskit components move into the leptoskit repository as `leptoskit_skribble`, built on `skribble_core`, where they can follow leptoskit's own API.

`skribble_core` holds:

- **Colours.** The `colorway` module: `Rgba`, the named `swatch`es (Flutter's `WiredPalette` values), `Appearance`, the sunny, berry, ocean, citrus, and quiet `Colorway`s, WCAG contrast, and the default 1.6-pixel pen at playful roughness. `Theme` and `Palette` build on it: `Theme::SKRIBBLE` is the sunny colourway, `Theme::colorway` picks another, and `marker()`, `accent()`, `accent_at(i)`, and `on(wash)` match the Flutter theme.
- **Component ink.** The `components` module has a recipe for every component the leptoskit crate drew: `button`, `boxed`, `card`, `circle`, `badge`, `input`, `divider`, `checkbox`, `radio`, `switch`, `progress`, and `highlight`. Each returns an `Ink` (a shape, its outline, and its fill) whose drawing stretches to the component behind it, plus the tone that reads on its fill.
- **Scribbles.** `Scribble` draws arrows, curves, and annotations at an explicit size with the pen's compact, tapered ink, and returns an error instead of panicking for a bad size or shape.
- **Charts.** `charts::CandlestickChart`, `LineChart`, and `BarChart` draw at an explicit size with exact price geometry, and return an error for a size that is not positive and finite. `ChartTheme`, `indicators`, and `geometry` move unchanged.
- **Maps.** `maps::Camera`, `LatLng`, `LatLngBounds`, `MapFeature`, `MapStyle`, and `PinCategory` move unchanged, with `features_drawing`, `graticule`, `pin_drawing`, `pin_origin`, `zoom_button_drawing`, and `zoom_steps` for the ink the leptoskit map drew.

Every drawing is an `InkDrawing`: SVG path data with a light and a dark `Tone` per path. `runs()` groups paths by tone for renderers that recolour ink through a text colour, and `to_svg(appearance)` writes a standalone SVG document.

The workspace no longer depends on leptoskit or leptos, so it drops its `[patch.crates-io]` pin of leptoskit `main`. The docs replace the three leptoskit guides with [skribble for Rust](https://openbudgetfun.github.io/skribble/docs/guides/rust) and a short note on moving to `leptoskit_skribble`.
