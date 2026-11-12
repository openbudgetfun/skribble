---
title: skribble charts for leptoskit (Rust)
description: Hand-drawn candlestick, line, and bar charts for leptoskit apps, with exact price geometry and pure technical indicators.
---

# skribble charts for leptoskit (Rust)

[`skribble_leptoskit_charts`](https://github.com/openbudgetfun/skribble/tree/main/rust/leptoskit_charts) adds financial charts to the [leptoskit components](/guides/leptoskit): candlesticks, OHLC bars, lines, areas, volume bars, and technical overlays, all drawn by hand.

Price geometry stays exact. Candle bodies and wicks keep the open, high, low, and close positions the data gives them; the texture and line wobble come from [`skribble_rough`](https://github.com/openbudgetfun/skribble/tree/main/rust/rough). Every chart draws into an explicit `width` and `height` in logical pixels, so the same data lands on the same coordinates on the web and every native backend.

## 1. Install

```toml
[dependencies]
leptoskit = "0.3"
skribble_leptoskit_charts = "0.1"
```

<!-- {=leptoskitPatch} -->

The leptoskit requirements above stay crates.io ranges so you stay free to choose your own leptoskit commit, but the skribble Rust crates build and test against leptoskit's `main`, which runs ahead of the 0.3 releases on crates.io. Bring the same commit into your build with a `[patch.crates-io]` section in your root `Cargo.toml`: cargo applies `[patch]` sections only from the workspace root, so a patch inside a dependency never reaches you. Keep every entry at the same rev, in step with the rev pinned in [`Cargo.toml`](https://github.com/openbudgetfun/skribble/blob/main/Cargo.toml) at the root of the skribble repository at the commit you depend on, and give any leptoskit crate you depend on directly that same rev, so the graph holds one leptoskit checkout. The rev below needs Rust 1.95 or later.

```toml
[patch.crates-io]
leptoskit = { git = "https://github.com/leptoskit/leptoskit", rev = "a93214edc8e5f6c7999c628285093f15cf188639" }
leptoskit_native = { git = "https://github.com/leptoskit/leptoskit", rev = "a93214edc8e5f6c7999c628285093f15cf188639" }
leptoskit_testing = { git = "https://github.com/leptoskit/leptoskit", rev = "a93214edc8e5f6c7999c628285093f15cf188639" }
```

<!-- {/leptoskitPatch} -->

There is no feature to turn on. Dark mode follows leptoskit's `dark:` classes on the web and the host's appearance on native platforms.

## 2. Draw a price chart

```rust
use leptoskit::prelude::*;
use skribble_leptoskit_charts::{Candle, Overlay, WiredCandlestickChart};

fn price_chart(candles: Vec<Candle>) -> Element {
	view! {
		<WiredCandlestickChart
			candles=candles
			width=640.0
			height=360.0
			overlays=vec![Overlay::Sma(20), Overlay::Ema(50)]
			show_volume=true
			label="Daily price in US dollars"
		/>
	}
}
```

`Candle` is a plain struct with `time`, `open`, `high`, `low`, `close`, and `volume`. Charts draw candles in the order given, so sort by time before passing a series.

```rust
use skribble_leptoskit_charts::Candle;

let candle = Candle::new(1_789_000_000, 142.5, 143.125, 141.875, 142.9875, 1_234.5);
```

### Series kinds

`kind` chooses what the price pane draws:

| `SeriesKind` | Draws                                                    |
| ------------ | -------------------------------------------------------- |
| `Candles`    | Open and close bodies with exact high and low wicks      |
| `Ohlc`       | A high-to-low wick with open and close ticks             |
| `Line`       | A line through closing prices                            |
| `Area`       | A line through closing prices, hatched to the plot floor |

### Overlays

`overlays` draws indicators on the same price scale:

```rust
use skribble_leptoskit_charts::*;

let overlays = vec![
	Overlay::Sma(20),
	Overlay::Ema(50),
	Overlay::Bollinger { period: 20, deviations: 2.0 },
];
```

Overlay lines cycle through `ChartTheme::indicator_colors`, so neighbouring lines stay distinct. `show_volume=true` adds a volume pane below the price pane, coloured by each candle's direction.

## 3. Line and bar charts

```rust
use leptoskit::prelude::*;
use skribble_leptoskit_charts::{WiredBarChart, WiredLineChart};

fn small_charts() -> Element {
	view! {
		<View class="gap-6">
			<WiredLineChart
				series=vec![12.0, 18.0, 15.0, 27.0, 22.0]
				width=360.0
				height=160.0
				label="Weekly revenue"
			/>
			<WiredLineChart
				series=vec![(0.0, 1.0), (1.0, 4.0), (2.0, 2.0)]
				width=360.0
				height=160.0
				label="Measured points"
			/>
			<WiredBarChart
				bars=vec![("Mon".to_owned(), 4.0), ("Tue".to_owned(), -1.0)]
				width=360.0
				height=180.0
				label="Weekday change"
			/>
		</View>
	}
}
```

`WiredLineChart` accepts a `Vec<f64>` through `LineSeries::Values` or a `Vec<(f64, f64)>` through `LineSeries::Points`. `WiredBarChart` grows bars from zero, uses the rising tone for positive values and the falling tone for negative ones, and puts a label under every bar. Its plot is `height` tall and the label row adds one text line below it.

## 4. Indicators and geometry

The `indicators` module is pure and unit-tested. Every result lines up with its input slot; warm-up slots and non-finite inputs are `None`. The arithmetic follows `packages/skribble_charts`, so ordinary market data produces the same numbers as skribble's Flutter charts.

| Function                                            | Returns                                      |
| --------------------------------------------------- | -------------------------------------------- |
| `indicators::sma(values, period)`                   | A simple moving average over `period` closes |
| `indicators::ema(values, period)`                   | An exponential average seeded by an SMA      |
| `indicators::bollinger(values, period, deviations)` | Middle, upper, and lower bands               |
| `indicators::rsi(values, period)`                   | Wilder's relative strength index             |
| `indicators::macd(values, fast, slow, signal)`      | The MACD line, signal line, and histogram    |

```rust
use skribble_leptoskit_charts::indicators;

let closes = [44.0, 44.15, 43.9, 44.35, 44.6];
let average = indicators::sma(&closes, 3);
let bands = indicators::bollinger(&closes, 3, 2.0);
let strength = indicators::rsi(&closes, 3);
let macd = indicators::macd(&closes, 3, 6, 4);
```

The `geometry` module exposes the mappings the components use, for charts that need their own drawing: `PriceScale`, `IndexScale`, `LinearScale`, `ChartGeometry`, `price_range`, `values_range`, and `padded_range`. Empty data has no range; a flat price maps to the middle of its pane; NaN is ignored rather than moving a drawing.

## 5. Theme it

`ChartTheme` carries a light and a dark tone for paper, ink, grid, rising candles, falling candles, and four indicator colours, plus a roughness and stroke width. Start from skribble's palette and change what you need:

```rust
use leptoskit::native::Color;
use skribble_leptoskit::Tone;
use skribble_leptoskit_charts::ChartTheme;

pub const MINT: ChartTheme = ChartTheme {
	rise: Tone {
		light: Color::rgba(0x26, 0x77, 0x55, 0xff),
		dark: Color::rgba(0x8c, 0xe9, 0xc2, 0xff),
	},
	..ChartTheme::SKRIBBLE
};
```

Pass it as `theme=MINT`.

## 6. Accessibility

Give a chart a `label` and it becomes an image with that name for assistive technology. Without one it is decorative and hidden from screen readers, like the rest of skribble's ink. Bar labels are visible text, and the whole chart group is named by the `label` you pass.

## 7. See it

The crate's `charts` example server-renders a gallery to a static page:

```bash
cargo run -p skribble_leptoskit_charts --example charts -- charts.html
```

## What this crate leaves out

It ports the drawing essentials of the Flutter package: data, exact price geometry, indicators, and static charts. It does not include the interactive controller, panning or zooming, annotations, workspace persistence, or live feeds. Give a chart new `candles` when data changes and leptoskit rebuilds it.
