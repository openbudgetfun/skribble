//! What the components server-render on the web, where leptoskit draws their
//! ink as inline SVG.

use leptos::prelude::RenderHtml;
use leptoskit::prelude::*;
use leptoskit_native::web::render;
use skribble_leptoskit::Theme;
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
		svgs[0].contains("fill=\"currentColor\"") && html.contains("text-[#ff6b4a]"),
		"the primary button is filled with the tomato accent: {html}"
	);
	assert!(svgs[1].contains("stroke=\"currentColor\""), "{}", svgs[1]);
}

#[test]
fn ink_follows_dark_mode_through_its_text_colour() {
	let html = html(view! { <WiredBox><Text>"Box"</Text></WiredBox> });
	assert!(ink_svgs(&html)[0].contains("currentColor"), "{html}");
	assert!(html.contains("text-[#34283f]"), "plum ink: {html}");
	assert!(
		html.contains("dark:text-[#fffaf0]"),
		"paper ink on night: {html}"
	);
}

#[test]
fn the_page_is_warm_paper_and_a_plum_night() {
	let html = html(view! { <SkribblePage><Text>"Hi"</Text></SkribblePage> });
	assert!(html.contains("bg-[#fffaf0]"), "{html}");
	assert!(html.contains("dark:bg-[#292331]"), "{html}");
}

#[test]
fn a_primary_label_flips_to_dark_on_the_accent_at_night() {
	let html = html(view! { <WiredButton label="Go" on_press=|| {} /> });
	assert!(
		html.contains("text-[#34283f]") && html.contains("dark:text-[#292331]"),
		"plum on tomato by day, night on tomato after dark: {html}"
	);
}

#[test]
fn marks_and_switches_use_the_sunshine_marker() {
	for element in [
		view! { <WiredHighlight kind=HighlightKind::Marker><Text>"Hi"</Text></WiredHighlight> },
		view! { <WiredSwitch label="On" on=true on_toggle=|_: bool| {} /> },
		view! { <WiredProgress label="Half" value=0.5 /> },
		view! { <WiredBox fill_style=FillStyle::Hachure><Text>"Box"</Text></WiredBox> },
	] {
		let html = html(element);
		assert!(html.contains("text-[#ffd43b]"), "{html}");
	}
}

#[test]
fn colour_coded_cards_take_their_wash_and_readable_ink() {
	let theme = Theme::SKRIBBLE;
	let washes: Vec<String> = (0..6)
		.map(|index| {
			html(view! {
				<WiredCard seed=index as i64 fill_style=FillStyle::Solid fill=theme.accent_at(index)>
					<Text>"Card"</Text>
				</WiredCard>
			})
		})
		.collect();
	for (index, html) in washes.iter().enumerate() {
		let wash = theme.accent_at(index).light;
		let hex = format!(
			"text-[#{:02x}{:02x}{:02x}]",
			wash.red(),
			wash.green(),
			wash.blue()
		);
		assert!(
			html.contains(&hex),
			"card {index} is washed with {hex}: {html}"
		);
		assert!(
			html.contains("dark:text-[#292331]"),
			"dark labels on a vivid wash at night: {html}"
		);
	}
}

#[test]
fn another_colourway_recolours_every_component() {
	let theme = Theme::colorway(colorway::Colorway::Ocean);
	let html = html(view! { <WiredButton label="Dive" on_press=|| {} theme=theme /> });
	assert!(html.contains("text-[#6aa6ff]"), "a cobalt primary: {html}");
	let html = self::html(view! {
		<WiredHighlight kind=HighlightKind::Marker theme=theme><Text>"Sea"</Text></WiredHighlight>
	});
	assert!(html.contains("text-[#6be3f2]"), "an aqua marker: {html}");
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
