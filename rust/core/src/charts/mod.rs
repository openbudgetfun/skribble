//! Hand-drawn financial charts: candlesticks, OHLC bars, lines, areas, bars,
//! volume, and technical overlays.
//!
//! Charts draw at an explicit `width` and `height` in logical pixels, so price
//! geometry is exact: candle bodies and wicks keep the open, high, low, and
//! close positions the data gives them. Only the texture and line wobble come
//! from the hand.
//!
//! ```
//! use skribble_core::charts::Candle;
//! use skribble_core::charts::CandlestickChart;
//! use skribble_core::charts::Overlay;
//!
//! let chart = CandlestickChart {
//! 	overlays: vec![Overlay::Sma(2)],
//! 	show_volume: true,
//! 	..CandlestickChart::new(vec![
//! 		Candle::new(1, 10.0, 12.0, 9.0, 11.0, 100.0),
//! 		Candle::new(2, 11.0, 13.0, 10.0, 12.0, 120.0),
//! 		Candle::new(3, 12.0, 12.5, 10.5, 11.0, 90.0),
//! 	])
//! };
//! let drawing = chart.drawing(320.0, 200.0).expect("a positive size");
//! assert!(drawing.paths.len() > 3);
//! ```
//!
//! [`Candle`] holds one interval. The [`indicators`] module has pure
//! `sma`, `ema`, `bollinger`, `rsi`, and `macd` functions that match the
//! Flutter package's numbers, and [`geometry`] maps prices and indices to
//! pixels for callers that need the same coordinates.

mod data;
mod draw;
mod ink;
mod theme;

pub mod geometry;
pub mod indicators;

pub use data::Candle;
pub use data::LineSeries;
pub use data::Overlay;
pub use data::SeriesKind;
pub use draw::BarChart;
pub use draw::CandlestickChart;
pub use draw::ChartSizeError;
pub use draw::LineChart;
pub use theme::ChartTheme;
