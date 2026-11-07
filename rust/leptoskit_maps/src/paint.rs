//! Rough paths painted as leptoskit vectors.

use leptoskit::native::Color;
use leptoskit::native::Element;
use leptoskit::native::Paint;
use leptoskit::native::PathData;
use leptoskit::native::Stroke;
use leptoskit::native::VectorPath;
use leptoskit::native::VectorScaling;
use leptoskit::native::ViewBox;
use leptoskit::prelude::Vector;
use leptoskit::prelude::View;
use skribble_leptoskit::Tone;

/// Covers the parent, so the drawing stretches with it.
const COVER: &str = "absolute top-0 left-0 w-full h-full";

/// How one path is painted.
#[derive(Debug, Clone, Copy, PartialEq)]
pub(crate) enum MapPaint {
	/// Filled with a tone.
	Fill(Tone),
	/// Stroked with a tone, `width` logical pixels wide.
	Stroke { tone: Tone, width: f32 },
}

impl MapPaint {
	/// The tone this paint uses.
	pub(crate) const fn tone(self) -> Tone {
		match self {
			Self::Fill(tone) | Self::Stroke { tone, .. } => tone,
		}
	}
}

/// One rough path, as SVG path data, and its paint.
#[derive(Debug, Clone, PartialEq)]
pub(crate) struct MapPath {
	pub(crate) data: String,
	pub(crate) paint: MapPaint,
}

/// Rough paths in their own coordinate space, ready to become vector
/// elements.
#[derive(Debug, Clone, PartialEq)]
pub(crate) struct MapDrawing {
	/// The coordinate space the paths are drawn in.
	pub(crate) width: f64,
	pub(crate) height: f64,
	pub(crate) paths: Vec<MapPath>,
}

impl MapDrawing {
	/// An empty drawing on a `width` by `height` canvas.
	pub(crate) fn new(width: f64, height: f64) -> Self {
		Self {
			width,
			height,
			paths: Vec::new(),
		}
	}

	/// Adds `data` as a path filled with `tone`.
	pub(crate) fn push_fill(&mut self, data: String, tone: Tone) {
		if !data.is_empty() {
			self.paths.push(MapPath {
				data,
				paint: MapPaint::Fill(tone),
			});
		}
	}

	/// Adds `data` as a path stroked with `tone`.
	pub(crate) fn push_stroke(&mut self, data: String, tone: Tone, width: f32) {
		if !data.is_empty() {
			self.paths.push(MapPath {
				data,
				paint: MapPaint::Stroke { tone, width },
			});
		}
	}

	/// Whether this drawing has anything to paint.
	pub(crate) fn is_empty(&self) -> bool {
		self.paths.is_empty()
	}

	/// The vector elements that draw these paths, covering their parent.
	///
	/// Each run of paths in one tone becomes one `Vector` painting with
	/// `currentColor`, so a `dark:` text colour recolours it on every
	/// platform. The runs stack in order, so fills stay under outlines.
	pub(crate) fn vectors(&self) -> Vec<Element> {
		let view_box = ViewBox::new(0.0, 0.0, self.width as f32, self.height as f32)
			.expect("a map is drawn on a positive, finite canvas");

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
fn vector_path(path: &MapPath) -> VectorPath {
	let data = PathData::parse(&path.data).expect("the rough engine writes valid path data");
	let vector = VectorPath::new(data);
	match path.paint {
		MapPaint::Fill(_) => vector.fill(Paint::CurrentColor),
		MapPaint::Stroke { width, .. } => vector.stroke(
			Stroke::new(Paint::CurrentColor, width)
				.expect("map stroke widths are positive")
				.round(),
		),
	}
}

/// `color` as a CSS hex colour, with alpha only when it is not opaque.
pub(crate) fn css_hex(color: Color) -> String {
	let rgb = format!(
		"#{:02x}{:02x}{:02x}",
		color.red(),
		color.green(),
		color.blue()
	);
	match color.alpha() {
		0xff => rgb,
		alpha => format!("{rgb}{alpha:02x}"),
	}
}

/// A Tailwind utility for `tone`, such as `text-[#1f1d1a]
/// dark:text-[#f2efe6]`.
pub(crate) fn tone_class(utility: &str, tone: Tone) -> String {
	let light = format!("{utility}-[{}]", css_hex(tone.light));
	if tone.light == tone.dark {
		light
	} else {
		format!("{light} dark:{utility}-[{}]", css_hex(tone.dark))
	}
}

#[cfg(test)]
mod tests {
	use leptoskit::native::NativeKind;
	use skribble_leptoskit::Palette;
	use skribble_leptoskit::Theme;

	use super::*;

	fn drawing() -> MapDrawing {
		let mut drawing = MapDrawing::new(100.0, 50.0);
		drawing.push_fill("M0 0 L10 0 L10 10 Z".to_owned(), Theme::SKRIBBLE.accent());
		drawing.push_stroke(
			"M0 0 L10 10".to_owned(),
			Theme::SKRIBBLE.ink(),
			Theme::SKRIBBLE.stroke_width,
		);
		drawing
	}

	#[test]
	fn paths_in_one_tone_share_a_vector_and_stack_by_tone() {
		let vectors = drawing().vectors();
		assert_eq!(vectors.len(), 2);
		assert_eq!(vectors[0].kind, NativeKind::Vector);
		let fill = vectors[0].props.drawing.as_ref().expect("a fill");
		assert!(fill.paths()[0].fill_paint().is_some());
		assert!(fill.uses_current_color());
		let outline = vectors[1].props.drawing.as_ref().expect("an outline");
		assert!(outline.paths()[0].stroke_style().is_some());
	}

	#[test]
	fn a_drawing_fits_its_view_box_and_covers_its_parent() {
		let layer = drawing().layer();
		let drawing = layer.children[0].props.drawing.as_ref().expect("a vector");
		assert_eq!(drawing.vector_scaling(), VectorScaling::Fit);
		assert_eq!(
			drawing.view_box(),
			ViewBox::new(0.0, 0.0, 100.0, 50.0).expect("valid")
		);
		assert!(layer.children[0].classes().classes().contains("absolute"));
	}

	#[test]
	fn dark_mode_recolours_a_drawing_through_its_text_colour() {
		let classes = tone_class("text", Theme::SKRIBBLE.ink());
		assert!(classes.contains("dark:text-"));
		let vectors = drawing().vectors();
		let ink = &vectors[1];
		for class in classes.split(' ') {
			assert!(
				ink.classes().classes().split(' ').any(|own| own == class),
				"{class}"
			);
		}
	}

	#[test]
	fn a_fixed_tone_needs_no_dark_class() {
		assert_eq!(
			tone_class("text", Tone::fixed(Palette::LIGHT.ink)),
			"text-[#1f1d1a]"
		);
	}

	#[test]
	fn translucent_colours_keep_their_alpha() {
		assert_eq!(css_hex(Palette::LIGHT.accent), "#ffd43b");
		assert_eq!(css_hex(Color::rgba(1, 2, 3, 0x80)), "#01020380");
	}

	#[test]
	fn empty_paths_are_dropped() {
		let mut drawing = MapDrawing::new(10.0, 10.0);
		drawing.push_fill(String::new(), Theme::SKRIBBLE.ink());
		drawing.push_stroke(String::new(), Theme::SKRIBBLE.ink(), 2.0);
		assert!(drawing.is_empty());
	}
}
