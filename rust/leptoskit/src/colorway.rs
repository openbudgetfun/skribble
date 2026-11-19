//! skribble's colours and default pen, free of any UI framework.
//!
//! Everything here is plain data: an [`Rgba`] colour type, the named
//! [`swatch`]es, the five [`Colorway`]s, and the contrast maths that picks a
//! readable ink for a wash. It mirrors `WiredPalette` and `WiredColorway` in
//! the Flutter package and the sunny stylesheet in `skribble_jaspr`, so every
//! skribble target draws the same colours.
//!
//! ```
//! use skribble_leptoskit::colorway::Appearance;
//! use skribble_leptoskit::colorway::Colorway;
//! use skribble_leptoskit::colorway::swatch;
//!
//! let sunny = Colorway::default();
//! assert_eq!(sunny.marker(Appearance::Light), swatch::SUNSHINE);
//! assert_eq!(sunny.accent(Appearance::Light), swatch::TOMATO);
//! assert_eq!(sunny.wash(Appearance::Light, 1), swatch::SKY);
//! assert_eq!(sunny.wash(Appearance::Light, 6), swatch::SUNSHINE);
//! assert_eq!(swatch::SUNSHINE.css_hex(), "#ffd43b");
//! ```

/// The outline width, in logical pixels, skribble draws with by default.
pub const STROKE_WIDTH: f32 = 1.6;

/// How far the hand wanders by default: skribble's playful roughness.
pub const ROUGHNESS: f64 = 1.1;

/// An sRGB colour with 8 bits per channel and straight alpha.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
pub struct Rgba {
	/// Red, from 0 to 255.
	pub red: u8,
	/// Green, from 0 to 255.
	pub green: u8,
	/// Blue, from 0 to 255.
	pub blue: u8,
	/// Opacity, from 0 (clear) to 255 (opaque).
	pub alpha: u8,
}

impl Rgba {
	/// A colour from its four channels.
	pub const fn new(red: u8, green: u8, blue: u8, alpha: u8) -> Self {
		Self {
			red,
			green,
			blue,
			alpha,
		}
	}

	/// An opaque colour from a `0xRR_GG_BB` literal, such as
	/// `Rgba::hex(0xff_d4_3b)`.
	pub const fn hex(rgb: u32) -> Self {
		Self::new((rgb >> 16) as u8, (rgb >> 8) as u8, rgb as u8, 0xff)
	}

	/// This colour as a CSS hex colour, such as `#ffd43b`, with an alpha pair
	/// only when it is translucent.
	pub fn css_hex(self) -> String {
		let rgb = format!("#{:02x}{:02x}{:02x}", self.red, self.green, self.blue);
		match self.alpha {
			0xff => rgb,
			alpha => format!("{rgb}{alpha:02x}"),
		}
	}

	/// The WCAG relative luminance, from 0 (black) to 1 (white). Alpha is
	/// ignored.
	pub fn luminance(self) -> f64 {
		fn linear(channel: u8) -> f64 {
			let srgb = f64::from(channel) / 255.0;
			if srgb <= 0.040_45 {
				srgb / 12.92
			} else {
				((srgb + 0.055) / 1.055).powf(2.4)
			}
		}
		0.2126 * linear(self.red) + 0.7152 * linear(self.green) + 0.0722 * linear(self.blue)
	}

	/// The WCAG contrast ratio between this colour and `other`, from 1 to 21.
	pub fn contrast(self, other: Self) -> f64 {
		let (a, b) = (self.luminance(), other.luminance());
		let (light, dark) = if a > b { (a, b) } else { (b, a) };
		(light + 0.05) / (dark + 0.05)
	}
}

/// Whichever of `ink` and `paper` reads better on `background`: the colour
/// for a label, icon, or number drawn on a wash. Ties go to `ink`.
///
/// ```
/// use skribble_leptoskit::colorway::readable_on;
/// use skribble_leptoskit::colorway::swatch;
///
/// // Plum ink reads on sunshine in the light appearance…
/// assert_eq!(readable_on(swatch::SUNSHINE, swatch::INK, swatch::PAPER), swatch::INK);
/// // …and on night paper the label flips to the dark paper colour.
/// assert_eq!(readable_on(swatch::SUNSHINE, swatch::PAPER, swatch::NIGHT), swatch::NIGHT);
/// ```
pub fn readable_on(background: Rgba, ink: Rgba, paper: Rgba) -> Rgba {
	if background.contrast(ink) >= background.contrast(paper) {
		ink
	} else {
		paper
	}
}

/// skribble's named colours, the same values as Flutter's `WiredPalette`.
///
/// The vivid colours ([`SUNSHINE`] through [`CHERRY_GLOW`]) are the markers,
/// accents, and washes of the [`Colorway`]s. Each reads with plum [`INK`] or
/// with [`NIGHT`] text at 4.5:1 or better.
pub mod swatch {
	use super::Rgba;

	/// Warm paper: the light page and the dark appearance's ink.
	pub const PAPER: Rgba = Rgba::hex(0xff_fa_f0);
	/// A deep plum night: the dark page.
	pub const NIGHT: Rgba = Rgba::hex(0x29_23_31);
	/// Plum ink: outlines and running text on paper.
	pub const INK: Rgba = Rgba::hex(0x34_28_3f);
	/// Faded plum ink, for disabled labels on paper.
	pub const MUTED_INK: Rgba = Rgba::hex(0x73_66_78);
	/// Faded paper, for disabled labels on night.
	pub const MUTED_PAPER: Rgba = Rgba::hex(0xb9_ac_bf);

	/// A pale purple wash: the quiet colourway's marker.
	pub const LILAC: Rgba = Rgba::hex(0xe5_dd_f4);
	/// A pale peach wash.
	pub const PEACH: Rgba = Rgba::hex(0xf6_df_d5);
	/// A pale sage wash.
	pub const SAGE: Rgba = Rgba::hex(0xdd_ea_d9);
	/// A pale butter wash.
	pub const BUTTER: Rgba = Rgba::hex(0xf6_e8_af);
	/// A deep plum wash: the quiet colourway's marker on night.
	pub const DUSK: Rgba = Rgba::hex(0x4a_3b_5e);
	/// A soft coral.
	pub const CORAL: Rgba = Rgba::hex(0xe8_79_60);
	/// A soft blush pink.
	pub const BLUSH: Rgba = Rgba::hex(0xf5_9c_9c);

	/// Highlighter yellow: the default marker.
	pub const SUNSHINE: Rgba = Rgba::hex(0xff_d4_3b);
	/// A juicy tomato red: the default accent on primary actions.
	pub const TOMATO: Rgba = Rgba::hex(0xff_6b_4a);
	/// A bright tangerine orange.
	pub const TANGERINE: Rgba = Rgba::hex(0xff_9f_1c);
	/// A clear sky blue.
	pub const SKY: Rgba = Rgba::hex(0x4c_c3_ff);
	/// A glowing aqua.
	pub const AQUA: Rgba = Rgba::hex(0x6b_e3_f2);
	/// A fresh mint green.
	pub const MINT: Rgba = Rgba::hex(0x3d_dc_97);
	/// An acid lime.
	pub const LIME: Rgba = Rgba::hex(0xc4_f0_4d);
	/// A bubblegum pink.
	pub const BUBBLEGUM: Rgba = Rgba::hex(0xff_85_c0);
	/// A grape violet.
	pub const GRAPE: Rgba = Rgba::hex(0xa9_8b_ff);
	/// A cornflower cobalt blue.
	pub const COBALT: Rgba = Rgba::hex(0x6a_a6_ff);
	/// A cherry red for errors on paper.
	pub const CHERRY: Rgba = Rgba::hex(0xd6_1f_45);
	/// A glowing cherry for errors on night.
	pub const CHERRY_GLOW: Rgba = Rgba::hex(0xff_6b_81);
}

/// Light or dark: which page a colour is drawn on.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash, Default)]
pub enum Appearance {
	/// Plum ink on warm paper.
	#[default]
	Light,
	/// Paper-coloured ink on a plum night.
	Dark,
}

impl Appearance {
	/// Both appearances, light first.
	pub const ALL: [Self; 2] = [Self::Light, Self::Dark];

	/// The ink for outlines and running text.
	pub const fn ink(self) -> Rgba {
		match self {
			Self::Light => swatch::INK,
			Self::Dark => swatch::PAPER,
		}
	}

	/// The page behind everything.
	pub const fn paper(self) -> Rgba {
		match self {
			Self::Light => swatch::PAPER,
			Self::Dark => swatch::NIGHT,
		}
	}

	/// The ink for disabled labels.
	pub const fn muted_ink(self) -> Rgba {
		match self {
			Self::Light => swatch::MUTED_INK,
			Self::Dark => swatch::MUTED_PAPER,
		}
	}

	/// Whichever of this appearance's ink and paper reads better on `wash`.
	pub fn ink_on(self, wash: Rgba) -> Rgba {
		readable_on(wash, self.ink(), self.paper())
	}
}

const SUNNY: [Rgba; 6] = [
	swatch::SUNSHINE,
	swatch::SKY,
	swatch::BUBBLEGUM,
	swatch::MINT,
	swatch::GRAPE,
	swatch::TANGERINE,
];
const BERRY: [Rgba; 6] = [
	swatch::BUBBLEGUM,
	swatch::GRAPE,
	swatch::TANGERINE,
	swatch::AQUA,
	swatch::SUNSHINE,
	swatch::MINT,
];
const OCEAN: [Rgba; 6] = [
	swatch::AQUA,
	swatch::COBALT,
	swatch::MINT,
	swatch::TANGERINE,
	swatch::LIME,
	swatch::GRAPE,
];
const CITRUS: [Rgba; 6] = [
	swatch::LIME,
	swatch::TANGERINE,
	swatch::SUNSHINE,
	swatch::BUBBLEGUM,
	swatch::SKY,
	swatch::MINT,
];
const QUIET: [Rgba; 4] = [swatch::LILAC, swatch::PEACH, swatch::SAGE, swatch::BUTTER];
const QUIET_DARK: [Rgba; 1] = [swatch::DUSK];

/// A named set of vivid colours: the marker under selected things, the accent
/// on the one primary action, and a run of washes for colour-coding content.
///
/// Every colourway keeps plum ink on warm paper (or paper ink on night) and
/// changes only the colour. [`Colorway::Sunny`] is the default;
/// [`Colorway::Quiet`] is the calm lilac look for briefs that ask for one.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash, Default)]
pub enum Colorway {
	/// Highlighter yellow and tomato red, with sky, bubblegum, mint, grape,
	/// and tangerine washes. The default.
	#[default]
	Sunny,
	/// Bubblegum pink and grape violet, with tangerine, aqua, and sunshine.
	Berry,
	/// Glowing aqua and cobalt blue, with mint, lime, and a tangerine spark.
	Ocean,
	/// Acid lime and juicy tangerine, with sunshine, bubblegum, and sky.
	Citrus,
	/// Lilac, peach, sage, and butter washes, for apps that want to whisper.
	Quiet,
}

impl Colorway {
	/// Every colourway, the default first.
	pub const ALL: [Self; 5] = [
		Self::Sunny,
		Self::Berry,
		Self::Ocean,
		Self::Citrus,
		Self::Quiet,
	];

	/// The highlighter under selected and active things. Vivid colourways glow
	/// the same on night; the quiet one dims to dusk.
	pub const fn marker(self, appearance: Appearance) -> Rgba {
		match (self, appearance) {
			(Self::Sunny, _) => swatch::SUNSHINE,
			(Self::Berry, _) => swatch::BUBBLEGUM,
			(Self::Ocean, _) => swatch::AQUA,
			(Self::Citrus, _) => swatch::LIME,
			(Self::Quiet, Appearance::Light) => swatch::LILAC,
			(Self::Quiet, Appearance::Dark) => swatch::DUSK,
		}
	}

	/// The fill of the one primary action on a screen.
	pub const fn accent(self, appearance: Appearance) -> Rgba {
		match (self, appearance) {
			(Self::Sunny, _) => swatch::TOMATO,
			(Self::Berry, _) => swatch::GRAPE,
			(Self::Ocean, _) => swatch::COBALT,
			(Self::Citrus, _) => swatch::TANGERINE,
			(Self::Quiet, Appearance::Light) => swatch::LILAC,
			(Self::Quiet, Appearance::Dark) => swatch::DUSK,
		}
	}

	/// The washes for colour-coding cards, chips, and series, in order. Never
	/// empty.
	pub const fn washes(self, appearance: Appearance) -> &'static [Rgba] {
		match (self, appearance) {
			(Self::Sunny, _) => &SUNNY,
			(Self::Berry, _) => &BERRY,
			(Self::Ocean, _) => &OCEAN,
			(Self::Citrus, _) => &CITRUS,
			(Self::Quiet, Appearance::Light) => &QUIET,
			(Self::Quiet, Appearance::Dark) => &QUIET_DARK,
		}
	}

	/// The wash for item `index`, cycling through [`Self::washes`], so five
	/// cards get five colours.
	pub const fn wash(self, appearance: Appearance, index: usize) -> Rgba {
		let washes = self.washes(appearance);
		washes[index % washes.len()]
	}
}

#[cfg(test)]
mod tests {
	use super::*;

	#[test]
	fn hex_unpacks_channels() {
		assert_eq!(swatch::TOMATO, Rgba::new(0xff, 0x6b, 0x4a, 0xff));
		assert_eq!(Rgba::new(1, 2, 3, 0x80).css_hex(), "#01020380");
		assert_eq!(swatch::INK.css_hex(), "#34283f");
	}

	#[test]
	fn contrast_matches_wcag() {
		let black = Rgba::hex(0);
		let white = Rgba::hex(0xff_ff_ff);
		assert!((black.contrast(white) - 21.0).abs() < 1e-9);
		assert!((white.contrast(white) - 1.0).abs() < 1e-9);
		assert_eq!(black.contrast(white), white.contrast(black));
	}

	#[test]
	fn every_wash_keeps_readable_ink_in_both_appearances() {
		for colorway in Colorway::ALL {
			for appearance in Appearance::ALL {
				let marks = [colorway.marker(appearance), colorway.accent(appearance)];
				for wash in colorway.washes(appearance).iter().chain(&marks) {
					let ink = appearance.ink_on(*wash);
					assert!(
						wash.contrast(ink) >= 4.5,
						"{colorway:?} {appearance:?} {} on {} is {:.2}:1",
						ink.css_hex(),
						wash.css_hex(),
						wash.contrast(ink)
					);
				}
			}
		}
	}

	#[test]
	fn vivid_washes_take_dark_labels_on_night() {
		for wash in Colorway::Sunny.washes(Appearance::Dark) {
			assert_eq!(Appearance::Dark.ink_on(*wash), swatch::NIGHT);
		}
		assert_eq!(Appearance::Dark.ink_on(swatch::DUSK), swatch::PAPER);
	}

	#[test]
	fn washes_cycle() {
		let sunny = Colorway::Sunny;
		assert_eq!(sunny.wash(Appearance::Light, 0), swatch::SUNSHINE);
		assert_eq!(sunny.wash(Appearance::Light, 7), swatch::SKY);
		assert_eq!(Colorway::Quiet.wash(Appearance::Dark, 3), swatch::DUSK);
		for colorway in Colorway::ALL {
			for appearance in Appearance::ALL {
				assert!(!colorway.washes(appearance).is_empty());
			}
		}
	}

	#[test]
	fn running_text_reads_on_the_page() {
		for appearance in Appearance::ALL {
			assert!(appearance.ink().contrast(appearance.paper()) >= 7.0);
			assert!(appearance.muted_ink().contrast(appearance.paper()) >= 4.5);
		}
	}
}
