//! The hand-drawn map itself.

use leptoskit::native::Element;
use leptoskit::native::Role;
use leptoskit::prelude::*;
use leptoskit::yoga::Dimension;
use skribble_leptoskit::Theme;

use crate::camera::Camera;
use crate::feature::MapFeature;
use crate::feature::drawing as feature_drawing;
use crate::paint::tone_class;
use crate::pin::MapPin;
use crate::pin::elements as pin_elements;
use crate::style::MapStyle;
use crate::style::graticule;

/// A hand-drawn map: rough areas, routes, dots, and pins at an explicit size.
///
/// leptoskit has no vector map engine, so this map draws itself. There are no
/// tiles and no network: the camera's Web Mercator projection turns
/// coordinates into pixels, and the rough engine inks them on paper. Areas get
/// a light hachure fill, routes a round-capped wobbling line, and pins a cream
/// sticker edge over a pastel category fill.
///
/// The map takes its size in logical pixels and draws in that coordinate
/// space, so a feature never drifts from the pin that marks it. Features and
/// pins outside the viewport are culled.
///
/// A `label` makes the map an image with that name. Without one the map is
/// decorative, while its pressable pins keep their own names.
///
/// ```
/// use leptoskit::prelude::*;
/// use skribble_leptoskit_maps::Camera;
/// use skribble_leptoskit_maps::LatLng;
/// use skribble_leptoskit_maps::MapFeature;
/// use skribble_leptoskit_maps::MapPin;
/// use skribble_leptoskit_maps::WiredMap;
///
/// let map = view! {
/// 	<WiredMap
/// 		camera=Camera::new(LatLng::new(51.5074, -0.1278), 12.0)
/// 		width=320.0
/// 		height=200.0
/// 		features=vec![MapFeature::point(LatLng::new(51.5074, -0.1278))]
/// 		pins=vec![MapPin::new(LatLng::new(51.5074, -0.1278), "You are here")]
/// 		label="A sketch map of London"
/// 	/>
/// };
/// assert_eq!(map.props.accessibility_label.as_deref(), Some("A sketch map of London"));
/// ```
///
/// # Panics
///
/// Panics when `width` or `height` is not a positive, finite number. A map
/// with no size is a mistake in the layout rather than something to recover
/// from.
#[component]
pub fn WiredMap(
	/// Where the map looks and how close.
	camera: Camera,
	/// Width, in logical pixels, in the map's own coordinates.
	width: f32,
	/// Height, in logical pixels, in the map's own coordinates.
	height: f32,
	/// Areas, routes, and dots, painted in list order under the pins.
	#[prop(default = Vec::new())]
	features: Vec<MapFeature>,
	/// Pins anchored to geographic points, painted last.
	#[prop(default = Vec::new())]
	pins: Vec<MapPin>,
	/// The paper and graticule behind the ink. Defaults to
	/// [`MapStyle::PAPER`].
	#[prop(optional)]
	background: Option<MapStyle>,
	/// Chooses the wobble. The same seed always draws the same map.
	#[prop(default = 1)]
	seed: i64,
	/// The colours and line weight to draw with.
	#[prop(default = Theme::SKRIBBLE)]
	theme: Theme,
	/// Names the map for assistive technology. Without one the map is
	/// decorative.
	#[prop(optional, into)]
	label: Option<String>,
	/// Extra Tailwind classes.
	#[prop(optional, into)]
	class: Option<String>,
) -> Element {
	assert!(
		width.is_finite() && width > 0.0 && height.is_finite() && height > 0.0,
		"a map needs a positive, finite size, found {width} by {height}"
	);

	let style = background.unwrap_or(MapStyle::PAPER);
	let theme = style.inked(theme);
	let mut map = View()
		.class("relative overflow-hidden")
		.class(tone_class("bg", style.paper))
		.class(tone_class("text", theme.ink()));

	if let Some(tone) = style.graticule {
		let grid = graticule(camera, width, height, tone, seed);
		if !grid.is_empty() {
			map = map.child(grid.layer());
		}
	}

	let features = feature_drawing(camera, width, height, &features, theme, seed);
	if !features.is_empty() {
		map = map.child(features.layer());
	}

	map = map.children(pin_elements(camera, width, height, &pins, theme, seed));

	map = map.with_style(|style| {
		style.width = Dimension::Points(width);
		style.height = Dimension::Points(height);
	});

	if let Some(label) = label {
		map = map.role(Role::Img).aria_label(label);
	}

	match class {
		Some(class) => map.class(class),
		None => map,
	}
}
