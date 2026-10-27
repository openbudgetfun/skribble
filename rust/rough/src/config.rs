//! How far the hand wanders from the ideal geometry.

use crate::Randomizer;
use crate::RoughPen;

/// The values that shape a rough drawing.
///
/// Start from the defaults and change what you need:
///
/// ```
/// use skribble_rough::DrawOptions;
///
/// let options = DrawOptions {
/// 	seed: 7,
/// 	roughness: 1.4,
/// 	..DrawOptions::default()
/// };
/// assert_eq!(options.bowing, 1.0);
/// ```
#[derive(Debug, Clone, Copy, PartialEq)]
pub struct DrawOptions {
	/// Largest endpoint displacement, in drawing units, before roughness.
	pub max_randomness_offset: f64,
	/// Amplitude multiplier for every random displacement.
	pub roughness: f64,
	/// How far straight edges bow away from their chord.
	pub bowing: f64,
	/// Local wandering along long edges; zero restores softly bowed lines.
	pub line_wobble: f64,
	/// How closely ellipses follow their ideal radius, from zero to one.
	pub curve_fitting: f64,
	/// Catmull-Rom tension for fitted curves; zero is the smoothest.
	pub curve_tightness: f64,
	/// Minimum number of points used to approximate a full ellipse.
	pub curve_step_count: f64,
	/// Seed for the random stream. The same seed always draws the same shape.
	pub seed: i64,
	/// How ink leaves the pen along the generated geometry.
	pub pen: RoughPen,
}

impl Default for DrawOptions {
	/// The library defaults: playful roughness drawn with [`RoughPen::INK`].
	fn default() -> Self {
		Self {
			max_randomness_offset: 1.2,
			roughness: 1.1,
			bowing: 1.0,
			line_wobble: 0.35,
			curve_fitting: 0.95,
			curve_tightness: 0.0,
			curve_step_count: 9.0,
			seed: 1,
			pen: RoughPen::INK,
		}
	}
}

/// [`DrawOptions`] together with the random stream they seed.
///
/// Each configuration owns its stream, so build a new one for every shape
/// (and for its filler) instead of sharing one: drawing advances the stream.
#[derive(Debug, Clone, PartialEq)]
pub struct DrawConfig {
	/// The values the configuration draws with.
	pub options: DrawOptions,
	randomizer: Randomizer,
}

impl DrawConfig {
	/// Creates a configuration with a fresh stream for `options.seed`.
	pub fn new(options: DrawOptions) -> Self {
		Self {
			options,
			randomizer: Randomizer::new(options.seed),
		}
	}

	/// The next random value in `[0, 1)`.
	pub fn next_double(&mut self) -> f64 {
		self.randomizer.next_double()
	}

	/// A random displacement between `min` and `max`, scaled by roughness and
	/// `gain`.
	pub fn offset(&mut self, min: f64, max: f64, gain: f64) -> f64 {
		self.options.roughness * gain * (self.next_double() * (max - min) + min)
	}

	/// A random displacement between `-x` and `x`, scaled by roughness and
	/// `gain`.
	pub fn offset_symmetric(&mut self, x: f64, gain: f64) -> f64 {
		self.offset(-x, x, gain)
	}

	/// A configuration with the same values and a stream of its own, so
	/// replaying it never advances this one.
	#[must_use]
	pub fn fork(&self, edit: impl FnOnce(&mut DrawOptions)) -> Self {
		let mut options = self.options;
		edit(&mut options);
		Self::new(options)
	}
}

impl Default for DrawConfig {
	fn default() -> Self {
		Self::new(DrawOptions::default())
	}
}

impl From<DrawOptions> for DrawConfig {
	fn from(options: DrawOptions) -> Self {
		Self::new(options)
	}
}
