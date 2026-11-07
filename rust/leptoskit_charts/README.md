# skribble charts for leptoskit

Hand-drawn financial charts for Rust apps written with [leptoskit](https://github.com/ifiokjr/leptoskit): candlesticks, OHLC bars, lines, areas, volume, and technical overlays.

Candle bodies and wicks keep their exact open, high, low, and close positions; the texture and line wobble come from [`skribble_rough`](../rough), the same engine skribble's Flutter and Jaspr charts paint with. The ink is drawn with leptoskit `Vector` elements, so the web gets inline SVG and every native backend draws the same paths natively.

## Install

```toml
[dependencies]
leptoskit = "0.3"
skribble_leptoskit_charts = "0.1"
```

There is no feature to turn on. Dark mode follows leptoskit's `dark:` classes on the web and the host's appearance on native platforms.

## Draw a price chart

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

`Candle` is a plain struct:

```rust
use skribble_leptoskit_charts::Candle;

let candle = Candle::new(
	1_789_000_000,
	142.5000,
	143.1250,
	141.8750,
	142.9875,
	1_234.5,
);
```

Price series come in four kinds: `SeriesKind::Candles` (the default), `SeriesKind::Ohlc`, `SeriesKind::Line`, and `SeriesKind::Area`. Overlays are `Overlay::Sma(period)`, `Overlay::Ema(period)`, and `Overlay::Bollinger { period, deviations }`.

## Simple charts

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

`WiredLineChart` takes either a `Vec<f64>` (evenly spaced slots) or a `Vec<(f64, f64)>` (its own coordinates) through `LineSeries`. `WiredBarChart` draws labelled bars from zero and puts the labels in a row beneath the plot.

## Indicators and geometry

The `indicators` module is pure and unit-tested. Each value lines up with the input slot; warm-up slots and non-finite inputs are `None`. The arithmetic matches `packages/skribble_charts` in Dart.

```rust
use skribble_leptoskit_charts::indicators;

let closes = [44.0, 44.15, 43.9, 44.35, 44.6];
let average = indicators::sma(&closes, 3);
let bands = indicators::bollinger(&closes, 3, 2.0);
let strength = indicators::rsi(&closes, 3);
let macd = indicators::macd(&closes, 3, 6, 4);
assert_eq!(average[2], Some(44.016_666_666_666_67));
assert!(bands.upper[2].is_some());
assert!(strength.last().is_some());
assert!(macd.histogram.len() == closes.len());
```

The `geometry` module exposes the same mappings the components use: `PriceScale`, `IndexScale`, `LinearScale`, `ChartGeometry`, `price_range`, `values_range`, and `padded_range`. Empty data has no range; a flat price maps to the middle of its pane; NaN is ignored.

## Theme it

`ChartTheme` carries light and dark tones for paper, ink, grid, rising and falling candles, and four indicator colours. Start from skribble's palette:

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

## See it

```bash
cargo run -p skribble_leptoskit_charts --example charts -- charts.html
```

The example server-renders a gallery of every chart to a static HTML file. Open it in a browser to see the ink in light and dark mode.

## Limits

This crate ports the drawing essentials of the Flutter package: data, price geometry, indicators, and static charts. It does not include the Flutter package's interactive controller, pan/zoom, annotations, workspace persistence, or live feeds. Give charts new `candles` when data changes and leptoskit rebuilds them.
