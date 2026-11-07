//! Hand-drawn zoom controls for a controlled map camera.

use std::sync::Arc;

use leptoskit::native::Element;
use leptoskit::prelude::*;
use leptoskit::yoga::Dimension;
use skribble_leptoskit::Theme;
use skribble_rough::DrawConfig;
use skribble_rough::DrawOptions;
use skribble_rough::FillOptions;
use skribble_rough::FillStyle;
use skribble_rough::Filler;
use skribble_rough::Generator;
use skribble_rough::RoughPen;
use skribble_rough::RoughSvgPaths;

use crate::camera::MAX_ZOOM;
use crate::camera::MIN_ZOOM;
use crate::paint::MapDrawing;
use crate::paint::tone_class;

/// The width and height of each zoom button, in logical pixels.
const BUTTON_SIZE: f32 = 44.0;

/// Two hand-drawn buttons that propose a closer or further camera.
///
/// Like every leptoskit control it holds no state: it shows `zoom` and
/// proposes `zoom + step` or `zoom - step` through `on_zoom`. Keep the zoom in
/// your own state, build the [`Camera`](crate::Camera) from it, and rebuild
/// with the value you accept.
///
/// ```
/// use leptoskit::prelude::*;
/// use skribble_leptoskit_maps::WiredMapZoomControls;
///
/// let controls = view! {
/// 	<WiredMapZoomControls zoom=12.0 on_zoom=|next: f64| println!("zoom to {next}") />
/// };
/// assert_eq!(controls.children.len(), 2);
/// ```
///
/// # Panics
///
/// Panics when `step` or `zoom` is not finite, or when `step` is not positive.
#[component]
pub fn WiredMapZoomControls(
	/// The zoom the map is showing now.
	zoom: f64,
	/// Receives the proposed zoom. Clamp it to your own limits and rebuild.
	on_zoom: impl Fn(f64) + Send + Sync + 'static,
	/// How far one press moves the zoom.
	#[prop(default = 1.0)]
	step: f64,
	/// Chooses the wobble. The same seed always draws the same buttons.
	#[prop(default = 1)]
	seed: i64,
	/// The colours and line weight to draw with.
	#[prop(default = Theme::SKRIBBLE)]
	theme: Theme,
	/// Extra Tailwind classes for the column.
	#[prop(optional, into)]
	class: Option<String>,
) -> Element {
	assert!(
		zoom.is_finite() && step.is_finite() && step > 0.0,
		"zoom controls need a finite zoom and a positive step, found zoom {zoom} and step {step}"
	);

	let on_zoom = Arc::new(on_zoom);
	let closer = Arc::clone(&on_zoom);
	let further = Arc::clone(&on_zoom);
	let next_closer = (zoom + step).clamp(MIN_ZOOM, MAX_ZOOM);
	let next_further = (zoom - step).clamp(MIN_ZOOM, MAX_ZOOM);

	let controls = View()
		.class("flex-col gap-2")
		.child(button("Zoom in", "+", seed, theme, move || {
			closer(next_closer);
		}))
		.child(button(
			"Zoom out",
			"−",
			seed.wrapping_add(1),
			theme,
			move || further(next_further),
		));

	match class {
		Some(class) => controls.class(class),
		None => controls,
	}
}

/// One square, pressable zoom button with its rough border.
fn button(
	label: &str,
	glyph: &str,
	seed: i64,
	theme: Theme,
	on_press: impl Fn() + Send + Sync + 'static,
) -> Element {
	let drawing = border(seed, theme);
	Pressable(label.to_owned())
		.class("items-center justify-center")
		.class(tone_class("text", theme.ink()))
		.child(drawing.layer())
		.child(Text(glyph.to_owned()).class("text-xl font-bold"))
		.with_style(|style| {
			style.width = Dimension::Points(BUTTON_SIZE);
			style.height = Dimension::Points(BUTTON_SIZE);
		})
		.on_press(on_press)
}

/// The rounded, rough border each button draws.
fn border(seed: i64, theme: Theme) -> MapDrawing {
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
	let side = f64::from(BUTTON_SIZE) - inset * 2.0;
	let paths = RoughSvgPaths::from_drawable(
		&generator.rounded_rectangle(inset, inset, side, side, [9.0; 4]),
	);
	let mut drawing = MapDrawing::new(f64::from(BUTTON_SIZE), f64::from(BUTTON_SIZE));
	drawing.push_stroke(paths.outline, theme.ink(), theme.stroke_width);
	drawing
}
