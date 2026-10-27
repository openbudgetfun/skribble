//! Ink as plain views: borders and backgrounds in the ink's colours.
//!
//! Native leptoskit has no way to draw paths, so this keeps each component's
//! shape, colours, and weight with straight lines until it does.

use leptoskit::native::Color;
use leptoskit::native::Element;
use leptoskit::prelude::Text;
use leptoskit::prelude::View;
use leptoskit::yoga::Dimension;
use skribble_rough::FillStyle;

use super::Ink;
use super::InkShape;
use crate::Tone;
use crate::theme::tone_class;

/// How strongly a sketched pattern tints its shape when it becomes a flat
/// background: roughly the share of the area hachure lines cover.
const SKETCH_TINT_ALPHA: u8 = 0x59;

/// The view that draws `ink` over its parent.
pub(super) fn layer(ink: &Ink) -> Element {
	let layer = cover(ink);
	let line_width = format!("{}px", ink.theme.stroke_width);

	match ink.shape {
		InkShape::Rectangle | InkShape::Capsule | InkShape::Ellipse => {
			let corners = if ink.shape == InkShape::Rectangle {
				"rounded-[3px]"
			} else {
				"rounded-full"
			};
			let mut layer = layer.class(corners);
			if let Some(tone) = ink.outline {
				layer = layer
					.class(format!("border-[{line_width}]"))
					.class(tone_class("border", tone));
			}
			if let Some(fill) = ink.fill {
				let tone = match fill.style {
					FillStyle::Solid => fill.tone,
					_ => tinted(fill.tone),
				};
				layer = layer.class(tone_class("bg", tone));
			}
			layer
		}
		InkShape::Rule | InkShape::Underline => {
			let placement = if ink.shape == InkShape::Rule {
				"justify-center"
			} else {
				"justify-end"
			};
			let tone = ink.outline.or(ink.fill.map(|fill| fill.tone));
			layer.class(placement).children(tone.map(|tone| {
				View()
					.class(format!("w-full h-[{line_width}]"))
					.class(tone_class("bg", tone))
			}))
		}
		InkShape::Check => {
			let tone = ink.outline.unwrap_or(ink.theme.ink());
			layer.class("items-center justify-center").child(
				Text("✓")
					.class("text-base font-bold")
					.class(tone_class("text", tone)),
			)
		}
	}
}

/// A decorative view over the parent, inset by the share of the canvas the
/// drawn outline is inset, so a small shape such as a radio dot keeps its
/// size.
fn cover(ink: &Ink) -> Element {
	let canvas = ink.canvas;
	let x = (canvas.inset / canvas.width) as f32;
	let y = (canvas.inset / canvas.height) as f32;
	View()
		.class("absolute")
		.aria_hidden(true)
		.with_style(|style| {
			style.inset.left = Dimension::Percent(x);
			style.inset.top = Dimension::Percent(y);
			style.width = Dimension::Percent(1.0 - 2.0 * x);
			style.height = Dimension::Percent(1.0 - 2.0 * y);
		})
}

/// `tone` at the opacity that stands in for a sketched pattern.
fn tinted(tone: Tone) -> Tone {
	let tint =
		|color: Color| Color::rgba(color.red(), color.green(), color.blue(), SKETCH_TINT_ALPHA);
	Tone {
		light: tint(tone.light),
		dark: tint(tone.dark),
	}
}

#[cfg(test)]
mod tests {
	use leptoskit::native::Element;

	use super::*;
	use crate::Theme;
	use crate::ink::Canvas;

	fn classes(element: &Element) -> String {
		element.classes().classes().to_owned()
	}

	#[test]
	fn outlines_become_borders_in_both_appearances() {
		let ink = Ink::outline(
			InkShape::Rectangle,
			Canvas::new(100.0, 40.0),
			1,
			Theme::SKRIBBLE,
		);
		let layer = layer(&ink);
		let classes = classes(&layer);
		assert!(classes.contains("border-[2px]"), "{classes}");
		assert!(classes.contains("border-[#1f1d1a]"), "{classes}");
		assert!(classes.contains("dark:border-[#f2efe6]"), "{classes}");
	}

	#[test]
	fn sketched_fills_become_a_tint_and_solid_fills_stay_solid() {
		let theme = Theme::SKRIBBLE;
		let base = Ink::outline(InkShape::Ellipse, Canvas::new(40.0, 40.0), 1, theme);
		let hachure = classes(&layer(&base.filled(FillStyle::Hachure, theme.accent())));
		assert!(hachure.contains("bg-[#ffd43b59]"), "{hachure}");
		let solid = classes(&layer(&base.filled(FillStyle::Solid, theme.accent())));
		assert!(solid.contains("bg-[#ffd43b]"), "{solid}");
	}

	#[test]
	fn rules_draw_a_line_and_checks_draw_a_tick() {
		let theme = Theme::SKRIBBLE;
		let rule = layer(&Ink::outline(
			InkShape::Rule,
			Canvas::new(100.0, 10.0),
			1,
			theme,
		));
		assert_eq!(rule.children.len(), 1);
		let check = layer(&Ink::outline(
			InkShape::Check,
			Canvas::new(24.0, 24.0),
			1,
			theme,
		));
		assert_eq!(check.text_content(), "✓");
	}
}
