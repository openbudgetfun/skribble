//! The hand-drawn rule between sections.

use leptoskit::native::Element;
use leptoskit::native::Orientation;
use leptoskit::native::Role;
use leptoskit::prelude::*;

use crate::Theme;
use crate::container::with_class;
use crate::ink::Canvas;
use crate::ink::Ink;
use crate::ink::InkShape;

const DIVIDER_CANVAS: Canvas = Canvas::new(600.0, 12.0).inset(2.0);

/// A rough horizontal rule that separates sections.
///
/// It stretches across its parent and is a separator for assistive
/// technology.
///
/// ```
/// use leptoskit::prelude::*;
/// use skribble_leptoskit::WiredDivider;
///
/// let section = view! {
/// 	<View class="gap-4">
/// 		<Text>"Above"</Text>
/// 		<WiredDivider seed=3 />
/// 		<Text>"Below"</Text>
/// 	</View>
/// };
/// assert_eq!(section.children.len(), 3);
/// ```
#[component]
pub fn WiredDivider(
	/// Chooses the wobble. The same seed always draws the same line.
	#[prop(default = 1)]
	seed: i64,
	/// The colours to draw with.
	#[prop(default = Theme::SKRIBBLE)]
	theme: Theme,
	/// Extra Tailwind classes, such as vertical margins.
	#[prop(optional, into)]
	class: Option<String>,
) -> Element {
	let ink = Ink::outline(InkShape::Rule, DIVIDER_CANVAS, seed, theme);
	let divider = View()
		.role(Role::Separator)
		.aria_orientation(Orientation::Horizontal)
		.class("w-full h-3")
		.child(ink.layer());
	with_class(divider, class)
}
