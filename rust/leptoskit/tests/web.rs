//! What the components server-render on the web, where the `web` feature
//! draws their ink as SVG images.
#![cfg(feature = "web")]

use leptos::prelude::RenderHtml;
use leptoskit::prelude::*;
use leptoskit_native::web::render;
use skribble_leptoskit::*;

fn html(element: Element) -> String {
	render(element).to_html()
}

/// The decoded SVG of every ink image in `html`.
fn ink_images(html: &str) -> Vec<String> {
	html.split("src=\"data:image/svg+xml,")
		.skip(1)
		.map(|rest| {
			let encoded = &rest[..rest.find('"').expect("a closed src attribute")];
			percent_decode(encoded)
		})
		.collect()
}

fn percent_decode(encoded: &str) -> String {
	let bytes = encoded.as_bytes();
	let mut decoded = Vec::with_capacity(bytes.len());
	let mut index = 0;
	while index < bytes.len() {
		if bytes[index] == b'%' {
			let hex = std::str::from_utf8(&bytes[index + 1..index + 3]).expect("ASCII escapes");
			decoded.push(u8::from_str_radix(hex, 16).expect("a hex escape"));
			index += 3;
		} else {
			decoded.push(bytes[index]);
			index += 1;
		}
	}
	String::from_utf8(decoded).expect("UTF-8 markup")
}

#[test]
fn a_button_is_a_real_button_with_decorative_ink() {
	let html = html(view! { <WiredButton label="Save" on_press=|| {} /> });
	assert!(html.contains("<button"), "{html}");
	assert!(html.contains("aria-label=\"Save\""), "{html}");
	assert!(html.contains("aria-hidden=\"true\""), "{html}");
	assert!(html.contains("alt=\"\""), "{html}");

	let images = ink_images(&html);
	assert_eq!(images.len(), 1);
	let svg = &images[0];
	assert!(
		svg.starts_with("<svg xmlns='http://www.w3.org/2000/svg'"),
		"{svg}"
	);
	assert!(
		svg.contains("fill='#ffd43b'"),
		"the primary button is filled: {svg}"
	);
	assert!(svg.contains("vector-effect='non-scaling-stroke'"), "{svg}");
}

#[test]
fn ink_follows_dark_mode_inside_the_image() {
	let html = html(view! { <WiredBox><Text>"Box"</Text></WiredBox> });
	let svg = &ink_images(&html)[0];
	assert!(svg.contains("stroke='#1f1d1a'"), "{svg}");
	assert!(
		svg.contains("@media (prefers-color-scheme:dark){.d0{stroke:#f2efe6}}"),
		"{svg}"
	);
}

#[test]
fn controls_render_their_aria_roles_and_states() {
	let html = html(view! {
		<View>
			<WiredCheckbox label="Email me" checked=true on_toggle=|_: bool| {} />
			<WiredSwitch label="Dark paper" on=false on_toggle=|_: bool| {} />
			<WiredRadio label="Pencil" selected=true on_select=|| {} />
			<WiredProgress label="Uploading" value=0.25 />
		</View>
	});
	for expected in [
		"role=\"checkbox\"",
		"role=\"switch\"",
		"role=\"radio\"",
		"aria-checked=\"true\"",
		"aria-checked=\"false\"",
		"role=\"progressbar\"",
		"aria-valuenow=\"25\"",
	] {
		assert!(html.contains(expected), "missing {expected} in {html}");
	}
}

#[test]
fn a_ticked_checkbox_draws_the_tick_as_ink() {
	let unticked = html(view! { <WiredCheckbox label="A" checked=false on_toggle=|_: bool| {} /> });
	let ticked = html(view! { <WiredCheckbox label="A" checked=true on_toggle=|_: bool| {} /> });
	assert_eq!(ink_images(&unticked).len(), 1);
	assert_eq!(ink_images(&ticked).len(), 2);
	assert!(!ticked.contains('✓'));
}

#[test]
fn a_sketch_keeps_its_own_size_and_pen_ink() {
	let html = html(view! {
		<Sketch
			width=120.0
			height=60.0
			shapes=vec![Shape::curve([(4.0, 50.0), (40.0, 10.0), (116.0, 12.0)]).with_arrowhead()]
			label="An arrow"
		/>
	});
	assert!(html.contains("aria-label=\"An arrow\""), "{html}");
	let svg = &ink_images(&html)[0];
	assert!(
		svg.contains("width='120' height='60' viewBox='0 0 120 60'"),
		"{svg}"
	);
	// Pen ink is filled outlines rather than strokes.
	assert!(svg.contains("stroke='none'"), "{svg}");
	assert!(!svg.contains("preserveAspectRatio"), "{svg}");
}

#[test]
fn server_rendering_is_byte_stable() {
	let screen = || {
		view! {
			<SkribblePage class="gap-4 p-4">
				<WiredCard seed=3 fill_style=FillStyle::Hachure><Text>"Card"</Text></WiredCard>
				<WiredButton label="Go" seed=4 on_press=|| {} />
				<WiredDivider seed=5 />
			</SkribblePage>
		}
	};
	assert_eq!(html(screen()), html(screen()));
}

#[test]
fn progress_hachure_keeps_its_density_at_every_value() {
	let quarter = html(view! { <WiredProgress label="Upload" value=0.25 /> });
	let images = ink_images(&quarter);
	assert_eq!(images.len(), 2, "a filling and a track");
	// The filling's canvas is a quarter of the 240-unit track, so it stretches
	// by the same factor as the track does.
	assert!(images[0].contains("viewBox='0 0 60 24'"), "{}", images[0]);
	assert!(images[1].contains("viewBox='0 0 240 24'"), "{}", images[1]);
}
