//! Turning chart geometry into ink.

use skribble_rough::DrawConfig;
use skribble_rough::DrawOptions;
use skribble_rough::Drawable;
use skribble_rough::FillOptions;
use skribble_rough::FillStyle;
use skribble_rough::Filler;
use skribble_rough::Generator;
use skribble_rough::Point;
use skribble_rough::RoughPen;
use skribble_rough::RoughSvgPaths;
use skribble_rough::format_number;

use crate::InkDrawing;
use crate::InkScaling;
use crate::Tone;

/// Sketched fill lines are a little lighter than outlines.
const SKETCH_WEIGHT: f32 = 0.65;

/// Paint order: the paper goes down first, then the grid, fills, hatch
/// strokes, outlines, and finally overlay lines.
pub(crate) const LAYER_BACKGROUND: u8 = 0;
pub(crate) const LAYER_GRID: u8 = 1;
pub(crate) const LAYER_FILL: u8 = 2;
pub(crate) const LAYER_SKETCH: u8 = 3;
pub(crate) const LAYER_OUTLINE: u8 = 4;
pub(crate) const LAYER_OVERLAY: u8 = 5;

/// How one path is painted.
#[derive(Debug, Clone, Copy, PartialEq)]
pub(crate) enum PaintKind {
	/// Filled with a tone.
	Fill(Tone),
	/// Stroked with a tone, `width` logical pixels wide.
	Stroke(Tone, f32),
}

/// One path, as SVG path data, its paint, and its place in the paint order.
#[derive(Debug, Clone, PartialEq)]
struct ChartPath {
	data: String,
	paint: PaintKind,
	layer: u8,
}

/// Builds the ink for one chart at its final size.
#[derive(Debug, Clone, PartialEq)]
pub(crate) struct ChartInk {
	width: f32,
	height: f32,
	paths: Vec<ChartPath>,
}

impl ChartInk {
	/// A blank canvas `width` by `height` logical pixels.
	pub(crate) fn new(width: f32, height: f32) -> Self {
		Self {
			width,
			height,
			paths: Vec::new(),
		}
	}

	/// Paints the paper behind everything.
	pub(crate) fn background(&mut self, tone: Tone) {
		let path = rect_path(0.0, 0.0, f64::from(self.width), f64::from(self.height));
		self.add(&path, PaintKind::Fill(tone), LAYER_BACKGROUND);
	}

	/// Draws an exact, un-wobbled line. The grid uses these so it never
	/// competes with the data.
	pub(crate) fn exact_line(
		&mut self,
		from: (f64, f64),
		to: (f64, f64),
		tone: Tone,
		width: f32,
		layer: u8,
	) {
		let path = line_path(from.0, from.1, to.0, to.1);
		self.add(&path, PaintKind::Stroke(tone, width), layer);
	}

	/// Draws one rough shape with a sketched fill and an outline.
	pub(crate) fn shape(
		&mut self,
		seed: i64,
		roughness: f64,
		style: FillStyle,
		fill: Option<Tone>,
		outline: Option<(Tone, f32)>,
		build: impl FnOnce(&mut Generator) -> Drawable,
	) {
		let options = rough_options(seed, roughness);
		let pattern = FillOptions {
			hachure_gap: 4.5,
			hachure_angle: -45.0,
			..FillOptions::default()
		};
		let mut generator = Generator::new(
			DrawConfig::new(options),
			Filler::new(style, pattern, DrawConfig::new(options)),
		);
		let drawable = build(&mut generator);
		let paths = RoughSvgPaths::from_drawable(&drawable);
		if let Some(tone) = fill {
			self.add(&paths.solid, PaintKind::Fill(tone), LAYER_FILL);
			self.add(
				&paths.sketch,
				PaintKind::Stroke(tone, SKETCH_WEIGHT),
				LAYER_SKETCH,
			);
		}
		if let Some((tone, width)) = outline {
			self.add(
				&paths.outline,
				PaintKind::Stroke(tone, width),
				LAYER_OUTLINE,
			);
		}
	}

	/// Draws a hand-drawn line through `points`, above the price ink.
	pub(crate) fn overlay(
		&mut self,
		seed: i64,
		roughness: f64,
		points: &[Point],
		tone: Tone,
		width: f32,
	) {
		if points.len() < 2 {
			return;
		}
		let options = rough_options(seed, roughness);
		let mut generator = Generator::new(
			DrawConfig::new(options),
			Filler::new(
				FillStyle::None,
				FillOptions::default(),
				DrawConfig::new(options),
			),
		);
		let drawable = generator.linear_path(points, false);
		let paths = RoughSvgPaths::from_drawable(&drawable);
		self.add(
			&paths.outline,
			PaintKind::Stroke(tone, width),
			LAYER_OVERLAY,
		);
	}

	/// The finished drawing, in paint order.
	pub(crate) fn finish(self) -> InkDrawing {
		let mut paths = self.paths;
		paths.sort_by_key(|path| path.layer);
		let mut drawing = InkDrawing::new(
			f64::from(self.width),
			f64::from(self.height),
			InkScaling::Fit,
		);
		for path in paths {
			match path.paint {
				PaintKind::Fill(tone) => drawing.push_fill(path.data, tone),
				PaintKind::Stroke(tone, width) => drawing.push_stroke(path.data, tone, width),
			}
		}
		drawing
	}

	fn add(&mut self, data: &str, paint: PaintKind, layer: u8) {
		if data.is_empty() {
			return;
		}
		if let Some(existing) = self
			.paths
			.iter_mut()
			.find(|path| path.paint == paint && path.layer == layer)
		{
			existing.data.push_str(data);
		} else {
			self.paths.push(ChartPath {
				data: data.to_owned(),
				paint,
				layer,
			});
		}
	}
}

fn rough_options(seed: i64, roughness: f64) -> DrawOptions {
	DrawOptions {
		seed,
		roughness,
		pen: RoughPen::UNIFORM,
		..DrawOptions::default()
	}
}

/// Path data for an exact rectangle.
pub(crate) fn rect_path(x: f64, y: f64, width: f64, height: f64) -> String {
	format!(
		"M {} {} L {} {} L {} {} L {} {} Z",
		format_number(x, 2),
		format_number(y, 2),
		format_number(x + width, 2),
		format_number(y, 2),
		format_number(x + width, 2),
		format_number(y + height, 2),
		format_number(x, 2),
		format_number(y + height, 2),
	)
}

/// Path data for an exact line.
pub(crate) fn line_path(x1: f64, y1: f64, x2: f64, y2: f64) -> String {
	format!(
		"M {} {} L {} {}",
		format_number(x1, 2),
		format_number(y1, 2),
		format_number(x2, 2),
		format_number(y2, 2)
	)
}

#[cfg(test)]
mod tests {
	use super::*;
	use crate::InkPaint;
	use crate::charts::ChartTheme;

	#[test]
	fn a_drawing_is_one_run_per_tone() {
		let mut ink = ChartInk::new(100.0, 50.0);
		ink.background(ChartTheme::SKRIBBLE.background);
		ink.exact_line(
			(0.0, 0.0),
			(100.0, 50.0),
			ChartTheme::SKRIBBLE.grid,
			1.0,
			LAYER_GRID,
		);
		let drawing = ink.finish();
		assert_eq!(drawing.runs().count(), 2);
		assert_eq!(drawing.scaling, InkScaling::Fit);
	}

	#[test]
	fn the_background_is_a_fill() {
		let mut ink = ChartInk::new(100.0, 50.0);
		ink.background(ChartTheme::SKRIBBLE.background);
		let drawing = ink.finish();
		assert_eq!(
			drawing.paths[0].paint,
			InkPaint::Fill(ChartTheme::SKRIBBLE.background)
		);
	}

	#[test]
	fn exact_paths_are_stable() {
		assert_eq!(
			rect_path(0.0, 0.0, 10.0, 5.0),
			"M 0 0 L 10 0 L 10 5 L 0 5 Z"
		);
		assert_eq!(line_path(1.0, 2.0, 3.0, 4.0), "M 1 2 L 3 4");
	}

	#[test]
	fn later_layers_paint_over_earlier_ones() {
		let mut ink = ChartInk::new(20.0, 20.0);
		ink.exact_line(
			(0.0, 0.0),
			(1.0, 1.0),
			ChartTheme::SKRIBBLE.grid,
			1.0,
			LAYER_GRID,
		);
		ink.background(ChartTheme::SKRIBBLE.background);
		let drawing = ink.finish();
		assert!(matches!(drawing.paths[0].paint, InkPaint::Fill(_)));
		assert!(matches!(drawing.paths[1].paint, InkPaint::Stroke { .. }));
	}
}
