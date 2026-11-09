//! Behaviour, layout, and semantics of the hand-drawn map, through
//! leptoskit's real renderer and layout engine.

use std::sync::Arc;
use std::sync::Mutex;
use std::sync::PoisonError;
use std::sync::atomic::AtomicUsize;
use std::sync::atomic::Ordering;

use leptoskit::native::Element;
use leptoskit::native::Role;
use leptoskit::prelude::*;
use leptoskit_testing::Finder;
use leptoskit_testing::WidgetTester;
// leptoskit grew a `Camera` widget of its own, so the glob alone would leave
// the name ambiguous; the explicit import keeps this crate's projection type.
use skribble_leptoskit_maps::Camera;
use skribble_leptoskit_maps::*;

const SCREEN: (f32, f32) = (390.0, 844.0);

fn mount(render: impl FnMut() -> Element + 'static) -> WidgetTester {
	WidgetTester::new(render, SCREEN.0, SCREEN.1).expect("the screen mounts")
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

#[test]
fn a_map_renders_with_its_name_and_its_own_size() {
	let tester = mount(|| {
		view! {
			<WiredMap
				camera=camera()
				width=320.0
				height=200.0
				features=vec![park()]
				pins=vec![MapPin::new(london(), "You are here")]
				label="A sketch map"
			/>
		}
	});
	let map = tester
		.find(&Finder::aria_role(Role::Img, "A sketch map"))
		.expect("one map");
	assert_eq!((map.frame.width, map.frame.height), (320.0, 200.0));
}

#[test]
fn a_map_without_a_label_has_no_image_role() {
	let tester = mount(|| view! { <WiredMap camera=camera() width=320.0 height=200.0 /> });
	let surface = tester.surface();
	let map = surface.root().expect("a committed root");
	let aria = surface.props(map).aria();
	assert_eq!(aria.role, None);
	assert_eq!(aria.hidden, None);
}

#[test]
fn a_pressable_pin_is_a_button_that_fires_its_callback() {
	let presses = Arc::new(AtomicUsize::new(0));
	let counter = Arc::clone(&presses);
	let mut tester = mount(move || {
		let counter = Arc::clone(&counter);
		view! {
			<WiredMap
				camera=camera()
				width=320.0
				height=200.0
				pins=vec![
					MapPin::new(london(), "Favourite cafe")
						.with_category(PinCategory::Coffee)
						.with_on_press(move || {
							counter.fetch_add(1, Ordering::SeqCst);
						}),
				]
			/>
		}
	});

	tester
		.tap(&Finder::aria_role(Role::Button, "Favourite cafe"))
		.expect("the pin is pressable");
	assert_eq!(presses.load(Ordering::SeqCst), 1);
}

#[test]
fn a_pin_shows_its_short_label() {
	let tester = mount(|| {
		view! {
			<WiredMap
				camera=camera()
				width=320.0
				height=200.0
				pins=vec![MapPin::new(london(), "Market stall")]
			/>
		}
	});
	let label = tester
		.find(&Finder::text("Market stall"))
		.expect("the label");
	let pin = tester
		.find(&Finder::aria_role(Role::Img, "Market stall"))
		.expect("the pin");
	// The label sits under the pin's tip, not over its head.
	assert!(label.frame.y > pin.frame.y + pin.frame.height - 1.0);
}

#[test]
fn zoom_controls_propose_a_closer_and_further_zoom() {
	let zoom = Arc::new(Mutex::new(4.0_f64));
	let shared = Arc::clone(&zoom);
	let mut tester = mount(move || {
		let current = *shared.lock().unwrap_or_else(PoisonError::into_inner);
		let update = Arc::clone(&shared);
		view! {
			<View>
				<WiredMapZoomControls
					zoom=current
					on_zoom=move |next: f64| {
						*update.lock().unwrap_or_else(PoisonError::into_inner) = next;
					}
				/>
			</View>
		}
	});

	tester
		.tap(&Finder::aria_role(Role::Button, "Zoom in"))
		.expect("the closer button is pressable");
	assert_eq!(*zoom.lock().unwrap_or_else(PoisonError::into_inner), 5.0);

	tester
		.tap(&Finder::aria_role(Role::Button, "Zoom out"))
		.expect("the further button is pressable");
	assert_eq!(*zoom.lock().unwrap_or_else(PoisonError::into_inner), 4.0);
}

#[test]
fn a_new_camera_rebuilds_the_pins() {
	let state = Arc::new(Mutex::new(camera()));
	let shared = Arc::clone(&state);
	let mut tester = mount(move || {
		let camera = *shared.lock().unwrap_or_else(PoisonError::into_inner);
		let update = Arc::clone(&shared);
		view! {
			<View>
				<WiredMap
					camera=camera
					width=320.0
					height=200.0
					pins=vec![MapPin::new(LatLng::new(51.5090, -0.1250), "Corner shop")]
				/>
				<WiredMapZoomControls
					zoom=camera.zoom
					on_zoom=move |next: f64| {
						update.lock().unwrap_or_else(PoisonError::into_inner).zoom = next;
					}
				/>
			</View>
		}
	});
	let finder = Finder::aria_role(Role::Img, "Corner shop");
	let before = tester.find(&finder).expect("the pin").frame;
	tester
		.tap(&Finder::aria_role(Role::Button, "Zoom in"))
		.expect("the closer button is pressable");
	let after = tester.find(&finder).expect("the pin").frame;
	assert_ne!(before.x, after.x, "{before:?}");
	assert!(after.x > before.x, "{before:?} to {after:?}");
}

#[test]
fn zoom_controls_stop_at_the_camera_limits() {
	let zoom = Arc::new(Mutex::new(MIN_ZOOM));
	let shared = Arc::clone(&zoom);
	let mut tester = mount(move || {
		let current = *shared.lock().unwrap_or_else(PoisonError::into_inner);
		let update = Arc::clone(&shared);
		view! {
			<View>
				<WiredMapZoomControls
					zoom=current
					on_zoom=move |next: f64| {
						*update.lock().unwrap_or_else(PoisonError::into_inner) = next;
					}
				/>
			</View>
		}
	});
	tester
		.tap(&Finder::aria_role(Role::Button, "Zoom out"))
		.expect("the further button is pressable");
	assert_eq!(
		*zoom.lock().unwrap_or_else(PoisonError::into_inner),
		MIN_ZOOM
	);
}

#[test]
fn a_map_with_no_features_or_pins_still_draws() {
	let tester = mount(|| {
		view! {
			<WiredMap camera=camera() width=200.0 height=120.0 label="Empty map" />
		}
	});
	tester
		.find(&Finder::aria_role(Role::Img, "Empty map"))
		.expect("one map");
}

#[test]
fn features_at_the_poles_and_across_the_antimeridian_build() {
	let screen = view! {
		<View>
			<WiredMap
				camera=Camera::new(LatLng::new(0.0, 180.0), 3.0)
				width=320.0
				height=200.0
				features=vec![
					MapFeature::area(vec![
						LatLng::new(10.0, 179.0),
						LatLng::new(10.0, -179.0),
						LatLng::new(-10.0, 180.0),
					]),
					MapFeature::route(vec![
						LatLng::new(90.0, 179.0),
						LatLng::new(-90.0, -179.0),
					]),
					MapFeature::point(LatLng::new(90.0, 0.0)),
				]
			/>
			<WiredMap
				camera=Camera::new(london(), 13.0)
				width=320.0
				height=200.0
				features=vec![MapFeature::area(vec![london(), london(), london()])]
			/>
		</View>
	};
	screen
		.validate()
		.expect("every feature builds a valid tree");
}

#[test]
fn every_seed_draws_without_overflowing() {
	for seed in [i64::MIN, -1, 0, i64::MAX] {
		let screen = view! {
			<View>
				<WiredMap
					camera=camera()
					width=320.0
					height=200.0
					seed=seed
					features=vec![park()]
					pins=vec![MapPin::new(london(), "Pin")]
				/>
				<WiredMapZoomControls zoom=3.0 seed=seed on_zoom=|_: f64| {} />
			</View>
		};
		screen.validate().expect("every seed builds a valid tree");
	}
}

#[test]
fn plain_and_dark_paper_change_the_background() {
	let plain = view! {
		<WiredMap
			camera=camera()
			width=200.0
			height=120.0
			background=MapStyle::PLAIN
			label="Plain map"
		/>
	};
	let dark = view! {
		<WiredMap
			camera=camera()
			width=200.0
			height=120.0
			background=MapStyle::DARK
			label="Dark map"
		/>
	};
	plain.validate().expect("plain paper");
	dark.validate().expect("dark paper");
}

#[test]
#[should_panic(expected = "a map needs a positive, finite size")]
fn a_map_rejects_a_size_it_cannot_draw_at() {
	let _ = view! { <WiredMap camera=camera() width=f32::NAN height=200.0 /> };
}

#[test]
#[should_panic(expected = "zoom controls need a finite zoom and a positive step")]
fn zoom_controls_reject_a_non_positive_step() {
	let _ = view! { <WiredMapZoomControls zoom=3.0 step=0.0 on_zoom=|_: f64| {} /> };
}
