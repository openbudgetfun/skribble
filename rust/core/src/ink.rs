//! The hand-drawn layer behind components: rough borders, fills, rules, and
//! ticks that stretch to the component they sit in.
//!
//! An [`Ink`] describes one layer: a shape, the nominal [`Canvas`] it is drawn
//! on, its outline, and its fill. [`Ink::drawing`] draws it with the rough
//! engine as an [`InkDrawing`] that stretches to its parent, so a framework
//! adapter puts it first among a component's children and the content paints
//! on top.

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

use crate::InkDrawing;
use crate::InkScaling;
use crate::Theme;
use crate::Tone;

/// Sketched fill lines are a little lighter than outlines.
const SKETCH_WEIGHT: f32 = 0.75;

/// What an ink layer draws, in the space of its parent.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum InkShape {
	/// A rough rectangle around the parent.
	Rectangle,
	/// A rough capsule: a rectangle whose short sides are half circles.
	Capsule,
	/// A rough ellipse touching the middle of each side.
	Ellipse,
	/// A rough horizontal line across the middle.
	Rule,
	/// A rough horizontal line along the bottom.
	Underline,
	/// A rough tick.
	Check,
}

/// The nominal space ink is drawn in before it stretches to its parent.
///
/// Components rarely know their final size when they are built, so each draws
/// into a box near its usual proportions; the closer the box, the less the
/// wobble stretches.
#[derive(Debug, Clone, Copy, PartialEq)]
pub struct Canvas {
	/// Nominal width.
	pub width: f64,
	/// Nominal height.
	pub height: f64,
	/// Distance from the edge to the ideal outline, which leaves room for the
	/// wobble.
	pub inset: f64,
	/// Distance between sketched fill lines.
	pub gap: f64,
}

impl Canvas {
	/// A canvas with skribble's default inset and hachure gap.
	pub const fn new(width: f64, height: f64) -> Self {
		Self {
			width,
			height,
			inset: 3.0,
			gap: 8.0,
		}
	}

	/// This canvas with the outline `inset` from its edges.
	#[must_use]
	pub const fn inset(self, inset: f64) -> Self {
		Self { inset, ..self }
	}

	/// This canvas with fill lines `gap` apart.
	#[must_use]
	pub const fn gap(self, gap: f64) -> Self {
		Self { gap, ..self }
	}
}

/// A fill pattern and the tone it is drawn in.
#[derive(Debug, Clone, Copy, PartialEq)]
pub struct InkFill {
	/// The pattern.
	pub style: FillStyle,
	/// The colour.
	pub tone: Tone,
}

/// One hand-drawn layer: a shape, its outline, and its fill.
///
/// ```
/// use skribble_core::Canvas;
/// use skribble_core::FillStyle;
/// use skribble_core::Ink;
/// use skribble_core::InkShape;
/// use skribble_core::InkScaling;
/// use skribble_core::Theme;
///
/// let theme = Theme::SKRIBBLE;
/// let ink = Ink::outline(InkShape::Rectangle, Canvas::new(160.0, 48.0), 3, theme)
/// 	.filled(FillStyle::Solid, theme.accent());
/// let drawing = ink.drawing();
/// assert_eq!(drawing.scaling, InkScaling::Stretch);
/// assert_eq!(drawing.paths.len(), 2);
/// ```
#[derive(Debug, Clone, Copy, PartialEq)]
pub struct Ink {
	/// What to draw.
	pub shape: InkShape,
	/// The nominal space to draw it in.
	pub canvas: Canvas,
	/// Chooses the wobble. The same seed always draws the same ink.
	pub seed: i64,
	/// The outline tone, or `None` for a fill without an outline.
	pub outline: Option<Tone>,
	/// The fill, or `None` for an outline alone.
	pub fill: Option<InkFill>,
	/// The line weight and wobble.
	pub theme: Theme,
}

impl Ink {
	/// An outline in the theme's ink, without a fill.
	pub const fn outline(shape: InkShape, canvas: Canvas, seed: i64, theme: Theme) -> Self {
		Self {
			shape,
			canvas,
			seed,
			outline: Some(theme.ink()),
			fill: None,
			theme,
		}
	}

	/// This ink filled with `style` in `tone`; [`FillStyle::None`] removes the
	/// fill.
	#[must_use]
	pub fn filled(self, style: FillStyle, tone: Tone) -> Self {
		let fill = (style != FillStyle::None).then_some(InkFill { style, tone });
		Self { fill, ..self }
	}

	/// This ink with its outline in `tone`.
	#[must_use]
	pub const fn outlined(self, tone: Tone) -> Self {
		Self {
			outline: Some(tone),
			..self
		}
	}

	/// This ink without its outline.
	#[must_use]
	pub const fn without_outline(self) -> Self {
		Self {
			outline: None,
			..self
		}
	}

	/// Whether this ink has a solid fill, so content over it needs the tone
	/// that reads on the fill rather than the ink.
	pub fn is_solid(&self) -> bool {
		self.fill.is_some_and(|fill| fill.style == FillStyle::Solid)
	}

	/// The tone for text and icons drawn over this ink: the one that reads on
	/// a solid fill, and the theme's ink otherwise.
	pub fn content_tone(&self) -> Tone {
		match self.fill {
			Some(fill) if fill.style == FillStyle::Solid => self.theme.on(fill.tone),
			_ => self.theme.ink(),
		}
	}

	/// The drawing this ink makes: fills under the outline, stretched to its
	/// parent.
	pub fn drawing(&self) -> InkDrawing {
		let paths = RoughSvgPaths::from_drawable(&self.drawable());
		let stroke_width = self.theme.stroke_width;
		let mut drawing =
			InkDrawing::new(self.canvas.width, self.canvas.height, InkScaling::Stretch);
		if let Some(fill) = self.fill {
			drawing.push_fill(paths.solid, fill.tone);
			drawing.push_stroke(paths.sketch, fill.tone, stroke_width * SKETCH_WEIGHT);
		}
		if let Some(tone) = self.outline {
			drawing.push_stroke(paths.outline, tone, stroke_width);
		}
		drawing
	}

	/// Draws this ink with the rough engine.
	fn drawable(&self) -> Drawable {
		let canvas = self.canvas;
		let options = DrawOptions {
			seed: self.seed,
			roughness: self.theme.roughness,
			// The drawing stretches, so it keeps plain centrelines; the pen only
			// shapes ink drawn at its final size.
			pen: RoughPen::UNIFORM,
			..DrawOptions::default()
		};
		let pattern = FillOptions {
			hachure_gap: canvas.gap,
			..FillOptions::default()
		};
		let style = self.fill.map_or(FillStyle::None, |fill| fill.style);
		let mut generator = Generator::new(
			DrawConfig::new(options),
			Filler::new(style, pattern, DrawConfig::new(options)),
		);

		let (width, height, inset) = (canvas.width, canvas.height, canvas.inset);
		let inner_width = width - inset * 2.0;
		let inner_height = height - inset * 2.0;
		match self.shape {
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
}

#[cfg(test)]
mod tests {
	use super::*;
	use crate::InkPaint;

	fn ink(shape: InkShape) -> Ink {
		Ink::outline(shape, Canvas::new(120.0, 40.0), 3, Theme::SKRIBBLE)
	}

	#[test]
	fn an_outline_is_one_stretched_stroke_in_the_ink() {
		let drawing = ink(InkShape::Rectangle).drawing();
		assert_eq!(drawing.scaling, InkScaling::Stretch);
		assert_eq!((drawing.width, drawing.height), (120.0, 40.0));
		assert_eq!(drawing.paths.len(), 1);
		assert_eq!(
			drawing.paths[0].paint,
			InkPaint::Stroke {
				tone: Theme::SKRIBBLE.ink(),
				width: Theme::SKRIBBLE.stroke_width,
			}
		);
	}

	#[test]
	fn fills_paint_under_the_outline() {
		let theme = Theme::SKRIBBLE;
		let drawing = ink(InkShape::Rectangle)
			.filled(FillStyle::Solid, theme.accent())
			.drawing();
		assert_eq!(drawing.paths.len(), 2);
		assert_eq!(drawing.paths[0].paint, InkPaint::Fill(theme.accent()));
		assert_eq!(drawing.paths[1].paint.tone(), theme.ink());
	}

	#[test]
	fn hachure_strokes_are_lighter_than_the_outline() {
		let theme = Theme::SKRIBBLE;
		let drawing = ink(InkShape::Rectangle)
			.filled(FillStyle::Hachure, theme.marker())
			.drawing();
		let InkPaint::Stroke { width, .. } = drawing.paths[0].paint else {
			panic!("hachure is stroked");
		};
		assert!(width < theme.stroke_width);
	}

	#[test]
	fn paths_in_one_tone_share_a_run() {
		let theme = Theme::SKRIBBLE;
		let same = ink(InkShape::Rectangle)
			.filled(FillStyle::Hachure, theme.accent())
			.outlined(theme.accent());
		assert_eq!(same.drawing().runs().count(), 1);
	}

	#[test]
	fn the_same_seed_draws_the_same_ink() {
		assert_eq!(
			ink(InkShape::Capsule).drawing(),
			ink(InkShape::Capsule).drawing()
		);
		let other = Ink {
			seed: 4,
			..ink(InkShape::Capsule)
		};
		assert_ne!(ink(InkShape::Capsule).drawing(), other.drawing());
	}

	#[test]
	fn every_shape_draws_something() {
		for shape in [
			InkShape::Rectangle,
			InkShape::Capsule,
			InkShape::Ellipse,
			InkShape::Rule,
			InkShape::Underline,
			InkShape::Check,
		] {
			assert!(!ink(shape).drawing().is_empty(), "{shape:?}");
		}
	}

	#[test]
	fn content_reads_on_solid_fills() {
		let theme = Theme::SKRIBBLE;
		let outline = ink(InkShape::Rectangle);
		assert_eq!(outline.content_tone(), theme.ink());
		let solid = outline.filled(FillStyle::Solid, theme.accent());
		assert!(solid.is_solid());
		assert_eq!(solid.content_tone(), theme.on_accent());
		let hachure = outline.filled(FillStyle::Hachure, theme.accent());
		assert_eq!(hachure.content_tone(), theme.ink());
	}

	#[test]
	fn no_fill_style_removes_the_fill() {
		let theme = Theme::SKRIBBLE;
		let ink = ink(InkShape::Ellipse).filled(FillStyle::None, theme.accent());
		assert!(ink.fill.is_none());
		let bare = ink.without_outline();
		assert!(bare.drawing().is_empty());
	}
}
