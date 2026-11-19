//! Whole charts, drawn at an explicit size.

use std::fmt;

use skribble_rough::FillStyle;
use skribble_rough::Point;

use crate::InkDrawing;
use crate::Tone;
use crate::charts::ChartTheme;
use crate::charts::data::Candle;
use crate::charts::data::LineSeries;
use crate::charts::data::Overlay;
use crate::charts::data::SeriesKind;
use crate::charts::geometry::ChartGeometry;
use crate::charts::geometry::LinearScale;
use crate::charts::geometry::PriceScale;
use crate::charts::geometry::Rect;
use crate::charts::geometry::padded_range;
use crate::charts::geometry::price_range;
use crate::charts::geometry::values_range;
use crate::charts::indicators;
use crate::charts::ink::ChartInk;
use crate::charts::ink::LAYER_GRID;

/// Vertical grid lines across the price pane.
const GRID_STEPS: [f64; 3] = [0.25, 0.5, 0.75];

/// A chart was asked to draw at a size that is not a positive, finite number.
#[derive(Debug, Clone, Copy, PartialEq)]
pub struct ChartSizeError {
	/// The width given.
	pub width: f32,
	/// The height given.
	pub height: f32,
}

impl fmt::Display for ChartSizeError {
	fn fmt(&self, formatter: &mut fmt::Formatter<'_>) -> fmt::Result {
		write!(
			formatter,
			"a chart needs a positive, finite size, found {} by {}",
			self.width, self.height
		)
	}
}

impl std::error::Error for ChartSizeError {}

fn check_size(width: f32, height: f32) -> Result<(), ChartSizeError> {
	if width.is_finite() && width > 0.0 && height.is_finite() && height > 0.0 {
		Ok(())
	} else {
		Err(ChartSizeError { width, height })
	}
}

/// A hand-drawn price chart: candlesticks, OHLC bars, a line, or an area.
///
/// Candles are drawn in the order given. Rising candles use
/// [`ChartTheme::rise`], falling ones [`ChartTheme::fall`], and every body
/// keeps its exact open, high, low, and close positions; only the texture
/// wobbles. Volume, moving averages, and Bollinger Bands are optional.
///
/// ```
/// use skribble_core::charts::Candle;
/// use skribble_core::charts::CandlestickChart;
/// use skribble_core::charts::Overlay;
///
/// let chart = CandlestickChart {
/// 	overlays: vec![Overlay::Sma(2)],
/// 	show_volume: true,
/// 	..CandlestickChart::new(vec![
/// 		Candle::new(1, 10.0, 12.0, 9.0, 11.0, 100.0),
/// 		Candle::new(2, 11.0, 13.0, 10.0, 12.0, 120.0),
/// 	])
/// };
/// let drawing = chart.drawing(320.0, 200.0).expect("a positive size");
/// assert!(!drawing.is_empty());
/// ```
#[derive(Debug, Clone, PartialEq)]
pub struct CandlestickChart {
	/// The intervals to draw, usually oldest first. Candles with a non-finite
	/// price are skipped.
	pub candles: Vec<Candle>,
	/// Candles, OHLC bars, a line, or an area.
	pub kind: SeriesKind,
	/// Technical overlays drawn over the price series.
	pub overlays: Vec<Overlay>,
	/// Draws volume bars below the price pane.
	pub show_volume: bool,
	/// Chooses the wobble. The same seed always draws the same chart.
	pub seed: i64,
	/// The colours and line weight to draw with.
	pub theme: ChartTheme,
}

impl CandlestickChart {
	/// Candlesticks for `candles`, with no overlays or volume.
	pub fn new(candles: Vec<Candle>) -> Self {
		Self {
			candles,
			kind: SeriesKind::default(),
			overlays: Vec::new(),
			show_volume: false,
			seed: 1,
			theme: ChartTheme::SKRIBBLE,
		}
	}

	/// The chart drawn on a `width` by `height` canvas.
	///
	/// # Errors
	///
	/// [`ChartSizeError`] when `width` or `height` is not a positive, finite
	/// number.
	///
	/// # Panics
	///
	/// Panics when an overlay's period is zero.
	pub fn drawing(&self, width: f32, height: f32) -> Result<InkDrawing, ChartSizeError> {
		check_size(width, height)?;
		let Self {
			kind,
			show_volume,
			seed,
			theme,
			..
		} = *self;

		let candles: Vec<Candle> = self
			.candles
			.iter()
			.copied()
			.filter(Candle::is_finite)
			.collect();
		let closes: Vec<f64> = candles.iter().map(|candle| candle.close).collect();
		let lines = overlay_lines(&self.overlays, &closes, theme);
		let bounds = lines.iter().fold(price_range(&candles), |bounds, line| {
			extend_bounds(bounds, &line.values)
		});
		let (min, max) = bounds.map_or((0.0, 1.0), |(min, max)| padded_range(min, max, 0.06));
		let geometry = ChartGeometry::new(
			f64::from(width),
			f64::from(height),
			candles.len(),
			min,
			max,
			show_volume,
		);

		let mut ink = ChartInk::new(width, height);
		ink.background(theme.background);
		draw_grid(&mut ink, &geometry, theme);
		if show_volume {
			draw_volume(&mut ink, &candles, &geometry, theme, seed);
		}
		match kind {
			SeriesKind::Candles | SeriesKind::Ohlc => {
				draw_candles(&mut ink, &candles, &geometry, theme, seed, kind);
			}
			SeriesKind::Line | SeriesKind::Area => {
				draw_close_series(&mut ink, &candles, &geometry, theme, seed, kind);
			}
		}
		for (index, line) in lines.iter().enumerate() {
			draw_values(
				&mut ink,
				&line.values,
				&geometry,
				line.tone,
				line.width,
				seed.wrapping_add(index as i64 * 31),
				theme.roughness,
			);
		}
		Ok(ink.finish())
	}
}

/// A hand-drawn line chart over values or explicit points.
///
/// A [`LineSeries::Values`] series plots one value per evenly spaced slot; a
/// [`LineSeries::Points`] series plots each point at its own coordinates.
/// Non-finite values are skipped, leaving a gap in the line.
///
/// ```
/// use skribble_core::charts::LineChart;
///
/// let chart = LineChart::new(vec![1.0, 3.0, 2.0, 5.0]);
/// assert!(chart.drawing(240.0, 120.0).is_ok());
/// assert!(chart.drawing(0.0, 120.0).is_err());
/// ```
#[derive(Debug, Clone, PartialEq)]
pub struct LineChart {
	/// The values or points to draw.
	pub series: LineSeries,
	/// Chooses the wobble. The same seed always draws the same chart.
	pub seed: i64,
	/// The colours and line weight to draw with.
	pub theme: ChartTheme,
}

impl LineChart {
	/// A line through `series`.
	pub fn new(series: impl Into<LineSeries>) -> Self {
		Self {
			series: series.into(),
			seed: 1,
			theme: ChartTheme::SKRIBBLE,
		}
	}

	/// The chart drawn on a `width` by `height` canvas.
	///
	/// # Errors
	///
	/// [`ChartSizeError`] when `width` or `height` is not a positive, finite
	/// number.
	pub fn drawing(&self, width: f32, height: f32) -> Result<InkDrawing, ChartSizeError> {
		check_size(width, height)?;
		let Self { seed, theme, .. } = *self;
		let mut ink = ChartInk::new(width, height);
		ink.background(theme.background);
		let plot = ChartGeometry::plot_only(f64::from(width), f64::from(height));
		draw_plot_frame(&mut ink, plot, theme);

		match &self.series {
			LineSeries::Values(values) => {
				let (min, max) = values_range(values)
					.map_or((0.0, 1.0), |(min, max)| padded_range(min, max, 0.06));
				let geometry = ChartGeometry::new(
					f64::from(width),
					f64::from(height),
					values.len(),
					min,
					max,
					false,
				);
				draw_values(
					&mut ink,
					&values.iter().copied().map(Some).collect::<Vec<_>>(),
					&geometry,
					theme.rise,
					1.6,
					seed,
					theme.roughness,
				);
			}
			LineSeries::Points(points) => {
				let finite: Vec<(f64, f64)> = points
					.iter()
					.copied()
					.filter(|(x, y)| x.is_finite() && y.is_finite())
					.collect();
				if let (Some((x_min, x_max)), Some((y_min, y_max))) = (
					values_range(&finite.iter().map(|(x, _)| *x).collect::<Vec<_>>()),
					values_range(&finite.iter().map(|(_, y)| *y).collect::<Vec<_>>()),
				) {
					let (x_min, x_max) = padded_range(x_min, x_max, 0.04);
					let (y_min, y_max) = padded_range(y_min, y_max, 0.06);
					let x_scale = LinearScale::new(x_min, x_max, plot.x, plot.right());
					let y_scale = PriceScale::new(y_min, y_max, plot.y, plot.bottom());
					let mapped: Vec<Point> = finite
						.iter()
						.map(|(x, y)| Point::new(x_scale.position(*x), y_scale.y(*y)))
						.collect();
					draw_line_runs(&mut ink, &mapped, theme.rise, 1.6, seed, theme.roughness);
				}
			}
		}
		Ok(ink.finish())
	}
}

/// A hand-drawn bar chart.
///
/// Bars grow from zero; positive values use [`ChartTheme::rise`] and negative
/// ones [`ChartTheme::fall`]. Bars with a non-finite value are skipped. The
/// labels are not drawn: lay them out under the plot as text, one per slot,
/// from [`BarChart::labels`].
///
/// ```
/// use skribble_core::charts::BarChart;
///
/// let chart = BarChart::new(vec![("Mon".to_owned(), 4.0), ("Tue".to_owned(), -1.0)]);
/// assert_eq!(chart.labels().collect::<Vec<_>>(), ["Mon", "Tue"]);
/// assert!(chart.drawing(240.0, 140.0).is_ok());
/// ```
#[derive(Debug, Clone, PartialEq)]
pub struct BarChart {
	/// Bars as `(label, value)` pairs, drawn left to right.
	pub bars: Vec<(String, f64)>,
	/// Chooses the wobble. The same seed always draws the same chart.
	pub seed: i64,
	/// The colours and line weight to draw with.
	pub theme: ChartTheme,
}

impl BarChart {
	/// Bars for `bars`, as `(label, value)` pairs.
	pub fn new(bars: Vec<(String, f64)>) -> Self {
		Self {
			bars,
			seed: 1,
			theme: ChartTheme::SKRIBBLE,
		}
	}

	/// The labels of the bars that are drawn, left to right, one per slot.
	pub fn labels(&self) -> impl Iterator<Item = &str> {
		self.bars
			.iter()
			.filter(|(_, value)| value.is_finite())
			.map(|(label, _)| label.as_str())
	}

	/// The plot drawn on a `width` by `height` canvas, without the labels.
	///
	/// # Errors
	///
	/// [`ChartSizeError`] when `width` or `height` is not a positive, finite
	/// number.
	pub fn drawing(&self, width: f32, height: f32) -> Result<InkDrawing, ChartSizeError> {
		check_size(width, height)?;
		let Self { seed, theme, .. } = *self;
		let values: Vec<f64> = self
			.bars
			.iter()
			.map(|(_, value)| *value)
			.filter(|value| value.is_finite())
			.collect();
		let mut min = 0.0_f64;
		let mut max = 0.0_f64;
		for value in &values {
			min = min.min(*value);
			max = max.max(*value);
		}
		let (min, max) = padded_range(min, max, 0.04);
		let plot = ChartGeometry::plot_only(f64::from(width), f64::from(height));
		let price = PriceScale::new(min, max, plot.y, plot.bottom());
		let baseline = price.y(0.0);
		let slot = if values.is_empty() {
			0.0
		} else {
			plot.width / values.len() as f64
		};
		let bar_width = (slot * 0.64).max(0.8);

		let mut ink = ChartInk::new(width, height);
		ink.background(theme.background);
		draw_plot_frame(&mut ink, plot, theme);
		for (index, value) in values.iter().enumerate() {
			let x = plot.x + slot * (index as f64 + 0.5);
			let top = price.y(value.max(0.0)).min(baseline);
			let bottom = price.y(value.min(0.0)).max(baseline);
			let height = (bottom - top).max(0.75);
			let tone = if *value >= 0.0 {
				theme.rise
			} else {
				theme.fall
			};
			ink.shape(
				seed.wrapping_add(index as i64 * 7919),
				theme.roughness,
				FillStyle::Hachure,
				Some(tone),
				Some((tone, theme.stroke_width)),
				|generator| generator.rectangle(x - bar_width / 2.0, top, bar_width, height),
			);
		}
		Ok(ink.finish())
	}
}

/// One overlay line resolved against the theme.
struct OverlayLine {
	values: Vec<Option<f64>>,
	tone: Tone,
	width: f32,
}

fn overlay_lines(overlays: &[Overlay], closes: &[f64], theme: ChartTheme) -> Vec<OverlayLine> {
	let mut lines = Vec::new();
	for (index, overlay) in overlays.iter().enumerate() {
		let tone = theme.indicator(index);
		match *overlay {
			Overlay::Sma(period) => lines.push(OverlayLine {
				values: indicators::sma(closes, period),
				tone,
				width: 1.35,
			}),
			Overlay::Ema(period) => lines.push(OverlayLine {
				values: indicators::ema(closes, period),
				tone,
				width: 1.35,
			}),
			Overlay::Bollinger { period, deviations } => {
				let bands = indicators::bollinger(closes, period, deviations);
				for (values, width) in [
					(bands.upper, 1.15),
					(bands.middle, 1.35),
					(bands.lower, 1.15),
				] {
					lines.push(OverlayLine {
						values,
						tone,
						width,
					});
				}
			}
		}
	}
	lines
}

fn extend_bounds(bounds: Option<(f64, f64)>, values: &[Option<f64>]) -> Option<(f64, f64)> {
	let mut bounds = bounds;
	for value in values
		.iter()
		.flatten()
		.copied()
		.filter(|value| value.is_finite())
	{
		bounds = Some(bounds.map_or((value, value), |(min, max)| {
			(min.min(value), max.max(value))
		}));
	}
	bounds
}

fn draw_grid(ink: &mut ChartInk, geometry: &ChartGeometry, theme: ChartTheme) {
	let plot = geometry.plot;
	for step in GRID_STEPS {
		let y = plot.y + plot.height * step;
		ink.exact_line((plot.x, y), (plot.right(), y), theme.grid, 1.0, LAYER_GRID);
	}
}

fn draw_plot_frame(ink: &mut ChartInk, plot: Rect, theme: ChartTheme) {
	ink.exact_line(
		(plot.x, plot.bottom()),
		(plot.right(), plot.bottom()),
		theme.grid,
		1.0,
		LAYER_GRID,
	);
}

fn draw_candles(
	ink: &mut ChartInk,
	candles: &[Candle],
	geometry: &ChartGeometry,
	theme: ChartTheme,
	seed: i64,
	kind: SeriesKind,
) {
	let width = geometry.index.candle_width();
	for (index, candle) in candles.iter().enumerate() {
		let x = geometry.index.x(index as f64);
		let tone = if candle.is_bullish() {
			theme.rise
		} else {
			theme.fall
		};
		let shape_seed = seed.wrapping_add(index as i64 * 7919);
		let high = geometry.price.y(candle.high);
		let low = geometry.price.y(candle.low);
		ink.shape(
			shape_seed,
			theme.roughness,
			FillStyle::None,
			None,
			Some((tone, theme.stroke_width)),
			|generator| generator.line(x, high, x, low),
		);
		if kind == SeriesKind::Ohlc {
			let open = geometry.price.y(candle.open);
			let close = geometry.price.y(candle.close);
			ink.shape(
				shape_seed.wrapping_add(1),
				theme.roughness,
				FillStyle::None,
				None,
				Some((tone, theme.stroke_width)),
				|generator| generator.line(x - width / 2.0, open, x, open),
			);
			ink.shape(
				shape_seed.wrapping_add(2),
				theme.roughness,
				FillStyle::None,
				None,
				Some((tone, theme.stroke_width)),
				|generator| generator.line(x, close, x + width / 2.0, close),
			);
		} else {
			let open = geometry.price.y(candle.open);
			let close = geometry.price.y(candle.close);
			let top = open.min(close);
			let bottom = open.max(close);
			let body = bottom - top;
			if body < 0.75 {
				ink.shape(
					shape_seed.wrapping_add(1),
					theme.roughness,
					FillStyle::None,
					None,
					Some((tone, theme.stroke_width)),
					|generator| generator.line(x - width / 2.0, top, x + width / 2.0, top),
				);
			} else {
				ink.shape(
					shape_seed.wrapping_add(1),
					theme.roughness,
					FillStyle::Hachure,
					Some(tone),
					Some((tone, theme.stroke_width)),
					|generator| generator.rectangle(x - width / 2.0, top, width, body),
				);
			}
		}
	}
}

fn draw_close_series(
	ink: &mut ChartInk,
	candles: &[Candle],
	geometry: &ChartGeometry,
	theme: ChartTheme,
	seed: i64,
	kind: SeriesKind,
) {
	let points: Vec<Point> = candles
		.iter()
		.enumerate()
		.map(|(index, candle)| {
			Point::new(
				geometry.index.x(index as f64),
				geometry.price.y(candle.close),
			)
		})
		.collect();
	match kind {
		SeriesKind::Area => {
			if points.len() >= 2 {
				let mut polygon = points;
				let left = polygon[0].x;
				let right = polygon[polygon.len() - 1].x;
				polygon.push(Point::new(right, geometry.plot.bottom()));
				polygon.push(Point::new(left, geometry.plot.bottom()));
				ink.shape(
					seed,
					theme.roughness,
					FillStyle::Hachure,
					Some(theme.rise),
					Some((theme.rise, 1.6)),
					|generator| generator.polygon(&polygon),
				);
			}
		}
		_ => draw_line_runs(ink, &points, theme.rise, 1.6, seed, theme.roughness),
	}
}

fn draw_values(
	ink: &mut ChartInk,
	values: &[Option<f64>],
	geometry: &ChartGeometry,
	tone: Tone,
	width: f32,
	seed: i64,
	roughness: f64,
) {
	let mut run: Vec<Point> = Vec::new();
	let mut runs = 0_usize;
	for (index, value) in values.iter().enumerate() {
		match value {
			Some(value) if value.is_finite() => {
				run.push(Point::new(
					geometry.index.x(index as f64),
					geometry.price.y(*value),
				));
			}
			_ => {
				draw_line_runs(
					ink,
					&run,
					tone,
					width,
					seed.wrapping_add(runs as i64 * 13),
					roughness,
				);
				runs += 1;
				run.clear();
			}
		}
	}
	draw_line_runs(
		ink,
		&run,
		tone,
		width,
		seed.wrapping_add(runs as i64 * 13),
		roughness,
	);
}

fn draw_line_runs(
	ink: &mut ChartInk,
	points: &[Point],
	tone: Tone,
	width: f32,
	seed: i64,
	roughness: f64,
) {
	if points.len() >= 2 {
		ink.overlay(seed, roughness, points, tone, width);
	}
}

fn draw_volume(
	ink: &mut ChartInk,
	candles: &[Candle],
	geometry: &ChartGeometry,
	theme: ChartTheme,
	seed: i64,
) {
	let Some(volume) = geometry.volume else {
		return;
	};
	let peak = candles
		.iter()
		.map(|candle| candle.volume)
		.filter(|volume| volume.is_finite())
		.fold(0.0_f64, f64::max);
	if peak <= 0.0 {
		return;
	}
	let width = geometry.index.candle_width() * 0.9;
	for (index, candle) in candles.iter().enumerate() {
		let x = geometry.index.x(index as f64);
		let height = candle.volume / peak * volume.height;
		let top = volume.bottom() - height.max(0.75);
		let tone = if candle.is_bullish() {
			theme.rise
		} else {
			theme.fall
		};
		ink.shape(
			seed.wrapping_add(index as i64 * 7919),
			theme.roughness * 0.8,
			FillStyle::Hachure,
			Some(tone),
			Some((tone, theme.stroke_width * 0.6)),
			|generator| generator.rectangle(x - width / 2.0, top, width, height.max(0.75)),
		);
	}
}

#[cfg(test)]
mod tests {
	use super::*;
	use crate::InkPaint;
	use crate::InkScaling;

	fn candles() -> Vec<Candle> {
		vec![
			Candle::new(1, 10.0, 12.0, 9.0, 11.0, 100.0),
			Candle::new(2, 11.0, 13.0, 10.0, 12.0, 120.0),
			Candle::new(3, 12.0, 12.5, 10.5, 11.0, 90.0),
		]
	}

	fn tones(drawing: &InkDrawing) -> Vec<Tone> {
		drawing.paths.iter().map(|path| path.paint.tone()).collect()
	}

	#[test]
	fn candles_draw_rises_and_falls_over_paper() {
		let drawing = CandlestickChart::new(candles())
			.drawing(320.0, 200.0)
			.expect("valid");
		let theme = ChartTheme::SKRIBBLE;
		assert_eq!(drawing.scaling, InkScaling::Fit);
		assert_eq!(drawing.paths[0].paint, InkPaint::Fill(theme.background));
		let tones = tones(&drawing);
		assert!(tones.contains(&theme.rise));
		assert!(tones.contains(&theme.fall));
	}

	#[test]
	fn overlays_and_volume_add_ink() {
		let plain = CandlestickChart::new(candles())
			.drawing(320.0, 200.0)
			.expect("valid");
		let busy = CandlestickChart {
			overlays: vec![
				Overlay::Sma(2),
				Overlay::Ema(2),
				Overlay::Bollinger {
					period: 2,
					deviations: 2.0,
				},
			],
			show_volume: true,
			..CandlestickChart::new(candles())
		}
		.drawing(320.0, 200.0)
		.expect("valid");
		assert!(busy.paths.len() > plain.paths.len());
		assert!(tones(&busy).contains(&ChartTheme::SKRIBBLE.indicator(0)));
	}

	#[test]
	fn every_series_kind_draws() {
		for kind in [
			SeriesKind::Candles,
			SeriesKind::Ohlc,
			SeriesKind::Line,
			SeriesKind::Area,
		] {
			let chart = CandlestickChart {
				kind,
				..CandlestickChart::new(candles())
			};
			assert!(chart.drawing(200.0, 100.0).expect("valid").paths.len() > 2);
		}
	}

	#[test]
	fn bad_sizes_are_errors() {
		let error = CandlestickChart::new(candles())
			.drawing(f32::NAN, 10.0)
			.unwrap_err();
		assert!(error.to_string().contains("positive"));
		assert!(LineChart::new(vec![1.0]).drawing(10.0, -1.0).is_err());
		assert!(BarChart::new(Vec::new()).drawing(0.0, 0.0).is_err());
	}

	#[test]
	fn line_charts_take_values_or_points() {
		let values = LineChart::new(vec![1.0, f64::NAN, 2.0, 3.0])
			.drawing(200.0, 100.0)
			.expect("valid");
		assert!(tones(&values).contains(&ChartTheme::SKRIBBLE.rise));
		let points = LineChart::new(vec![(0.0, 1.0), (2.0, 3.0), (5.0, 2.0)])
			.drawing(200.0, 100.0)
			.expect("valid");
		assert!(tones(&points).contains(&ChartTheme::SKRIBBLE.rise));
	}

	#[test]
	fn bars_grow_both_ways_and_skip_gaps() {
		let chart = BarChart::new(vec![
			("Up".to_owned(), 4.0),
			("Gap".to_owned(), f64::NAN),
			("Down".to_owned(), -2.0),
		]);
		assert_eq!(chart.labels().collect::<Vec<_>>(), ["Up", "Down"]);
		let drawing = chart.drawing(200.0, 100.0).expect("valid");
		let tones = tones(&drawing);
		assert!(tones.contains(&ChartTheme::SKRIBBLE.rise));
		assert!(tones.contains(&ChartTheme::SKRIBBLE.fall));
	}

	#[test]
	fn the_same_seed_draws_the_same_chart() {
		let chart = CandlestickChart::new(candles());
		assert_eq!(chart.drawing(200.0, 100.0), chart.drawing(200.0, 100.0));
		let other = CandlestickChart {
			seed: 9,
			..chart.clone()
		};
		assert_ne!(chart.drawing(200.0, 100.0), other.drawing(200.0, 100.0));
	}
}
