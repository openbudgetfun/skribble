//! The hand-drawn text field.

use leptoskit::native::Element;
use leptoskit::prelude::*;

use crate::Theme;
use crate::container::with_class;
use crate::ink::Canvas;
use crate::ink::Ink;
use crate::ink::InkShape;
use crate::theme::tone_class;

const INPUT_CANVAS: Canvas = Canvas::new(280.0, 44.0).inset(2.5);

/// A single-line text field inside a hand-drawn box.
///
/// The field is the platform's own, so typing, selection, and keyboards work
/// as users expect; only its frame is drawn. Like every leptoskit control,
/// it shows `value` and proposes changes through `on_change`: keep the text
/// in your state and rebuild with it.
///
/// ```
/// use leptoskit::prelude::*;
/// use skribble_leptoskit::WiredInput;
///
/// let field = view! {
/// 	<WiredInput label="Name" value="Ada" placeholder="Your name" on_change=|name: &str| println!("{name}") />
/// };
/// assert_eq!(field.children.len(), 2);
/// ```
#[component]
pub fn WiredInput(
	/// Names the field for assistive technology.
	#[prop(into)]
	label: String,
	/// The text the field shows.
	#[prop(into)]
	value: String,
	/// Receives each proposed new text.
	on_change: impl Fn(&str) + Send + Sync + 'static,
	/// Hint text shown while the field is empty.
	#[prop(optional, into)]
	placeholder: Option<String>,
	/// Masks the text, for passwords.
	#[prop(optional)]
	secret: bool,
	/// Chooses the wobble. The same seed always draws the same frame.
	#[prop(default = 1)]
	seed: i64,
	/// The colours to draw with.
	#[prop(default = Theme::SKRIBBLE)]
	theme: Theme,
	/// Extra Tailwind classes for the frame, such as a width.
	#[prop(optional, into)]
	class: Option<String>,
) -> Element {
	let ink = Ink::outline(InkShape::Rectangle, INPUT_CANVAS, seed, theme);
	let field = if secret { PasswordInput() } else { TextInput() };
	// A transparent background replaces the platform's own frame, so only the
	// drawn one shows.
	let field = field
		.class("w-full border-0 bg-[#00000000] text-base")
		.class(tone_class("text", theme.ink()))
		.aria_label(label)
		.value(value)
		.on_change(on_change);
	let field = match placeholder {
		Some(placeholder) => field.placeholder(placeholder),
		None => field,
	};

	let frame = View()
		.class("justify-center min-h-11 px-3 py-2")
		.child(ink.layer())
		.child(field);
	with_class(frame, class)
}
