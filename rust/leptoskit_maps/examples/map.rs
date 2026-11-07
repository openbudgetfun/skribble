//! A hand-drawn atlas page, server-rendered to a static HTML file.
//!
//! ```sh
//! cargo run -p skribble_leptoskit_maps --example map -- map.html
//! ```
//!
//! Open the file in a browser. It is the same `Element` tree a native app
//! commits, rendered by leptoskit's web renderer, so it doubles as a visual
//! check of the ink in light and dark mode.

use std::path::PathBuf;

use leptos::prelude::RenderHtml;
use leptoskit::prelude::*;
use leptoskit_native::web::render;
use skribble_leptoskit::HighlightKind;
use skribble_leptoskit::Palette;
use skribble_leptoskit::SkribblePage;
use skribble_leptoskit::Theme;
use skribble_leptoskit::WiredBadge;
use skribble_leptoskit::WiredCard;
use skribble_leptoskit::WiredHighlight;
use skribble_leptoskit_maps::*;

/// The subject of the page: a walk through a made-up city square.
const START: LatLng = LatLng::new(51.5074, -0.1278);
const FINISH: LatLng = LatLng::new(51.5160, -0.1100);

/// A warmer accent for the park, so the page shows a custom theme.
const MEADOW: Theme = Theme {
	light: Palette {
		accent: Color::rgba(0x9d, 0xd4, 0x8f, 0xff),
		..Palette::LIGHT
	},
	dark: Palette {
		accent: Color::rgba(0x6f, 0xa8, 0x63, 0xff),
		..Palette::DARK
	},
	..Theme::SKRIBBLE
};

fn header() -> Element {
	view! {
		<View class="gap-3">
			<View class="flex-row flex-wrap items-center gap-2">
				<Heading aria_level=1 class="text-4xl font-bold">"skribble"</Heading>
				<WiredHighlight kind=HighlightKind::Marker seed=2>
					<Text class="text-4xl font-bold">"maps"</Text>
				</WiredHighlight>
			</View>
			<Text class="text-lg">
				"One sketch map, projected from coordinates and drawn by hand."
			</Text>
		</View>
	}
}

fn park() -> MapFeature {
	MapFeature::area(vec![
		LatLng::new(51.5040, -0.1400),
		LatLng::new(51.5040, -0.1250),
		LatLng::new(51.5080, -0.1180),
		LatLng::new(51.5130, -0.1240),
	])
	.with_tone(MEADOW.accent())
}

fn route() -> MapFeature {
	MapFeature::route(vec![
		START,
		LatLng::new(51.5095, -0.1240),
		LatLng::new(51.5110, -0.1205),
		LatLng::new(51.5140, -0.1140),
		FINISH,
	])
}

fn pins() -> Vec<MapPin> {
	vec![
		MapPin::new(START, "Coffee first")
			.with_category(PinCategory::Coffee)
			.with_on_press(|| println!("start the walk")),
		MapPin::new(LatLng::new(51.5110, -0.1205), "Market").with_category(PinCategory::Market),
		MapPin::new(LatLng::new(51.5140, -0.1140), "Gallery").with_category(PinCategory::Gallery),
		MapPin::new(FINISH, "Finish").with_category(PinCategory::Favorite),
	]
}

fn map_paper() -> Element {
	view! {
		<WiredCard seed=11 class="flex-1 min-w-[320px] overflow-hidden">
			<View class="flex-row items-center justify-between">
				<Heading aria_level=2 class="text-xl font-bold">"Paper with a graticule"</Heading>
				<WiredBadge seed=12><Text>"MapStyle::PAPER"</Text></WiredBadge>
			</View>
			<WiredMap
				camera=Camera::fit(
					LatLngBounds::new(LatLng::new(51.5040, -0.1400), FINISH),
					480.0,
					330.0,
					72.0,
				)
				width=480.0
				height=330.0
				features=vec![park(), route(), MapFeature::point(FINISH)]
				pins=pins()
				theme=MEADOW
				label="A sketch map of a city walk"
			/>
		</WiredCard>
	}
}

fn map_night() -> Element {
	view! {
		<WiredCard seed=21 class="flex-1 min-w-[320px] overflow-hidden">
			<View class="flex-row items-center justify-between">
				<Heading aria_level=2 class="text-xl font-bold">"Charcoal paper"</Heading>
				<WiredBadge seed=22><Text>"MapStyle::DARK"</Text></WiredBadge>
			</View>
			<WiredMap
				camera=Camera::fit(
					LatLngBounds::new(START, FINISH),
					480.0,
					330.0,
					72.0,
				)
				width=480.0
				height=330.0
				features=vec![route()]
				pins=pins()
				background=MapStyle::DARK
				theme=MEADOW
				seed=3
				label="The same walk on charcoal paper"
			/>
		</WiredCard>
	}
}

fn controls() -> Element {
	view! {
		<WiredCard seed=31 class="w-full">
			<Heading aria_level=2 class="text-xl font-bold">"Zoom controls"</Heading>
			<Text>"A controlled pair: they show the zoom and propose the next one."</Text>
			<View class="flex-row items-center gap-6">
				<WiredMapZoomControls zoom=14.0 on_zoom=|next: f64| println!("zoom to {next}") />
				<WiredMap
					camera=Camera::new(FINISH, 16.0)
					width=280.0
					height=180.0
					features=vec![MapFeature::point(FINISH)]
					pins=vec![MapPin::new(FINISH, "Close up").with_category(PinCategory::Person)]
					background=MapStyle::PLAIN
					label="A close-up of the finish"
				/>
			</View>
		</WiredCard>
	}
}

fn atlas() -> Element {
	view! {
		<SkribblePage class="items-center px-4 py-10">
			<View class="w-full max-w-[1120px] gap-8">
				{header()}
				<View class="flex-row flex-wrap gap-6">{map_paper()}{map_night()}</View>
				{controls()}
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
		.map_or_else(|| PathBuf::from("map.html"), PathBuf::from);
	let body = render(atlas()).to_html();
	let page = format!(
		"<!doctype html><html lang=\"en\"><head><meta charset=\"utf-8\"><meta name=\"viewport\" \
		 content=\"width=device-width, initial-scale=1\"><title>skribble maps for \
		 leptoskit</title><style>{PAGE_CSS}</style></head><body>{body}</body></html>"
	);
	std::fs::write(&path, page)?;
	std::fs::copy(FONT, path.with_file_name(FONT_FILE))?;
	println!("wrote {}", path.display());
	Ok(())
}
