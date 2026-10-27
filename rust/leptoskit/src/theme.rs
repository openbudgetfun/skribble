//! The colours and line weight every component draws with.

use leptoskit::native::Color;

/// The colours of one appearance, light or dark.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub struct Palette {
	/// Outlines, text, and pen marks.
	pub ink: Color,
	/// The page behind everything.
	pub paper: Color,
	/// Default fills, primary buttons, and markers.
	pub accent: Color,
	/// Text and marks drawn on the accent.
	pub on_accent: Color,
}

impl Palette {
	/// skribble's light palette: dark ink on warm paper with a yellow accent.
	pub const LIGHT: Self = Self {
		ink: Color::rgba(0x1f, 0x1d, 0x1a, 0xff),
		paper: Color::rgba(0xff, 0xfd, 0xf6, 0xff),
		accent: Color::rgba(0xff, 0xd4, 0x3b, 0xff),
		on_accent: Color::rgba(0x1f, 0x1d, 0x1a, 0xff),
	};
	/// skribble's dark palette: chalk on a charcoal page.
	pub const DARK: Self = Self {
		ink: Color::rgba(0xf2, 0xef, 0xe6, 0xff),
		paper: Color::rgba(0x1b, 0x1a, 0x17, 0xff),
		accent: Color::rgba(0xe3, 0xb6, 0x2f, 0xff),
		on_accent: Color::rgba(0x1b, 0x1a, 0x17, 0xff),
	};
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

/// How skribble components draw: their colours, line weight, and wobble.
///
/// Every component takes an optional `theme` and uses [`Theme::default`]
/// without one. Define your theme once and pass it where you need it:
///
/// ```
/// use leptoskit::native::Color;
/// use skribble_leptoskit::Palette;
/// use skribble_leptoskit::Theme;
///
/// pub const MINT: Theme = Theme {
/// 	light: Palette {
/// 		accent: Color::rgba(0x8c, 0xe9, 0xc2, 0xff),
/// 		..Palette::LIGHT
/// 	},
/// 	..Theme::SKRIBBLE
/// };
/// assert_eq!(MINT.stroke_width, 2.0);
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
	/// skribble's own look.
	pub const SKRIBBLE: Self = Self {
		light: Palette::LIGHT,
		dark: Palette::DARK,
		stroke_width: 2.0,
		roughness: 1.0,
	};

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

	/// The accent tone.
	pub const fn accent(&self) -> Tone {
		Tone {
			light: self.light.accent,
			dark: self.dark.accent,
		}
	}

	/// The tone of marks on the accent.
	pub const fn on_accent(&self) -> Tone {
		Tone {
			light: self.light.on_accent,
			dark: self.dark.on_accent,
		}
	}
}

impl Default for Theme {
	fn default() -> Self {
		Self::SKRIBBLE
	}
}

/// `color` as a CSS hex colour, with alpha only when it is not opaque.
pub(crate) fn css_hex(color: Color) -> String {
	let rgb = format!(
		"#{:02x}{:02x}{:02x}",
		color.red(),
		color.green(),
		color.blue()
	);
	match color.alpha() {
		0xff => rgb,
		alpha => format!("{rgb}{alpha:02x}"),
	}
}

/// A Tailwind utility for `tone`, such as `border-[#1f1d1a]
/// dark:border-[#f2efe6]`.
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
		assert_eq!(css_hex(Palette::LIGHT.accent), "#ffd43b");
		assert_eq!(css_hex(Color::rgba(1, 2, 3, 0x80)), "#01020380");
	}

	#[test]
	fn tone_classes_switch_in_dark_mode() {
		assert_eq!(
			tone_class("bg", Theme::SKRIBBLE.accent()),
			"bg-[#ffd43b] dark:bg-[#e3b62f]"
		);
		assert_eq!(
			tone_class("text", Tone::fixed(Palette::LIGHT.ink)),
			"text-[#1f1d1a]"
		);
	}
}
