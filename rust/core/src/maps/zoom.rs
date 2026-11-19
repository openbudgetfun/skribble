//! Hand-drawn zoom buttons for a controlled map camera.

use skribble_rough::DrawConfig;
use skribble_rough::DrawOptions;
use skribble_rough::FillOptions;
use skribble_rough::FillStyle;
use skribble_rough::Filler;
use skribble_rough::Generator;
use skribble_rough::RoughPen;
use skribble_rough::RoughSvgPaths;

use crate::InkDrawing;
use crate::InkScaling;
use crate::Theme;
use crate::maps::MAX_ZOOM;
use crate::maps::MIN_ZOOM;

/// The width and height of each zoom button, in logical pixels.
pub const ZOOM_BUTTON_SIZE: f32 = 44.0;

/// The zooms a pair of zoom buttons propose from `zoom`: one `step` closer
/// and one `step` further, each clamped to [`MIN_ZOOM`] through [`MAX_ZOOM`].
///
/// Returns `None` when `zoom` or `step` is not finite, or `step` is not
/// positive.
///
/// ```
/// use skribble_core::maps::MAX_ZOOM;
/// use skribble_core::maps::zoom_steps;
///
/// assert_eq!(zoom_steps(12.0, 1.0), Some((13.0, 11.0)));
/// assert_eq!(zoom_steps(MAX_ZOOM, 2.0), Some((MAX_ZOOM, MAX_ZOOM - 2.0)));
/// assert_eq!(zoom_steps(12.0, 0.0), None);
/// ```
pub fn zoom_steps(zoom: f64, step: f64) -> Option<(f64, f64)> {
	(zoom.is_finite() && step.is_finite() && step > 0.0).then(|| {
		(
			(zoom + step).clamp(MIN_ZOOM, MAX_ZOOM),
			(zoom - step).clamp(MIN_ZOOM, MAX_ZOOM),
		)
	})
}

/// The rounded, rough border of one zoom button, [`ZOOM_BUTTON_SIZE`]
/// square.
pub fn zoom_button_drawing(seed: i64, theme: Theme) -> InkDrawing {
	let options = DrawOptions {
		seed,
		roughness: theme.roughness.min(1.25),
		pen: RoughPen::UNIFORM,
		..DrawOptions::default()
	};
	let mut generator = Generator::new(
		DrawConfig::new(options),
		Filler::new(
			FillStyle::None,
			FillOptions::default(),
			DrawConfig::new(options),
		),
	);
	let inset = 3.0;
	let side = f64::from(ZOOM_BUTTON_SIZE) - inset * 2.0;
	let paths = RoughSvgPaths::from_drawable(
		&generator.rounded_rectangle(inset, inset, side, side, [9.0; 4]),
	);
	let size = f64::from(ZOOM_BUTTON_SIZE);
	let mut drawing = InkDrawing::new(size, size, InkScaling::Fit);
	drawing.push_stroke(paths.outline, theme.ink(), theme.stroke_width);
	drawing
}

#[cfg(test)]
mod tests {
	use super::*;

	#[test]
	fn steps_clamp_to_the_zoom_range() {
		assert_eq!(zoom_steps(MIN_ZOOM, 1.0), Some((MIN_ZOOM + 1.0, MIN_ZOOM)));
		assert_eq!(zoom_steps(f64::NAN, 1.0), None);
		assert_eq!(zoom_steps(3.0, -1.0), None);
		assert_eq!(zoom_steps(3.0, f64::INFINITY), None);
	}

	#[test]
	fn a_button_border_is_one_ink_stroke() {
		let drawing = zoom_button_drawing(1, Theme::SKRIBBLE);
		assert_eq!(drawing.paths.len(), 1);
		assert_eq!(drawing.paths[0].paint.tone(), Theme::SKRIBBLE.ink());
		assert_eq!(drawing.width, f64::from(ZOOM_BUTTON_SIZE));
		assert_ne!(drawing, zoom_button_drawing(2, Theme::SKRIBBLE));
	}
}
