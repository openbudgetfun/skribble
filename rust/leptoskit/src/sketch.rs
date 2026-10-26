//! Standalone doodles at an explicit size.

use leptoskit::native::Element;
use leptoskit::native::Role;
use leptoskit::prelude::*;
use leptoskit::yoga::Dimension;
use skribble_rough::DrawOptions;
use skribble_rough::FillStyle;
use skribble_rough::RoughPen;
use skribble_rough::Shape;
use skribble_rough::SketchOptions;
use skribble_rough::SketchPart;
use skribble_rough::sketch;

use crate::Theme;
use crate::Tone;
use crate::container::with_class;
use crate::ink::InkTarget;
use crate::ink::SvgImage;
use crate::ink::SvgPaint;
use crate::ink::SvgPath;
use crate::theme::css_hex;

/// A hand-drawn doodle: arrows, scribbles, and annotations the other
/// components do not cover.
///
/// The shapes are drawn in the sketch's own coordinates, `width` by `height`
/// logical pixels, with the pen's tapered ink. Colours default to the theme,
/// including in dark mode.
///
/// A sketch is decorative and hidden from assistive technology unless it has
/// a `label`, which makes it an image with that name.
///
/// On the web (the `web` feature) the sketch is drawn as an SVG image. Native
/// leptoskit cannot draw paths yet, so there the sketch keeps its size and
/// accessible name but draws nothing.
///
/// # Panics
///
/// Panics when `width` or `height` is not a positive, finite number, or when a
/// shape fails [`Shape::validate`]: a NaN or infinite coordinate, an arc that
/// sweeps nothing, or a curve through fewer than two points. These are
/// mistakes in the drawing rather than something to recover from.
///
/// ```
/// use leptoskit::prelude::*;
/// use skribble_leptoskit::Shape;
/// use skribble_leptoskit::Sketch;
///
/// let arrow = view! {
/// 	<Sketch
/// 		width=120.0
/// 		height=60.0
/// 		shapes=vec![Shape::curve([(4.0, 50.0), (40.0, 10.0), (80.0, 40.0), (116.0, 12.0)]).with_arrowhead()]
/// 		label="Points to the sign-up form"
/// 	/>
/// };
/// assert_eq!(arrow.props.accessibility_label.as_deref(), Some("Points to the sign-up form"));
/// ```
#[component]
pub fn Sketch(
	/// Width, in logical pixels and in the shapes' coordinates.
	width: f32,
	/// Height, in logical pixels and in the shapes' coordinates.
	height: f32,
	/// What to draw, in order, from one random stream.
	shapes: Vec<Shape>,
	/// Names the drawing for assistive technology. Without one the sketch is
	/// decorative.
	#[prop(optional, into)]
	label: Option<String>,
	/// Chooses the wobble. The same seed always draws the same doodle.
	#[prop(default = 1)]
	seed: i64,
	/// How ink leaves the pen.
	#[prop(default = RoughPen::INK)]
	pen: RoughPen,
	/// The fill pattern for closed shapes. Defaults to hachure when `fill` is
	/// set, and to no fill otherwise.
	#[prop(optional)]
	fill_style: Option<FillStyle>,
	/// The fill colour. Defaults to the theme's accent.
	#[prop(optional, into)]
	fill: Option<Tone>,
	/// The ink colour. Defaults to the theme's ink.
	#[prop(optional, into)]
	stroke: Option<Tone>,
	/// The colours, line weight, and wobble to draw with.
	#[prop(default = Theme::SKRIBBLE)]
	theme: Theme,
	/// Extra Tailwind classes.
	#[prop(optional, into)]
	class: Option<String>,
) -> Element {
	// Check the shapes on every target, so a mistake fails on native as well
	// as on the web.
	assert!(
		width.is_finite() && width > 0.0 && height.is_finite() && height > 0.0,
		"a sketch needs a positive, finite size, found {width} by {height}"
	);
	for shape in &shapes {
		if let Err(error) = shape.validate() {
			panic!("{error}");
		}
	}

	let drawing = SketchDrawing {
		width,
		height,
		shapes,
		seed,
		pen,
		fill_style: fill_style.unwrap_or(if fill.is_some() {
			FillStyle::Hachure
		} else {
			FillStyle::None
		}),
		fill: fill.unwrap_or(theme.accent()),
		stroke: stroke.unwrap_or(theme.ink()),
		theme,
	};

	let element = match InkTarget::ACTIVE {
		InkTarget::SvgImage => Image(drawing.image().data_uri()),
		InkTarget::PlainViews => View(),
	};
	let element = match label {
		Some(label) => element.role(Role::Img).aria_label(label),
		None => element.aria_hidden(true),
	};
	let element = element.with_style(|style| {
		style.width = Dimension::Points(width);
		style.height = Dimension::Points(height);
	});
	with_class(element, class)
}

/// Everything a [`Sketch`](fn@Sketch) draws, resolved against its theme.
pub(crate) struct SketchDrawing {
	pub(crate) width: f32,
	pub(crate) height: f32,
	pub(crate) shapes: Vec<Shape>,
	pub(crate) seed: i64,
	pub(crate) pen: RoughPen,
	pub(crate) fill_style: FillStyle,
	pub(crate) fill: Tone,
	pub(crate) stroke: Tone,
	pub(crate) theme: Theme,
}

impl SketchDrawing {
	/// The drawing as an SVG image at its own size.
	pub(crate) fn image(&self) -> SvgImage {
		let options = SketchOptions {
			draw: DrawOptions {
				seed: self.seed,
				roughness: self.theme.roughness,
				pen: self.pen,
				..DrawOptions::default()
			},
			fill_style: Some(self.fill_style),
			fill: Some(css_hex(self.fill.light)),
			stroke: css_hex(self.stroke.light),
			stroke_width: f64::from(self.theme.stroke_width),
			sketch_width: f64::from(self.theme.stroke_width) * 0.75,
			..SketchOptions::default()
		};
		let drawn = sketch(&self.shapes, &options).expect("the component validated its shapes");

		let paths = drawn
			.paths
			.into_iter()
			.map(|path| {
				let tone = match path.part {
					SketchPart::Outline => self.stroke,
					SketchPart::Sketch | SketchPart::Solid => self.fill,
				};
				let paint = if path.stroke == "none" {
					SvgPaint::Fill(tone)
				} else {
					SvgPaint::Stroke {
						tone,
						width: path.stroke_width as f32,
					}
				};
				SvgPath {
					data: path.d,
					paint,
				}
			})
			.collect();

		SvgImage {
			width: f64::from(self.width),
			height: f64::from(self.height),
			stretch: false,
			paths,
		}
	}
}
