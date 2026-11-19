//! The colours, line weight, and wobble everything draws with.

use crate::colorway::Appearance;
use crate::colorway::Colorway;
use crate::colorway::ROUGHNESS;
use crate::colorway::Rgba;
use crate::colorway::STROKE_WIDTH;
use crate::colorway::readable_on;

/// The colours of one appearance, light or dark.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub struct Palette {
	/// Outlines, running text, and pen marks.
	pub ink: Rgba,
	/// The page behind everything.
	pub paper: Rgba,
	/// Disabled labels.
	pub muted_ink: Rgba,
	/// The highlighter under selected and active things: switches, progress,
	/// marker highlights, and default box fills.
	pub marker: Rgba,
	/// The fill of the one primary action on a screen.
	pub accent: Rgba,
	/// The washes for colour-coding cards, chips, and series, in order.
	/// Never empty.
	pub washes: &'static [Rgba],
}

impl Palette {
	/// `colorway` in `appearance`: plum ink on warm paper, or paper ink on a
	/// plum night, with the colourway's marker, accent, and washes.
	pub const fn colorway(colorway: Colorway, appearance: Appearance) -> Self {
		Self {
			ink: appearance.ink(),
			paper: appearance.paper(),
			muted_ink: appearance.muted_ink(),
			marker: colorway.marker(appearance),
			accent: colorway.accent(appearance),
			washes: colorway.washes(appearance),
		}
	}

	/// skribble's light palette: the sunny colourway on warm paper.
	pub const LIGHT: Self = Self::colorway(Colorway::Sunny, Appearance::Light);

	/// skribble's dark palette: the sunny colourway on a plum night.
	pub const DARK: Self = Self::colorway(Colorway::Sunny, Appearance::Dark);

	/// The wash for item `index`, cycling through [`Self::washes`].
	pub const fn wash(&self, index: usize) -> Rgba {
		self.washes[index % self.washes.len()]
	}

	/// Whichever of this palette's ink and paper reads better on
	/// `background`.
	pub fn on(&self, background: Rgba) -> Rgba {
		readable_on(background, self.ink, self.paper)
	}
}

/// One colour role in both appearances.
///
/// Everything paints with tones rather than single colours so it follows dark
/// mode. A renderer picks the side that matches the host's appearance: on the
/// web a `prefers-color-scheme` rule or a `dark:` class, and on native
/// platforms the system appearance.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
pub struct Tone {
	/// The colour in the light appearance.
	pub light: Rgba,
	/// The colour in the dark appearance.
	pub dark: Rgba,
}

impl Tone {
	/// The same colour in both appearances.
	pub const fn fixed(color: Rgba) -> Self {
		Self {
			light: color,
			dark: color,
		}
	}

	/// The colour in `appearance`.
	pub const fn get(self, appearance: Appearance) -> Rgba {
		match appearance {
			Appearance::Light => self.light,
			Appearance::Dark => self.dark,
		}
	}

	/// Whether both appearances use the same colour.
	pub fn is_fixed(self) -> bool {
		self.light == self.dark
	}
}

impl From<Rgba> for Tone {
	fn from(color: Rgba) -> Self {
		Self::fixed(color)
	}
}

/// How skribble draws: its colours, line weight, and wobble.
///
/// Start from a colourway, [`Theme::SKRIBBLE`] (the sunny one) or
/// [`Theme::colorway`], and replace the parts you need:
///
/// ```
/// use skribble_core::Palette;
/// use skribble_core::Theme;
/// use skribble_core::colorway::Colorway;
/// use skribble_core::colorway::swatch;
///
/// pub const MINTY: Theme = Theme {
/// 	light: Palette {
/// 		accent: swatch::MINT,
/// 		..Palette::LIGHT
/// 	},
/// 	..Theme::SKRIBBLE
/// };
/// assert_eq!(MINTY.stroke_width, 1.6);
/// assert_eq!(Theme::colorway(Colorway::Ocean).accent().light, swatch::COBALT);
/// ```
#[derive(Debug, Clone, Copy, PartialEq)]
pub struct Theme {
	/// The colours in the light appearance.
	pub light: Palette,
	/// The colours in the dark appearance.
	pub dark: Palette,
	/// Outline width, in logical pixels, at every size.
	pub stroke_width: f32,
	/// How far the hand wanders from a straight line; zero is ruler-straight.
	pub roughness: f64,
}

impl Theme {
	/// `colorway` in both appearances, with skribble's default pen.
	pub const fn colorway(colorway: Colorway) -> Self {
		Self {
			light: Palette::colorway(colorway, Appearance::Light),
			dark: Palette::colorway(colorway, Appearance::Dark),
			stroke_width: STROKE_WIDTH,
			roughness: ROUGHNESS,
		}
	}

	/// skribble's own look: the sunny colourway.
	pub const SKRIBBLE: Self = Self::colorway(Colorway::Sunny);

	/// The palette for `appearance`.
	pub const fn palette(&self, appearance: Appearance) -> &Palette {
		match appearance {
			Appearance::Light => &self.light,
			Appearance::Dark => &self.dark,
		}
	}

	/// The ink tone, for outlines and running text.
	pub const fn ink(&self) -> Tone {
		Tone {
			light: self.light.ink,
			dark: self.dark.ink,
		}
	}

	/// The paper tone, behind everything.
	pub const fn paper(&self) -> Tone {
		Tone {
			light: self.light.paper,
			dark: self.dark.paper,
		}
	}

	/// The muted ink tone, for disabled labels.
	pub const fn muted_ink(&self) -> Tone {
		Tone {
			light: self.light.muted_ink,
			dark: self.dark.muted_ink,
		}
	}

	/// The marker tone, the highlighter under selected and active things.
	pub const fn marker(&self) -> Tone {
		Tone {
			light: self.light.marker,
			dark: self.dark.marker,
		}
	}

	/// The accent tone, for the one primary action on a screen.
	pub const fn accent(&self) -> Tone {
		Tone {
			light: self.light.accent,
			dark: self.dark.accent,
		}
	}

	/// The wash for item `index`, cycling through the colourway's washes, so
	/// five cards get five colours.
	pub const fn accent_at(&self, index: usize) -> Tone {
		Tone {
			light: self.light.wash(index),
			dark: self.dark.wash(index),
		}
	}

	/// The ink or paper that reads better on `wash` in each appearance: the
	/// tone for a label, icon, or number drawn on it.
	pub fn on(&self, wash: Tone) -> Tone {
		Tone {
			light: self.light.on(wash.light),
			dark: self.dark.on(wash.dark),
		}
	}

	/// The tone for marks on the accent.
	pub fn on_accent(&self) -> Tone {
		self.on(self.accent())
	}

	/// The tone for marks on the marker.
	pub fn on_marker(&self) -> Tone {
		self.on(self.marker())
	}
}

impl Default for Theme {
	fn default() -> Self {
		Self::SKRIBBLE
	}
}

#[cfg(test)]
mod tests {
	use super::*;
	use crate::colorway::swatch;

	#[test]
	fn the_default_theme_is_sunny() {
		let theme = Theme::default();
		assert_eq!(theme, Theme::colorway(Colorway::Sunny));
		assert_eq!(theme.marker().light, swatch::SUNSHINE);
		assert_eq!(theme.accent().light, swatch::TOMATO);
		assert_eq!(theme.ink().light, swatch::INK);
		assert_eq!(theme.paper().dark, swatch::NIGHT);
	}

	#[test]
	fn washes_cycle_by_index() {
		let theme = Theme::SKRIBBLE;
		assert_eq!(theme.accent_at(0).light, swatch::SUNSHINE);
		assert_eq!(theme.accent_at(1).light, swatch::SKY);
		assert_eq!(theme.accent_at(6), theme.accent_at(0));
		let quiet = Theme::colorway(Colorway::Quiet);
		assert_eq!(quiet.accent_at(5).dark, swatch::DUSK);
	}

	#[test]
	fn labels_on_a_wash_stay_readable_in_both_appearances() {
		for colorway in Colorway::ALL {
			let theme = Theme::colorway(colorway);
			for index in 0..6 {
				let wash = theme.accent_at(index);
				let label = theme.on(wash);
				for appearance in Appearance::ALL {
					assert!(wash.get(appearance).contrast(label.get(appearance)) >= 4.5);
				}
			}
		}
	}

	#[test]
	fn tones_know_when_they_are_fixed() {
		assert!(Tone::fixed(swatch::SKY).is_fixed());
		assert!(!Theme::SKRIBBLE.ink().is_fixed());
		assert_eq!(Tone::from(swatch::SKY), Tone::fixed(swatch::SKY));
		assert_eq!(Theme::SKRIBBLE.ink().get(Appearance::Dark), swatch::PAPER);
	}
}
