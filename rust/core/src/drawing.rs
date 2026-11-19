//! Finished ink: path data and paint, ready for any renderer.
//!
//! Every recipe in this crate ends in an [`InkDrawing`]: SVG path data in the
//! drawing's own coordinate space, each path filled or stroked with a
//! [`Tone`]. A UI framework turns it into its own vector elements; anything
//! else can call [`InkDrawing::to_svg`].

use std::fmt::Write as _;

use skribble_rough::escape_attribute;
use skribble_rough::format_number;

use crate::Tone;
use crate::colorway::Appearance;

/// How one path is painted.
#[derive(Debug, Clone, Copy, PartialEq)]
pub enum InkPaint {
	/// Filled with a tone.
	Fill(Tone),
	/// Stroked with a tone, `width` logical pixels wide, with round caps and
	/// joins.
	Stroke {
		/// The stroke colour.
		tone: Tone,
		/// The stroke width, in logical pixels.
		width: f32,
	},
}

impl InkPaint {
	/// The tone this paint uses.
	pub const fn tone(self) -> Tone {
		match self {
			Self::Fill(tone) | Self::Stroke { tone, .. } => tone,
		}
	}
}

/// One path, as SVG path data, and its paint.
#[derive(Debug, Clone, PartialEq)]
pub struct InkPath {
	/// SVG path data in the drawing's coordinate space.
	pub data: String,
	/// How the path is painted.
	pub paint: InkPaint,
}

/// How a drawing fills a box of another size.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Default)]
pub enum InkScaling {
	/// Scale evenly and keep the drawing's proportions. Doodles, charts, maps,
	/// and pins drawn at their final size use this.
	#[default]
	Fit,
	/// Stretch to the box on both axes while strokes keep their width. The
	/// borders of boxes, buttons, and fields use this, so one drawing fits a
	/// component at any size.
	Stretch,
}

/// A finished drawing: paths in paint order, in a `width` by `height`
/// coordinate space.
///
/// ```
/// use skribble_core::InkDrawing;
/// use skribble_core::InkScaling;
/// use skribble_core::Theme;
/// use skribble_core::colorway::Appearance;
///
/// let mut drawing = InkDrawing::new(20.0, 10.0, InkScaling::Fit);
/// drawing.push_stroke("M 1 1 L 19 9".to_owned(), Theme::SKRIBBLE.ink(), 1.6);
/// let svg = drawing.to_svg(Appearance::Light);
/// assert!(svg.starts_with("<svg"));
/// assert!(svg.contains(r##"stroke="#34283f""##));
/// ```
#[derive(Debug, Clone, PartialEq)]
pub struct InkDrawing {
	/// The width of the coordinate space the paths are drawn in.
	pub width: f64,
	/// The height of the coordinate space the paths are drawn in.
	pub height: f64,
	/// How the drawing fills a box of another size.
	pub scaling: InkScaling,
	/// The paths, bottom first.
	pub paths: Vec<InkPath>,
}

/// A run of neighbouring paths that share one tone.
///
/// Renderers that recolour ink through the element's text colour, so a dark
/// mode class switches it, draw each run as one vector element.
#[derive(Debug, Clone, Copy, PartialEq)]
pub struct InkRun<'a> {
	/// The tone every path in the run uses.
	pub tone: Tone,
	/// The paths, bottom first.
	pub paths: &'a [InkPath],
}

impl InkDrawing {
	/// An empty drawing on a `width` by `height` canvas.
	pub const fn new(width: f64, height: f64, scaling: InkScaling) -> Self {
		Self {
			width,
			height,
			scaling,
			paths: Vec::new(),
		}
	}

	/// Adds `data` as a path filled with `tone`. Empty data adds nothing.
	pub fn push_fill(&mut self, data: String, tone: Tone) {
		if !data.is_empty() {
			self.paths.push(InkPath {
				data,
				paint: InkPaint::Fill(tone),
			});
		}
	}

	/// Adds `data` as a path stroked `width` wide with `tone`. Empty data adds
	/// nothing.
	pub fn push_stroke(&mut self, data: String, tone: Tone, width: f32) {
		if !data.is_empty() {
			self.paths.push(InkPath {
				data,
				paint: InkPaint::Stroke { tone, width },
			});
		}
	}

	/// Whether this drawing has anything to paint.
	pub fn is_empty(&self) -> bool {
		self.paths.is_empty()
	}

	/// The paths grouped into runs of one tone, bottom first.
	pub fn runs(&self) -> impl Iterator<Item = InkRun<'_>> {
		self.paths
			.chunk_by(|a, b| a.paint.tone() == b.paint.tone())
			.map(|paths| InkRun {
				tone: paths[0].paint.tone(),
				paths,
			})
	}

	/// The drawing as a standalone SVG document in `appearance`'s colours,
	/// `width` by `height` pixels.
	///
	/// A [`InkScaling::Stretch`] drawing keeps its stroke widths through
	/// `vector-effect`, so it can be stretched with CSS.
	pub fn to_svg(&self, appearance: Appearance) -> String {
		let width = format_number(self.width, 2);
		let height = format_number(self.height, 2);
		let aspect = match self.scaling {
			InkScaling::Fit => "",
			InkScaling::Stretch => r#" preserveAspectRatio="none""#,
		};
		let mut svg = format!(
			r#"<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {width} {height}" width="{width}" height="{height}"{aspect} aria-hidden="true">"#
		);
		for path in &self.paths {
			let data = escape_attribute(&path.data);
			match path.paint {
				InkPaint::Fill(tone) => {
					let _ = write!(
						svg,
						r#"<path d="{data}" fill="{}"/>"#,
						tone.get(appearance).css_hex()
					);
				}
				InkPaint::Stroke { tone, width } => {
					let effect = match self.scaling {
						InkScaling::Fit => "",
						InkScaling::Stretch => r#" vector-effect="non-scaling-stroke""#,
					};
					let _ = write!(
						svg,
						r#"<path d="{data}" fill="none" stroke="{}" stroke-width="{}" stroke-linecap="round" stroke-linejoin="round"{effect}/>"#,
						tone.get(appearance).css_hex(),
						format_number(f64::from(width), 2),
					);
				}
			}
		}
		svg.push_str("</svg>");
		svg
	}
}

#[cfg(test)]
mod tests {
	use super::*;
	use crate::Theme;

	fn drawing() -> InkDrawing {
		let theme = Theme::SKRIBBLE;
		let mut drawing = InkDrawing::new(100.0, 50.0, InkScaling::Fit);
		drawing.push_fill("M0 0 L10 0 L10 10 Z".to_owned(), theme.marker());
		drawing.push_stroke("M0 0 L5 5".to_owned(), theme.marker(), 1.2);
		drawing.push_stroke("M0 0 L10 10".to_owned(), theme.ink(), theme.stroke_width);
		drawing
	}

	#[test]
	fn paths_in_one_tone_form_one_run_in_paint_order() {
		let drawing = drawing();
		let runs: Vec<_> = drawing.runs().collect();
		assert_eq!(runs.len(), 2);
		assert_eq!(runs[0].tone, Theme::SKRIBBLE.marker());
		assert_eq!(runs[0].paths.len(), 2);
		assert_eq!(runs[1].tone, Theme::SKRIBBLE.ink());
	}

	#[test]
	fn empty_paths_are_dropped() {
		let mut drawing = InkDrawing::new(10.0, 10.0, InkScaling::Fit);
		drawing.push_fill(String::new(), Theme::SKRIBBLE.ink());
		drawing.push_stroke(String::new(), Theme::SKRIBBLE.ink(), 2.0);
		assert!(drawing.is_empty());
		assert_eq!(drawing.runs().count(), 0);
	}

	#[test]
	fn svg_paints_each_appearance() {
		let drawing = drawing();
		let light = drawing.to_svg(Appearance::Light);
		let dark = drawing.to_svg(Appearance::Dark);
		assert!(light.contains(r#"viewBox="0 0 100 50""#));
		assert!(light.contains(r##"fill="#ffd43b""##));
		assert!(light.contains(r##"stroke="#34283f""##));
		assert!(dark.contains(r##"stroke="#fffaf0""##));
		assert!(!light.contains("preserveAspectRatio"));
	}

	#[test]
	fn stretched_svg_keeps_its_stroke_width() {
		let drawing = InkDrawing {
			scaling: InkScaling::Stretch,
			..drawing()
		};
		let svg = drawing.to_svg(Appearance::Light);
		assert!(svg.contains(r#"preserveAspectRatio="none""#));
		assert!(svg.contains(r#"vector-effect="non-scaling-stroke""#));
	}
}
