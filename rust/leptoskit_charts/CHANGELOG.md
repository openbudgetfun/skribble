# Changelog

All notable changes to this project will be documented in this file.

This changelog is managed by [monochange](https://github.com/monochange/monochange).

## rust [0.1.0](https://github.com/openbudgetfun/skribble/releases/tag/rust/v0.1.0) (2026-11-07)

### Features

#### Add hand-drawn charts and maps for leptoskit

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #277](https://github.com/openbudgetfun/skribble/pull/277)

`skribble_leptoskit_charts` draws financial charts in leptoskit apps: `WiredCandlestickChart` (candles, OHLC bars, line, or area, with volume and SMA, EMA, or Bollinger overlays), `WiredLineChart`, and `WiredBarChart`, with exact price geometry and sketched textures. Its `indicators` module computes SMA, EMA, Bollinger Bands, RSI, and MACD with the same numbers as the Flutter `skribble_charts` package.

`skribble_leptoskit_maps` draws maps itself, with no tiles or network: `WiredMap` projects areas, routes, points, and sticker pins with Web Mercator onto a paper background with a faint hand-drawn graticule, and `WiredMapZoomControls` proposes zoom changes. Pins can be pressable, named buttons.

Both draw with leptoskit `Vector` elements, so they look the same on the web and every native platform, including in dark mode.
