//! The hand-drawn button.

use leptoskit::native::Element;
use leptoskit::prelude::*;
use skribble_rough::FillStyle;

use crate::Theme;
use crate::container::with_class;
use crate::ink::Canvas;
use crate::ink::Ink;
use crate::ink::InkShape;
use crate::theme::tone_class;

const BUTTON_CANVAS: Canvas = Canvas::new(160.0, 48.0).inset(2.5);

/// How much a button stands out.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Default)]
pub enum ButtonVariant {
	/// Filled with the accent: the one action a screen is about.
	#[default]
	Primary,
	/// An outline only, for every other action.
	Secondary,
}

/// A button drawn by hand: a rough rectangle around its label, filled with
/// the accent when it is the primary action.
///
/// It is a real button on every platform, named by its label, and at least
/// 44 pixels tall so it is easy to hit; larger text makes it taller.
///
/// ```
/// use leptoskit::prelude::*;
/// use skribble_leptoskit::ButtonVariant;
/// use skribble_leptoskit::WiredButton;
///
/// let actions = view! {
/// 	<View class="flex-row gap-3">
/// 		<WiredButton label="Save" on_press=|| println!("saved") />
/// 		<WiredButton label="Cancel" seed=2 variant=ButtonVariant::Secondary on_press=|| {} />
/// 	</View>
/// };
/// assert_eq!(actions.children.len(), 2);
/// ```
#[component]
pub fn WiredButton(
	/// The visible label, which also names the button for assistive
	/// technology.
	#[prop(into)]
	label: String,
	/// Runs when the button is activated by pointer, touch, or keyboard.
	on_press: impl Fn() + Send + Sync + 'static,
	/// Filled with the accent, or an outline only.
	#[prop(optional)]
	variant: ButtonVariant,
	/// Shows the button but ignores activation.
	#[prop(optional)]
	disabled: bool,
	/// Chooses the wobble. The same seed always draws the same border; give
	/// neighbouring buttons different seeds.
	#[prop(default = 1)]
	seed: i64,
	/// The colours to draw with.
	#[prop(default = Theme::SKRIBBLE)]
	theme: Theme,
	/// Extra Tailwind classes, such as `w-full`.
	#[prop(optional, into)]
	class: Option<String>,
) -> Element {
	let (fill_style, text) = match variant {
		ButtonVariant::Primary => (FillStyle::Solid, theme.on_accent()),
		ButtonVariant::Secondary => (FillStyle::None, theme.ink()),
	};
	let ink = Ink::outline(InkShape::Rectangle, BUTTON_CANVAS, seed, theme)
		.filled(fill_style, theme.accent());

	let button = Pressable(label.clone())
		.class("self-start items-center justify-center min-h-11 px-5 py-2")
		.class(tone_class("text", text))
		.enabled(!disabled)
		.child(ink.layer())
		.child(Text(label).class("text-[17px] font-semibold text-center"))
		.on_press(on_press);
	let button = if disabled {
		button.class("opacity-50")
	} else {
		button
	};
	with_class(button, class)
}
