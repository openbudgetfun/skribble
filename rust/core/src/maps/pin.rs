//! Hand-drawn map pins with pastel category fills and a cream sticker edge.

use skribble_rough::Drawable;
use skribble_rough::Op;
use skribble_rough::OpSet;
use skribble_rough::OpSetKind;
use skribble_rough::Point;
use skribble_rough::Randomizer;
use skribble_rough::RoughPen;
use skribble_rough::RoughSvgPaths;

use crate::InkDrawing;
use crate::InkScaling;
use crate::Theme;
use crate::Tone;
use crate::colorway::Rgba;
use crate::maps::Camera;
use crate::maps::LatLng;

/// The width of a pin, in logical pixels.
pub const PIN_WIDTH: f32 = 52.0;

/// The height of a pin, in logical pixels.
pub const PIN_HEIGHT: f32 = 64.0;

/// The width of the box a pin's short label is laid out in, centred under
/// the pin and [`PIN_LABEL_GAP`] below its tip.
pub const PIN_LABEL_WIDTH: f32 = 140.0;

/// The gap between a pin's tip and the top of its label.
pub const PIN_LABEL_GAP: f32 = 2.0;

/// The cream sticker edge drawn around every pin.
pub const PIN_STICKER: Tone = Tone::fixed(Rgba::new(0xff, 0xfc, 0xf3, 0xff));

/// The dark brown ink readable on every pastel fill.
pub const PIN_INK: Tone = Tone::fixed(Rgba::new(0x35, 0x33, 0x2f, 0xff));

/// What a pin marks, which chooses its pastel fill.
///
/// The palette matches skribble's Flutter map pins, so a place keeps its
/// colour across a Flutter app and a Rust one.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Default)]
pub enum PinCategory {
	/// A general place.
	#[default]
	Place,
	/// A completed check-in.
	CheckIn,
	/// A cafe or coffee stop.
	Coffee,
	/// A shop or market.
	Market,
	/// A gallery, studio, or museum.
	Gallery,
	/// A saved or favourite place.
	Favorite,
	/// A person or meeting point.
	Person,
}

impl PinCategory {
	/// The pastel fill this category draws with.
	#[must_use]
	pub const fn fill(self) -> Rgba {
		match self {
			Self::Place => Rgba::new(0xf3, 0xd7, 0x7a, 0xff),
			Self::CheckIn => Rgba::new(0xc9, 0xdc, 0x91, 0xff),
			Self::Coffee => Rgba::new(0xf5, 0xcb, 0x83, 0xff),
			Self::Market => Rgba::new(0xae, 0xd9, 0xbc, 0xff),
			Self::Gallery => Rgba::new(0xbf, 0xc8, 0xed, 0xff),
			Self::Favorite => Rgba::new(0xf3, 0xab, 0xa6, 0xff),
			Self::Person => Rgba::new(0xa9, 0xd8, 0xe8, 0xff),
		}
	}
}

/// Where a pin's top-left corner goes for a pin anchored at `position`, in
/// the map's own pixel space, or `None` when the pin is too far outside the
/// `width` by `height` viewport to paint.
///
/// The anchor is the tip of the pin: the rounded head sits above it, so a pin
/// never covers the place it marks.
///
/// ```
/// use skribble_core::maps::Camera;
/// use skribble_core::maps::LatLng;
/// use skribble_core::maps::PIN_HEIGHT;
/// use skribble_core::maps::PIN_WIDTH;
/// use skribble_core::maps::pin_origin;
///
/// let camera = Camera::new(LatLng::new(0.0, 0.0), 3.0);
/// let origin = pin_origin(camera, LatLng::new(0.0, 0.0), 400.0, 240.0);
/// assert_eq!(origin, Some((200.0 - PIN_WIDTH / 2.0, 120.0 - PIN_HEIGHT)));
/// ```
pub fn pin_origin(camera: Camera, position: LatLng, width: f32, height: f32) -> Option<(f32, f32)> {
	let (x, y) = camera.project(position, width, height);
	visible(x, y, width, height).then(|| (x - PIN_WIDTH / 2.0, y - PIN_HEIGHT))
}

/// Whether a pin's tip is near enough to the viewport to paint.
fn visible(x: f32, y: f32, width: f32, height: f32) -> bool {
	x >= -PIN_WIDTH && x <= width + PIN_WIDTH && y >= -PIN_HEIGHT && y <= height + PIN_HEIGHT
}

/// Draws one pin, [`PIN_WIDTH`] by [`PIN_HEIGHT`]: the cream sticker edge,
/// the category's pastel fill, and the ink outline.
pub fn pin_drawing(category: PinCategory, theme: Theme, seed: i64) -> InkDrawing {
	let width = f64::from(PIN_WIDTH);
	let height = f64::from(PIN_HEIGHT);
	let stroke = f64::from(theme.stroke_width);
	let (contour, shoulder) = outline(width, height, stroke, seed);
	let mut outline_ops = contour.clone();
	outline_ops.extend(shoulder);
	let drawable = Drawable {
		sets: vec![
			OpSet {
				kind: OpSetKind::FillPath,
				ops: contour,
			},
			OpSet::path(outline_ops),
		],
		pen: RoughPen::UNIFORM,
		seed,
	};
	let paths = RoughSvgPaths::from_drawable(&drawable);
	let mut drawing = InkDrawing::new(width, height, InkScaling::Fit);

	drawing.push_fill(paths.solid.clone(), PIN_STICKER);
	if !paths.outline.is_empty() {
		drawing.push_stroke(paths.outline.clone(), PIN_STICKER, theme.stroke_width + 4.0);
	}
	drawing.push_fill(paths.solid, Tone::fixed(category.fill()));
	drawing.push_stroke(paths.outline, PIN_INK, theme.stroke_width);

	drawing
}

/// The pin contour and its retraced shoulder, jittered away from the tip so
/// the marker still points at its anchor.
fn outline(width: f64, height: f64, stroke: f64, seed: i64) -> (Vec<Op>, Vec<Op>) {
	let inset = (stroke / 2.0 + 3.0).min(width.min(height) / 4.0);
	let inner_width = width - inset * 2.0;
	let inner_height = height - inset * 2.0;
	let mut random = Randomizer::new(seed);
	// Vary the shoulders, never the tip: seeded deviations keep the pen
	// irregular without letting the border flicker on rebuild or drift away
	// from the fill.
	let lean = (random.next_double() - 0.5) * 0.06;
	let wobble = (width.min(height) * 0.018).min(1.1);
	let mut point = |x: f64, y: f64| {
		if (x - 0.5).abs() < f64::EPSILON && (y - 1.0).abs() < f64::EPSILON {
			return Point::new(width / 2.0, height - inset);
		}
		Point::new(
			inset + inner_width * x + (random.next_double() - 0.5) * wobble * 2.0,
			inset + inner_height * y + (random.next_double() - 0.5) * wobble * 2.0,
		)
	};

	let contour = vec![
		Op::move_to(point(0.5, 1.0)),
		Op::CurveTo {
			control1: point(0.43, 0.84),
			control2: point(0.25, 0.72),
			end: point(0.16, 0.60),
		},
		Op::CurveTo {
			control1: point(0.06, 0.48),
			control2: point(0.02, 0.43),
			end: point(0.02, 0.35),
		},
		Op::CurveTo {
			control1: point(0.0, 0.13),
			control2: point(0.20 + lean, 0.01),
			end: point(0.47, 0.02),
		},
		Op::CurveTo {
			control1: point(0.77 + lean, 0.0),
			control2: point(0.99, 0.13),
			end: point(0.98, 0.36),
		},
		Op::CurveTo {
			control1: point(0.98, 0.48),
			control2: point(0.90, 0.59),
			end: point(0.79, 0.70),
		},
		Op::CurveTo {
			control1: point(0.66, 0.82),
			control2: point(0.58, 0.89),
			end: point(0.5, 1.0),
		},
	];
	// A short retraced shoulder reads as a pen correction rather than a
	// second outline around the whole pin.
	let shoulder = vec![
		Op::move_to(point(0.04, 0.30)),
		Op::CurveTo {
			control1: point(0.05, 0.14),
			control2: point(0.22, 0.04),
			end: point(0.40, 0.045),
		},
	];
	(contour, shoulder)
}

#[cfg(test)]
mod tests {
	use super::*;
	use crate::maps::MAX_LATITUDE;

	const SIZE: (f32, f32) = (320.0, 200.0);

	fn camera() -> Camera {
		Camera::new(LatLng::new(0.0, 0.0), 4.0)
	}

	#[test]
	fn a_pin_draws_a_sticker_edge_a_category_fill_and_ink() {
		let drawing = pin_drawing(PinCategory::Coffee, Theme::SKRIBBLE, 1);
		assert_eq!(drawing.paths.len(), 4);
		assert_eq!(drawing.paths[0].paint.tone(), PIN_STICKER);
		assert_eq!(drawing.paths[1].paint.tone(), PIN_STICKER);
		assert_eq!(
			drawing.paths[2].paint.tone(),
			Tone::fixed(PinCategory::Coffee.fill())
		);
		assert_eq!(drawing.paths[3].paint.tone(), PIN_INK);
	}

	#[test]
	fn every_category_has_its_own_pastel() {
		let categories = [
			PinCategory::Place,
			PinCategory::CheckIn,
			PinCategory::Coffee,
			PinCategory::Market,
			PinCategory::Gallery,
			PinCategory::Favorite,
			PinCategory::Person,
		];
		for (index, category) in categories.iter().enumerate() {
			for other in categories.iter().skip(index + 1) {
				assert_ne!(category.fill(), other.fill(), "{category:?} and {other:?}");
			}
		}
	}

	#[test]
	fn a_pin_keeps_its_tip_on_the_anchor() {
		for seed in [0, 1, 7] {
			let (contour, _) = outline(f64::from(PIN_WIDTH), f64::from(PIN_HEIGHT), 2.0, seed);
			let Op::Move { to, .. } = contour[0] else {
				panic!("a contour starts with a move");
			};
			assert!((to.x - f64::from(PIN_WIDTH) / 2.0).abs() < 0.01);
			assert!((to.y - (f64::from(PIN_HEIGHT) - 4.0)).abs() < 0.01);
		}
	}

	#[test]
	fn the_same_seed_draws_the_same_pin() {
		let pin = |seed| pin_drawing(PinCategory::Place, Theme::SKRIBBLE, seed);
		assert_eq!(pin(3), pin(3));
		assert_ne!(pin(3), pin(4));
	}

	#[test]
	fn pins_sit_with_their_tip_on_the_point() {
		let (x, y) = camera().project(LatLng::default(), SIZE.0, SIZE.1);
		assert_eq!(
			pin_origin(camera(), LatLng::default(), SIZE.0, SIZE.1),
			Some((x - PIN_WIDTH / 2.0, y - PIN_HEIGHT))
		);
	}

	#[test]
	fn pins_outside_the_viewport_are_culled() {
		let far = LatLng::new(MAX_LATITUDE, 170.0);
		assert_eq!(pin_origin(camera(), far, SIZE.0, SIZE.1), None);
	}
}
