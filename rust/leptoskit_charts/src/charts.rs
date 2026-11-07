//! The hand-drawn chart components.

use leptoskit::native::Element;
use leptoskit::native::Role;
use leptoskit::prelude::*;
use leptoskit::yoga::Dimension;
use skribble_leptoskit::Tone;
use skribble_rough::FillStyle;
use skribble_rough::Point;

use crate::data::Candle;
use crate::data::LineSeries;
use crate::data::Overlay;
use crate::data::SeriesKind;
use crate::geometry::ChartGeometry;
use crate::geometry::LinearScale;
use crate::geometry::PriceScale;
use crate::geometry::Rect;
use crate::geometry::padded_range;
use crate::geometry::price_range;
use crate::geometry::values_range;
use crate::indicators;
use crate::render::ChartInk;
use crate::render::LAYER_GRID;
use crate::theme::ChartTheme;

/// Vertical grid lines across the price pane.
const GRID_STEPS: [f64; 3] = [0.25, 0.5, 0.75];

/// A hand-drawn price chart: candlesticks, OHLC bars, a line, or an area.
///
/// Candles are drawn in the order given. Rising candles use
/// [`ChartTheme::rise`], falling ones [`ChartTheme::fall`], and every body
/// keeps its exact open, high, low, and close positions; only the texture
/// wobbles. Volume, moving averages, and Bollinger Bands are optional.
///
/// The drawing paints with the element's text colour and follows the host's
/// light or dark appearance. Give it a `label` to make it an image for
/// assistive technology; without one it is decorative.
///
/// # Panics
///
/// Panics when `width` or `height` is not a positive, finite number, or when
/// an overlay's period is zero. These are mistakes in the layout or settings
/// rather than something to recover from.
///
/// ```
/// use leptoskit::prelude::*;
/// use skribble_leptoskit_charts::Candle;
/// use skribble_leptoskit_charts::Overlay;
/// use skribble_leptoskit_charts::WiredCandlestickChart;
///
/// let candles = vec![
/// 	Candle::new(1, 10.0, 12.0, 9.0, 11.0, 100.0),
/// 	Candle::new(2, 11.0, 13.0, 10.0, 12.0, 120.0),
/// ];
/// let chart = view! {
/// 	<WiredCandlestickChart
/// 		candles=candles
/// 		width=320.0
/// 		height=200.0
/// 		overlays=vec![Overlay::Sma(2)]
/// 		show_volume=true
/// 		label="Price in US dollars"
/// 	/>
/// };
/// assert!(chart.validate().is_ok());
/// ```
#[component]
pub fn WiredCandlestickChart(
	/// The intervals to draw, usually oldest first.
	candles: Vec<Candle>,
	/// Width in logical pixels.
	width: f32,
	/// Height in logical pixels.
	height: f32,
	/// Candles, OHLC bars, a line, or an area.
	#[prop(optional)]
	kind: SeriesKind,
	/// Technical overlays drawn over the price series.
	#[prop(optional)]
	overlays: Vec<Overlay>,
	/// Draws volume bars below the price pane.
	#[prop(optional)]
	show_volume: bool,
	/// Chooses the wobble. The same seed always draws the same chart.
	#[prop(default = 1)]
	seed: i64,
	/// The colours and line weight to draw with.
	#[prop(default = ChartTheme::SKRIBBLE)]
	theme: ChartTheme,
	/// Names the chart for assistive technology. Without one the chart is
	/// decorative.
	#[prop(optional, into)]
	label: Option<String>,
	/// Extra Tailwind classes.
	#[prop(optional, into)]
	class: Option<String>,
) -> Element {
	assert!(
		width.is_finite() && width > 0.0 && height.is_finite() && height > 0.0,
		"a chart needs a positive, finite size, found {width} by {height}"
	);

	let candles: Vec<Candle> = candles.into_iter().filter(Candle::is_finite).collect();
	let closes: Vec<f64> = candles.iter().map(|candle| candle.close).collect();
	let lines = overlay_lines(&overlays, &closes, theme);
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

	let chart = View().children(ink.finish().vectors());
	let chart = sized(chart, width, height);
	let chart = accessible(chart, label);
	with_class(chart, class)
}

/// A hand-drawn line chart over values or explicit points.
///
/// A [`LineSeries::Values`] series plots one value per evenly spaced slot; a
/// [`LineSeries::Points`] series plots each point at its own coordinates.
/// Non-finite values are skipped, leaving a gap in the line. Give it a `label`
/// to make it an image for assistive technology; without one it is
/// decorative.
///
/// # Panics
///
/// Panics when `width` or `height` is not a positive, finite number.
///
/// ```
/// use leptoskit::prelude::*;
/// use skribble_leptoskit_charts::WiredLineChart;
///
/// let chart = view! {
/// 	<WiredLineChart series=vec![1.0, 3.0, 2.0, 5.0] width=240.0 height=120.0 label="Revenue" />
/// };
/// assert!(chart.validate().is_ok());
/// ```
#[component]
pub fn WiredLineChart(
	/// The values or points to draw.
	#[prop(into)]
	series: LineSeries,
	/// Width in logical pixels.
	width: f32,
	/// Height in logical pixels.
	height: f32,
	/// Chooses the wobble. The same seed always draws the same chart.
	#[prop(default = 1)]
	seed: i64,
	/// The colours and line weight to draw with.
	#[prop(default = ChartTheme::SKRIBBLE)]
	theme: ChartTheme,
	/// Names the chart for assistive technology. Without one the chart is
	/// decorative.
	#[prop(optional, into)]
	label: Option<String>,
	/// Extra Tailwind classes.
	#[prop(optional, into)]
	class: Option<String>,
) -> Element {
	assert!(
		width.is_finite() && width > 0.0 && height.is_finite() && height > 0.0,
		"a chart needs a positive, finite size, found {width} by {height}"
	);

	let mut ink = ChartInk::new(width, height);
	ink.background(theme.background);
	let plot = ChartGeometry::plot_only(f64::from(width), f64::from(height));
	draw_plot_frame(&mut ink, plot, theme);

	match series {
		LineSeries::Values(values) => {
			let (min, max) =
				values_range(&values).map_or((0.0, 1.0), |(min, max)| padded_range(min, max, 0.06));
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
				.into_iter()
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

	let chart = View().children(ink.finish().vectors());
	let chart = sized(chart, width, height);
	let chart = accessible(chart, label);
	with_class(chart, class)
}

/// A hand-drawn bar chart with a label under every bar.
///
/// Bars grow from zero; positive values use [`ChartTheme::rise`] and negative
/// ones [`ChartTheme::fall`]. The labels sit in a row below the plot, so the
/// component is `height` plus one text line tall. Give it a `label` to make it
/// an image for assistive technology; without one it is decorative.
///
/// # Panics
///
/// Panics when `width` or `height` is not a positive, finite number.
///
/// ```
/// use leptoskit::prelude::*;
/// use skribble_leptoskit_charts::WiredBarChart;
///
/// let chart = view! {
/// 	<WiredBarChart
/// 		bars=vec![("Mon".to_owned(), 4.0), ("Tue".to_owned(), -1.0)]
/// 		width=240.0
/// 		height=140.0
/// 		label="Weekday change"
/// 	/>
/// };
/// assert!(chart.validate().is_ok());
/// ```
#[component]
pub fn WiredBarChart(
	/// Bars as `(label, value)` pairs, drawn left to right.
	bars: Vec<(String, f64)>,
	/// Width in logical pixels.
	width: f32,
	/// Height in logical pixels, before the label row.
	height: f32,
	/// Chooses the wobble. The same seed always draws the same chart.
	#[prop(default = 1)]
	seed: i64,
	/// The colours and line weight to draw with.
	#[prop(default = ChartTheme::SKRIBBLE)]
	theme: ChartTheme,
	/// Names the chart for assistive technology. Without one the chart is
	/// decorative.
	#[prop(optional, into)]
	label: Option<String>,
	/// Extra Tailwind classes.
	#[prop(optional, into)]
	class: Option<String>,
) -> Element {
	assert!(
		width.is_finite() && width > 0.0 && height.is_finite() && height > 0.0,
		"a chart needs a positive, finite size, found {width} by {height}"
	);

	let bars: Vec<(String, f64)> = bars
		.into_iter()
		.filter(|(_, value)| value.is_finite())
		.collect();
	let mut min = 0.0_f64;
	let mut max = 0.0_f64;
	for (_, value) in &bars {
		min = min.min(*value);
		max = max.max(*value);
	}
	let (min, max) = padded_range(min, max, 0.04);
	let plot = ChartGeometry::plot_only(f64::from(width), f64::from(height));
	let price = PriceScale::new(min, max, plot.y, plot.bottom());
	let baseline = price.y(0.0);
	let slot = if bars.is_empty() {
		0.0
	} else {
		plot.width / bars.len() as f64
	};
	let bar_width = (slot * 0.64).max(0.8);

	let mut ink = ChartInk::new(width, height);
	ink.background(theme.background);
	draw_plot_frame(&mut ink, plot, theme);
	for (index, (_, value)) in bars.iter().enumerate() {
		let x = plot.x + slot * (index as f64 + 0.5);
		let top = price.y((*value).max(0.0)).min(baseline);
		let bottom = price.y((*value).min(0.0)).max(baseline);
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

	let plot_view = sized(View().children(ink.finish().vectors()), width, height);
	let labels = View()
		.class("flex-row w-full")
		.children(bars.iter().map(|(label, _)| {
			Text(label.clone()).class("flex-1 text-center text-xs overflow-hidden")
		}))
		.with_style(|style| style.width = Dimension::Points(width));
	let chart = View()
		.class("flex-col")
		.child(plot_view)
		.child(labels)
		.with_style(|style| style.width = Dimension::Points(width));
	let chart = accessible(chart, label);
	with_class(chart, class)
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

fn sized(element: Element, width: f32, height: f32) -> Element {
	element.with_style(|style| {
		style.width = Dimension::Points(width);
		style.height = Dimension::Points(height);
	})
}

fn accessible(element: Element, label: Option<String>) -> Element {
	match label {
		Some(label) => element.role(Role::Img).aria_label(label),
		None => element.aria_hidden(true),
	}
}

fn with_class(element: Element, class: Option<String>) -> Element {
	match class {
		Some(class) => element.class(class),
		None => element,
	}
}
