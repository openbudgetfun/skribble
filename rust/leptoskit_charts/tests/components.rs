//! Behaviour, layout, and semantics of the charts, through leptoskit's real
//! renderer and layout engine.

use std::sync::Arc;
use std::sync::Mutex;
use std::sync::PoisonError;

use leptoskit::native::Element;
use leptoskit::native::Role;
use leptoskit::prelude::*;
use leptoskit_testing::Finder;
use leptoskit_testing::WidgetTester;
use skribble_leptoskit_charts::*;

const PHONE: (f32, f32) = (390.0, 844.0);

fn mount(render: impl FnMut() -> Element + 'static) -> WidgetTester {
	WidgetTester::new(render, PHONE.0, PHONE.1).expect("the screen mounts")
}

fn rising() -> Vec<Candle> {
	vec![
		Candle::new(1, 10.0, 12.0, 9.0, 11.0, 100.0),
		Candle::new(2, 11.0, 14.0, 10.0, 13.0, 140.0),
		Candle::new(3, 13.0, 15.0, 12.0, 14.0, 120.0),
	]
}

fn mixed() -> Vec<Candle> {
	vec![
		Candle::new(1, 10.0, 12.0, 9.0, 11.0, 100.0),
		Candle::new(2, 11.0, 12.0, 9.0, 10.0, 120.0),
	]
}

fn ink_layers(tester: &WidgetTester) -> usize {
	let surface = tester.surface();
	let root = surface.root().expect("a committed root");
	surface.children(root).len()
}

#[test]
fn a_labelled_chart_is_an_image_at_its_size() {
	let tester = mount(|| {
		view! {
			<View class="items-start">
				<WiredCandlestickChart
					candles=rising()
					width=320.0
					height=200.0
					label="Price in US dollars"
				/>
			</View>
		}
	});
	let chart = tester
		.find(&Finder::aria_role(Role::Img, "Price in US dollars"))
		.expect("one chart");
	assert_eq!((chart.frame.width, chart.frame.height), (320.0, 200.0));
}

#[test]
fn an_unlabelled_chart_is_decorative() {
	let tester = mount(|| {
		view! { <WiredCandlestickChart candles=rising() width=200.0 height=120.0 /> }
	});
	let surface = tester.surface();
	let root = surface.root().expect("a committed root");
	assert_eq!(surface.props(root).aria().hidden, Some(true));
}

#[test]
fn a_chart_rebuilds_with_new_data() {
	let data = Arc::new(Mutex::new(rising()));
	let shared = Arc::clone(&data);
	let mut tester = mount(move || {
		let candles = shared
			.lock()
			.unwrap_or_else(PoisonError::into_inner)
			.clone();
		view! { <WiredCandlestickChart candles=candles width=240.0 height=160.0 label="Price" /> }
	});
	let before = ink_layers(&tester);

	*data.lock().unwrap_or_else(PoisonError::into_inner) = mixed();
	tester.pump();
	let after = ink_layers(&tester);
	assert_ne!(before, after, "new data draws new ink");
	tester
		.find(&Finder::aria_role(Role::Img, "Price"))
		.expect("the chart rebuilt");
}

#[test]
fn an_empty_chart_still_reserves_its_size() {
	let tester = mount(|| {
		view! { <WiredCandlestickChart candles=vec![] width=300.0 height=180.0 label="No data" /> }
	});
	let chart = tester
		.find(&Finder::aria_role(Role::Img, "No data"))
		.expect("one chart");
	assert_eq!((chart.frame.width, chart.frame.height), (300.0, 180.0));
}

#[test]
fn one_candle_and_flat_prices_render() {
	for candles in [
		vec![Candle::new(1, 10.0, 12.0, 9.0, 11.0, 1.0)],
		vec![
			Candle::new(1, 10.0, 10.0, 10.0, 10.0, 1.0),
			Candle::new(2, 10.0, 10.0, 10.0, 10.0, 1.0),
		],
	] {
		let tester = mount(move || {
			view! {
				<WiredCandlestickChart
					candles=candles.clone()
					width=200.0
					height=120.0
					label="Flat"
				/>
			}
		});
		tester
			.find(&Finder::aria_role(Role::Img, "Flat"))
			.expect("one chart");
	}
}

#[test]
fn every_series_kind_and_overlay_renders() {
	for kind in [
		SeriesKind::Candles,
		SeriesKind::Ohlc,
		SeriesKind::Line,
		SeriesKind::Area,
	] {
		let tester = mount(move || {
			view! {
				<WiredCandlestickChart
					candles=rising()
					width=260.0
					height=180.0
					kind=kind
					overlays=vec![
						Overlay::Sma(2),
						Overlay::Ema(2),
						Overlay::Bollinger { period: 2, deviations: 2.0 },
					]
					show_volume=true
					label="Everything"
				/>
			}
		});
		tester
			.find(&Finder::aria_role(Role::Img, "Everything"))
			.expect("one chart");
	}
}

#[test]
fn line_and_bar_charts_keep_their_promised_sizes() {
	let tester = mount(|| {
		view! {
			<View class="items-start gap-4">
				<WiredLineChart series=vec![1.0, 3.0, 2.0, 5.0] width=240.0 height=120.0 label="Revenue" />
				<WiredLineChart
					series=vec![(0.0, 1.0), (1.0, 4.0), (2.0, 2.0)]
					width=240.0
					height=120.0
					label="Points"
				/>
				<WiredBarChart
					bars=vec![("Mon".to_owned(), 4.0), ("Tue".to_owned(), -1.0)]
					width=240.0
					height=140.0
					label="Weekday change"
				/>
			</View>
		}
	});
	let line = tester
		.find(&Finder::aria_role(Role::Img, "Revenue"))
		.expect("one line chart");
	assert_eq!((line.frame.width, line.frame.height), (240.0, 120.0));
	let points = tester
		.find(&Finder::aria_role(Role::Img, "Points"))
		.expect("one point chart");
	assert_eq!((points.frame.width, points.frame.height), (240.0, 120.0));
	let bars = tester
		.find(&Finder::aria_role(Role::Img, "Weekday change"))
		.expect("one bar chart");
	assert_eq!(bars.frame.width, 240.0);
	assert!(
		bars.frame.height > 140.0,
		"the label row adds height: {:?}",
		bars.frame
	);
	assert_eq!(
		tester
			.find(&Finder::text("Mon"))
			.expect("a label")
			.props
			.text
			.as_deref(),
		Some("Mon")
	);
}

#[test]
fn tiny_and_large_charts_do_not_overflow() {
	for (width, height) in [(1.0, 1.0), (4000.0, 2400.0)] {
		let tester = mount(move || {
			view! {
				<WiredCandlestickChart
					candles=rising()
					width=width
					height=height
					show_volume=true
					label="Size"
				/>
			}
		});
		let chart = tester
			.find(&Finder::aria_role(Role::Img, "Size"))
			.expect("one chart");
		assert_eq!((chart.frame.width, chart.frame.height), (width, height));
	}
}

#[test]
#[should_panic(expected = "a chart needs a positive, finite size")]
fn a_chart_rejects_a_size_it_cannot_draw_at() {
	let _ = view! {
		<WiredCandlestickChart candles=rising() width=f32::NAN height=120.0 />
	};
}
