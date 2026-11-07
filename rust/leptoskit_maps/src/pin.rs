//! Hand-drawn map pins with pastel category fills and a cream sticker edge.

use std::fmt;
use std::sync::Arc;

use leptoskit::native::Color;
use leptoskit::native::Element;
use leptoskit::native::Role;
use leptoskit::prelude::Pressable;
use leptoskit::prelude::Text;
use leptoskit::prelude::View;
use leptoskit::yoga::Dimension;
use leptoskit::yoga::PositionType;
use skribble_leptoskit::Theme;
use skribble_leptoskit::Tone;
use skribble_rough::Drawable;
use skribble_rough::Op;
use skribble_rough::OpSet;
use skribble_rough::OpSetKind;
use skribble_rough::Point;
use skribble_rough::Randomizer;
use skribble_rough::RoughPen;
use skribble_rough::RoughSvgPaths;

use crate::camera::Camera;
use crate::camera::LatLng;
use crate::paint::MapDrawing;
use crate::paint::tone_class;

/// The width of a pin, in logical pixels.
pub const PIN_WIDTH: f32 = 52.0;

/// The height of a pin, in logical pixels.
pub const PIN_HEIGHT: f32 = 64.0;

/// The width of the box a pin's short label is laid out in.
const LABEL_WIDTH: f32 = 140.0;

/// The cream sticker edge drawn around every pin.
const STICKER: Tone = Tone::fixed(Color::rgba(0xff, 0xfc, 0xf3, 0xff));

/// The dark brown ink readable on every pastel fill.
const PIN_INK: Tone = Tone::fixed(Color::rgba(0x35, 0x33, 0x2f, 0xff));

/// What a pin marks, which chooses its pastel fill.
///
/// The palette matches skribble's Flutter map pins, so a place keeps its
/// colour across a Flutter app and a `leptoskit` one.
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
	pub const fn fill(self) -> Color {
		match self {
			Self::Place => Color::rgba(0xf3, 0xd7, 0x7a, 0xff),
			Self::CheckIn => Color::rgba(0xc9, 0xdc, 0x91, 0xff),
			Self::Coffee => Color::rgba(0xf5, 0xcb, 0x83, 0xff),
			Self::Market => Color::rgba(0xae, 0xd9, 0xbc, 0xff),
			Self::Gallery => Color::rgba(0xbf, 0xc8, 0xed, 0xff),
			Self::Favorite => Color::rgba(0xf3, 0xab, 0xa6, 0xff),
			Self::Person => Color::rgba(0xa9, 0xd8, 0xe8, 0xff),
		}
	}
}

/// A hand-drawn pin anchored to one geographic point.
///
/// The point is the tip of the pin: the rounded head sits above it, so a pin
/// never covers the place it marks. A short label can sit under the tip. With
/// an `on_press` the pin is a real button named by its label; without one it
/// is a decorative image.
///
/// ```
/// use skribble_leptoskit_maps::LatLng;
/// use skribble_leptoskit_maps::MapPin;
/// use skribble_leptoskit_maps::PinCategory;
///
/// let cafe = MapPin::new(LatLng::new(51.5074, -0.1278), "Favourite cafe")
/// 	.with_category(PinCategory::Coffee);
/// assert_eq!(cafe.category, PinCategory::Coffee);
/// ```
#[derive(Clone)]
pub struct MapPin {
	/// The geographic anchor, at the tip of the pin.
	pub position: LatLng,
	/// A short label shown under the pin, and its accessible name.
	pub label: String,
	/// What the pin marks, which chooses its pastel fill.
	pub category: PinCategory,
	/// Runs when the pin is activated. Without one the pin is decorative.
	pub on_press: Option<Arc<dyn Fn() + Send + Sync>>,
}

impl MapPin {
	/// A pin at `position` carrying `label`.
	#[must_use]
	pub fn new(position: LatLng, label: impl Into<String>) -> Self {
		Self {
			position,
			label: label.into(),
			category: PinCategory::Place,
			on_press: None,
		}
	}

	/// The same pin in another category.
	#[must_use]
	pub fn with_category(mut self, category: PinCategory) -> Self {
		self.category = category;
		self
	}

	/// The same pin, pressable.
	#[must_use]
	pub fn with_on_press(self, on_press: impl Fn() + Send + Sync + 'static) -> Self {
		Self {
			on_press: Some(Arc::new(on_press)),
			..self
		}
	}

	/// A pin with no position and no label, useful as a placeholder.
	#[must_use]
	pub fn empty() -> Self {
		Self::new(LatLng::default(), String::new())
	}
}

impl Default for MapPin {
	fn default() -> Self {
		Self::empty()
	}
}

impl fmt::Debug for MapPin {
	fn fmt(&self, formatter: &mut fmt::Formatter<'_>) -> fmt::Result {
		formatter
			.debug_struct("MapPin")
			.field("position", &self.position)
			.field("label", &self.label)
			.field("category", &self.category)
			.field("on_press", &self.on_press.is_some())
			.finish()
	}
}

/// The pin elements inside the map, positioned and culled.
pub(crate) fn elements(
	camera: Camera,
	width: f32,
	height: f32,
	pins: &[MapPin],
	theme: Theme,
	seed: i64,
) -> Vec<Element> {
	pins.iter()
		.enumerate()
		.filter_map(|(index, pin)| {
			let (x, y) = camera.project(pin.position, width, height);
			if !visible(x, y, width, height) {
				return None;
			}
			let drawing = drawing(pin, theme, seed.wrapping_add(index as i64));
			let mut children = drawing.vectors();
			if !pin.label.is_empty() {
				children.push(label(pin, theme));
			}
			let container = if let Some(on_press) = &pin.on_press {
				let on_press = Arc::clone(on_press);
				let name = if pin.label.is_empty() {
					"Map pin"
				} else {
					pin.label.as_str()
				};
				Pressable(name.to_owned())
					.class("items-center")
					.on_press(move || on_press())
			} else {
				let view = View();
				if pin.label.is_empty() {
					view.aria_hidden(true)
				} else {
					view.role(Role::Img).aria_label(pin.label.clone())
				}
			};
			Some(container.children(children).with_style(|style| {
				style.position = PositionType::Absolute;
				style.width = Dimension::Points(PIN_WIDTH);
				style.height = Dimension::Points(PIN_HEIGHT);
				style.inset.left = Dimension::Points(x - PIN_WIDTH / 2.0);
				style.inset.top = Dimension::Points(y - PIN_HEIGHT);
			}))
		})
		.collect()
}

/// Whether a pin's tip is near enough to the viewport to paint.
fn visible(x: f32, y: f32, width: f32, height: f32) -> bool {
	x >= -PIN_WIDTH && x <= width + PIN_WIDTH && y >= -PIN_HEIGHT && y <= height + PIN_HEIGHT
}

/// The pin's short label, centred under the tip.
fn label(pin: &MapPin, theme: Theme) -> Element {
	View()
		.class("items-center")
		.child(
			Text(pin.label.clone())
				.class("text-xs text-center")
				.class(tone_class("text", theme.ink())),
		)
		.with_style(|style| {
			style.position = PositionType::Absolute;
			style.width = Dimension::Points(LABEL_WIDTH);
			style.inset.left = Dimension::Points((PIN_WIDTH - LABEL_WIDTH) / 2.0);
			style.inset.top = Dimension::Points(PIN_HEIGHT + 2.0);
		})
}

/// Draws one pin: the cream sticker edge, the category fill, and the ink
/// outline.
pub(crate) fn drawing(pin: &MapPin, theme: Theme, seed: i64) -> MapDrawing {
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
	let mut drawing = MapDrawing::new(width, height);

	drawing.push_fill(paths.solid.clone(), STICKER);
	if !paths.outline.is_empty() {
		drawing.push_stroke(paths.outline.clone(), STICKER, theme.stroke_width + 4.0);
	}
	drawing.push_fill(paths.solid, Tone::fixed(pin.category.fill()));
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
	use crate::camera::MAX_LATITUDE;

	const SIZE: (f32, f32) = (320.0, 200.0);

	fn camera() -> Camera {
		Camera::new(LatLng::new(0.0, 0.0), 4.0)
	}

	#[test]
	fn a_pin_draws_a_sticker_edge_a_category_fill_and_ink() {
		let pin = MapPin::new(LatLng::default(), "Cafe").with_category(PinCategory::Coffee);
		let drawing = drawing(&pin, Theme::SKRIBBLE, 1);
		assert_eq!(drawing.paths.len(), 4);
		assert_eq!(drawing.paths[0].paint.tone(), STICKER);
		assert_eq!(drawing.paths[1].paint.tone(), STICKER);
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
	fn pins_are_positioned_with_their_tip_at_the_point() {
		let pin = MapPin::new(LatLng::default(), "Centre");
		let (x, y) = camera().project(LatLng::default(), SIZE.0, SIZE.1);
		let elements = elements(camera(), SIZE.0, SIZE.1, &[pin], Theme::SKRIBBLE, 1);
		assert_eq!(elements.len(), 1);
		let style = elements[0].style.clone();
		assert_eq!(style.position, PositionType::Absolute);
		assert_eq!(style.width, Dimension::Points(PIN_WIDTH));
		assert_eq!(style.height, Dimension::Points(PIN_HEIGHT));
		assert_eq!(style.inset.left, Dimension::Points(x - PIN_WIDTH / 2.0));
		assert_eq!(style.inset.top, Dimension::Points(y - PIN_HEIGHT));
	}

	#[test]
	fn pins_outside_the_viewport_are_culled() {
		let far = MapPin::new(LatLng::new(MAX_LATITUDE, 170.0), "Far");
		let elements = elements(camera(), SIZE.0, SIZE.1, &[far], Theme::SKRIBBLE, 1);
		assert!(elements.is_empty());
	}

	#[test]
	fn a_pressable_pin_is_a_button_named_by_its_label() {
		let pressed = Arc::new(std::sync::atomic::AtomicBool::new(false));
		let shared = Arc::clone(&pressed);
		let pin = MapPin::new(LatLng::default(), "Favourite cafe")
			.with_on_press(move || shared.store(true, std::sync::atomic::Ordering::SeqCst));
		let elements = elements(camera(), SIZE.0, SIZE.1, &[pin], Theme::SKRIBBLE, 1);
		assert_eq!(
			elements[0].props.accessibility_label.as_deref(),
			Some("Favourite cafe")
		);
	}

	#[test]
	fn a_pin_without_a_label_is_hidden_from_assistive_technology() {
		let pin = MapPin::new(LatLng::default(), "");
		let elements = elements(camera(), SIZE.0, SIZE.1, &[pin], Theme::SKRIBBLE, 1);
		assert_eq!(elements[0].props.aria().hidden, Some(true));
	}

	#[test]
	fn empty_pins_draw_their_shape_without_a_label() {
		let pin = MapPin::empty();
		let elements = elements(camera(), SIZE.0, SIZE.1, &[pin], Theme::SKRIBBLE, 1);
		assert_eq!(elements[0].children.len(), 3);
	}

	#[test]
	fn the_same_seed_draws_the_same_pin() {
		let pin = MapPin::new(LatLng::default(), "Cafe");
		assert_eq!(
			drawing(&pin, Theme::SKRIBBLE, 3),
			drawing(&pin, Theme::SKRIBBLE, 3)
		);
		assert_ne!(
			drawing(&pin, Theme::SKRIBBLE, 3),
			drawing(&pin, Theme::SKRIBBLE, 4)
		);
	}
}
