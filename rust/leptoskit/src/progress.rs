//! The hand-drawn progress bar.

use leptoskit::native::Element;
use leptoskit::native::Role;
use leptoskit::prelude::*;
use leptoskit::yoga::Dimension;
use skribble_rough::FillStyle;

use crate::Theme;
use crate::container::with_class;
use crate::ink::Canvas;
use crate::ink::Ink;
use crate::ink::InkShape;

const TRACK_CANVAS: Canvas = Canvas::new(240.0, 24.0).inset(2.5).gap(6.0);

/// A progress bar drawn by hand: a rough track that fills with hachure.
///
/// It is a progress bar for assistive technology, which reads the label and
/// the percentage.
///
/// ```
/// use leptoskit::prelude::*;
/// use skribble_leptoskit::WiredProgress;
///
/// let upload = view! { <WiredProgress label="Uploading" value=0.4 /> };
/// assert_eq!(upload.children.len(), 2);
/// ```
#[component]
pub fn WiredProgress(
	/// Names the task for assistive technology.
	#[prop(into)]
	label: String,
	/// How much is done, from 0 to 1. Values outside are clamped.
	value: f64,
	/// Chooses the wobble. The same seed always draws the same bar.
	#[prop(default = 1)]
	seed: i64,
	/// The colours to draw with.
	#[prop(default = Theme::SKRIBBLE)]
	theme: Theme,
	/// Extra Tailwind classes, such as a width.
	#[prop(optional, into)]
	class: Option<String>,
) -> Element {
	let done = if value.is_nan() {
		0.0
	} else {
		value.clamp(0.0, 1.0)
	};
	// Adding zero turns a clamped `-0.0` into `0`.
	let percent = (done * 100.0).round() + 0.0;
	let track = Ink::outline(InkShape::Rectangle, TRACK_CANVAS, seed, theme);
	// The filled part draws on a canvas as wide as its share of the track, so
	// the hachure keeps one density at every value instead of squeezing up.
	let filling = (done > 0.0).then(|| {
		let canvas = Canvas {
			width: TRACK_CANVAS.width * done,
			..TRACK_CANVAS
		};
		let ink = Ink::outline(InkShape::Rectangle, canvas, seed.wrapping_add(1), theme)
			.without_outline()
			.filled(FillStyle::Hachure, theme.accent());
		View()
			.class("absolute top-0 left-0 h-full")
			.with_style(|style| style.width = Dimension::Percent(done as f32))
			.child(ink.layer())
	});

	// Screen readers announce the value as a percentage of the range.
	let bar = View()
		.role(Role::ProgressBar)
		.aria_label(label)
		.aria_value_min(0.0)
		.aria_value_max(100.0)
		.aria_value_now(percent)
		.class("w-full h-6")
		.children(filling)
		.child(track.layer());
	with_class(bar, class)
}
