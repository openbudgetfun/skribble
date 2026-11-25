# Changelog

All notable changes to this project will be documented in this file.

This changelog is managed by [monochange](https://github.com/monochange/monochange).

## rust [0.1.1](https://github.com/openbudgetfun/skribble/releases/tag/rust/v0.1.1) (2026-11-25)

Grouped release for `rust`.

### Features

#### Compact ink for drawings that ship to a browser

_Packages:_ 🟠 _rust:skribble_rough_

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #278](https://github.com/openbudgetfun/skribble/pull/278)

`skribble_rough` can write pen-shaped ink compactly: `CompactSvgInkOutline`, `InkStroke::compact_svg_path_data`, `DrawableInk::compact_svg_paths`, and `SketchOptions::tolerance`. The pen samples a stroke about every pen width, which keeps the taper smooth but writes far more points than a screen shows. Compact ink drops the samples within the tolerance of the line through their neighbours, draws through the rest with the same midpoint curves, and writes two decimals. The default output is unchanged, so ink still matches the Dart and TypeScript engines.

`skribble_core`'s `Scribble` draws compact ink within a quarter of a logical pixel. Its paths are about a sixth of the full size: a server-rendered page of sketches dropped from 1.2 MB to 370 KB.

#### skribble_core: skribble's design system for Rust, free of any UI framework

_Packages:_ 🟠 _skribble_core_

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

## rust [0.1.0](https://github.com/openbudgetfun/skribble/releases/tag/rust/v0.1.0) (2026-11-07)

Grouped release for `rust`.

### Features

#### Draw skribble_leptoskit ink natively on leptoskit 0.3

_Packages:_ 🟠 _rust:skribble_rough_, 🟠 _skribble_leptoskit_

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #277](https://github.com/openbudgetfun/skribble/pull/277)

`skribble_leptoskit` now builds on leptoskit 0.3 from crates.io and draws its ink with leptoskit's `Vector` element, which the web renderer shows as inline SVG and every native backend (macOS, iOS, Android, Windows, Linux) draws with its own path API. Native apps get the same rough borders, sketched fills, and ticks as the web, and `Sketch` draws on native too. Ink paints with the element's text colour, so `dark:` classes recolour it on every platform.

The `web` feature is gone: there is nothing to turn on. `skribble_rough` and `skribble_leptoskit` are now published to crates.io and release together under `rust/v<version>` tags.

#### Add hand-drawn charts and maps for leptoskit

_Packages:_ 🟠 _skribble_leptoskit_charts_, 🟠 _skribble_leptoskit_maps_

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #277](https://github.com/openbudgetfun/skribble/pull/277)

`skribble_leptoskit_charts` draws financial charts in leptoskit apps: `WiredCandlestickChart` (candles, OHLC bars, line, or area, with volume and SMA, EMA, or Bollinger overlays), `WiredLineChart`, and `WiredBarChart`, with exact price geometry and sketched textures. Its `indicators` module computes SMA, EMA, Bollinger Bands, RSI, and MACD with the same numbers as the Flutter `skribble_charts` package.

`skribble_leptoskit_maps` draws maps itself, with no tiles or network: `WiredMap` projects areas, routes, points, and sticker pins with Web Mercator onto a paper background with a faint hand-drawn graticule, and `WiredMapZoomControls` proposes zoom changes. Pins can be pressable, named buttons.

Both draw with leptoskit `Vector` elements, so they look the same on the web and every native platform, including in dark mode.
