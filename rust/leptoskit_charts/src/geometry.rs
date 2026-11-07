//! Pure price and index geometry for chart plotting.
//!
//! These functions turn prices, indices, and chart sizes into logical pixel
//! positions. They never panic on empty data: an empty series simply has no
//! range, and a flat price maps to the middle of its scale.

use crate::data::Candle;

/// Space kept between the plot and its edges, in logical pixels.
pub const CHART_PADDING: f64 = 8.0;

/// Share of the plot height given to volume bars when they are shown.
pub const VOLUME_SHARE: f64 = 0.24;

/// Space between the price plot and the volume bars, in logical pixels.
const VOLUME_GAP: f64 = 4.0;

/// A rectangle in logical pixels.
#[derive(Debug, Clone, Copy, PartialEq)]
pub struct Rect {
	/// Distance from the left edge.
	pub x: f64,
	/// Distance from the top edge.
	pub y: f64,
	/// Width in logical pixels.
	pub width: f64,
	/// Height in logical pixels.
	pub height: f64,
}

impl Rect {
	/// Creates a rectangle from its top-left corner and size.
	pub const fn new(x: f64, y: f64, width: f64, height: f64) -> Self {
		Self {
			x,
			y,
			width,
			height,
		}
	}

	/// The right edge.
	pub const fn right(&self) -> f64 {
		self.x + self.width
	}

	/// The bottom edge.
	pub const fn bottom(&self) -> f64 {
		self.y + self.height
	}
}

/// A linear mapping from a value range to a pixel range.
///
/// Equal value differences occupy equal pixel distances. A flat range maps
/// every value to the middle of the pixel range, and a non-finite value maps
/// there too, so a stray NaN cannot move a drawing off the chart.
#[derive(Debug, Clone, Copy, PartialEq)]
pub struct LinearScale {
	/// The smallest value.
	pub min: f64,
	/// The largest value.
	pub max: f64,
	/// The pixel position of [`Self::min`].
	pub start: f64,
	/// The pixel position of [`Self::max`].
	pub end: f64,
}

impl LinearScale {
	/// Creates a scale from a value range to a pixel range.
	pub const fn new(min: f64, max: f64, start: f64, end: f64) -> Self {
		Self {
			min,
			max,
			start,
			end,
		}
	}

	/// The pixel position of `value`.
	pub fn position(&self, value: f64) -> f64 {
		let middle = (self.start + self.end) / 2.0;
		if !value.is_finite()
			|| !self.min.is_finite()
			|| !self.max.is_finite()
			|| !self.start.is_finite()
			|| !self.end.is_finite()
			|| self.min == self.max
		{
			return middle;
		}
		let fraction = (value - self.min) / (self.max - self.min);
		self.start + fraction * (self.end - self.start)
	}
}

/// Maps prices to vertical pixels, with the smallest price at the bottom.
#[derive(Debug, Clone, Copy, PartialEq)]
pub struct PriceScale {
	/// The smallest visible price.
	pub min: f64,
	/// The largest visible price.
	pub max: f64,
	/// The top pixel of the pane.
	pub top: f64,
	/// The bottom pixel of the pane.
	pub bottom: f64,
}

impl PriceScale {
	/// Creates a price scale for a pane.
	pub const fn new(min: f64, max: f64, top: f64, bottom: f64) -> Self {
		Self {
			min,
			max,
			top,
			bottom,
		}
	}

	/// The pixel position of `price`.
	pub fn y(&self, price: f64) -> f64 {
		LinearScale::new(self.min, self.max, self.bottom, self.top).position(price)
	}
}

/// Maps candle indices to horizontal pixels.
#[derive(Debug, Clone, Copy, PartialEq)]
pub struct IndexScale {
	/// Number of slots across the plot.
	pub count: usize,
	/// The left pixel of the plot.
	pub left: f64,
	/// The width of the plot in logical pixels.
	pub width: f64,
}

impl IndexScale {
	/// Creates an index scale for `count` slots.
	pub const fn new(count: usize, left: f64, width: f64) -> Self {
		Self { count, left, width }
	}

	/// The centre of the slot at `index`.
	pub fn x(&self, index: f64) -> f64 {
		if self.count == 0 {
			return self.left + self.width / 2.0;
		}
		self.left + (index + 0.5) / self.count as f64 * self.width
	}

	/// The width of one candle body: 68% of a slot, between 0.8 and 22
	/// pixels.
	pub fn candle_width(&self) -> f64 {
		if self.count == 0 {
			return 0.0;
		}
		(self.width / self.count as f64 * 0.68).clamp(0.8, 22.0)
	}
}

/// The panes a chart draws into, and the scales that map data onto them.
#[derive(Debug, Clone, Copy, PartialEq)]
pub struct ChartGeometry {
	/// The price pane.
	pub plot: Rect,
	/// Prices mapped to the price pane.
	pub price: PriceScale,
	/// Candle slots mapped across the price pane.
	pub index: IndexScale,
	/// The volume pane when volume is shown.
	pub volume: Option<Rect>,
}

impl ChartGeometry {
	/// Lays out a chart of `width` by `height` logical pixels.
	///
	/// `count` is the number of candle slots, and `min` and `max` are the price
	/// bounds. A non-finite bound falls back to `0..1`; tiny sizes keep a
	/// one-pixel plot rather than collapsing.
	pub fn new(
		width: f64,
		height: f64,
		count: usize,
		min: f64,
		max: f64,
		show_volume: bool,
	) -> Self {
		let width = width.max(1.0);
		let height = height.max(1.0);
		let (min, max) = sanitize_bounds(min, max);
		let inner_width = (width - CHART_PADDING * 2.0).max(1.0);
		let inner_height = (height - CHART_PADDING * 2.0).max(1.0);
		let (price_height, volume) = if show_volume && inner_height > 24.0 {
			let volume_height = inner_height * VOLUME_SHARE;
			let gap = VOLUME_GAP.min(inner_height * 0.1);
			let price_height = (inner_height - volume_height - gap).max(1.0);
			let top = CHART_PADDING + price_height + gap;
			let height = (height - CHART_PADDING - top).max(1.0);
			(
				price_height,
				Some(Rect::new(CHART_PADDING, top, inner_width, height)),
			)
		} else {
			(inner_height, None)
		};
		let plot = Rect::new(CHART_PADDING, CHART_PADDING, inner_width, price_height);
		Self {
			plot,
			price: PriceScale::new(min, max, plot.y, plot.bottom()),
			index: IndexScale::new(count, plot.x, plot.width),
			volume,
		}
	}

	/// The price pane of a chart that shows no volume.
	pub fn plot_only(width: f64, height: f64) -> Rect {
		let width = width.max(1.0);
		let height = height.max(1.0);
		Rect::new(
			CHART_PADDING,
			CHART_PADDING,
			(width - CHART_PADDING * 2.0).max(1.0),
			(height - CHART_PADDING * 2.0).max(1.0),
		)
	}
}

/// The lowest and highest finite prices in `candles`.
///
/// Returns [`None`] when no candle has a finite price.
pub fn price_range(candles: &[Candle]) -> Option<(f64, f64)> {
	range(
		candles
			.iter()
			.flat_map(|candle| [candle.low, candle.high, candle.open, candle.close]),
	)
}

/// The lowest and highest finite value in `values`.
///
/// Returns [`None`] when every value is non-finite.
pub fn values_range(values: &[f64]) -> Option<(f64, f64)> {
	range(values.iter().copied())
}

/// Expands a price range so its edges are not drawn on the plot border.
///
/// A flat range grows by 1% of its magnitude, or by one when it is zero.
/// Non-finite or reversed bounds fall back to `0..1`.
pub fn padded_range(min: f64, max: f64, fraction: f64) -> (f64, f64) {
	let (min, max) = sanitize_bounds(min, max);
	let range = max - min;
	let pad = if range == 0.0 {
		(max.abs() * 0.01).max(1.0)
	} else {
		range * fraction.abs().min(1.0)
	};
	(min - pad, max + pad)
}

fn range(values: impl Iterator<Item = f64>) -> Option<(f64, f64)> {
	let mut min = f64::INFINITY;
	let mut max = f64::NEG_INFINITY;
	let mut seen = false;
	for value in values {
		if value.is_finite() {
			seen = true;
			min = min.min(value);
			max = max.max(value);
		}
	}
	seen.then_some((min, max))
}

fn sanitize_bounds(min: f64, max: f64) -> (f64, f64) {
	if !min.is_finite() || !max.is_finite() {
		return (0.0, 1.0);
	}
	if min <= max { (min, max) } else { (max, min) }
}

#[cfg(test)]
mod tests {
	use super::*;

	fn candle(open: f64, high: f64, low: f64, close: f64) -> Candle {
		Candle::new(0, open, high, low, close, 1.0)
	}

	#[test]
	fn prices_map_to_the_pane_edges() {
		let scale = PriceScale::new(10.0, 20.0, 8.0, 208.0);
		assert_eq!(scale.y(10.0), 208.0);
		assert_eq!(scale.y(20.0), 8.0);
		assert_eq!(scale.y(15.0), 108.0);
	}

	#[test]
	fn a_flat_price_sits_in_the_middle() {
		let scale = PriceScale::new(5.0, 5.0, 0.0, 100.0);
		assert_eq!(scale.y(5.0), 50.0);
		assert_eq!(scale.y(f64::NAN), 50.0);
	}

	#[test]
	fn candle_slots_are_centred_and_ordered() {
		let scale = IndexScale::new(4, 8.0, 400.0);
		assert_eq!(scale.x(0.0), 58.0);
		assert_eq!(scale.x(3.0), 358.0);
		assert!(scale.candle_width() > 0.8);
		assert!(scale.candle_width() <= 22.0);
		let single = IndexScale::new(1, 8.0, 400.0);
		assert_eq!(single.x(0.0), 208.0);
	}

	#[test]
	fn empty_and_flat_ranges_are_safe() {
		assert_eq!(price_range(&[]), None);
		let flat = [candle(10.0, 10.0, 10.0, 10.0)];
		assert_eq!(price_range(&flat), Some((10.0, 10.0)));
		let (min, max) = padded_range(10.0, 10.0, 0.05);
		assert!(min < 10.0 && max > 10.0);
		let (min, max) = padded_range(f64::NAN, 4.0, 0.05);
		assert!(min < 0.0 && max > 1.0);
	}

	#[test]
	fn nan_prices_are_ignored() {
		let candles = [
			candle(1.0, 2.0, 1.0, 1.5),
			candle(f64::NAN, f64::NAN, f64::NAN, f64::NAN),
			candle(3.0, 4.0, 3.0, 3.5),
		];
		assert_eq!(price_range(&candles), Some((1.0, 4.0)));
		assert_eq!(
			values_range(&[f64::NAN, 2.0, f64::INFINITY]),
			Some((2.0, 2.0))
		);
	}

	#[test]
	fn volume_sits_below_the_price_plot_inside_the_chart() {
		let geometry = ChartGeometry::new(320.0, 200.0, 10, 10.0, 20.0, true);
		let volume = geometry.volume.expect("a volume pane");
		assert!(volume.y >= geometry.plot.bottom());
		assert!(volume.bottom() <= 200.0);
		assert!(volume.height > 0.0);
	}

	#[test]
	fn tiny_charts_keep_a_drawable_plot() {
		let geometry = ChartGeometry::new(1.0, 1.0, 0, 0.0, 0.0, true);
		assert!(geometry.plot.width >= 1.0);
		assert!(geometry.plot.height >= 1.0);
		assert!(geometry.volume.is_none());
	}
}
