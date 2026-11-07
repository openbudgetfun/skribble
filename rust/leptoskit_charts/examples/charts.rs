//! A gallery of every skribble chart, server-rendered to a static HTML file.
//!
//! ```sh
//! cargo run -p skribble_leptoskit_charts --example charts -- charts.html
//! ```
//!
//! Open the file in a browser. It is the same `Element` tree a native app
//! commits, rendered by leptoskit's web renderer, so it doubles as a visual
//! check of the ink in light and dark mode.

use std::path::PathBuf;

use leptos::prelude::RenderHtml;
use leptoskit::prelude::*;
use leptoskit_native::web::render;
use skribble_leptoskit::*;
use skribble_leptoskit_charts::*;

/// Illustrative prices, generated without any randomness so every run of the
/// example draws the same page.
fn candles() -> Vec<Candle> {
	let mut previous: f64 = 100.0;
	(0..48)
		.map(|index| {
			let wave =
				(f64::from(index) * 0.55).sin() * 7.0 + (f64::from(index) * 0.17).cos() * 3.0;
			let open = previous;
			let close = 100.0 + wave;
			let high = open.max(close) + 2.5;
			let low = open.min(close) - 2.5;
			let volume = 800.0 + (f64::from(index) * 37.0) % 500.0;
			previous = close;
			Candle::new(i64::from(index), open, high, low, close, volume)
		})
		.collect()
}

fn values() -> Vec<f64> {
	(0..24)
		.map(|index| 40.0 + (f64::from(index) * 0.5).sin() * 12.0)
		.collect()
}

fn bars() -> Vec<(String, f64)> {
	["Mon", "Tue", "Wed", "Thu", "Fri"]
		.into_iter()
		.zip([4.0, -2.0, 6.0, 1.0, -3.0])
		.map(|(label, value)| (label.to_owned(), value))
		.collect()
}

fn card(title: &'static str, seed: i64, chart: Element) -> Element {
	view! {
		<WiredCard seed=seed class="gap-3">
			<Heading aria_level=2 class="text-xl font-bold">{title}</Heading>
			{chart}
		</WiredCard>
	}
}

fn page() -> Element {
	view! {
		<SkribblePage class="items-center px-4 py-10">
			<View class="w-full max-w-[980px] gap-6">
				<View class="gap-2">
					<Heading aria_level=1 class="text-4xl font-bold">"skribble charts"</Heading>
					<Text class="text-lg">"Hand-drawn financial charts for leptoskit."</Text>
				</View>
				{card(
					"Candles, volume, and overlays",
					3,
					view! {
						<WiredCandlestickChart
							candles=candles()
							width=900.0
							height=320.0
							overlays=vec![
								Overlay::Sma(5),
								Overlay::Bollinger { period: 12, deviations: 2.0 },
							]
							show_volume=true
							label="Illustrative price with volume and Bollinger Bands"
						/>
					},
				)}
				<View class="flex-row flex-wrap gap-6">
					{card(
						"OHLC bars",
						5,
						view! {
							<WiredCandlestickChart
								candles=candles()
								width=440.0
								height=240.0
								kind=SeriesKind::Ohlc
								label="Illustrative OHLC bars"
							/>
						},
					)}
					{card(
						"Area",
						7,
						view! {
							<WiredCandlestickChart
								candles=candles()
								width=440.0
								height=240.0
								kind=SeriesKind::Area
								label="Illustrative area chart"
							/>
						},
					)}
				</View>
				<View class="flex-row flex-wrap gap-6">
					{card(
						"Line",
						9,
						view! {
							<WiredLineChart
								series=values()
								width=440.0
								height=200.0
								label="Illustrative line chart"
							/>
						},
					)}
					{card(
						"Bars",
						11,
						view! {
							<WiredBarChart
								bars=bars()
								width=440.0
								height=200.0
								label="Illustrative weekday change"
							/>
						},
					)}
				</View>
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

const PAGE_CSS: &str = "html,body{margin:0;height:100%}@font-face{font-family:'SkribbleNotoSketch';\
                        src:url('SkribbleNotoSketch-Regular.ttf') format('truetype')}body \
                        *{font-family:'SkribbleNotoSketch','Segoe Print','Bradley \
                        Hand',cursive}";

fn main() -> std::io::Result<()> {
	let path = std::env::args_os()
		.nth(1)
		.map_or_else(|| PathBuf::from("charts.html"), PathBuf::from);
	let body = render(page()).to_html();
	let page = format!(
		"<!doctype html><html lang=\"en\"><head><meta charset=\"utf-8\"><meta name=\"viewport\" \
		 content=\"width=device-width, initial-scale=1\"><title>skribble charts for \
		 leptoskit</title><style>{PAGE_CSS}</style></head><body>{body}</body></html>"
	);
	std::fs::write(&path, page)?;
	std::fs::copy(FONT, path.with_file_name(FONT_FILE))?;
	println!("wrote {}", path.display());
	Ok(())
}
