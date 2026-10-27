//! Pen marks around text: underlines, circles, boxes, strikes, and markers.

use leptoskit::native::Element;
use leptoskit::prelude::*;
use skribble_rough::FillStyle;

use crate::Theme;
use crate::Tone;
use crate::container::with_class;
use crate::ink::Canvas;
use crate::ink::Ink;
use crate::ink::InkShape;
use crate::theme::tone_class;

const LINE_CANVAS: Canvas = Canvas::new(100.0, 10.0).inset(2.0);
const LOOP_CANVAS: Canvas = Canvas::new(100.0, 40.0).inset(2.0);

/// The mark a [`WiredHighlight`](fn@WiredHighlight) draws.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Default)]
pub enum HighlightKind {
	/// A rough line under the text.
	#[default]
	Underline,
	/// A rough loop around the text, like a circled word.
	Circle,
	/// A highlighter stroke behind the text.
	Marker,
	/// A rough line through the text.
	Strikethrough,
	/// A rough rectangle around the text.
	Box,
}

/// Marks text the way a pen would: underlined, circled, boxed, struck
/// through, or highlighted.
///
/// The mark is decorative, so it adds nothing for screen readers. When it
/// carries meaning, such as a struck-out price, say so in the text.
///
/// ```
/// use leptoskit::prelude::*;
/// use skribble_leptoskit::HighlightKind;
/// use skribble_leptoskit::WiredHighlight;
///
/// let title = view! {
/// 	<View class="flex-row items-center gap-1">
/// 		<Text>"Draw it"</Text>
/// 		<WiredHighlight kind=HighlightKind::Circle seed=5>
/// 			<Text>"differently"</Text>
/// 		</WiredHighlight>
/// 	</View>
/// };
/// assert_eq!(title.text_content(), "Draw it differently");
/// ```
#[component]
pub fn WiredHighlight(
	/// The mark to draw.
	#[prop(optional)]
	kind: HighlightKind,
	/// The mark's colour. Defaults to the ink for pen marks and the accent for
	/// the marker.
	#[prop(optional, into)]
	color: Option<Tone>,
	/// Chooses the wobble. The same seed always draws the same mark.
	#[prop(default = 1)]
	seed: i64,
	/// The colours to draw with.
	#[prop(default = Theme::SKRIBBLE)]
	theme: Theme,
	/// Extra Tailwind classes.
	#[prop(optional, into)]
	class: Option<String>,
	/// The marked text.
	children: Children,
) -> Element {
	let pen = color.unwrap_or(theme.ink());
	let outline = |shape, canvas| Ink {
		outline: Some(pen),
		..Ink::outline(shape, canvas, seed, theme)
	};
	let (ink, padding, text) = match kind {
		HighlightKind::Underline => (
			outline(InkShape::Underline, LINE_CANVAS),
			"pb-1.5",
			theme.ink(),
		),
		HighlightKind::Strikethrough => {
			(outline(InkShape::Rule, LINE_CANVAS), "px-0.5", theme.ink())
		}
		HighlightKind::Circle => (
			outline(InkShape::Ellipse, LOOP_CANVAS),
			// Enough room that the corners of the text stay inside the ellipse.
			"px-4 py-2.5",
			theme.ink(),
		),
		HighlightKind::Box => (
			outline(InkShape::Rectangle, LOOP_CANVAS),
			"px-1.5 py-0.5",
			theme.ink(),
		),
		HighlightKind::Marker => (
			Ink::outline(InkShape::Rectangle, LOOP_CANVAS, seed, theme)
				.without_outline()
				.filled(FillStyle::Solid, color.unwrap_or(theme.accent())),
			"px-1 py-0.5",
			theme.on_accent(),
		),
	};

	let highlight = View()
		.class("self-start")
		.class(padding)
		.class(tone_class("text", text));
	// A strike crosses the text, so it paints over it; every other mark sits
	// behind.
	let highlight = if kind == HighlightKind::Strikethrough {
		highlight.children(children).child(ink.layer())
	} else {
		highlight.child(ink.layer()).children(children)
	};
	with_class(highlight, class)
}
