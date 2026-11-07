//! Ink as leptoskit vector drawings, which every backend draws natively.

use leptoskit::native::Element;
use leptoskit::native::Paint;
use leptoskit::native::PathData;
use leptoskit::native::Stroke;
use leptoskit::native::VectorPath;
use leptoskit::native::VectorScaling;
use leptoskit::native::ViewBox;
use leptoskit::prelude::Vector;
use leptoskit::prelude::View;
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

use super::Ink;
use super::InkShape;
use crate::Tone;
use crate::theme::tone_class;

/// Sketched fill lines are a little lighter than outlines.
const SKETCH_WEIGHT: f32 = 0.75;

/// Covers the parent, so the drawing stretches with it.
const COVER: &str = "absolute top-0 left-0 w-full h-full";

/// How one path is painted.
#[derive(Debug, Clone, Copy, PartialEq)]
pub(crate) enum InkPaint {
	/// Filled with a tone.
	Fill(Tone),
	/// Stroked with a tone, `width` logical pixels wide.
	Stroke { tone: Tone, width: f32 },
}

impl InkPaint {
	/// The tone this paint uses.
	pub(crate) const fn tone(self) -> Tone {
		match self {
			Self::Fill(tone) | Self::Stroke { tone, .. } => tone,
		}
	}
}

/// One path, as SVG path data, and its paint.
#[derive(Debug, Clone, PartialEq)]
pub(crate) struct InkPath {
	pub(crate) data: String,
	pub(crate) paint: InkPaint,
}

/// Rough paths in their own coordinate space, ready to become vector
/// elements.
#[derive(Debug, Clone, PartialEq)]
pub(crate) struct InkDrawing {
	/// The coordinate space the paths are drawn in.
	pub(crate) width: f64,
	pub(crate) height: f64,
	/// Stretch to the parent on both axes, keeping strokes at their width.
	/// Otherwise the drawing keeps its proportions.
	pub(crate) stretch: bool,
	pub(crate) paths: Vec<InkPath>,
}

impl InkDrawing {
	/// The vector elements that draw these paths, covering their parent.
	///
	/// Each run of paths in one tone becomes one `Vector` painting with
	/// `currentColor`, so a `dark:` text colour recolours it on every
	/// platform. The runs stack in order, so fills stay under outlines.
	pub(crate) fn vectors(&self) -> Vec<Element> {
		let view_box = ViewBox::new(0.0, 0.0, self.width as f32, self.height as f32)
			.expect("ink is drawn on a positive, finite canvas");
		let scaling = if self.stretch {
			VectorScaling::Stretch
		} else {
			VectorScaling::Fit
		};

		let mut vectors = Vec::new();
		let mut run: Option<(Tone, Element)> = None;
		for path in &self.paths {
			let tone = path.paint.tone();
			let (_, vector) = match run.take() {
				Some((current, vector)) if current == tone => (current, vector),
				previous => {
					vectors.extend(previous.map(|(_, vector)| vector));
					let vector = Vector(view_box)
						.scaling(scaling)
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

	/// One decorative element that draws these paths over its whole parent.
	pub(crate) fn layer(&self) -> Element {
		let mut vectors = self.vectors();
		if vectors.len() == 1 {
			return vectors.remove(0);
		}
		View().class(COVER).aria_hidden(true).children(vectors)
	}
}

/// `path` as a vector path painted with the element's text colour.
fn vector_path(path: &InkPath) -> VectorPath {
	let data = PathData::parse(&path.data).expect("the rough engine writes valid path data");
	let vector = VectorPath::new(data);
	match path.paint {
		InkPaint::Fill(_) => vector.fill(Paint::CurrentColor),
		InkPaint::Stroke { width, .. } => vector.stroke(
			Stroke::new(Paint::CurrentColor, width)
				.expect("theme stroke widths are positive")
				.round(),
		),
	}
}

/// Draws `ink` with the rough engine.
fn drawable(ink: &Ink) -> Drawable {
	let canvas = ink.canvas;
	let options = DrawOptions {
		seed: ink.seed,
		roughness: ink.theme.roughness,
		// The drawing stretches, so it keeps plain centrelines; the pen only
		// shapes ink drawn at its final size.
		pen: RoughPen::UNIFORM,
		..DrawOptions::default()
	};
	let pattern = FillOptions {
		hachure_gap: canvas.gap,
		..FillOptions::default()
	};
	let style = ink.fill.map_or(FillStyle::None, |fill| fill.style);
	let mut generator = Generator::new(
		DrawConfig::new(options),
		Filler::new(style, pattern, DrawConfig::new(options)),
	);

	let (width, height, inset) = (canvas.width, canvas.height, canvas.inset);
	let inner_width = width - inset * 2.0;
	let inner_height = height - inset * 2.0;
	match ink.shape {
		InkShape::Rectangle => generator.rectangle(inset, inset, inner_width, inner_height),
		InkShape::Capsule => {
			let radius = inner_width.min(inner_height) / 2.0;
			generator.rounded_rectangle(inset, inset, inner_width, inner_height, [radius; 4])
		}
		InkShape::Ellipse => {
			generator.ellipse(width / 2.0, height / 2.0, inner_width, inner_height)
		}
		InkShape::Rule => {
			let middle = height / 2.0;
			generator.line(inset, middle + 0.5, width - inset, middle - 0.5)
		}
		InkShape::Underline => {
			let bottom = height - inset;
			generator.line(inset, bottom, width - inset, bottom - 1.0)
		}
		InkShape::Check => generator.linear_path(
			&[
				Point::new(width * 0.2, height * 0.52),
				Point::new(width * 0.42, height * 0.76),
				Point::new(width * 0.8, height * 0.24),
			],
			false,
		),
	}
}

/// The drawing `ink` makes, stretched to its parent.
pub(crate) fn drawing(ink: &Ink) -> InkDrawing {
	let paths = RoughSvgPaths::from_drawable(&drawable(ink));
	let stroke_width = ink.theme.stroke_width;
	let mut layers = Vec::new();
	if let Some(fill) = ink.fill {
		if !paths.solid.is_empty() {
			layers.push(InkPath {
				data: paths.solid,
				paint: InkPaint::Fill(fill.tone),
			});
		}
		if !paths.sketch.is_empty() {
			layers.push(InkPath {
				data: paths.sketch,
				paint: InkPaint::Stroke {
					tone: fill.tone,
					width: stroke_width * SKETCH_WEIGHT,
				},
			});
		}
	}
	if let Some(tone) = ink.outline
		&& !paths.outline.is_empty()
	{
		layers.push(InkPath {
			data: paths.outline,
			paint: InkPaint::Stroke {
				tone,
				width: stroke_width,
			},
		});
	}

	InkDrawing {
		width: ink.canvas.width,
		height: ink.canvas.height,
		stretch: true,
		paths: layers,
	}
}

#[cfg(test)]
mod tests {
	use leptoskit::native::NativeKind;

	use super::*;
	use crate::Palette;
	use crate::Theme;
	use crate::ink::Canvas;

	fn ink(shape: InkShape) -> Ink {
		Ink::outline(shape, Canvas::new(120.0, 40.0), 3, Theme::SKRIBBLE)
	}

	#[test]
	fn outlines_are_one_stretched_vector_in_the_ink_colour() {
		let layer = drawing(&ink(InkShape::Rectangle)).layer();
		assert_eq!(layer.kind, NativeKind::Vector);
		let drawing = layer.props.drawing.as_ref().expect("a drawing");
		assert_eq!(drawing.vector_scaling(), VectorScaling::Stretch);
		assert_eq!(drawing.paths().len(), 1);
		let stroke = drawing.paths()[0].stroke_style().expect("an outline");
		assert_eq!(stroke.width(), Theme::SKRIBBLE.stroke_width);
		assert!(drawing.uses_current_color());
	}

	#[test]
	fn dark_mode_recolours_ink_through_the_text_colour() {
		let classes = tone_class("text", Theme::SKRIBBLE.ink());
		assert!(classes.contains("dark:text-"));
		let layer = drawing(&ink(InkShape::Ellipse)).layer();
		for class in classes.split(' ') {
			assert!(
				layer.classes().classes().split(' ').any(|own| own == class),
				"{class}"
			);
		}
	}

	#[test]
	fn fills_paint_under_the_outline() {
		let theme = Theme::SKRIBBLE;
		let filled = ink(InkShape::Rectangle).filled(FillStyle::Solid, theme.accent());
		let vectors = drawing(&filled).vectors();
		assert_eq!(vectors.len(), 2);
		let fill = vectors[0].props.drawing.as_ref().expect("a fill");
		assert!(fill.paths()[0].fill_paint().is_some());
		let outline = vectors[1].props.drawing.as_ref().expect("an outline");
		assert!(outline.paths()[0].stroke_style().is_some());
	}

	#[test]
	fn paths_in_one_tone_share_a_vector() {
		let theme = Theme::SKRIBBLE;
		let same = Ink {
			outline: Some(theme.accent()),
			..ink(InkShape::Rectangle).filled(FillStyle::Hachure, theme.accent())
		};
		assert_eq!(drawing(&same).vectors().len(), 1);
	}

	#[test]
	fn the_same_seed_draws_the_same_ink() {
		assert_eq!(
			drawing(&ink(InkShape::Capsule)),
			drawing(&ink(InkShape::Capsule))
		);
		let other = Ink {
			seed: 4,
			..ink(InkShape::Capsule)
		};
		assert_ne!(drawing(&ink(InkShape::Capsule)), drawing(&other));
	}

	#[test]
	fn fixed_tones_need_no_dark_class() {
		let fixed = Ink {
			outline: Some(Tone::fixed(Palette::LIGHT.ink)),
			..ink(InkShape::Rule)
		};
		let layer = drawing(&fixed).layer();
		assert!(!layer.classes().classes().contains("dark:"));
	}
}
