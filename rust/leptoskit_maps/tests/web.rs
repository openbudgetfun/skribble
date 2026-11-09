//! What the map server-renders on the web, where leptoskit draws its ink as
//! inline SVG.

use leptos::prelude::RenderHtml;
use leptoskit::prelude::*;
use leptoskit_native::web::render;
// leptoskit grew a `Camera` widget of its own, so the glob alone would leave
// the name ambiguous; the explicit import keeps this crate's projection type.
use skribble_leptoskit_maps::Camera;
use skribble_leptoskit_maps::*;

fn html(element: Element) -> String {
	render(element).to_html()
}

fn london() -> LatLng {
	LatLng::new(51.5074, -0.1278)
}

fn camera() -> Camera {
	Camera::new(london(), 12.0)
}

fn park() -> MapFeature {
	MapFeature::area(vec![
		LatLng::new(51.505, -0.135),
		LatLng::new(51.505, -0.120),
		LatLng::new(51.515, -0.125),
	])
}

/// Every inline ink drawing in `html`, as its `<svg>` markup.
fn svgs(html: &str) -> Vec<&str> {
	html.match_indices("<svg ")
		.map(|(start, _)| {
			let end = start + html[start..].find("</svg>").expect("a closed svg") + 6;
			&html[start..end]
		})
		.collect()
}

#[test]
fn a_labelled_map_is_an_image_with_inline_ink() {
	let html = html(view! {
		<WiredMap camera=camera() width=320.0 height=200.0 label="A sketch map" />
	});
	assert!(html.contains("role=\"img\""), "{html}");
	assert!(html.contains("aria-label=\"A sketch map\""), "{html}");
	assert!(html.contains("viewBox=\"0 0 320 200\""), "{html}");
	let drawings = svgs(&html);
	assert!(!drawings.is_empty(), "{html}");
	for drawing in &drawings {
		assert!(drawing.contains("aria-hidden=\"true\""), "{drawing}");
		assert!(drawing.contains("preserveAspectRatio"), "{drawing}");
	}
}

#[test]
fn ink_paints_with_the_current_colour_and_follows_dark_mode() {
	let html = html(view! {
		<WiredMap
			camera=camera()
			width=320.0
			height=200.0
			features=vec![park(), MapFeature::point(london())]
		/>
	});
	assert!(html.contains("fill=\"currentColor\""), "{html}");
	assert!(html.contains("stroke=\"currentColor\""), "{html}");
	assert!(html.contains("text-[#"), "{html}");
	assert!(html.contains("dark:text-[#"), "{html}");
	assert!(html.contains("bg-[#"), "{html}");
	assert!(html.contains("dark:bg-[#"), "{html}");
}

#[test]
fn features_keep_the_map_size_and_pins_keep_their_own() {
	let html = html(view! {
		<WiredMap
			camera=camera()
			width=320.0
			height=200.0
			features=vec![park(), MapFeature::route(vec![london(), LatLng::new(51.515, -0.115)])]
			pins=vec![MapPin::new(london(), "Cafe").with_category(PinCategory::Coffee)]
		/>
	});
	assert!(html.contains("viewBox=\"0 0 320 200\""), "{html}");
	assert!(html.contains("viewBox=\"0 0 52 64\""), "{html}");
}

#[test]
fn a_pin_label_is_visible_text_and_its_button_has_a_name() {
	let html = html(view! {
		<WiredMap
			camera=camera()
			width=320.0
			height=200.0
			pins=vec![
				MapPin::new(london(), "Favourite cafe")
					.with_category(PinCategory::Coffee)
					.with_on_press(|| println!("pressed")),
			]
		/>
	});
	assert!(html.contains("<button"), "{html}");
	assert!(html.contains("aria-label=\"Favourite cafe\""), "{html}");
	assert!(
		html.contains(">Favourite cafe<"),
		"the label is text: {html}"
	);
}

#[test]
fn a_plain_map_draws_no_graticule() {
	let paper = html(view! {
		<WiredMap camera=camera() width=200.0 height=120.0 background=MapStyle::PAPER />
	});
	let plain = html(view! {
		<WiredMap camera=camera() width=200.0 height=120.0 background=MapStyle::PLAIN />
	});
	assert!(svgs(&paper).len() > svgs(&plain).len());
}

#[test]
fn offscreen_features_draw_nothing() {
	let without = html(view! {
		<WiredMap camera=camera() width=320.0 height=200.0 background=MapStyle::PLAIN />
	});
	let with = html(view! {
		<WiredMap
			camera=camera()
			width=320.0
			height=200.0
			background=MapStyle::PLAIN
			features=vec![MapFeature::area(vec![
				LatLng::new(-33.9, 151.2),
				LatLng::new(-33.9, 151.3),
				LatLng::new(-33.8, 151.25),
			])]
			pins=vec![MapPin::new(LatLng::new(-33.9, 151.2), "Far away")]
		/>
	});
	assert_eq!(without, with);
}

#[test]
fn zoom_controls_are_named_buttons_with_drawn_borders() {
	let html = html(view! { <WiredMapZoomControls zoom=3.0 on_zoom=|_: f64| {} /> });
	assert!(html.contains("<button"), "{html}");
	assert!(html.contains("aria-label=\"Zoom in\""), "{html}");
	assert!(html.contains("aria-label=\"Zoom out\""), "{html}");
	assert_eq!(svgs(&html).len(), 2, "one border each: {html}");
	assert!(html.contains(">+<"), "{html}");
	assert!(html.contains(">−<"), "{html}");
}

#[test]
fn server_rendering_is_byte_stable() {
	let map = || {
		view! {
			<WiredMap
				camera=camera()
				width=320.0
				height=200.0
				features=vec![park()]
				pins=vec![MapPin::new(london(), "Cafe")]
				seed=7
				label="A sketch map"
			/>
		}
	};
	assert_eq!(html(map()), html(map()));
}
