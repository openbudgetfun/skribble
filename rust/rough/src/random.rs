//! The seeded random stream every rough shape draws from.

const MULTIPLIER: u64 = 0xffff_da61;
const LOW_MASK: u64 = 0xffff_ffff;

/// A seedable pseudo-random number generator for deterministic rough drawing.
///
/// The stream is the Dart VM's `Random(seed)` (multiply-with-carry, base
/// 2^32), reproduced bit for bit, so a seed draws exactly the shape skribble's
/// Flutter widgets, Jaspr components, and npm packages draw for it. Call
/// [`Randomizer::reset`] to replay the same sequence.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct Randomizer {
	seed: i64,
	initial: u64,
	state: u64,
}

impl Randomizer {
	/// Creates the stream for `seed`.
	pub fn new(seed: i64) -> Self {
		// Dart reads the seed as an unsigned 64-bit integer.
		let mut state = mix64(seed.cast_unsigned());
		if state == 0 {
			state = 0x5a17;
		}

		let mut randomizer = Self {
			seed,
			initial: state,
			state,
		};
		// Dart cranks the generator four times to spread the seed's bits.
		for _ in 0..4 {
			randomizer.advance();
		}
		randomizer.initial = randomizer.state;
		randomizer
	}

	/// The seed this stream was created from.
	pub fn seed(&self) -> i64 {
		self.seed
	}

	/// The next value in `[0, 1)`.
	pub fn next_double(&mut self) -> f64 {
		let high = self.advance() & 0x3ff_ffff;
		let low = self.advance() & 0x7ff_ffff;
		(high * 134_217_728 + low) as f64 / 9_007_199_254_740_992.0
	}

	/// Rewinds the stream to its first value.
	pub fn reset(&mut self) {
		self.state = self.initial;
	}

	/// `state = A * low + high`, which never overflows 64 bits. Returns the
	/// new low half.
	fn advance(&mut self) -> u64 {
		let low = self.state & LOW_MASK;
		let high = self.state >> 32;
		self.state = MULTIPLIER * low + high;
		self.state & LOW_MASK
	}
}

/// Thomas Wang's 64-bit integer mix, as the Dart VM uses it to seed `Random`.
fn mix64(seed: u64) -> u64 {
	let mut n = (!seed).wrapping_add(seed << 21);
	n ^= n >> 24;
	n = n.wrapping_mul(265);
	n ^= n >> 14;
	n = n.wrapping_mul(21);
	n ^= n >> 28;
	n.wrapping_add(n << 31)
}

#[cfg(test)]
mod tests {
	use super::*;

	#[test]
	fn reset_replays_the_same_values() {
		let mut random = Randomizer::new(42);
		let first: Vec<f64> = (0..5).map(|_| random.next_double()).collect();
		random.reset();
		let second: Vec<f64> = (0..5).map(|_| random.next_double()).collect();
		assert_eq!(first, second);
	}

	#[test]
	fn values_stay_in_the_unit_interval() {
		let mut random = Randomizer::new(-3);
		for _ in 0..1_000 {
			let value = random.next_double();
			assert!((0.0..1.0).contains(&value), "{value} is outside [0, 1)");
		}
	}
}
