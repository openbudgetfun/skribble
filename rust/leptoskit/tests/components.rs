//! Behaviour, layout, and semantics of every component, through leptoskit's
//! real renderer and layout engine.

use std::sync::Arc;
use std::sync::Mutex;
use std::sync::PoisonError;
use std::sync::atomic::AtomicBool;
use std::sync::atomic::AtomicUsize;
use std::sync::atomic::Ordering;

use leptoskit::native::Element;
use leptoskit::native::Role;
use leptoskit::native::Tristate;
use leptoskit::prelude::*;
use leptoskit_testing::Finder;
use leptoskit_testing::Widget;
use leptoskit_testing::WidgetTester;
use skribble_leptoskit::*;

const PHONE: (f32, f32) = (390.0, 844.0);

fn mount(render: impl FnMut() -> Element + 'static) -> WidgetTester {
	WidgetTester::new(render, PHONE.0, PHONE.1).expect("the screen mounts")
}

fn checked(widget: &Widget) -> Option<Tristate> {
	widget.props.aria().checked
}

#[test]
fn a_button_runs_its_action_when_pressed() {
	let presses = Arc::new(AtomicUsize::new(0));
	let counter = Arc::clone(&presses);
	let mut tester = mount(move || {
		let counter = Arc::clone(&counter);
		view! {
			<SkribblePage>
				<WiredButton label="Save" on_press=move || { counter.fetch_add(1, Ordering::SeqCst); } />
			</SkribblePage>
		}
	});

	tester
		.tap(&Finder::aria_role(Role::Button, "Save"))
		.expect("the button is pressable");
	assert_eq!(presses.load(Ordering::SeqCst), 1);
}

#[test]
fn a_disabled_button_cannot_be_pressed() {
	let mut tester = mount(|| {
		view! { <WiredButton label="Save" disabled on_press=|| panic!("disabled buttons ignore presses") /> }
	});
	assert!(
		tester
			.tap(&Finder::aria_role(Role::Button, "Save"))
			.is_err()
	);
}

#[test]
fn buttons_are_easy_to_hit_and_shrink_to_their_label() {
	let tester = mount(|| {
		view! {
			<View class="w-full p-4">
				<WiredButton label="Go" on_press=|| {} />
			</View>
		}
	});
	let button = tester
		.find(&Finder::aria_role(Role::Button, "Go"))
		.expect("one button");
	assert!(button.frame.height >= 44.0, "{:?}", button.frame);
	assert!(button.frame.width < 200.0, "{:?}", button.frame);
}

#[test]
fn ink_covers_its_component_and_is_hidden_from_assistive_technology() {
	let tester = mount(|| {
		view! {
			<View class="w-full p-4">
				<WiredCard seed=3 class="h-40">
					<Text>"Grouped"</Text>
				</WiredCard>
			</View>
		}
	});
	let surface = tester.surface();
	let root = surface.root().expect("a committed root");
	let card = surface.children(root)[0];
	let ink = surface.children(card)[0];
	let card_frame = surface.frame(card).expect("the card is laid out");
	let ink_frame = surface.frame(ink).expect("the ink is laid out");

	// The ink is centred on the card and covers it, less the room the outline
	// leaves for its wobble.
	let right_gap = card_frame.width - ink_frame.x - ink_frame.width;
	let bottom_gap = card_frame.height - ink_frame.y - ink_frame.height;
	assert!(
		(ink_frame.x - right_gap).abs() < 0.01,
		"{ink_frame:?} in {card_frame:?}"
	);
	assert!(
		(ink_frame.y - bottom_gap).abs() < 0.01,
		"{ink_frame:?} in {card_frame:?}"
	);
	assert!(
		ink_frame.width >= card_frame.width * 0.95,
		"{ink_frame:?} in {card_frame:?}"
	);
	assert!(
		ink_frame.height >= card_frame.height * 0.95,
		"{ink_frame:?} in {card_frame:?}"
	);
	assert_eq!(surface.props(ink).aria().hidden, Some(true));
}

#[test]
fn content_keeps_its_distance_from_the_ink() {
	let tester = mount(|| {
		view! {
			<View class="w-full p-4">
				<WiredBox>
					<Text>"Breathing room"</Text>
				</WiredBox>
			</View>
		}
	});
	let text = tester
		.find(&Finder::text("Breathing room"))
		.expect("the content");
	// The box starts at 16 from the padding; content starts 12 and 8 inside.
	assert_eq!((text.frame.x, text.frame.y), (28.0, 24.0));
}

#[test]
fn a_checkbox_proposes_the_opposite_state_and_shows_a_tick() {
	let state = Arc::new(AtomicBool::new(false));
	let shared = Arc::clone(&state);
	let mut tester = mount(move || {
		let update = Arc::clone(&shared);
		let on = shared.load(Ordering::SeqCst);
		view! {
			<WiredCheckbox
				label="Email me"
				checked=on
				on_toggle=move |next: bool| update.store(next, Ordering::SeqCst)
			/>
		}
	});
	let finder = Finder::aria_role(Role::Checkbox, "Email me");
	assert_eq!(
		checked(&tester.find(&finder).expect("one checkbox")),
		Some(Tristate::False)
	);
	let ticks_before = tester.find_all(&Finder::text("✓")).len();

	tester.tap(&finder).expect("the checkbox is pressable");
	assert!(state.load(Ordering::SeqCst));
	assert_eq!(
		checked(&tester.find(&finder).expect("one checkbox")),
		Some(Tristate::True)
	);
	if cfg!(not(feature = "web")) {
		// Native draws the tick as a glyph; the web draws it as ink.
		assert_eq!(tester.find_all(&Finder::text("✓")).len(), ticks_before + 1);
	}
}

#[test]
fn radios_report_selection_and_select_on_press() {
	let selected = Arc::new(Mutex::new("Pencil"));
	let shared = Arc::clone(&selected);
	let mut tester = mount(move || {
		let current = *shared.lock().unwrap_or_else(PoisonError::into_inner);
		let options = ["Pencil", "Brush"].map(|name| {
			let choose = Arc::clone(&shared);
			view! {
				<WiredRadio
					label=name
					selected=current == name
					on_select=move || *choose.lock().unwrap_or_else(PoisonError::into_inner) = name
				/>
			}
		});
		View().children(options)
	});

	let brush = Finder::aria_role(Role::Radio, "Brush");
	assert_eq!(
		checked(&tester.find(&brush).expect("one radio")),
		Some(Tristate::False)
	);
	tester.tap(&brush).expect("the radio is pressable");
	assert_eq!(
		*selected.lock().unwrap_or_else(PoisonError::into_inner),
		"Brush"
	);
	assert_eq!(
		checked(&tester.find(&brush).expect("one radio")),
		Some(Tristate::True)
	);
}

#[test]
fn a_switch_toggles_and_slides_its_knob() {
	let state = Arc::new(AtomicBool::new(false));
	let shared = Arc::clone(&state);
	let mut tester = mount(move || {
		let update = Arc::clone(&shared);
		view! {
			<WiredSwitch
				label="Dark paper"
				on=shared.load(Ordering::SeqCst)
				on_toggle=move |next: bool| update.store(next, Ordering::SeqCst)
			/>
		}
	});
	let knob_x = |tester: &WidgetTester| {
		let surface = tester.surface();
		let row = surface.root().expect("a committed root");
		let track = surface.children(row)[0];
		let knob = surface.children(track)[1];
		surface.frame(knob).expect("the knob is laid out").x
	};
	let off = knob_x(&tester);

	let finder = Finder::aria_role(Role::Switch, "Dark paper");
	tester.tap(&finder).expect("the switch is pressable");
	assert!(state.load(Ordering::SeqCst));
	assert_eq!(
		checked(&tester.find(&finder).expect("one switch")),
		Some(Tristate::True)
	);
	assert!(knob_x(&tester) > off);
}

#[test]
fn an_input_proposes_typed_text() {
	let text = Arc::new(Mutex::new(String::from("Ada")));
	let shared = Arc::clone(&text);
	let mut tester = mount(move || {
		let update = Arc::clone(&shared);
		let value = shared
			.lock()
			.unwrap_or_else(PoisonError::into_inner)
			.clone();
		view! {
			<WiredInput
				label="Name"
				value=value
				placeholder="Your name"
				on_change=move |next: &str| *update.lock().unwrap_or_else(PoisonError::into_inner) = next.to_owned()
			/>
		}
	});

	tester
		.enter_text(&Finder::label("Name"), "Grace")
		.expect("the field takes text");
	assert_eq!(
		*text.lock().unwrap_or_else(PoisonError::into_inner),
		"Grace"
	);
	assert_eq!(
		tester
			.find(&Finder::label("Name"))
			.expect("one field")
			.props
			.value
			.as_deref(),
		Some("Grace")
	);
}

#[test]
fn secret_inputs_mask_their_text() {
	let tester = mount(|| {
		view! { <WiredInput label="Password" value="hunter2" secret on_change=|_: &str| {} /> }
	});
	let field = tester.find(&Finder::label("Password")).expect("one field");
	assert_eq!(field.kind, NativeKind::PasswordInput);
}

#[test]
fn progress_reports_its_value_and_fills_that_share_of_the_track() {
	let tester = mount(|| {
		view! {
			<View class="w-[300px]">
				<WiredProgress label="Uploading" value=0.4 />
			</View>
		}
	});
	let bar = tester
		.find(&Finder::aria_role(Role::ProgressBar, "Uploading"))
		.expect("one progress bar");
	assert_eq!(bar.props.aria().value_now, Some(40.0));

	let surface = tester.surface();
	let root = surface.root().expect("a committed root");
	let track = surface.children(root)[0];
	let filling = surface.children(track)[0];
	let track_width = surface.frame(track).expect("laid out").width;
	let filled_width = surface.frame(filling).expect("laid out").width;
	assert!((filled_width - track_width * 0.4).abs() < 0.5);
}

#[test]
fn progress_clamps_values_outside_zero_to_one() {
	for (value, expected) in [(-1.0, 0.0), (2.5, 100.0), (f64::NAN, 0.0)] {
		let tester = mount(move || view! { <WiredProgress label="Done" value=value /> });
		let bar = tester
			.find(&Finder::aria_role(Role::ProgressBar, "Done"))
			.expect("one progress bar");
		assert_eq!(bar.props.aria().value_now, Some(expected), "{value}");
	}
}

#[test]
fn dividers_are_separators() {
	let tester = mount(|| view! { <View class="w-full"><WiredDivider /></View> });
	let surface = tester.surface();
	let root = surface.root().expect("a committed root");
	let divider = surface.children(root)[0];
	assert_eq!(surface.props(divider).aria().role, Some(Role::Separator));
	let frame = surface.frame(divider).expect("laid out");
	assert_eq!(frame.width, PHONE.0);
	assert_eq!(frame.height, 12.0);
}

#[test]
fn highlights_keep_their_text_readable() {
	for kind in [
		HighlightKind::Underline,
		HighlightKind::Circle,
		HighlightKind::Marker,
		HighlightKind::Strikethrough,
		HighlightKind::Box,
	] {
		let tester = mount(move || {
			view! {
				<WiredHighlight kind=kind>
					<Text>"marked"</Text>
				</WiredHighlight>
			}
		});
		tester
			.find(&Finder::text("marked"))
			.unwrap_or_else(|error| panic!("{kind:?}: {error}"));
	}
}

#[test]
fn a_labelled_sketch_is_an_image_at_its_size() {
	let tester = mount(|| {
		view! {
			<View class="items-start">
				<Sketch
					width=120.0
					height=60.0
					shapes=vec![Shape::line((4.0, 30.0), (116.0, 30.0)).with_arrowhead()]
					label="An arrow"
				/>
			</View>
		}
	});
	let sketch = tester
		.find(&Finder::aria_role(Role::Img, "An arrow"))
		.expect("one image");
	assert_eq!((sketch.frame.width, sketch.frame.height), (120.0, 60.0));
}

#[test]
fn an_unlabelled_sketch_is_decorative() {
	let tester = mount(|| {
		view! { <Sketch width=40.0 height=40.0 shapes=vec![Shape::ellipse(20.0, 20.0, 32.0, 32.0)] /> }
	});
	let surface = tester.surface();
	let sketch = surface.root().expect("a committed root");
	assert_eq!(surface.props(sketch).aria().hidden, Some(true));
}

#[test]
#[should_panic(expected = "a curve needs at least two points")]
fn a_sketch_rejects_a_curve_without_two_points() {
	let _ = view! {
		<Sketch width=40.0 height=40.0 shapes=vec![Shape::curve([(1.0, 1.0)])] />
	};
}

#[test]
fn every_component_builds_a_valid_tree() {
	let screen = view! {
		<SkribblePage class="gap-4 p-4">
			<WiredBox fill_style=FillStyle::Hachure><Text>"Box"</Text></WiredBox>
			<WiredCard fill_style=FillStyle::Dots><Text>"Card"</Text></WiredCard>
			<WiredCircle class="size-16"><Text>"1"</Text></WiredCircle>
			<WiredBadge><Text>"New"</Text></WiredBadge>
			<WiredButton label="Primary" on_press=|| {} />
			<WiredButton label="Secondary" variant=ButtonVariant::Secondary on_press=|| {} />
			<WiredInput label="Name" value="" on_change=|_: &str| {} />
			<WiredCheckbox label="Check" checked=true on_toggle=|_: bool| {} />
			<WiredRadio label="Radio" selected=true on_select=|| {} />
			<WiredSwitch label="Switch" on=true on_toggle=|_: bool| {} />
			<WiredProgress label="Progress" value=0.5 />
			<WiredHighlight><Text>"Highlight"</Text></WiredHighlight>
			<WiredDivider />
			<Sketch width=20.0 height=20.0 shapes=vec![Shape::rectangle(2.0, 2.0, 16.0, 16.0)] />
		</SkribblePage>
	};
	screen
		.validate()
		.expect("every component builds a valid tree");
}

#[test]
fn any_seed_draws_without_overflowing() {
	for seed in [i64::MIN, -1, 0, i64::MAX] {
		let screen = view! {
			<View>
				<WiredCheckbox label="Check" checked=true seed=seed on_toggle=|_: bool| {} />
				<WiredRadio label="Radio" selected=true seed=seed on_select=|| {} />
				<WiredSwitch label="Switch" on=true seed=seed on_toggle=|_: bool| {} />
				<WiredProgress label="Progress" value=0.5 seed=seed />
				<Sketch width=20.0 height=20.0 seed=seed shapes=vec![Shape::ellipse(10.0, 10.0, 16.0, 16.0)] />
			</View>
		};
		screen.validate().expect("every seed builds a valid tree");
	}
}

#[test]
fn empty_progress_draws_only_its_track() {
	let tester = mount(|| view! { <WiredProgress label="Waiting" value=0.0 /> });
	let surface = tester.surface();
	let bar = surface.root().expect("a committed root");
	assert_eq!(surface.children(bar).len(), 1);
}

#[test]
#[should_panic(expected = "a sketch needs a positive, finite size")]
fn a_sketch_rejects_a_size_it_cannot_draw_at() {
	let _ = view! { <Sketch width=f32::NAN height=40.0 shapes=vec![Shape::circle(20.0, 20.0, 30.0)] /> };
}
