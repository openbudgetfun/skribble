# Changelog

All notable changes to this project will be documented in this file.

This changelog is managed by [monochange](https://github.com/monochange/monochange).

## rust [0.1.1](https://github.com/openbudgetfun/skribble/releases/tag/rust/v0.1.1) (2026-11-12)

Grouped release for `rust`.

### Features

#### Compact ink for drawings that ship to a browser

_Packages:_ 🟠 _rust:skribble_rough_, 🟢 _skribble_leptoskit_

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #278](https://github.com/openbudgetfun/skribble/pull/278)

`skribble_rough` can write pen-shaped ink compactly: `CompactSvgInkOutline`, `InkStroke::compact_svg_path_data`, `DrawableInk::compact_svg_paths`, and `SketchOptions::tolerance`. The pen samples a stroke about every pen width, which keeps the taper smooth but writes far more points than a screen shows. Compact ink drops the samples within the tolerance of the line through their neighbours, draws through the rest with the same midpoint curves, and writes two decimals. The default output is unchanged, so ink still matches the Dart and TypeScript engines.

`skribble_leptoskit`'s `Sketch` now draws compact ink within a quarter of a logical pixel. Its paths are about a sixth of their old size: a server-rendered page of sketches dropped from 1.2 MB to 370 KB.

### Fixes

#### Build and test the Rust crates against leptoskit main

_Packages:_ 🟢 _skribble_leptoskit_, 🟢 _skribble_leptoskit_charts_, 🟢 _skribble_leptoskit_maps_

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #279](https://github.com/openbudgetfun/skribble/pull/279)

The Rust crates keep their crates.io version requirements for leptoskit, so consumers stay free to choose their own leptoskit commit, but the workspace now pins the leptoskit crates it uses to a `main` commit through a `[patch.crates-io]` section in the root `Cargo.toml`, and its builds and tests run against that commit. `main` is ahead of the published 0.3 releases: new widgets and exports there collided with names these crates also export through glob imports (`Camera`, `Theme`), so tests and examples now import the skribble names explicitly, and everything builds and passes against the pinned rev.

The patch lives in the workspace root, and cargo applies `[patch]` sections only from the workspace root, so the pinned commit does not follow a consumer's build on its own. Every install section now documents the `[patch.crates-io]` entries a consumer adds to their own root manifest, shared through one MDT block: `leptoskit`, `leptoskit_native`, and `leptoskit_testing` at the same rev the skribble commit they depend on pins. The stale `ifiokjr/leptoskit` links are replaced with the repository's new `leptoskit/leptoskit` home.

New tests cover the native drawing path through leptoskit's real renderer: a `WiredBox` commits a stretched `Vector` whose rough path repeats for a seed and changes with it, and a `Sketch` commits a fitted `Vector` drawing its doodle, so it is no longer empty on native.

- **Build against leptoskit a93214e.** The workspace's `[patch.crates-io]` pin, and the entries the install sections tell consumers to add, move to leptoskit `a93214edc8e5f6c7999c628285093f15cf188639`, the commit Verily pins, so an app using both holds one leptoskit checkout. _Packages:_ 🟢 _skribble_leptoskit_, 🟢 _skribble_leptoskit_charts_, 🟢 _skribble_leptoskit_maps_ _Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #278](https://github.com/openbudgetfun/skribble/pull/278)

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
