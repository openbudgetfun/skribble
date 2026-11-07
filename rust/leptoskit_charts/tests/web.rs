//! What the charts server-render on the web, where leptoskit draws their ink
//! as inline SVG.

use leptos::prelude::RenderHtml;
use leptoskit::prelude::*;
use leptoskit_native::web::render;
use skribble_leptoskit_charts::*;

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

fn candles() -> Vec<Candle> {
	vec![
		Candle::new(1, 10.0, 12.0, 9.0, 11.0, 100.0),
		Candle::new(2, 11.0, 14.0, 10.0, 13.0, 140.0),
		Candle::new(3, 13.0, 15.0, 12.0, 14.0, 120.0),
	]
}

#[test]
fn a_candlestick_chart_keeps_its_size_and_ink() {
	let html = html(view! {
		<WiredCandlestickChart
			candles=candles()
			width=320.0
			height=200.0
			show_volume=true
			label="Price in US dollars"
		/>
	});
	assert!(
		html.contains("aria-label=\"Price in US dollars\""),
		"{html}"
	);
	assert!(html.contains("viewBox=\"0 0 320 200\""), "{html}");
	let svgs = ink_svgs(&html);
	assert!(svgs.len() >= 3, "paper, grid, and price ink: {html}");
	for svg in &svgs {
		assert!(svg.contains("aria-hidden=\"true\""), "{svg}");
		assert!(
			svg.contains("preserveAspectRatio=\"xMidYMid meet\""),
			"{svg}"
		);
	}
	assert!(svgs.iter().any(|svg| svg.contains("fill=\"currentColor\"")));
	assert!(
		svgs.iter()
			.any(|svg| svg.contains("stroke=\"currentColor\""))
	);
}

#[test]
fn ink_follows_dark_mode_through_its_text_colour() {
	let html = html(view! { <WiredCandlestickChart candles=candles() width=240.0 height=140.0 /> });
	assert!(html.contains("text-[#267755]"), "rising ink: {html}");
	assert!(
		html.contains("dark:text-[#85c7a0]"),
		"rising dark ink: {html}"
	);
	assert!(html.contains("text-[#fffcf5]"), "paper: {html}");
}

#[test]
fn an_unlabelled_chart_is_hidden_from_assistive_technology() {
	let html = html(view! { <WiredCandlestickChart candles=candles() width=240.0 height=140.0 /> });
	assert!(!html.contains("role=\"img\""), "{html}");
	assert!(html.contains("aria-hidden=\"true\""), "{html}");
}

#[test]
fn line_and_bar_charts_server_render() {
	let line = html(view! {
		<WiredLineChart series=vec![1.0, 3.0, 2.0, 5.0] width=240.0 height=120.0 label="Revenue" />
	});
	assert!(line.contains("aria-label=\"Revenue\""), "{line}");
	assert!(line.contains("viewBox=\"0 0 240 120\""), "{line}");

	let bars = html(view! {
		<WiredBarChart
			bars=vec![("Mon".to_owned(), 4.0), ("Tue".to_owned(), -1.0)]
			width=240.0
			height=140.0
			label="Weekday change"
		/>
	});
	assert!(bars.contains("aria-label=\"Weekday change\""), "{bars}");
	assert!(bars.contains(">Mon<"), "a visible bar label: {bars}");
	assert!(bars.contains(">Tue<"), "a visible bar label: {bars}");
}

#[test]
fn the_same_seed_is_byte_stable() {
	let chart = || {
		view! {
			<WiredCandlestickChart
				candles=candles()
				width=320.0
				height=200.0
				overlays=vec![Overlay::Sma(2), Overlay::Bollinger { period: 2, deviations: 2.0 }]
				show_volume=true
				seed=7
				label="Stable"
			/>
		}
	};
	assert_eq!(html(chart()), html(chart()));
}

#[test]
fn a_different_seed_draws_different_ink() {
	let first = html(view! {
		<WiredCandlestickChart candles=candles() width=320.0 height=200.0 seed=1 />
	});
	let second = html(view! {
		<WiredCandlestickChart candles=candles() width=320.0 height=200.0 seed=2 />
	});
	assert_ne!(first, second);
}
