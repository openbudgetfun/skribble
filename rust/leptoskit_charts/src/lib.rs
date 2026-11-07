//! Hand-drawn financial charts for leptoskit apps.
//!
//! Candlesticks, OHLC bars, lines, areas, volume bars, and technical overlays
//! for apps written once with [leptoskit](https://github.com/ifiokjr/leptoskit).
//! The ink comes from [`skribble_rough`](https://github.com/openbudgetfun/skribble/tree/main/rust/rough),
//! the same engine skribble's Flutter and Jaspr charts paint with, so a seed
//! wobbles the same everywhere.
//!
//! Charts take an explicit `width` and `height` in logical pixels and draw in
//! that coordinate space, so price geometry is exact: candle bodies and wicks
//! keep the open, high, low, and close positions the data gives them. Only the
//! texture and line wobble come from the hand.
//!
//! ```
//! use leptoskit::prelude::*;
//! use skribble_leptoskit_charts::Candle;
//! use skribble_leptoskit_charts::Overlay;
//! use skribble_leptoskit_charts::WiredCandlestickChart;
//!
//! let candles = vec![
//! 	Candle::new(1, 10.0, 12.0, 9.0, 11.0, 100.0),
//! 	Candle::new(2, 11.0, 13.0, 10.0, 12.0, 120.0),
//! 	Candle::new(3, 12.0, 12.5, 10.5, 11.0, 90.0),
//! ];
//! pub fn price_chart(candles: Vec<Candle>) -> Element {
//! 	view! {
//! 		<WiredCandlestickChart
//! 			candles=candles
//! 			width=320.0
//! 			height=200.0
//! 			overlays=vec![Overlay::Sma(2)]
//! 			show_volume=true
//! 			label="Price in US dollars"
//! 		/>
//! 	}
//! }
//! # let _ = price_chart(candles);
//! ```
//!
//! # Components
//!
//! | Component                                    | Draws                                                       |
//! | -------------------------------------------- | ----------------------------------------------------------- |
//! | [`WiredCandlestickChart`](fn@WiredCandlestickChart) | Candles, OHLC bars, lines, areas, volume, and overlays |
//! | [`WiredLineChart`](fn@WiredLineChart)        | A hand-drawn line through values or points                   |
//! | [`WiredBarChart`](fn@WiredBarChart)          | Labelled bars growing from zero                              |
//!
//! Every chart takes a [`seed`](fn@WiredCandlestickChart), an optional
//! [`ChartTheme`], and extra Tailwind `class`es. The ink paints with the
//! element's text colour, so dark mode follows leptoskit's `dark:` classes on
//! the web and the host's appearance on native platforms.
//!
//! # Data and indicators
//!
//! [`Candle`] holds one interval. The [`indicators`] module has pure,
//! unit-tested `sma`, `ema`, `bollinger`, `rsi`, and `macd` functions that
//! match the Flutter package's numbers, and [`geometry`] maps prices and
//! indices to pixels for callers that need the same coordinates.
//!
//! # Platforms
//!
//! The ink is drawn as leptoskit `Vector` elements, which the web renderer
//! shows as inline SVG and every native backend draws through its own path
//! API. No feature needs turning on.

mod charts;
mod data;
mod render;
mod theme;

pub mod geometry;
pub mod indicators;

pub use charts::WiredBarChart;
pub use charts::WiredCandlestickChart;
pub use charts::WiredLineChart;
pub use data::Candle;
pub use data::LineSeries;
pub use data::Overlay;
pub use data::SeriesKind;
pub use theme::ChartTheme;
