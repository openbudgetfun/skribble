//! The ink of each skribble component, ready for a framework to lay out.
//!
//! A recipe answers "what does this component draw?" and leaves layout,
//! events, and accessibility to the framework adapter: a button recipe gives
//! the rough rectangle and its fill, and the adapter puts it behind a real,
//! labelled button. Every adapter that uses these recipes draws the same
//! component the same way, from the same seed.
//!
//! ```
//! use skribble_core::Theme;
//! use skribble_core::components;
//! use skribble_core::components::ButtonVariant;
//!
//! let theme = Theme::SKRIBBLE;
//! let save = components::button(ButtonVariant::Primary, 1, theme);
//! assert_eq!(save.content_tone(), theme.on_accent());
//! let drawing = save.drawing();
//! assert!(!drawing.is_empty());
//! ```

use skribble_rough::FillStyle;

use crate::Canvas;
use crate::Ink;
use crate::InkShape;
use crate::Theme;
use crate::Tone;

/// The canvas a button's border is drawn on.
pub const BUTTON_CANVAS: Canvas = Canvas::new(160.0, 48.0).inset(2.5);
/// The canvas a box's border is drawn on.
pub const BOX_CANVAS: Canvas = Canvas::new(240.0, 120.0);
/// The canvas a card's border is drawn on.
pub const CARD_CANVAS: Canvas = Canvas::new(320.0, 200.0).gap(10.0);
/// The canvas a circle is drawn on.
pub const CIRCLE_CANVAS: Canvas = Canvas::new(120.0, 120.0).inset(4.0);
/// The canvas a badge's capsule is drawn on.
pub const BADGE_CANVAS: Canvas = Canvas::new(96.0, 32.0).inset(2.5).gap(5.0);
/// The canvas a text field's frame is drawn on.
pub const INPUT_CANVAS: Canvas = Canvas::new(280.0, 44.0).inset(2.5);
/// The canvas a divider is drawn on.
pub const DIVIDER_CANVAS: Canvas = Canvas::new(600.0, 12.0).inset(2.0);
/// The canvas a checkbox's square and tick, and a radio's ring, are drawn on.
pub const MARK_CANVAS: Canvas = Canvas::new(24.0, 24.0).inset(2.5).gap(4.0);
/// The canvas a radio's dot is drawn on.
pub const DOT_CANVAS: Canvas = Canvas::new(24.0, 24.0).inset(7.0);
/// The canvas a switch's track is drawn on.
pub const TRACK_CANVAS: Canvas = Canvas::new(52.0, 28.0).inset(2.5).gap(5.0);
/// The canvas a switch's knob is drawn on.
pub const KNOB_CANVAS: Canvas = Canvas::new(20.0, 20.0).inset(2.0);
/// The canvas a progress bar's track is drawn on.
pub const PROGRESS_CANVAS: Canvas = Canvas::new(240.0, 24.0).inset(2.5).gap(6.0);
/// The canvas an underline or strike is drawn on.
pub const LINE_CANVAS: Canvas = Canvas::new(100.0, 10.0).inset(2.0);
/// The canvas a circle, box, or marker around text is drawn on.
pub const LOOP_CANVAS: Canvas = Canvas::new(100.0, 40.0).inset(2.0);

/// The width of a switch, in logical pixels.
pub const SWITCH_WIDTH: f32 = 52.0;
/// The height of a switch, in logical pixels.
pub const SWITCH_HEIGHT: f32 = 28.0;
/// The width and height of a switch's knob, in logical pixels.
pub const KNOB_SIZE: f32 = 20.0;
/// The distance from the top of a switch to its knob, in logical pixels.
pub const KNOB_TOP: f32 = 4.0;

/// How much a button stands out.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Default)]
pub enum ButtonVariant {
	/// Filled with the accent: the one action a screen is about.
	#[default]
	Primary,
	/// An outline only, for every other action.
	Secondary,
}

/// A button's border: a rough rectangle, filled with the accent when it is
/// the primary action. Draw its label in [`Ink::content_tone`].
pub fn button(variant: ButtonVariant, seed: i64, theme: Theme) -> Ink {
	let fill_style = match variant {
		ButtonVariant::Primary => FillStyle::Solid,
		ButtonVariant::Secondary => FillStyle::None,
	};
	Ink::outline(InkShape::Rectangle, BUTTON_CANVAS, seed, theme).filled(fill_style, theme.accent())
}

/// A box's border, optionally filled; the fill defaults to the marker.
pub fn boxed(seed: i64, fill_style: FillStyle, fill: Option<Tone>, theme: Theme) -> Ink {
	Ink::outline(InkShape::Rectangle, BOX_CANVAS, seed, theme)
		.filled(fill_style, fill.unwrap_or(theme.marker()))
}

/// A card's border, optionally filled; the fill defaults to the marker.
///
/// Colour-code a run of cards with [`Theme::accent_at`].
pub fn card(seed: i64, fill_style: FillStyle, fill: Option<Tone>, theme: Theme) -> Ink {
	Ink::outline(InkShape::Rectangle, CARD_CANVAS, seed, theme)
		.filled(fill_style, fill.unwrap_or(theme.marker()))
}

/// A rough ellipse around content, optionally filled; the fill defaults to
/// the marker.
pub fn circle(seed: i64, fill_style: FillStyle, fill: Option<Tone>, theme: Theme) -> Ink {
	Ink::outline(InkShape::Ellipse, CIRCLE_CANVAS, seed, theme)
		.filled(fill_style, fill.unwrap_or(theme.marker()))
}

/// A badge's capsule, filled like a sticker; the fill defaults to the accent.
pub fn badge(seed: i64, fill_style: FillStyle, fill: Option<Tone>, theme: Theme) -> Ink {
	Ink::outline(InkShape::Capsule, BADGE_CANVAS, seed, theme)
		.filled(fill_style, fill.unwrap_or(theme.accent()))
}

/// A text field's frame.
pub const fn input(seed: i64, theme: Theme) -> Ink {
	Ink::outline(InkShape::Rectangle, INPUT_CANVAS, seed, theme)
}

/// A rough horizontal rule.
pub const fn divider(seed: i64, theme: Theme) -> Ink {
	Ink::outline(InkShape::Rule, DIVIDER_CANVAS, seed, theme)
}

/// The ink of a checkbox.
#[derive(Debug, Clone, Copy, PartialEq)]
pub struct CheckboxInk {
	/// The rough square.
	pub square: Ink,
	/// The tick, when checked. It draws over the square.
	pub tick: Option<Ink>,
}

/// A checkbox: a rough square that gets a tick when `checked`.
pub fn checkbox(checked: bool, seed: i64, theme: Theme) -> CheckboxInk {
	CheckboxInk {
		square: Ink::outline(InkShape::Rectangle, MARK_CANVAS, seed, theme),
		tick: checked
			.then(|| Ink::outline(InkShape::Check, MARK_CANVAS, seed.wrapping_add(1), theme)),
	}
}

/// The ink of a radio button.
#[derive(Debug, Clone, Copy, PartialEq)]
pub struct RadioInk {
	/// The rough circle.
	pub ring: Ink,
	/// The dot, when selected. It draws over the ring.
	pub dot: Option<Ink>,
}

/// A radio button: a rough circle that gets a dot when `selected`.
pub fn radio(selected: bool, seed: i64, theme: Theme) -> RadioInk {
	RadioInk {
		ring: Ink::outline(InkShape::Ellipse, MARK_CANVAS, seed, theme),
		dot: selected.then(|| {
			Ink::outline(InkShape::Ellipse, DOT_CANVAS, seed.wrapping_add(1), theme)
				.without_outline()
				.filled(FillStyle::Solid, theme.ink())
		}),
	}
}

/// The ink of a switch.
#[derive(Debug, Clone, Copy, PartialEq)]
pub struct SwitchInk {
	/// The rough capsule, filled with the marker when on. It is
	/// [`SWITCH_WIDTH`] by [`SWITCH_HEIGHT`].
	pub track: Ink,
	/// The paper knob, [`KNOB_SIZE`] square, drawn over the track.
	pub knob: Ink,
	/// The knob's distance from the track's left edge, in logical pixels: at
	/// the end when on, at the start when off.
	pub knob_left: f32,
}

/// A switch: a rough capsule that fills with the marker, and a knob that
/// slides to the end when `on`.
pub fn switch(on: bool, seed: i64, theme: Theme) -> SwitchInk {
	let track_fill = if on {
		FillStyle::Solid
	} else {
		FillStyle::None
	};
	SwitchInk {
		track: Ink::outline(InkShape::Capsule, TRACK_CANVAS, seed, theme)
			.filled(track_fill, theme.marker()),
		knob: Ink::outline(InkShape::Ellipse, KNOB_CANVAS, seed.wrapping_add(1), theme)
			.filled(FillStyle::Solid, theme.paper()),
		knob_left: if on {
			SWITCH_WIDTH - KNOB_SIZE - KNOB_TOP
		} else {
			KNOB_TOP
		},
	}
}

/// The ink of a progress bar.
#[derive(Debug, Clone, Copy, PartialEq)]
pub struct ProgressInk {
	/// The rough track, drawn over the filling.
	pub track: Ink,
	/// The hachure filling, when anything is done. It covers the share of the
	/// track's width given by [`Self::done`], and draws on a canvas that wide
	/// so the hachure keeps one density at every value.
	pub filling: Option<Ink>,
	/// The share done, from 0 to 1. NaN counts as nothing done.
	pub done: f64,
	/// The share done as a whole percentage, for assistive technology.
	pub percent: f64,
}

/// A progress bar at `value`, clamped to 0 through 1.
pub fn progress(value: f64, seed: i64, theme: Theme) -> ProgressInk {
	let done = if value.is_nan() {
		0.0
	} else {
		value.clamp(0.0, 1.0)
	};
	// Adding zero turns a clamped `-0.0` into `0`.
	let percent = (done * 100.0).round() + 0.0;
	let filling = (done > 0.0).then(|| {
		let canvas = Canvas {
			width: PROGRESS_CANVAS.width * done,
			..PROGRESS_CANVAS
		};
		Ink::outline(InkShape::Rectangle, canvas, seed.wrapping_add(1), theme)
			.without_outline()
			.filled(FillStyle::Hachure, theme.marker())
	});
	ProgressInk {
		track: Ink::outline(InkShape::Rectangle, PROGRESS_CANVAS, seed, theme),
		filling,
		done,
		percent,
	}
}

/// The mark a highlight draws around text.
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

/// The ink of a highlight.
#[derive(Debug, Clone, Copy, PartialEq)]
pub struct HighlightInk {
	/// The mark.
	pub ink: Ink,
	/// The tone of the marked text.
	pub text: Tone,
	/// Whether the mark paints over the text, as a strike does, rather than
	/// behind it.
	pub over_text: bool,
}

/// A pen mark around text. `color` defaults to the ink for pen marks and the
/// marker for [`HighlightKind::Marker`].
pub fn highlight(
	kind: HighlightKind,
	color: Option<Tone>,
	seed: i64,
	theme: Theme,
) -> HighlightInk {
	let pen = color.unwrap_or(theme.ink());
	let outline = |shape, canvas| Ink::outline(shape, canvas, seed, theme).outlined(pen);
	let (ink, text) = match kind {
		HighlightKind::Underline => (outline(InkShape::Underline, LINE_CANVAS), theme.ink()),
		HighlightKind::Strikethrough => (outline(InkShape::Rule, LINE_CANVAS), theme.ink()),
		HighlightKind::Circle => (outline(InkShape::Ellipse, LOOP_CANVAS), theme.ink()),
		HighlightKind::Box => (outline(InkShape::Rectangle, LOOP_CANVAS), theme.ink()),
		HighlightKind::Marker => {
			let wash = color.unwrap_or(theme.marker());
			(
				Ink::outline(InkShape::Rectangle, LOOP_CANVAS, seed, theme)
					.without_outline()
					.filled(FillStyle::Solid, wash),
				theme.on(wash),
			)
		}
	};
	HighlightInk {
		ink,
		text,
		over_text: kind == HighlightKind::Strikethrough,
	}
}

#[cfg(test)]
mod tests {
	use super::*;
	use crate::InkPaint;

	const THEME: Theme = Theme::SKRIBBLE;

	#[test]
	fn the_primary_button_is_the_loud_one() {
		let primary = button(ButtonVariant::Primary, 1, THEME);
		assert!(primary.is_solid());
		assert_eq!(primary.fill.map(|fill| fill.tone), Some(THEME.accent()));
		assert_eq!(primary.content_tone(), THEME.on_accent());
		let secondary = button(ButtonVariant::Secondary, 1, THEME);
		assert!(secondary.fill.is_none());
		assert_eq!(secondary.content_tone(), THEME.ink());
	}

	#[test]
	fn containers_default_to_the_marker_and_take_any_wash() {
		let plain = boxed(1, FillStyle::Hachure, None, THEME);
		assert_eq!(plain.fill.map(|fill| fill.tone), Some(THEME.marker()));
		let coded = card(2, FillStyle::Solid, Some(THEME.accent_at(1)), THEME);
		assert_eq!(coded.content_tone(), THEME.on(THEME.accent_at(1)));
		assert_eq!(
			circle(3, FillStyle::None, None, THEME).shape,
			InkShape::Ellipse
		);
		let sticker = badge(4, FillStyle::Solid, None, THEME);
		assert_eq!(sticker.shape, InkShape::Capsule);
		assert_eq!(sticker.fill.map(|fill| fill.tone), Some(THEME.accent()));
	}

	#[test]
	fn toggles_add_their_mark_only_when_on() {
		assert!(checkbox(false, 1, THEME).tick.is_none());
		let checked = checkbox(true, 1, THEME);
		assert_eq!(checked.tick.map(|tick| tick.shape), Some(InkShape::Check));
		assert_ne!(
			checked.tick.map(|tick| tick.seed),
			Some(checked.square.seed)
		);
		assert!(radio(false, 1, THEME).dot.is_none());
		let dot = radio(true, 1, THEME).dot.expect("a dot");
		assert!(dot.outline.is_none());
		assert!(dot.is_solid());
	}

	#[test]
	fn a_switch_slides_its_knob_and_fills_its_track() {
		let off = switch(false, 1, THEME);
		let on = switch(true, 1, THEME);
		assert!(off.track.fill.is_none());
		assert_eq!(on.track.fill.map(|fill| fill.tone), Some(THEME.marker()));
		assert_eq!(off.knob_left, 4.0);
		assert_eq!(on.knob_left, 28.0);
		assert_eq!(on.knob.fill.map(|fill| fill.tone), Some(THEME.paper()));
	}

	#[test]
	fn progress_clamps_and_rounds() {
		assert_eq!(progress(0.426, 1, THEME).percent, 43.0);
		assert_eq!(
			progress(-1.0, 1, THEME).percent.to_bits(),
			0.0_f64.to_bits()
		);
		assert!(progress(f64::NAN, 1, THEME).filling.is_none());
		let full = progress(4.0, 1, THEME);
		assert_eq!(full.done, 1.0);
		let half = progress(0.5, 1, THEME).filling.expect("a filling");
		assert_eq!(half.canvas.width, PROGRESS_CANVAS.width / 2.0);
		assert!(half.outline.is_none());
	}

	#[test]
	fn highlights_mark_text_the_way_a_pen_would() {
		let strike = highlight(HighlightKind::Strikethrough, None, 1, THEME);
		assert!(strike.over_text);
		assert_eq!(strike.ink.shape, InkShape::Rule);
		let circled = highlight(HighlightKind::Circle, Some(THEME.accent()), 1, THEME);
		assert!(!circled.over_text);
		assert_eq!(circled.ink.outline, Some(THEME.accent()));
		let marker = highlight(HighlightKind::Marker, None, 1, THEME);
		assert!(marker.ink.outline.is_none());
		assert_eq!(marker.text, THEME.on_marker());
		let drawing = marker.ink.drawing();
		assert_eq!(drawing.paths[0].paint, InkPaint::Fill(THEME.marker()));
		assert_eq!(
			highlight(HighlightKind::Underline, None, 1, THEME)
				.ink
				.shape,
			InkShape::Underline
		);
		assert_eq!(
			highlight(HighlightKind::Box, None, 1, THEME).ink.shape,
			InkShape::Rectangle
		);
	}

	#[test]
	fn rules_and_frames_are_outlines() {
		assert_eq!(divider(1, THEME).shape, InkShape::Rule);
		assert!(input(1, THEME).fill.is_none());
	}
}
