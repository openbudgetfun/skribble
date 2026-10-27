//! Hand-drawn containers: boxes, cards, circles, badges, and the page.

use leptoskit::native::Element;
use leptoskit::prelude::*;
use skribble_rough::FillStyle;

use crate::Theme;
use crate::Tone;
use crate::ink::Canvas;
use crate::ink::Ink;
use crate::ink::InkShape;
use crate::theme::tone_class;

const BOX_CANVAS: Canvas = Canvas::new(240.0, 120.0);
const CARD_CANVAS: Canvas = Canvas::new(320.0, 200.0).gap(10.0);
const CIRCLE_CANVAS: Canvas = Canvas::new(120.0, 120.0).inset(4.0);
const BADGE_CANVAS: Canvas = Canvas::new(96.0, 32.0).inset(2.5).gap(5.0);

/// A column with `ink` behind `children`. Text is in the theme's ink, or in its
/// on-accent colour over a solid fill.
pub(crate) fn inked(ink: Ink, layout: &str, class: Option<String>, children: Children) -> Element {
	let solid = ink.fill.is_some_and(|fill| fill.style == FillStyle::Solid);
	let text = if solid {
		ink.theme.on_accent()
	} else {
		ink.theme.ink()
	};
	let element = View()
		.class(layout)
		.class(tone_class("text", text))
		.child(ink.layer())
		.children(children);
	with_class(element, class)
}

/// `element` with the caller's extra classes, when there are any.
pub(crate) fn with_class(element: Element, class: Option<String>) -> Element {
	match class {
		Some(class) => element.class(class),
		None => element,
	}
}

/// The root of a skribble screen: the theme's paper behind everything, and
/// its ink as the default text colour.
///
/// ```
/// use leptoskit::prelude::*;
/// use skribble_leptoskit::SkribblePage;
///
/// let page = view! {
/// 	<SkribblePage class="gap-6 p-6">
/// 		<Text class="text-2xl font-bold">"Sketchbook"</Text>
/// 	</SkribblePage>
/// };
/// assert_eq!(page.text_content(), "Sketchbook");
/// ```
#[component]
pub fn SkribblePage(
	/// The colours to draw with.
	#[prop(default = Theme::SKRIBBLE)]
	theme: Theme,
	/// Extra Tailwind classes, such as padding and gaps.
	#[prop(optional, into)]
	class: Option<String>,
	/// The screen's content.
	children: Children,
) -> Element {
	let page = View()
		.class("w-full min-h-full")
		.class(tone_class("bg", theme.paper()))
		.class(tone_class("text", theme.ink()))
		.children(children);
	with_class(page, class)
}

/// Wraps content in a hand-drawn rectangle, optionally filled with a
/// sketched pattern.
///
/// The border stretches with the box, so the box can be any size. Content
/// keeps 12 pixels from the ink at the sides and 8 above and below.
///
/// ```
/// use leptoskit::prelude::*;
/// use skribble_leptoskit::FillStyle;
/// use skribble_leptoskit::WiredBox;
///
/// let tier = view! {
/// 	<WiredBox seed=4 fill_style=FillStyle::Hachure>
/// 		<Text>"Pro"</Text>
/// 	</WiredBox>
/// };
/// assert_eq!(tier.text_content(), "Pro");
/// ```
#[component]
pub fn WiredBox(
	/// Chooses the wobble. The same seed always draws the same border; give
	/// neighbouring boxes different seeds.
	#[prop(default = 1)]
	seed: i64,
	/// The pattern drawn inside the border.
	#[prop(optional)]
	fill_style: FillStyle,
	/// The fill colour. Defaults to the theme's accent.
	#[prop(optional, into)]
	fill: Option<Tone>,
	/// The colours to draw with.
	#[prop(default = Theme::SKRIBBLE)]
	theme: Theme,
	/// Extra Tailwind classes, such as a width or gap.
	#[prop(optional, into)]
	class: Option<String>,
	/// The content drawn over the ink.
	children: Children,
) -> Element {
	let ink = Ink::outline(InkShape::Rectangle, BOX_CANVAS, seed, theme)
		.filled(fill_style, fill.unwrap_or(theme.accent()));
	inked(ink, "px-3 py-2", class, children)
}

/// A hand-drawn card: a roomy box for grouping related content.
///
/// Give it a heading for screen readers; the border itself is decorative.
#[component]
pub fn WiredCard(
	/// Chooses the wobble. The same seed always draws the same border.
	#[prop(default = 1)]
	seed: i64,
	/// The pattern drawn inside the border.
	#[prop(optional)]
	fill_style: FillStyle,
	/// The fill colour. Defaults to the theme's accent.
	#[prop(optional, into)]
	fill: Option<Tone>,
	/// The colours to draw with.
	#[prop(default = Theme::SKRIBBLE)]
	theme: Theme,
	/// Extra Tailwind classes.
	#[prop(optional, into)]
	class: Option<String>,
	/// The card's content.
	children: Children,
) -> Element {
	let ink = Ink::outline(InkShape::Rectangle, CARD_CANVAS, seed, theme)
		.filled(fill_style, fill.unwrap_or(theme.accent()));
	inked(ink, "gap-3 px-6 py-5", class, children)
}

/// Wraps content in a hand-drawn ellipse, like a circled note.
///
/// The ellipse stretches with the element, so a square element gets a
/// circle. Use it for stickers and step numbers.
#[component]
pub fn WiredCircle(
	/// Chooses the wobble. The same seed always draws the same ellipse.
	#[prop(default = 1)]
	seed: i64,
	/// The pattern drawn inside the ellipse.
	#[prop(optional)]
	fill_style: FillStyle,
	/// The fill colour. Defaults to the theme's accent.
	#[prop(optional, into)]
	fill: Option<Tone>,
	/// The colours to draw with.
	#[prop(default = Theme::SKRIBBLE)]
	theme: Theme,
	/// Extra Tailwind classes, such as `size-16`.
	#[prop(optional, into)]
	class: Option<String>,
	/// The content drawn inside the ellipse.
	children: Children,
) -> Element {
	let ink = Ink::outline(InkShape::Ellipse, CIRCLE_CANVAS, seed, theme)
		.filled(fill_style, fill.unwrap_or(theme.accent()));
	inked(
		ink,
		"items-center justify-center px-5 py-4",
		class,
		children,
	)
}

/// A small hand-drawn capsule for a status or count, filled with the accent
/// like a sticker.
///
/// Screen readers read its text where it appears, so keep it meaningful on its
/// own, such as "3 new" rather than "3".
#[component]
pub fn WiredBadge(
	/// Chooses the wobble. The same seed always draws the same capsule.
	#[prop(default = 1)]
	seed: i64,
	/// The pattern drawn inside the capsule.
	#[prop(default = FillStyle::Solid)]
	fill_style: FillStyle,
	/// The fill colour. Defaults to the theme's accent.
	#[prop(optional, into)]
	fill: Option<Tone>,
	/// The colours to draw with.
	#[prop(default = Theme::SKRIBBLE)]
	theme: Theme,
	/// Extra Tailwind classes.
	#[prop(optional, into)]
	class: Option<String>,
	/// The badge's text.
	children: Children,
) -> Element {
	let ink = Ink::outline(InkShape::Capsule, BADGE_CANVAS, seed, theme)
		.filled(fill_style, fill.unwrap_or(theme.accent()));
	inked(
		ink,
		"self-start items-center justify-center px-3 py-1 text-xs font-semibold",
		class,
		children,
	)
}
