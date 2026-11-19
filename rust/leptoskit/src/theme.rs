//! The colours and line weight every component draws with.

use leptoskit::native::Color;

use crate::colorway;
use crate::colorway::Appearance;
use crate::colorway::Colorway;
use crate::colorway::Rgba;

/// `rgba`, a framework-free [`colorway`] colour, as a leptoskit colour.
///
/// ```
/// use leptoskit::native::Color;
/// use skribble_leptoskit::color;
/// use skribble_leptoskit::colorway::swatch;
///
/// assert_eq!(color(swatch::TOMATO), Color::rgba(0xff, 0x6b, 0x4a, 0xff));
/// ```
pub const fn color(rgba: Rgba) -> Color {
	Color::rgba(rgba.red, rgba.green, rgba.blue, rgba.alpha)
}

/// `color` as a framework-free colour.
pub(crate) fn rgba(color: Color) -> Rgba {
	Rgba::new(color.red(), color.green(), color.blue(), color.alpha())
}

/// Every colourway's washes as leptoskit colours, so palettes stay `const`.
const fn wash_colors(colorway: Colorway, appearance: Appearance) -> &'static [Color] {
	const fn wash<const N: usize>(colorway: Colorway, appearance: Appearance) -> [Color; N] {
		let washes = colorway.washes(appearance);
		let mut colors = [Color::rgba(0, 0, 0, 0); N];
		let mut index = 0;
		while index < N {
			colors[index] = color(washes[index % washes.len()]);
			index += 1;
		}
		colors
	}
	const SUNNY: [Color; 6] = wash(Colorway::Sunny, Appearance::Light);
	const BERRY: [Color; 6] = wash(Colorway::Berry, Appearance::Light);
	const OCEAN: [Color; 6] = wash(Colorway::Ocean, Appearance::Light);
	const CITRUS: [Color; 6] = wash(Colorway::Citrus, Appearance::Light);
	const QUIET: [Color; 4] = wash(Colorway::Quiet, Appearance::Light);
	const QUIET_DARK: [Color; 1] = wash(Colorway::Quiet, Appearance::Dark);
	match (colorway, appearance) {
		(Colorway::Sunny, _) => &SUNNY,
		(Colorway::Berry, _) => &BERRY,
		(Colorway::Ocean, _) => &OCEAN,
		(Colorway::Citrus, _) => &CITRUS,
		(Colorway::Quiet, Appearance::Light) => &QUIET,
		(Colorway::Quiet, Appearance::Dark) => &QUIET_DARK,
	}
}

/// The colours of one appearance, light or dark.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub struct Palette {
	/// Outlines, running text, and pen marks.
	pub ink: Color,
	/// The page behind everything.
	pub paper: Color,
	/// Labels of disabled controls.
	pub muted_ink: Color,
	/// The highlighter under selected and active things: marker highlights,
	/// switch tracks, progress, and sketched fills.
	pub marker: Color,
	/// The fill of the one primary action on a screen, and of badges.
	pub accent: Color,
	/// Washes for colour-coding cards, chips, and series, in order. Read one
	/// with [`Theme::accent_at`]. Never empty.
	pub washes: &'static [Color],
}

impl Palette {
	/// The `appearance` side of `colorway`: plum ink on warm paper, or paper
	/// ink on a plum night, with the colourway's marker, accent, and washes.
	pub const fn colorway(colorway: Colorway, appearance: Appearance) -> Self {
		Self {
			ink: color(appearance.ink()),
			paper: color(appearance.paper()),
			muted_ink: color(appearance.muted_ink()),
			marker: color(colorway.marker(appearance)),
			accent: color(colorway.accent(appearance)),
			washes: wash_colors(colorway, appearance),
		}
	}

	/// skribble's light palette: plum ink on warm paper, a sunshine marker,
	/// and a tomato accent.
	pub const LIGHT: Self = Self::colorway(Colorway::Sunny, Appearance::Light);
	/// skribble's dark palette: paper ink on a plum night, with the same
	/// glowing sunny colours.
	pub const DARK: Self = Self::colorway(Colorway::Sunny, Appearance::Dark);

	/// Whichever of this palette's ink and paper reads better on
	/// `background`.
	pub fn on(&self, background: Color) -> Color {
		color(colorway::readable_on(
			rgba(background),
			rgba(self.ink),
			rgba(self.paper),
		))
	}
}

/// One colour role in both appearances.
///
/// Components paint with tones rather than single colours so they follow
/// dark mode: on the web through `prefers-color-scheme`, and on native
/// through the host's appearance, the same switch leptoskit's `dark:`
/// classes use.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub struct Tone {
	/// The colour in the light appearance.
	pub light: Color,
	/// The colour in the dark appearance.
	pub dark: Color,
}

impl Tone {
	/// The same colour in both appearances.
	pub const fn fixed(color: Color) -> Self {
		Self {
			light: color,
			dark: color,
		}
	}
}

impl From<Color> for Tone {
	fn from(color: Color) -> Self {
		Self::fixed(color)
	}
}

impl From<Rgba> for Tone {
	fn from(rgba: Rgba) -> Self {
		Self::fixed(color(rgba))
	}
}

/// How skribble components draw: their colours, line weight, and wobble.
///
/// Every component takes an optional `theme` and uses [`Theme::default`],
/// the sunny colourway, without one. Pick another colourway with
/// [`Theme::colorway`], or define your own once and pass it where you need
/// it:
///
/// ```
/// use skribble_leptoskit::Theme;
/// use skribble_leptoskit::colorway::Colorway;
/// use skribble_leptoskit::colorway::swatch;
/// use skribble_leptoskit::color;
///
/// pub const BERRY: Theme = Theme::colorway(Colorway::Berry);
/// pub const MINTY: Theme = Theme {
/// 	light: skribble_leptoskit::Palette {
/// 		accent: color(swatch::MINT),
/// 		..Theme::SKRIBBLE.light
/// 	},
/// 	..Theme::SKRIBBLE
/// };
/// assert_eq!(BERRY.light.accent, color(swatch::GRAPE));
/// assert_eq!(MINTY.stroke_width, 1.6);
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
	/// `colorway` in both appearances, drawn with skribble's default pen.
	pub const fn colorway(colorway: Colorway) -> Self {
		Self {
			light: Palette::colorway(colorway, Appearance::Light),
			dark: Palette::colorway(colorway, Appearance::Dark),
			stroke_width: colorway::STROKE_WIDTH,
			roughness: colorway::ROUGHNESS,
		}
	}

	/// skribble's own look: the sunny colourway.
	pub const SKRIBBLE: Self = Self::colorway(Colorway::Sunny);

	/// The ink tone.
	pub const fn ink(&self) -> Tone {
		Tone {
			light: self.light.ink,
			dark: self.dark.ink,
		}
	}

	/// The paper tone.
	pub const fn paper(&self) -> Tone {
		Tone {
			light: self.light.paper,
			dark: self.dark.paper,
		}
	}

	/// The tone of disabled labels.
	pub const fn muted_ink(&self) -> Tone {
		Tone {
			light: self.light.muted_ink,
			dark: self.dark.muted_ink,
		}
	}

	/// The marker tone: the highlighter under selected and active things.
	pub const fn marker(&self) -> Tone {
		Tone {
			light: self.light.marker,
			dark: self.dark.marker,
		}
	}

	/// The accent tone: the fill of the one primary action.
	pub const fn accent(&self) -> Tone {
		Tone {
			light: self.light.accent,
			dark: self.dark.accent,
		}
	}

	/// The wash for item `index`, cycling through each palette's washes, so a
	/// run of cards gets a run of colours: `fill=theme.accent_at(i)`.
	pub const fn accent_at(&self, index: usize) -> Tone {
		Tone {
			light: self.light.washes[index % self.light.washes.len()],
			dark: self.dark.washes[index % self.dark.washes.len()],
		}
	}

	/// The ink for labels, icons, and outlines drawn on `wash`: the theme's
	/// ink or paper, whichever reads better in each appearance.
	pub fn on(&self, wash: Tone) -> Tone {
		Tone {
			light: self.light.on(wash.light),
			dark: self.dark.on(wash.dark),
		}
	}

	/// The tone of labels on the accent.
	pub fn on_accent(&self) -> Tone {
		self.on(self.accent())
	}

	/// The tone of labels on the marker.
	pub fn on_marker(&self) -> Tone {
		self.on(self.marker())
	}
}

impl Default for Theme {
	fn default() -> Self {
		Self::SKRIBBLE
	}
}

/// `color` as a CSS hex colour, with alpha only when it is not opaque.
pub(crate) fn css_hex(color: Color) -> String {
	rgba(color).css_hex()
}

/// A Tailwind utility for `tone`, such as `border-[#34283f]
/// dark:border-[#fffaf0]`.
pub(crate) fn tone_class(utility: &str, tone: Tone) -> String {
	let light = format!("{utility}-[{}]", css_hex(tone.light));
	if tone.light == tone.dark {
		light
	} else {
		format!("{light} dark:{utility}-[{}]", css_hex(tone.dark))
	}
}

#[cfg(test)]
mod tests {
	use super::*;

	#[test]
	fn hex_keeps_alpha_only_when_translucent() {
		assert_eq!(css_hex(Palette::LIGHT.marker), "#ffd43b");
		assert_eq!(css_hex(Color::rgba(1, 2, 3, 0x80)), "#01020380");
	}

	#[test]
	fn tone_classes_switch_in_dark_mode() {
		assert_eq!(
			tone_class("text", Theme::SKRIBBLE.ink()),
			"text-[#34283f] dark:text-[#fffaf0]"
		);
		assert_eq!(tone_class("bg", Theme::SKRIBBLE.accent()), "bg-[#ff6b4a]");
	}

	#[test]
	fn default_theme_is_sunny_with_the_softer_pen() {
		let theme = Theme::default();
		assert_eq!(theme, Theme::colorway(Colorway::Sunny));
		assert_eq!(theme.stroke_width, 1.6);
		assert_eq!(theme.roughness, 1.1);
		assert_eq!(theme.marker(), Tone::from(colorway::swatch::SUNSHINE));
		assert_eq!(theme.accent(), Tone::from(colorway::swatch::TOMATO));
		assert_eq!(theme.light.paper, color(colorway::swatch::PAPER));
		assert_eq!(theme.dark.paper, color(colorway::swatch::NIGHT));
	}

	#[test]
	fn palettes_match_the_framework_free_colourways() {
		for colorway in Colorway::ALL {
			let theme = Theme::colorway(colorway);
			for (palette, appearance) in [
				(theme.light, Appearance::Light),
				(theme.dark, Appearance::Dark),
			] {
				assert_eq!(palette.marker, color(colorway.marker(appearance)));
				assert_eq!(palette.accent, color(colorway.accent(appearance)));
				let washes: Vec<_> = colorway
					.washes(appearance)
					.iter()
					.map(|wash| color(*wash))
					.collect();
				assert_eq!(palette.washes, washes.as_slice());
			}
		}
	}

	#[test]
	fn accents_cycle_in_each_appearance() {
		let quiet = Theme::colorway(Colorway::Quiet);
		assert_eq!(quiet.accent_at(1).light, color(colorway::swatch::PEACH));
		assert_eq!(quiet.accent_at(1).dark, color(colorway::swatch::DUSK));
		let sunny = Theme::SKRIBBLE;
		assert_eq!(sunny.accent_at(6), sunny.accent_at(0));
		assert_eq!(sunny.accent_at(1), Tone::from(colorway::swatch::SKY));
	}

	#[test]
	fn labels_on_a_wash_flip_in_dark_mode() {
		let theme = Theme::SKRIBBLE;
		let on = theme.on(theme.accent_at(0));
		assert_eq!(on.light, color(colorway::swatch::INK));
		assert_eq!(on.dark, color(colorway::swatch::NIGHT));
		assert_eq!(theme.on(theme.paper()), theme.ink());
		assert_eq!(theme.on_accent(), theme.on(theme.accent()));
	}
}
