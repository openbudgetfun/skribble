//! Standalone scribbles at an explicit size.

use std::fmt;

use skribble_rough::DrawOptions;
use skribble_rough::FillStyle;
use skribble_rough::RoughPen;
use skribble_rough::Shape;
use skribble_rough::SketchError;
use skribble_rough::SketchOptions;
use skribble_rough::SketchPart;
use skribble_rough::sketch;

use crate::InkDrawing;
use crate::InkScaling;
use crate::Theme;
use crate::Tone;

/// How far a sketch's ink may stray from the pen's samples, in logical pixels.
const INK_TOLERANCE: f64 = 0.25;

/// A hand-drawn scribble at an explicit size: arrows, scribbles, and annotations the component
/// recipes do not cover.
///
/// The shapes are drawn in the sketch's own coordinates, `width` by `height`
/// logical pixels, with the pen's tapered ink.
///
/// ```
/// use skribble_core::Scribble;
/// use skribble_core::Shape;
///
/// let arrow = Scribble::new(
/// 	120.0,
/// 	60.0,
/// 	vec![Shape::curve([(4.0, 50.0), (40.0, 10.0), (80.0, 40.0), (116.0, 12.0)]).with_arrowhead()],
/// );
/// let drawing = arrow.drawing().expect("a valid scribble");
/// assert!(!drawing.is_empty());
/// ```
#[derive(Debug, Clone, PartialEq)]
pub struct Scribble {
	/// Width, in logical pixels and in the shapes' coordinates.
	pub width: f32,
	/// Height, in logical pixels and in the shapes' coordinates.
	pub height: f32,
	/// What to draw, in order, from one random stream.
	pub shapes: Vec<Shape>,
	/// Chooses the wobble. The same seed always draws the same scribble.
	pub seed: i64,
	/// How ink leaves the pen.
	pub pen: RoughPen,
	/// The fill pattern for closed shapes.
	pub fill_style: FillStyle,
	/// The fill colour.
	pub fill: Tone,
	/// The ink colour.
	pub stroke: Tone,
	/// The line weight and wobble.
	pub theme: Theme,
}

/// Why a [`Scribble`] cannot be drawn.
#[derive(Debug, Clone, PartialEq)]
pub enum ScribbleError {
	/// The width or height is not a positive, finite number.
	Size {
		/// The width given.
		width: f32,
		/// The height given.
		height: f32,
	},
	/// A shape failed [`Shape::validate`].
	Shape(SketchError),
}

impl fmt::Display for ScribbleError {
	fn fmt(&self, formatter: &mut fmt::Formatter<'_>) -> fmt::Result {
		match self {
			Self::Size { width, height } => {
				write!(
					formatter,
					"a sketch needs a positive, finite size, found {width} by {height}"
				)
			}
			Self::Shape(error) => error.fmt(formatter),
		}
	}
}

impl std::error::Error for ScribbleError {}

impl From<SketchError> for ScribbleError {
	fn from(error: SketchError) -> Self {
		Self::Shape(error)
	}
}

impl Scribble {
	/// `shapes` on a `width` by `height` canvas, in the theme's ink with no
	/// fill.
	pub fn new(width: f32, height: f32, shapes: Vec<Shape>) -> Self {
		let theme = Theme::SKRIBBLE;
		Self {
			width,
			height,
			shapes,
			seed: 1,
			pen: RoughPen::INK,
			fill_style: FillStyle::None,
			fill: theme.marker(),
			stroke: theme.ink(),
			theme,
		}
	}

	/// Checks the size and every shape.
	///
	/// # Errors
	///
	/// [`ScribbleError::Size`] when the width or height is not a positive,
	/// finite number, and [`ScribbleError::Shape`] for the first shape that
	/// cannot be drawn.
	pub fn validate(&self) -> Result<(), ScribbleError> {
		let (width, height) = (self.width, self.height);
		if !(width.is_finite() && width > 0.0 && height.is_finite() && height > 0.0) {
			return Err(ScribbleError::Size { width, height });
		}
		for shape in &self.shapes {
			shape.validate()?;
		}
		Ok(())
	}

	/// The paths at the scribble's own size.
	///
	/// # Errors
	///
	/// The same errors as [`Self::validate`].
	pub fn drawing(&self) -> Result<InkDrawing, ScribbleError> {
		self.validate()?;
		let options = SketchOptions {
			draw: DrawOptions {
				seed: self.seed,
				roughness: self.theme.roughness,
				pen: self.pen,
				..DrawOptions::default()
			},
			fill_style: Some(self.fill_style),
			fill: Some(self.fill.light.css_hex()),
			stroke: self.stroke.light.css_hex(),
			stroke_width: f64::from(self.theme.stroke_width),
			sketch_width: f64::from(self.theme.stroke_width) * 0.75,
			// Ink ships to browsers and over the air: a quarter of a logical
			// pixel is invisible, and drops most of the pen's samples.
			tolerance: INK_TOLERANCE,
			..SketchOptions::default()
		};
		let drawn = sketch(&self.shapes, &options)?;

		let mut drawing = InkDrawing::new(
			f64::from(self.width),
			f64::from(self.height),
			InkScaling::Fit,
		);
		for path in drawn.paths {
			let tone = match path.part {
				SketchPart::Outline => self.stroke,
				SketchPart::Sketch | SketchPart::Solid => self.fill,
			};
			if path.stroke == "none" {
				drawing.push_fill(path.d, tone);
			} else {
				drawing.push_stroke(path.d, tone, path.stroke_width as f32);
			}
		}
		Ok(drawing)
	}
}

#[cfg(test)]
mod tests {
	use super::*;
	use crate::InkPaint;

	fn arrow() -> Scribble {
		Scribble::new(
			120.0,
			60.0,
			vec![Shape::curve([(4.0, 50.0), (60.0, 10.0), (116.0, 12.0)]).with_arrowhead()],
		)
	}

	#[test]
	fn a_scribble_fits_its_own_size_in_the_theme_ink() {
		let drawing = arrow().drawing().expect("valid");
		assert_eq!(drawing.scaling, InkScaling::Fit);
		assert_eq!((drawing.width, drawing.height), (120.0, 60.0));
		assert!(
			drawing
				.paths
				.iter()
				.all(|path| path.paint.tone() == Theme::SKRIBBLE.ink())
		);
	}

	#[test]
	fn filled_shapes_paint_in_the_fill_tone() {
		let scribble = Scribble {
			shapes: vec![Shape::rectangle(10.0, 10.0, 60.0, 30.0)],
			fill_style: FillStyle::Solid,
			..arrow()
		};
		let drawing = scribble.drawing().expect("valid");
		assert!(
			drawing
				.paths
				.iter()
				.any(|path| path.paint == InkPaint::Fill(Theme::SKRIBBLE.marker()))
		);
	}

	#[test]
	fn bad_sizes_and_shapes_are_errors() {
		let flat = Scribble {
			height: 0.0,
			..arrow()
		};
		assert!(matches!(flat.drawing(), Err(ScribbleError::Size { .. })));
		let broken = Scribble {
			shapes: vec![Shape::curve([(f64::NAN, 0.0), (1.0, 1.0)])],
			..arrow()
		};
		assert_eq!(
			broken.validate(),
			Err(ScribbleError::Shape(SketchError::NonFinite))
		);
		assert!(
			flat.validate()
				.unwrap_err()
				.to_string()
				.contains("positive")
		);
	}

	#[test]
	fn the_same_seed_draws_the_same_scribble() {
		assert_eq!(arrow().drawing(), arrow().drawing());
		let other = Scribble { seed: 2, ..arrow() };
		assert_ne!(arrow().drawing(), other.drawing());
	}
}
