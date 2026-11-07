//! What the components server-render on the web, where leptoskit draws their
//! ink as inline SVG.

use leptos::prelude::RenderHtml;
use leptoskit::prelude::*;
use leptoskit_native::web::render;
use skribble_leptoskit::*;

fn html(element: Element) -> String {
	render(element).to_html()
}

/// Every inline ink drawing in `html`, as its `<svg>` markup.
fn ink_svgs(html: &str) -> Vec<&str> {
	html.match_indices("<svg ")
		.map(|(start, _)| {
			let end = start + html[start..].find("</svg>").expect("a closed svg") + 6;
			&html[start..end]
		})
		.collect()
}

#[test]
fn a_button_is_a_real_button_with_decorative_ink() {
	let html = html(view! { <WiredButton label="Save" on_press=|| {} /> });
	assert!(html.contains("<button"), "{html}");
	assert!(html.contains("aria-label=\"Save\""), "{html}");

	let svgs = ink_svgs(&html);
	assert_eq!(svgs.len(), 2, "a fill and an outline: {html}");
	for svg in &svgs {
		assert!(svg.contains("aria-hidden=\"true\""), "{svg}");
		assert!(svg.contains("preserveAspectRatio=\"none\""), "{svg}");
	}
	assert!(svgs[0].contains("fill=\"currentColor\""), "{}", svgs[0]);
	assert!(
		html.contains("text-[#ffd43b]"),
		"the primary button is filled: {html}"
	);
	assert!(svgs[1].contains("stroke=\"currentColor\""), "{}", svgs[1]);
}

#[test]
fn ink_follows_dark_mode_through_its_text_colour() {
	let html = html(view! { <WiredBox><Text>"Box"</Text></WiredBox> });
	assert!(ink_svgs(&html)[0].contains("currentColor"), "{html}");
	assert!(html.contains("text-[#1f1d1a]"), "{html}");
	assert!(html.contains("dark:text-[#f2efe6]"), "{html}");
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
	assert_eq!(ink_svgs(&unticked).len(), 1);
	assert_eq!(ink_svgs(&ticked).len(), 2);
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
	let svg = ink_svgs(&html)[0];
	assert!(svg.contains("viewBox=\"0 0 120 60\""), "{svg}");
	// Pen ink is filled outlines rather than strokes, drawn at its own size.
	assert!(svg.contains("fill=\"currentColor\""), "{svg}");
	assert!(!svg.contains("preserveAspectRatio=\"none\""), "{svg}");
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
	let svgs = ink_svgs(&quarter);
	assert_eq!(svgs.len(), 2, "a filling and a track");
	// The filling's canvas is a quarter of the 240-unit track, so it stretches
	// by the same factor as the track does.
	assert!(svgs[0].contains("viewBox=\"0 0 60 24\""), "{}", svgs[0]);
	assert!(svgs[1].contains("viewBox=\"0 0 240 24\""), "{}", svgs[1]);
}
