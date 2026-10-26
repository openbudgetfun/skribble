//! How ink leaves the pen along a rough centreline.

use crate::math::clamp;

/// How ink leaves the pen along a rough centreline.
///
/// The generator decides *where* a line goes. A pen decides how wide the ink
/// is at each point: a light touchdown that swells to full width, slow changes
/// in pressure, a lift that thins out, and a lighter repeat stroke when the
/// generator draws a second pass. Closed loops keep going a little past where
/// they started, the way a hand closes a circle.
///
/// Widths are fractions of the caller's stroke width, and lengths are in pen
/// widths, so a pen keeps its character when the stroke gets thicker. Start
/// from a preset and change what you need:
///
/// ```
/// use skribble_rough::RoughPen;
///
/// let pen = RoughPen {
/// 	pressure: 0.2,
/// 	..RoughPen::INK
/// };
/// assert!(!pen.is_uniform());
/// ```
#[derive(Debug, Clone, Copy, PartialEq)]
pub struct RoughPen {
	/// Width at the first touch, as a fraction of the full width.
	pub start_width: f64,
	/// Width as the pen lifts, as a fraction of the full width.
	pub end_width: f64,
	/// Distance over which the stroke reaches full width, in pen widths.
	pub taper_in: f64,
	/// Distance over which the stroke thins before lifting, in pen widths.
	pub taper_out: f64,
	/// Smooth width variation along the stroke, as a fraction of the width.
	pub pressure: f64,
	/// Distance between pressure swells, in drawing units.
	pub pressure_wavelength: f64,
	/// Width of repeat passes, as a fraction of the first pass.
	pub repeat_width: f64,
	/// Share of each repeat pass that is inked, from zero to one. Below one,
	/// each repeat pass covers a seeded stretch of roughly this fraction.
	pub repeat_coverage: f64,
	/// How far a closed loop continues past its start, in pen widths.
	pub closure: f64,
	/// How far the closing stretch drifts off the line, in pen widths. The
	/// drift curls toward the inside of the shape and shrinks on small shapes.
	pub closure_drift: f64,
}

impl RoughPen {
	/// A loaded brush: sharp entry and exit with pronounced pressure.
	pub const BRUSH: Self = Self {
		start_width: 0.15,
		end_width: 0.08,
		taper_in: 6.0,
		taper_out: 10.0,
		pressure: 0.28,
		pressure_wavelength: 34.0,
		repeat_width: 0.45,
		repeat_coverage: 0.55,
		closure: 3.5,
		closure_drift: 1.2,
	};
	/// A technical pen: nearly even width with a slight touchdown.
	pub const FINELINER: Self = Self {
		start_width: 0.8,
		end_width: 0.75,
		taper_in: 2.0,
		taper_out: 2.0,
		pressure: 0.04,
		pressure_wavelength: 26.0,
		repeat_width: 0.75,
		repeat_coverage: 0.85,
		closure: 1.5,
		closure_drift: 0.5,
	};
	/// A dip pen: tapered ends, gentle swells, and a lighter second pass. The
	/// default.
	pub const INK: Self = Self {
		start_width: 0.45,
		end_width: 0.3,
		taper_in: 4.0,
		taper_out: 7.0,
		pressure: 0.14,
		pressure_wavelength: 26.0,
		repeat_width: 0.5,
		repeat_coverage: 0.45,
		closure: 2.5,
		closure_drift: 0.9,
	};
	/// Constant width, round caps, and no closure. Painted as a plain stroke.
	pub const UNIFORM: Self = Self {
		start_width: 1.0,
		end_width: 1.0,
		taper_in: 0.0,
		taper_out: 0.0,
		pressure: 0.0,
		pressure_wavelength: 26.0,
		repeat_width: 1.0,
		repeat_coverage: 1.0,
		closure: 0.0,
		closure_drift: 0.0,
	};

	/// Whether this pen lays down constant-width ink.
	pub fn is_uniform(&self) -> bool {
		self.start_width == 1.0
			&& self.end_width == 1.0
			&& self.pressure == 0.0
			&& self.repeat_width == 1.0
			&& self.repeat_coverage >= 1.0
			&& self.closure == 0.0
	}

	/// The widest the ink can get, as a multiple of the stroke width.
	pub fn peak_width(&self) -> f64 {
		1.0 + clamp(self.pressure, 0.0, 1.0)
	}

	/// The furthest ink reaches outward from its centreline, in stroke widths.
	pub fn reach(&self) -> f64 {
		self.peak_width() / 2.0
	}
}

impl Default for RoughPen {
	fn default() -> Self {
		Self::INK
	}
}

#[cfg(test)]
mod tests {
	use super::*;

	#[test]
	fn only_the_uniform_preset_is_uniform() {
		assert!(RoughPen::UNIFORM.is_uniform());
		assert!(!RoughPen::FINELINER.is_uniform());
		assert!(!RoughPen::INK.is_uniform());
		assert!(!RoughPen::BRUSH.is_uniform());
	}

	#[test]
	fn reach_grows_with_pressure() {
		assert_eq!(RoughPen::UNIFORM.reach(), 0.5);
		assert!(RoughPen::BRUSH.reach() > RoughPen::INK.reach());
	}
}
