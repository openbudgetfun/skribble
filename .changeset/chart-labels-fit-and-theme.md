---
skribble_charts: patch
---

# Chart labels fit at any text size, and dark themes get a readable palette

- **Labels no longer clip or collide.** The right gutter used a fixed 72 pixels, so prices such as `12345678.52` were cut to `12356…`. It now widens to the measured price and pane labels, up to 40% of the chart. Price labels are centred on their grid lines, time labels on their slots, and the time axis grows to fit its labels. When neighbouring labels would touch, the chart shows fewer price ticks and time labels. A lower pane too short for its title or for both scale labels leaves them out instead of drawing them over the next pane. "No market data" is centred on its measured width.
- **Labels follow the reader's text size**, up to double, instead of ignoring it.
- **Dark themes.** `WiredChartStyle.fromTheme(theme)` builds a palette from a skribble theme, with lighter rising, falling, and indicator inks on night paper. `WiredChartStyle` now has value equality, so a style rebuilt with the same settings keeps the laid-out chart.
- **The details strip stays readable.** The selected-candle text beneath the plot now sits on the chart's own paper. With a night chart in a light app, it was light ink on a light page.
- **Readable times and spoken values.** Details show `2026-09-10 12:30 UTC` instead of `2026-09-10T12:30:00.000Z`. The chart's semantic value spells out open, high, low, close, and volume, and with nothing selected it announces the latest close. The visual strip is no longer read a second time.
- The selection crosshair stops at the lowest pane instead of 24 pixels above the bottom edge, and pane scale labels round before choosing a unit (999,999 reads `1.0M`, not `1000.0k`).
- The committed golden image is replaced by pixel checks of wick geometry, pane contents, the annotation level, and the label gutters.
