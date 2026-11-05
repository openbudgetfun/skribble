# Changelog

## skribble_charts [0.4.0](https://github.com/openbudgetfun/skribble/releases/tag/skribble_charts/v0.4.0) (2026-11-05)

### Fixes

#### Chart labels fit at any text size, and dark themes get a readable palette

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #276](https://github.com/openbudgetfun/skribble/pull/276)

- **Labels no longer clip or collide.** The right gutter used a fixed 72 pixels, so prices such as `12345678.52` were cut to `12356…`. It now widens to the measured price and pane labels, up to 40% of the chart. Price labels are centred on their grid lines, time labels on their slots, and the time axis grows to fit its labels. When neighbouring labels would touch, the chart shows fewer price ticks and time labels. A lower pane too short for its title or for both scale labels leaves them out instead of drawing them over the next pane. "No market data" is centred on its measured width.
- **Labels follow the reader's text size**, up to double, instead of ignoring it.
- **Dark themes.** `WiredChartStyle.fromTheme(theme)` builds a palette from a skribble theme, with lighter rising, falling, and indicator inks on night paper. `WiredChartStyle` now has value equality, so a style rebuilt with the same settings keeps the laid-out chart.
- **The details strip stays readable.** The selected-candle text beneath the plot now sits on the chart's own paper. With a night chart in a light app, it was light ink on a light page.
- **Readable times and spoken values.** Details show `2026-09-10 12:30 UTC` instead of `2026-09-10T12:30:00.000Z`. The chart's semantic value spells out open, high, low, close, and volume, and with nothing selected it announces the latest close. The visual strip is no longer read a second time.
- The selection crosshair stops at the lowest pane instead of 24 pixels above the bottom edge, and pane scale labels round before choosing a unit (999,999 reads `1.0M`, not `1000.0k`).
- The committed golden image is replaced by pixel checks of wick geometry, pane contents, the annotation level, and the label gutters.

## skribble_charts [0.1.0](https://github.com/openbudgetfun/skribble/releases/tag/skribble_charts/v0.1.0) (2026-09-11)

### Features

- **Add hand-drawn financial charts.** `skribble_charts` draws precise hand-drawn financial charts over exact OHLC data with interactive viewports, indicators, annotation editing, and saved workspaces. Live chart examples ship in the documentation and Storybook. _Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #166](https://github.com/openbudgetfun/skribble/pull/166) · _Related issues:_ [#174](https://github.com/openbudgetfun/skribble/issues/174)

## skribble_charts [0.1.1](https://github.com/openbudgetfun/skribble/releases/tag/skribble_charts/v0.1.1) (2026-09-13)

### Changed

- **No package-specific changes were recorded; `skribble_charts` was updated to 0.1.1.**

## skribble_charts [0.2.0](https://github.com/openbudgetfun/skribble/releases/tag/skribble_charts/v0.2.0) (2026-09-14)

### Documentation

- **Lowercase the skribble brand word across documentation.** READMEs, docs site pages and titles, package descriptions, and source comments now write the brand word as lowercase skribble. Dart identifiers, bundled font families such as SkribbleGentle, asset names, and runtime strings keep their casing, so no API or behaviour changes. _Owner:_ Ifiok Jr. · _Introduced in:_ [5e3937c](https://github.com/openbudgetfun/skribble/commit/5e3937ccb6db77bc38e9ac95d273e018def98843) · _Last updated in:_ [77bb664](https://github.com/openbudgetfun/skribble/commit/77bb6649c58d5be1876aec0eb1cc3a2389c7dc89)

## skribble_charts [0.2.1](https://github.com/openbudgetfun/skribble/releases/tag/skribble_charts/v0.2.1) (2026-09-22)

### Changed

- **No package-specific changes were recorded; `skribble_charts` was updated to 0.2.1.**

## skribble_charts [0.3.0](https://github.com/openbudgetfun/skribble/releases/tag/skribble_charts/v0.3.0) (2026-10-08)

### Changed

#### No package-specific changes were recorded; `skribble_charts` was updated to 0.3.0.

## skribble_charts [0.3.1](https://github.com/openbudgetfun/skribble/releases/tag/skribble_charts/v0.3.1) (2026-10-08)

### Changed

- **No package-specific changes were recorded; `skribble_charts` was updated to 0.3.1.**

## 0.0.1

Initial development of precise hand-drawn financial charts for Flutter.
