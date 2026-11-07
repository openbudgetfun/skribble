//! Chart data: candles, series kinds, overlays, and line inputs.

/// One trading interval, as prices and a volume.
///
/// Charts draw candles in the order they are given; sort by [`Candle::time`]
/// before passing a series so older intervals sit on the left.
///
/// ```
/// use skribble_leptoskit_charts::Candle;
///
/// let candle = Candle {
/// 	time: 1_789_000_000,
/// 	open: 142.5,
/// 	high: 143.125,
/// 	low: 141.875,
/// 	close: 142.9875,
/// 	volume: 1_234.5,
/// };
/// assert!(candle.is_bullish());
/// ```
#[derive(Debug, Clone, Copy, PartialEq)]
pub struct Candle {
	/// Start of the interval, in any ascending unit (usually Unix seconds).
	pub time: i64,
	/// The first price in the interval.
	pub open: f64,
	/// The highest price in the interval.
	pub high: f64,
	/// The lowest price in the interval.
	pub low: f64,
	/// The latest price in the interval.
	pub close: f64,
	/// Traded amount; the consuming app defines its unit.
	pub volume: f64,
}

impl Candle {
	/// Creates a candle from its interval and prices.
	pub const fn new(time: i64, open: f64, high: f64, low: f64, close: f64, volume: f64) -> Self {
		Self {
			time,
			open,
			high,
			low,
			close,
			volume,
		}
	}

	/// Whether the interval closed at or above its open.
	pub const fn is_bullish(&self) -> bool {
		self.close >= self.open
	}

	/// Whether every price and volume is a finite number.
	pub fn is_finite(&self) -> bool {
		[self.open, self.high, self.low, self.close, self.volume]
			.into_iter()
			.all(f64::is_finite)
	}
}

/// How a price series is drawn.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Default)]
pub enum SeriesKind {
	/// Open and close bodies with exact high and low wicks.
	#[default]
	Candles,
	/// OHLC bars: a high-to-low wick with open and close ticks.
	Ohlc,
	/// A hand-drawn line through closing prices.
	Line,
	/// A line through closing prices, hatched down to the plot floor.
	Area,
}

/// A technical overlay calculated from closing prices.
#[derive(Debug, Clone, Copy, PartialEq)]
pub enum Overlay {
	/// A simple moving average over `period` closes.
	Sma(usize),
	/// An exponential moving average over `period` closes, seeded by an SMA.
	Ema(usize),
	/// Bollinger Bands: an SMA middle and two deviations.
	Bollinger {
		/// Number of closes in each rolling window.
		period: usize,
		/// Population-standard-deviation multiplier for the bands.
		deviations: f64,
	},
}

/// A line series: one value per slot, or explicit `(x, y)` points.
///
/// ```
/// use skribble_leptoskit_charts::LineSeries;
///
/// let values = LineSeries::from(vec![1.0, 2.0, 3.0]);
/// let points = LineSeries::from(vec![(0.0, 1.0), (1.0, 4.0), (2.0, 2.0)]);
/// assert!(matches!(values, LineSeries::Values(_)));
/// assert!(matches!(points, LineSeries::Points(_)));
/// ```
#[derive(Debug, Clone, PartialEq)]
pub enum LineSeries {
	/// Values plotted at evenly spaced slots.
	Values(Vec<f64>),
	/// Points plotted at their own coordinates.
	Points(Vec<(f64, f64)>),
}

impl From<Vec<f64>> for LineSeries {
	fn from(values: Vec<f64>) -> Self {
		Self::Values(values)
	}
}

impl From<Vec<(f64, f64)>> for LineSeries {
	fn from(points: Vec<(f64, f64)>) -> Self {
		Self::Points(points)
	}
}

#[cfg(test)]
mod tests {
	use super::*;

	#[test]
	fn a_candle_knows_its_direction() {
		let up = Candle::new(1, 10.0, 12.0, 9.0, 11.0, 3.0);
		let flat = Candle::new(2, 11.0, 12.0, 10.0, 11.0, 3.0);
		let down = Candle::new(3, 11.0, 12.0, 9.0, 10.0, 3.0);
		assert!(up.is_bullish());
		assert!(flat.is_bullish());
		assert!(!down.is_bullish());
	}

	#[test]
	fn finite_candles_have_no_nan() {
		let good = Candle::new(1, 10.0, 12.0, 9.0, 11.0, 3.0);
		let bad = Candle::new(2, f64::NAN, 12.0, 9.0, 11.0, 3.0);
		assert!(good.is_finite());
		assert!(!bad.is_finite());
	}
}
