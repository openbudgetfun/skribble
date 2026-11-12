# Changelog

All notable changes to this project will be documented in this file.

This changelog is managed by [monochange](https://github.com/monochange/monochange).

## rust [0.1.1](https://github.com/openbudgetfun/skribble/releases/tag/rust/v0.1.1) (2026-11-12)

### Fixes

#### Build and test the Rust crates against leptoskit main

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #279](https://github.com/openbudgetfun/skribble/pull/279)

The Rust crates keep their crates.io version requirements for leptoskit, so consumers stay free to choose their own leptoskit commit, but the workspace now pins the leptoskit crates it uses to a `main` commit through a `[patch.crates-io]` section in the root `Cargo.toml`, and its builds and tests run against that commit. `main` is ahead of the published 0.3 releases: new widgets and exports there collided with names these crates also export through glob imports (`Camera`, `Theme`), so tests and examples now import the skribble names explicitly, and everything builds and passes against the pinned rev.

The patch lives in the workspace root, and cargo applies `[patch]` sections only from the workspace root, so the pinned commit does not follow a consumer's build on its own. Every install section now documents the `[patch.crates-io]` entries a consumer adds to their own root manifest, shared through one MDT block: `leptoskit`, `leptoskit_native`, and `leptoskit_testing` at the same rev the skribble commit they depend on pins. The stale `ifiokjr/leptoskit` links are replaced with the repository's new `leptoskit/leptoskit` home.

New tests cover the native drawing path through leptoskit's real renderer: a `WiredBox` commits a stretched `Vector` whose rough path repeats for a seed and changes with it, and a `Sketch` commits a fitted `Vector` drawing its doodle, so it is no longer empty on native.

- **Build against leptoskit a93214e.** The workspace's `[patch.crates-io]` pin, and the entries the install sections tell consumers to add, move to leptoskit `a93214edc8e5f6c7999c628285093f15cf188639`, the commit Verily pins, so an app using both holds one leptoskit checkout. _Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #278](https://github.com/openbudgetfun/skribble/pull/278)

## rust [0.1.0](https://github.com/openbudgetfun/skribble/releases/tag/rust/v0.1.0) (2026-11-07)

### Features

#### Add hand-drawn charts and maps for leptoskit

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #277](https://github.com/openbudgetfun/skribble/pull/277)

`skribble_leptoskit_charts` draws financial charts in leptoskit apps: `WiredCandlestickChart` (candles, OHLC bars, line, or area, with volume and SMA, EMA, or Bollinger overlays), `WiredLineChart`, and `WiredBarChart`, with exact price geometry and sketched textures. Its `indicators` module computes SMA, EMA, Bollinger Bands, RSI, and MACD with the same numbers as the Flutter `skribble_charts` package.

`skribble_leptoskit_maps` draws maps itself, with no tiles or network: `WiredMap` projects areas, routes, points, and sticker pins with Web Mercator onto a paper background with a faint hand-drawn graticule, and `WiredMapZoomControls` proposes zoom changes. Pins can be pressable, named buttons.

Both draw with leptoskit `Vector` elements, so they look the same on the web and every native platform, including in dark mode.
