//! Hand-drawn checkboxes, radio buttons, and switches.
//!
//! Each is one accessible control containing its drawing and its label, so
//! the whole row responds to a press and assistive technology announces the
//! label with the state.

use leptoskit::native::Element;
use leptoskit::native::Role;
use leptoskit::prelude::*;
use skribble_rough::FillStyle;

use crate::Theme;
use crate::container::with_class;
use crate::ink::Canvas;
use crate::ink::Ink;
use crate::ink::InkShape;
use crate::theme::tone_class;

const MARK_CANVAS: Canvas = Canvas::new(24.0, 24.0).inset(2.5).gap(4.0);
const DOT_CANVAS: Canvas = Canvas::new(24.0, 24.0).inset(7.0);
const TRACK_CANVAS: Canvas = Canvas::new(52.0, 28.0).inset(2.5).gap(5.0);
const KNOB_CANVAS: Canvas = Canvas::new(20.0, 20.0).inset(2.0);

/// The shared row: an accessible control with `role` and `checked`, its
/// drawing, then its label.
fn toggle_row(
	label: String,
	role: Role,
	checked: bool,
	disabled: bool,
	drawing: Element,
	theme: Theme,
	on_press: impl Fn() + Send + Sync + 'static,
) -> Element {
	let row = Pressable(label.clone())
		.role(role)
		.aria_checked(checked)
		.enabled(!disabled)
		.class("self-start flex-row items-center gap-3 min-h-11")
		.class(tone_class("text", theme.ink()))
		.child(drawing)
		.child(Text(label).class("text-base"))
		.on_press(on_press);
	if disabled {
		row.class("opacity-50")
	} else {
		row
	}
}

/// A checkbox drawn by hand: a rough square that gets a tick.
///
/// Like every leptoskit control it shows `checked` and proposes the opposite
/// through `on_toggle`; keep the value in your state and rebuild with it.
///
/// ```
/// use leptoskit::prelude::*;
/// use skribble_leptoskit::WiredCheckbox;
///
/// let row = view! {
/// 	<WiredCheckbox label="Email me updates" checked=true on_toggle=|on: bool| println!("{on}") />
/// };
/// assert_eq!(row.text_content(), "Email me updates");
/// ```
#[component]
pub fn WiredCheckbox(
	/// The visible label, which also names the checkbox.
	#[prop(into)]
	label: String,
	/// Whether the box is ticked.
	checked: bool,
	/// Receives the proposed new state.
	on_toggle: impl Fn(bool) + Send + Sync + 'static,
	/// Shows the checkbox but ignores presses.
	#[prop(optional)]
	disabled: bool,
	/// Chooses the wobble. The same seed always draws the same box and tick.
	#[prop(default = 1)]
	seed: i64,
	/// The colours to draw with.
	#[prop(default = Theme::SKRIBBLE)]
	theme: Theme,
	/// Extra Tailwind classes for the row.
	#[prop(optional, into)]
	class: Option<String>,
) -> Element {
	let square = Ink::outline(InkShape::Rectangle, MARK_CANVAS, seed, theme);
	let tick = Ink::outline(InkShape::Check, MARK_CANVAS, seed.wrapping_add(1), theme);
	let drawing = View()
		.class("w-6 h-6")
		.child(square.layer())
		.children(checked.then(|| tick.layer()));
	let row = toggle_row(
		label,
		Role::Checkbox,
		checked,
		disabled,
		drawing,
		theme,
		move || on_toggle(!checked),
	);
	with_class(row, class)
}

/// A radio button drawn by hand: a rough circle that gets a dot.
///
/// Render one per option, select at most one, and group the options in a
/// view with the radio group role and a name, so assistive technology
/// announces them as one set. `on_select` runs when this option is chosen.
///
/// ```
/// use leptoskit::native::Role;
/// use leptoskit::prelude::*;
/// use skribble_leptoskit::WiredRadio;
///
/// let options = view! {
/// 	<View role=Role::RadioGroup aria_label="Tool" class="gap-2">
/// 		<WiredRadio label="Pencil" selected=true on_select=|| {} />
/// 		<WiredRadio label="Brush" seed=2 selected=false on_select=|| {} />
/// 	</View>
/// };
/// assert_eq!(options.children.len(), 2);
/// ```
#[component]
pub fn WiredRadio(
	/// The visible label, which also names the option.
	#[prop(into)]
	label: String,
	/// Whether this option is the selected one.
	selected: bool,
	/// Runs when this option is chosen.
	on_select: impl Fn() + Send + Sync + 'static,
	/// Shows the option but ignores presses.
	#[prop(optional)]
	disabled: bool,
	/// Chooses the wobble. The same seed always draws the same circle.
	#[prop(default = 1)]
	seed: i64,
	/// The colours to draw with.
	#[prop(default = Theme::SKRIBBLE)]
	theme: Theme,
	/// Extra Tailwind classes for the row.
	#[prop(optional, into)]
	class: Option<String>,
) -> Element {
	let ring = Ink::outline(InkShape::Ellipse, MARK_CANVAS, seed, theme);
	let dot = Ink::outline(InkShape::Ellipse, DOT_CANVAS, seed.wrapping_add(1), theme)
		.without_outline()
		.filled(FillStyle::Solid, theme.ink());
	let drawing = View()
		.class("w-6 h-6")
		.child(ring.layer())
		.children(selected.then(|| dot.layer()));
	let row = toggle_row(
		label,
		Role::Radio,
		selected,
		disabled,
		drawing,
		theme,
		on_select,
	);
	with_class(row, class)
}

/// A switch drawn by hand: a rough capsule that fills with the accent, and a
/// knob that slides to the end.
///
/// ```
/// use leptoskit::prelude::*;
/// use skribble_leptoskit::WiredSwitch;
///
/// let row = view! {
/// 	<WiredSwitch label="Dark paper" on=false on_toggle=|on: bool| println!("{on}") />
/// };
/// assert_eq!(row.text_content(), "Dark paper");
/// ```
#[component]
pub fn WiredSwitch(
	/// The visible label, which also names the switch.
	#[prop(into)]
	label: String,
	/// Whether the switch is on.
	on: bool,
	/// Receives the proposed new state.
	on_toggle: impl Fn(bool) + Send + Sync + 'static,
	/// Shows the switch but ignores presses.
	#[prop(optional)]
	disabled: bool,
	/// Chooses the wobble. The same seed always draws the same track and knob.
	#[prop(default = 1)]
	seed: i64,
	/// The colours to draw with.
	#[prop(default = Theme::SKRIBBLE)]
	theme: Theme,
	/// Extra Tailwind classes for the row.
	#[prop(optional, into)]
	class: Option<String>,
) -> Element {
	let track_fill = if on {
		FillStyle::Solid
	} else {
		FillStyle::None
	};
	let track = Ink::outline(InkShape::Capsule, TRACK_CANVAS, seed, theme)
		.filled(track_fill, theme.accent());
	let knob = Ink::outline(InkShape::Ellipse, KNOB_CANVAS, seed.wrapping_add(1), theme)
		.filled(FillStyle::Solid, theme.paper());
	let knob_position = if on { "left-[28px]" } else { "left-[4px]" };
	let drawing = View().class("w-[52px] h-7").child(track.layer()).child(
		View()
			.class("absolute top-[4px] w-5 h-5")
			.class(knob_position)
			.child(knob.layer()),
	);
	let row = toggle_row(
		label,
		Role::Switch,
		on,
		disabled,
		drawing,
		theme,
		move || on_toggle(!on),
	);
	with_class(row, class)
}
