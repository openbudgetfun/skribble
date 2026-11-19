//! The colours and line weight charts draw with.

use crate::Tone;
use crate::colorway::Rgba;

/// The inks a chart draws with, in light and dark appearances.
///
/// Start from [`ChartTheme::SKRIBBLE`], skribble's own palette, and replace the
/// roles you need. Rising and falling candles, the grid, and indicator lines
/// each carry two [`Tone`]s so they follow the host's appearance without any
/// JavaScript.
///
/// ```
/// use skribble_core::Tone;
/// use skribble_core::charts::ChartTheme;
/// use skribble_core::colorway::Rgba;
///
/// pub const MINT: ChartTheme = ChartTheme {
/// 	rise: Tone {
/// 		light: Rgba::new(0x26, 0x77, 0x55, 0xff),
/// 		dark: Rgba::new(0x8c, 0xe9, 0xc2, 0xff),
/// 	},
/// 	..ChartTheme::SKRIBBLE
/// };
/// ```
#[derive(Debug, Clone, Copy, PartialEq)]
pub struct ChartTheme {
	/// The paper behind the plot.
	pub background: Tone,
	/// Axis text and annotation ink.
	pub foreground: Tone,
	/// Subtle horizontal grid lines.
	pub grid: Tone,
	/// Candles and bars that close at or above their open.
	pub rise: Tone,
	/// Candles and bars that close below their open.
	pub fall: Tone,
	/// Tones cycled across overlay lines.
	pub indicator_colors: [Tone; 4],
	/// How far decorative strokes wander, in logical pixels.
	pub roughness: f64,
	/// Outline width, in logical pixels.
	pub stroke_width: f32,
}

impl ChartTheme {
	/// skribble's chart palette: warm paper, green rises, and rust falls.
	pub const SKRIBBLE: Self = Self {
		background: Tone {
			light: Rgba::new(0xff, 0xfc, 0xf5, 0xff),
			dark: Rgba::new(0x1b, 0x1a, 0x17, 0xff),
		},
		foreground: Tone {
			light: Rgba::new(0x30, 0x2e, 0x2a, 0xff),
			dark: Rgba::new(0xf2, 0xef, 0xe6, 0xff),
		},
		grid: Tone {
			light: Rgba::new(0xdc, 0xd8, 0xcf, 0xff),
			dark: Rgba::new(0x3d, 0x3f, 0x3b, 0xff),
		},
		rise: Tone {
			light: Rgba::new(0x26, 0x77, 0x55, 0xff),
			dark: Rgba::new(0x85, 0xc7, 0xa0, 0xff),
		},
		fall: Tone {
			light: Rgba::new(0xba, 0x49, 0x45, 0xff),
			dark: Rgba::new(0xe3, 0x9a, 0x87, 0xff),
		},
		indicator_colors: [
			Tone {
				light: Rgba::new(0x48, 0x64, 0xa4, 0xff),
				dark: Rgba::new(0x9f, 0xbe, 0xeb, 0xff),
			},
			Tone {
				light: Rgba::new(0xb4, 0x76, 0x27, 0xff),
				dark: Rgba::new(0xde, 0xc1, 0x8c, 0xff),
			},
			Tone {
				light: Rgba::new(0x84, 0x55, 0x96, 0xff),
				dark: Rgba::new(0xd1, 0xa9, 0xe8, 0xff),
			},
			Tone {
				light: Rgba::new(0x31, 0x81, 0x8a, 0xff),
				dark: Rgba::new(0x84, 0xcb, 0xd1, 0xff),
			},
		],
		roughness: 0.35,
		stroke_width: 1.0,
	};

	/// The tone for the indicator at `index`, cycling through
	/// [`Self::indicator_colors`].
	pub const fn indicator(&self, index: usize) -> Tone {
		self.indicator_colors[index % self.indicator_colors.len()]
	}
}

impl Default for ChartTheme {
	fn default() -> Self {
		Self::SKRIBBLE
	}
}

#[cfg(test)]
mod tests {
	use super::*;

	#[test]
	fn indicator_tones_cycle() {
		let theme = ChartTheme::SKRIBBLE;
		assert_eq!(theme.indicator(0), theme.indicator(4));
		assert_ne!(theme.indicator(0), theme.indicator(1));
	}
}
