//! A notebook page of every skribble component, server-rendered to a static
//! HTML file.
//!
//! ```sh
//! cargo run -p skribble_leptoskit --example notebook --features web -- notebook.html
//! ```
//!
//! Open the file in a browser. It is the same `Element` tree a native app
//! commits, rendered by leptoskit's web renderer, so it doubles as a visual
//! check of the ink in light and dark mode. Leave out `--features web` to see
//! the straight-line drawing native builds use, through the same renderer.

use std::path::PathBuf;

use leptos::prelude::RenderHtml;
use leptoskit::native::Role;
use leptoskit::prelude::*;
use leptoskit_native::web::render;
use skribble_leptoskit::*;

/// A numbered section heading, with the number circled by hand.
#[component]
fn Section(
	number: &'static str,
	#[prop(into)] title: String,
	#[prop(default = 1)] seed: i64,
) -> Element {
	view! {
		<View class="flex-row items-center gap-3">
			<WiredCircle seed=seed class="size-11 px-0 py-0">
				<Text class="text-base font-bold">{number}</Text>
			</WiredCircle>
			<Heading aria_level=2 class="text-xl font-bold">{title}</Heading>
		</View>
	}
}

fn header() -> Element {
	view! {
		<View class="gap-3">
			<View class="flex-row flex-wrap items-center gap-2">
				<Heading aria_level=1 class="text-4xl font-bold">"skribble"</Heading>
				<WiredHighlight kind=HighlightKind::Marker seed=2>
					<Text class="text-4xl font-bold">"for leptoskit"</Text>
				</WiredHighlight>
			</View>
			<View class="flex-row flex-wrap items-center gap-1">
				<Text class="text-lg">"One interface, written once, drawn by"</Text>
				<WiredHighlight kind=HighlightKind::Underline seed=7>
					<Text class="text-lg">"hand"</Text>
				</WiredHighlight>
				<Text class="text-lg">"on the web and every native platform."</Text>
			</View>
		</View>
	}
}

fn sign_up() -> Element {
	view! {
		<WiredCard seed=11 class="flex-1 min-w-[300px]">
			<Section number="1" title="Controls" seed=12 />
			<WiredInput label="Name" value="Ada Lovelace" on_change=|_: &str| {} seed=13 />
			<WiredInput label="Password" value="analytical" secret on_change=|_: &str| {} seed=14 />
			<WiredCheckbox label="Email me new sketches" checked=true on_toggle=|_: bool| {} seed=15 />
			<WiredSwitch label="Dark paper" on=true on_toggle=|_: bool| {} seed=16 />
			<View role=Role::RadioGroup aria_label="Tool" class="flex-row flex-wrap gap-4">
				<WiredRadio label="Pencil" selected=true on_select=|| {} seed=17 />
				<WiredRadio label="Brush" selected=false on_select=|| {} seed=18 />
			</View>
			<View class="flex-row flex-wrap gap-3 pt-2">
				<WiredButton label="Start sketching" on_press=|| {} seed=19 />
				<WiredButton label="Later" variant=ButtonVariant::Secondary on_press=|| {} seed=20 />
			</View>
		</WiredCard>
	}
}

fn fills() -> Element {
	let swatches = [
		(FillStyle::Hachure, "hachure"),
		(FillStyle::CrossHatch, "cross-hatch"),
		(FillStyle::ZigZag, "zigzag"),
		(FillStyle::Dashed, "dashed"),
		(FillStyle::Dots, "dots"),
		(FillStyle::Solid, "solid"),
	]
	.into_iter()
	.zip(30..)
	.map(|((style, name), seed)| {
		view! {
			<View class="items-center gap-1">
				<WiredBox seed=seed fill_style=style class="w-[104px] h-[64px]"><></></WiredBox>
				<Text class="text-sm">{name}</Text>
			</View>
		}
	});

	view! {
		<WiredCard seed=21 class="flex-1 min-w-[300px]">
			<Section number="2" title="Fills and marks" seed=22 />
			<View class="flex-row flex-wrap gap-3">{swatches.collect::<Fragment>()}</View>
			<View class="flex-row flex-wrap items-center gap-3 pt-2">
				<WiredHighlight kind=HighlightKind::Circle seed=40><Text>"circled"</Text></WiredHighlight>
				<WiredHighlight kind=HighlightKind::Box seed=41><Text>"boxed"</Text></WiredHighlight>
				<WiredHighlight kind=HighlightKind::Strikethrough seed=42><Text>"struck"</Text></WiredHighlight>
				<WiredBadge seed=43><Text>"New"</Text></WiredBadge>
				<WiredBadge seed=44 fill_style=FillStyle::None><Text>"Beta"</Text></WiredBadge>
			</View>
		</WiredCard>
	}
}

fn progress_and_doodles() -> Element {
	let arrow =
		Shape::curve([(6.0, 70.0), (60.0, 18.0), (120.0, 58.0), (184.0, 14.0)]).with_arrowhead();
	let star = Shape::Polygon {
		points: [
			(40.0, 4.0),
			(50.0, 30.0),
			(78.0, 30.0),
			(55.0, 47.0),
			(64.0, 74.0),
			(40.0, 57.0),
			(16.0, 74.0),
			(25.0, 47.0),
			(2.0, 30.0),
			(30.0, 30.0),
		]
		.map(Point::from)
		.to_vec(),
	};

	view! {
		<WiredCard seed=51 class="w-full">
			<Section number="3" title="Progress and doodles" seed=52 />
			<View class="gap-3">
				<View class="flex-row justify-between">
					<Text>"Inking the sketchbook"</Text>
					<Text class="font-semibold">"64%"</Text>
				</View>
				<WiredProgress label="Inking the sketchbook" value=0.64 seed=53 />
			</View>
			<WiredDivider seed=54 class="my-2" />
			<View class="flex-row flex-wrap items-center gap-6">
				<Sketch width=190.0 height=80.0 shapes=vec![arrow] seed=55 label="An arrow pointing right" />
				<Sketch width=80.0 height=80.0 shapes=vec![star] seed=56 fill_style=FillStyle::Hachure label="A star" />
				<Sketch
					width=120.0
					height=80.0
					shapes=vec![Shape::ellipse(60.0, 40.0, 110.0, 64.0)]
					seed=57
					pen=RoughPen::BRUSH
					fill_style=FillStyle::CrossHatch
					label="A brush-drawn ellipse"
				/>
			</View>
		</WiredCard>
	}
}

fn notebook() -> Element {
	view! {
		<SkribblePage class="items-center px-4 py-10">
			<View class="w-full max-w-[960px] gap-8">
				{header()}
				<View class="flex-row flex-wrap gap-6">{sign_up()}{fills()}</View>
				{progress_and_doodles()}
			</View>
		</SkribblePage>
	}
}

/// skribble's lettering, Skribble Noto Sketch, from this repository.
const FONT: &str = concat!(
	env!("CARGO_MANIFEST_DIR"),
	"/../../packages/skribble_font_noto_sketch/assets/fonts/SkribbleNotoSketch-Regular.ttf"
);
const FONT_FILE: &str = "SkribbleNotoSketch-Regular.ttf";

/// leptoskit has no font-family utility yet, so the page sets skribble's
/// lettering itself, on every element so it reaches the root view's own
/// system-font declaration.
const PAGE_CSS: &str = "html,body{margin:0;height:100%}@font-face{font-family:'SkribbleNotoSketch';\
                        src:url('SkribbleNotoSketch-Regular.ttf') format('truetype')}body \
                        *{font-family:'SkribbleNotoSketch','Segoe Print','Bradley \
                        Hand',cursive}";

fn main() -> std::io::Result<()> {
	let path = std::env::args_os()
		.nth(1)
		.map_or_else(|| PathBuf::from("notebook.html"), PathBuf::from);
	let body = render(notebook()).to_html();
	let page = format!(
		"<!doctype html><html lang=\"en\"><head><meta charset=\"utf-8\"><meta name=\"viewport\" \
		 content=\"width=device-width, initial-scale=1\"><title>skribble for \
		 leptoskit</title><style>{PAGE_CSS}</style></head><body>{body}</body></html>"
	);
	std::fs::write(&path, page)?;
	std::fs::copy(FONT, path.with_file_name(FONT_FILE))?;
	println!("wrote {}", path.display());
	Ok(())
}
