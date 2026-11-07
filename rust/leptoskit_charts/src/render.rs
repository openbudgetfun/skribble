//! Turning chart geometry into leptoskit vector ink.

use leptoskit::native::Element;
use leptoskit::native::Paint;
use leptoskit::native::PathData;
use leptoskit::native::Stroke;
use leptoskit::native::VectorPath;
use leptoskit::native::VectorScaling;
use leptoskit::native::ViewBox;
use leptoskit::prelude::Vector;
use skribble_leptoskit::Tone;
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

use crate::theme::tone_class;

/// Sketched fill lines are a little lighter than outlines.
const SKETCH_WEIGHT: f32 = 0.65;

/// Covers the parent, so the drawing stretches with it.
const COVER: &str = "absolute top-0 left-0 w-full h-full";

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

impl PaintKind {
	const fn tone(self) -> Tone {
		match self {
			Self::Fill(tone) | Self::Stroke(tone, _) => tone,
		}
	}
}

/// One path, as SVG path data, its paint, and its place in the paint order.
#[derive(Debug, Clone, PartialEq)]
struct ChartPath {
	data: String,
	paint: PaintKind,
	layer: u8,
}

/// Chart paths in their own coordinate space, ready to become vector
/// elements.
#[derive(Debug, Clone, PartialEq)]
pub(crate) struct ChartDrawing {
	width: f32,
	height: f32,
	paths: Vec<ChartPath>,
}

impl ChartDrawing {
	/// The vector elements that draw these paths, covering their parent.
	pub(crate) fn vectors(&self) -> Vec<Element> {
		let view_box = ViewBox::new(0.0, 0.0, self.width, self.height)
			.expect("charts are drawn on a positive, finite canvas");
		let mut vectors = Vec::new();
		let mut run: Option<(Tone, Element)> = None;
		for path in &self.paths {
			let tone = path.paint.tone();
			let (_, vector) = match run.take() {
				Some((current, vector)) if current == tone => (current, vector),
				previous => {
					vectors.extend(previous.map(|(_, vector)| vector));
					let vector = Vector(view_box)
						.scaling(VectorScaling::Fit)
						.class(COVER)
						.class(tone_class("text", tone))
						.aria_hidden(true);
					(tone, vector)
				}
			};
			run = Some((tone, vector.path(vector_path(path))));
		}
		vectors.extend(run.map(|(_, vector)| vector));
		vectors
	}
}

/// `path` as a vector path painted with the element's text colour.
fn vector_path(path: &ChartPath) -> VectorPath {
	let data = PathData::parse(&path.data).expect("the rough engine writes valid path data");
	let vector = VectorPath::new(data);
	match path.paint {
		PaintKind::Fill(_) => vector.fill(Paint::CurrentColor),
		PaintKind::Stroke(_, width) => vector.stroke(
			Stroke::new(Paint::CurrentColor, width)
				.expect("chart stroke widths are positive")
				.round(),
		),
	}
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
	pub(crate) fn finish(self) -> ChartDrawing {
		let mut paths = self.paths;
		paths.sort_by_key(|path| path.layer);
		ChartDrawing {
			width: self.width,
			height: self.height,
			paths,
		}
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
	use leptoskit::native::NativeKind;

	use super::*;
	use crate::ChartTheme;

	#[test]
	fn a_drawing_is_one_vector_per_tone() {
		let mut ink = ChartInk::new(100.0, 50.0);
		ink.background(ChartTheme::SKRIBBLE.background);
		ink.exact_line(
			(0.0, 0.0),
			(100.0, 50.0),
			ChartTheme::SKRIBBLE.grid,
			1.0,
			LAYER_GRID,
		);
		let vectors = ink.finish().vectors();
		assert_eq!(vectors.len(), 2);
		for vector in &vectors {
			assert_eq!(vector.kind, NativeKind::Vector);
		}
	}

	#[test]
	fn paths_paint_with_the_text_colour() {
		let mut ink = ChartInk::new(100.0, 50.0);
		ink.background(ChartTheme::SKRIBBLE.background);
		let vectors = ink.finish().vectors();
		let drawing = vectors[0].props.drawing.as_ref().expect("a drawing");
		assert!(drawing.uses_current_color());
		let path = &drawing.paths()[0];
		assert!(path.fill_paint().is_some());
		assert_eq!(drawing.vector_scaling(), VectorScaling::Fit);
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
		assert_eq!(drawing.paths[0].layer, LAYER_BACKGROUND);
		assert_eq!(drawing.paths[1].layer, LAYER_GRID);
	}
}
