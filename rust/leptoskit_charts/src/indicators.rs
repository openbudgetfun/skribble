//! Pure technical indicators over closing prices.
//!
//! Every function returns one value per input slot. Warm-up slots, and slots
//! whose input is not finite, are [`None`]. The arithmetic follows the Dart
//! implementations in `packages/skribble_charts`, so ordinary market data
//! produces the same numbers as skribble's Flutter charts.
//!
//! ```
//! use skribble_leptoskit_charts::indicators;
//!
//! let closes = [1.0, 2.0, 3.0, 4.0, 5.0];
//! assert_eq!(indicators::sma(&closes, 3), [None, None, Some(2.0), Some(3.0), Some(4.0)]);
//! ```

/// A simple moving average over `period` finite closes.
///
/// Slots before the first full window are [`None`].
///
/// # Panics
///
/// Panics when `period` is zero.
pub fn sma(values: &[f64], period: usize) -> Vec<Option<f64>> {
	assert!(period > 0, "an SMA period must be greater than zero");
	let mut result = vec![None; values.len()];
	let mut window = Vec::with_capacity(period);
	let mut sum = 0.0;
	for (index, value) in finite_values(values) {
		sum += value;
		window.push(value);
		if window.len() > period {
			sum -= window.remove(0);
		}
		if window.len() == period {
			result[index] = Some(sum / period as f64);
		}
	}
	result
}

/// An exponential moving average over `period` finite closes.
///
/// The first full window seeds the average with its simple mean, then each
/// later close smooths it with `2 / (period + 1)`. Slots before the seed are
/// [`None`].
///
/// # Panics
///
/// Panics when `period` is zero.
pub fn ema(values: &[f64], period: usize) -> Vec<Option<f64>> {
	assert!(period > 0, "an EMA period must be greater than zero");
	let points = finite_values(values);
	let mut result = vec![None; values.len()];
	if points.len() < period {
		return result;
	}
	let seed: f64 = points[..period].iter().map(|(_, value)| *value).sum();
	let mut average = seed / period as f64;
	let multiplier = 2.0 / (period as f64 + 1.0);
	result[points[period - 1].0] = Some(average);
	for (index, value) in points.into_iter().skip(period) {
		average += (value - average) * multiplier;
		result[index] = Some(average);
	}
	result
}

/// Wilder's relative strength index over `period` closes.
///
/// The result runs from 0 to 100; a window with no gains or losses reads 50.
/// Slots before the first full period of changes are [`None`].
///
/// # Panics
///
/// Panics when `period` is zero.
pub fn rsi(values: &[f64], period: usize) -> Vec<Option<f64>> {
	assert!(period > 0, "an RSI period must be greater than zero");
	let points = finite_values(values);
	let mut result = vec![None; values.len()];
	if points.len() <= period {
		return result;
	}
	let mut average_gain = 0.0;
	let mut average_loss = 0.0;
	for pair in points[..=period].windows(2) {
		let change = pair[1].1 - pair[0].1;
		average_gain += change.max(0.0);
		average_loss += (-change).max(0.0);
	}
	average_gain /= period as f64;
	average_loss /= period as f64;
	result[points[period].0] = Some(relative_strength_index(average_gain, average_loss));
	for position in (period + 1)..points.len() {
		let change = points[position].1 - points[position - 1].1;
		let gain = change.max(0.0);
		let loss = (-change).max(0.0);
		average_gain = (average_gain * (period as f64 - 1.0) + gain) / period as f64;
		average_loss = (average_loss * (period as f64 - 1.0) + loss) / period as f64;
		result[points[position].0] = Some(relative_strength_index(average_gain, average_loss));
	}
	result
}

/// Moving average convergence divergence, its signal line, and histogram.
#[derive(Debug, Clone, PartialEq, Default)]
pub struct Macd {
	/// The fast EMA minus the slow EMA.
	pub macd: Vec<Option<f64>>,
	/// The exponential average of [`Self::macd`].
	pub signal: Vec<Option<f64>>,
	/// [`Self::macd`] minus [`Self::signal`].
	pub histogram: Vec<Option<f64>>,
}

/// Moving average convergence divergence over closing prices.
///
/// The fast and slow EMAs use SMA seeds; the signal line smooths the MACD
/// values that are available. Slots that need more history are [`None`].
///
/// # Panics
///
/// Panics when any period is zero.
pub fn macd(values: &[f64], fast_period: usize, slow_period: usize, signal_period: usize) -> Macd {
	assert!(
		fast_period > 0,
		"a MACD fast period must be greater than zero"
	);
	assert!(
		slow_period > 0,
		"a MACD slow period must be greater than zero"
	);
	assert!(
		signal_period > 0,
		"a MACD signal period must be greater than zero"
	);
	let fast = ema(values, fast_period);
	let slow = ema(values, slow_period);
	let mut line = vec![None; values.len()];
	for index in 0..values.len() {
		if let (Some(fast), Some(slow)) = (fast[index], slow[index]) {
			line[index] = Some(fast - slow);
		}
	}
	let signal = ema_of_available(&line, signal_period);
	let mut histogram = vec![None; values.len()];
	for index in 0..values.len() {
		if let (Some(line), Some(signal)) = (line[index], signal[index]) {
			histogram[index] = Some(line - signal);
		}
	}
	Macd {
		macd: line,
		signal,
		histogram,
	}
}

/// Bollinger Bands: an SMA middle and two population-standard-deviation bands.
#[derive(Debug, Clone, PartialEq, Default)]
pub struct BollingerBands {
	/// The middle band: an SMA over `period` closes.
	pub middle: Vec<Option<f64>>,
	/// The upper band: the middle plus `deviations` standard deviations.
	pub upper: Vec<Option<f64>>,
	/// The lower band: the middle minus `deviations` standard deviations.
	pub lower: Vec<Option<f64>>,
}

/// Bollinger Bands over `period` closes.
///
/// Bands use the population standard deviation, matching the Flutter
/// implementation. Slots before the first full window are [`None`].
///
/// # Panics
///
/// Panics when `period` is zero or `deviations` is not finite and
/// non-negative.
pub fn bollinger(values: &[f64], period: usize, deviations: f64) -> BollingerBands {
	assert!(period > 0, "a Bollinger period must be greater than zero");
	assert!(
		deviations.is_finite() && deviations >= 0.0,
		"Bollinger deviations must be finite and non-negative"
	);
	let mut upper = vec![None; values.len()];
	let mut middle = vec![None; values.len()];
	let mut lower = vec![None; values.len()];
	let mut window = RollingPopulation::default();
	let points = finite_values(values);
	for (position, (index, value)) in points.iter().enumerate() {
		window.add(*value);
		if position >= period {
			window.remove(points[position - period].1);
		}
		if position + 1 >= period {
			let mean = window.mean;
			let distance = window.variance().sqrt() * deviations;
			upper[*index] = Some(mean + distance);
			middle[*index] = Some(mean);
			lower[*index] = Some(mean - distance);
		}
	}
	BollingerBands {
		middle,
		upper,
		lower,
	}
}

/// The finite values in `values` paired with their original indices.
fn finite_values(values: &[f64]) -> Vec<(usize, f64)> {
	values
		.iter()
		.enumerate()
		.filter(|(_, value)| value.is_finite())
		.map(|(index, value)| (index, *value))
		.collect()
}

/// An EMA over the values that are present, skipping gaps.
fn ema_of_available(values: &[Option<f64>], period: usize) -> Vec<Option<f64>> {
	let mut result = vec![None; values.len()];
	let mut seen = 0;
	let mut seed = 0.0;
	let mut average = 0.0;
	let multiplier = 2.0 / (period as f64 + 1.0);
	for (index, value) in values.iter().enumerate() {
		let Some(value) = value else {
			continue;
		};
		seen += 1;
		if seen <= period {
			seed += value;
			if seen == period {
				average = seed / period as f64;
				result[index] = Some(average);
			}
		} else {
			average += (value - average) * multiplier;
			result[index] = Some(average);
		}
	}
	result
}

/// Wilder's RSI from average gains and losses.
fn relative_strength_index(average_gain: f64, average_loss: f64) -> f64 {
	if average_gain == 0.0 && average_loss == 0.0 {
		return 50.0;
	}
	if average_loss == 0.0 {
		return 100.0;
	}
	if average_gain == 0.0 {
		return 0.0;
	}
	100.0 - 100.0 / (1.0 + average_gain / average_loss)
}

/// A rolling population, matching the Dart implementation's Welford updates.
#[derive(Debug, Clone, Default)]
struct RollingPopulation {
	length: usize,
	mean: f64,
	sum_of_squared_distances: f64,
}

impl RollingPopulation {
	fn add(&mut self, value: f64) {
		self.length += 1;
		let delta = value - self.mean;
		self.mean += delta / self.length as f64;
		let next_delta = value - self.mean;
		self.sum_of_squared_distances += delta * next_delta;
	}

	fn remove(&mut self, value: f64) {
		if self.length == 1 {
			*self = Self::default();
			return;
		}
		let next_length = self.length - 1;
		let next_mean = (self.length as f64 * self.mean - value) / next_length as f64;
		self.sum_of_squared_distances -= (value - self.mean) * (value - next_mean);
		self.length = next_length;
		self.mean = next_mean;
	}

	fn variance(&self) -> f64 {
		if self.length == 0 {
			return 0.0;
		}
		(self.sum_of_squared_distances / self.length as f64).max(0.0)
	}
}

#[cfg(test)]
mod tests {
	use super::*;

	#[test]
	fn sma_matches_reference_values() {
		assert_eq!(
			sma(&[1.0, 2.0, 3.0, 4.0, 5.0], 3),
			[None, None, Some(2.0), Some(3.0), Some(4.0)]
		);
		assert_eq!(sma(&[1.0, 2.0], 5), [None, None]);
	}

	#[test]
	fn ema_is_seeded_by_an_sma() {
		assert_eq!(
			ema(&[1.0, 2.0, 3.0, 4.0, 5.0], 3),
			[None, None, Some(2.0), Some(3.0), Some(4.0)]
		);
	}

	#[test]
	fn rsi_reaches_its_extremes() {
		let rising = [1.0, 2.0, 3.0, 4.0, 5.0];
		assert_eq!(
			rsi(&rising, 3),
			[None, None, None, Some(100.0), Some(100.0)]
		);
		let falling = [5.0, 4.0, 3.0, 2.0, 1.0];
		assert_eq!(rsi(&falling, 3), [None, None, None, Some(0.0), Some(0.0)]);
		let flat = [4.0; 5];
		assert_eq!(rsi(&flat, 3), [None, None, None, Some(50.0), Some(50.0)]);
	}

	#[test]
	fn rsi_matches_wilder_smoothing() {
		let values = [44.0, 44.15, 43.9, 44.35, 44.6, 44.45, 44.2, 44.55];
		let result = rsi(&values, 3);
		assert!(result[..3].iter().all(Option::is_none));
		let expected = [Some(70.588_235_294_117_71), Some(79.591_836_734_693_9)];
		assert_eq!(result[3], expected[0]);
		assert_eq!(result[4], expected[1]);
		assert_eq!(result[6], Some(40.519_480_519_480_61));
	}

	#[test]
	fn bollinger_bands_use_population_deviation() {
		let bands = bollinger(&[1.0, 2.0, 3.0, 4.0], 3, 2.0);
		assert_eq!(bands.middle, [None, None, Some(2.0), Some(3.0)]);
		let deviation = (2.0_f64 / 3.0).sqrt() * 2.0;
		assert!((bands.upper[2].unwrap() - (2.0 + deviation)).abs() < 1e-12);
		assert!((bands.lower[2].unwrap() - (2.0 - deviation)).abs() < 1e-12);
	}

	#[test]
	fn macd_warmup_follows_both_emas() {
		let values: Vec<f64> = (1..=40).map(f64::from).collect();
		let result = macd(&values, 3, 6, 4);
		assert!(result.macd[..5].iter().all(Option::is_none));
		assert!(result.macd[5].is_some());
		assert!(result.signal[..8].iter().all(Option::is_none));
		assert!(result.signal[8].is_some());
		assert!(result.histogram[8].is_some());
	}

	#[test]
	fn non_finite_inputs_stay_missing() {
		let values = [1.0, f64::NAN, 3.0, 4.0];
		let average = sma(&values, 2);
		assert_eq!(average[1], None);
		assert_eq!(average[2], Some(2.0));
		assert_eq!(average[3], Some(3.5));
	}

	#[test]
	#[should_panic(expected = "greater than zero")]
	fn zero_periods_are_rejected() {
		let _ = sma(&[1.0], 0);
	}
}
