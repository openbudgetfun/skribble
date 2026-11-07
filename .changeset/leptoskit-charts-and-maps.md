---
skribble_leptoskit_charts: minor
skribble_leptoskit_maps: minor
---

# Add hand-drawn charts and maps for leptoskit

`skribble_leptoskit_charts` draws financial charts in leptoskit apps: `WiredCandlestickChart` (candles, OHLC bars, line, or area, with volume and SMA, EMA, or Bollinger overlays), `WiredLineChart`, and `WiredBarChart`, with exact price geometry and sketched textures. Its `indicators` module computes SMA, EMA, Bollinger Bands, RSI, and MACD with the same numbers as the Flutter `skribble_charts` package.

`skribble_leptoskit_maps` draws maps itself, with no tiles or network: `WiredMap` projects areas, routes, points, and sticker pins with Web Mercator onto a paper background with a faint hand-drawn graticule, and `WiredMapZoomControls` proposes zoom changes. Pins can be pressable, named buttons.

Both draw with leptoskit `Vector` elements, so they look the same on the web and every native platform, including in dark mode.
