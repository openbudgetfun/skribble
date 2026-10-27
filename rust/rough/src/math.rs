//! Numeric helpers that reproduce Dart's behaviour exactly, so the engine
//! writes the same bytes as `skribble_rough`.

use std::cmp::Ordering;

/// Dart's `num.clamp`: `value` limited to `[lower, upper]`.
///
/// Unlike [`f64::clamp`] it never panics, which matters when a limit derived
/// from user options comes out inverted.
pub(crate) fn clamp(value: f64, lower: f64, upper: f64) -> f64 {
	if value < lower {
		lower
	} else if value > upper {
		upper
	} else {
		value
	}
}

/// Dart's `double.compareTo` for ordinary values: `-0.0` sorts before `0.0`.
pub(crate) fn compare_doubles(a: f64, b: f64) -> Ordering {
	a.partial_cmp(&b)
		.filter(|ordering| ordering.is_ne())
		.unwrap_or_else(|| a.total_cmp(&b))
}

/// Sorts `items` in place with the insertion sort Dart's `List.sort` uses for
/// short lists.
///
/// It keeps the order identical even for comparators that are not consistent,
/// such as the zig-zag filler's rounded-up distance comparison, and never
/// panics on them as [`slice::sort_by`] may. For consistent comparators it is
/// a stable sort, which is what the TypeScript port uses for longer lists.
/// The engine only sorts polygon edges and crossings, so the quadratic cost
/// stays small.
pub(crate) fn dart_sort<T>(items: &mut [T], mut compare: impl FnMut(&T, &T) -> Ordering) {
	for i in 1..items.len() {
		let mut j = i;
		while j > 0 && compare(&items[j - 1], &items[j]) == Ordering::Greater {
			items.swap(j - 1, j);
			j -= 1;
		}
	}
}

/// Dart's `double.toStringAsFixed`, trimmed of trailing zeros.
///
/// Rust's `{:.N}` rounds exact ties to even, while Dart and JavaScript round
/// them away from zero, so ties are detected and rounded the Dart way.
pub(crate) fn format_number(value: f64, digits: usize) -> String {
	let fixed = to_fixed(value, digits);
	let trimmed = if fixed.contains('.') {
		fixed.trim_end_matches('0').trim_end_matches('.')
	} else {
		&fixed
	};

	if trimmed == "-0" {
		"0".to_owned()
	} else {
		trimmed.to_owned()
	}
}

/// Dart's `double.toString`, which keeps `.0` on whole numbers and switches
/// to exponents outside `[1e-6, 1e21)`.
pub(crate) fn dart_double_to_string(value: f64) -> String {
	if value.is_finite() && value == value.trunc() && value.abs() < 1e21 {
		let sign = if value.is_sign_negative() { "-" } else { "" };
		return format!("{sign}{:.0}.0", value.abs());
	}

	shortest_decimal(value)
}

/// JavaScript's `Number.prototype.toFixed`, which Dart's `toStringAsFixed`
/// matches for the values the engine writes.
fn to_fixed(value: f64, digits: usize) -> String {
	let magnitude = value.abs();
	if !value.is_finite() || magnitude >= 1e21 {
		return shortest_decimal(value);
	}

	let sign = if value < 0.0 { "-" } else { "" };
	let rounded = format!("{magnitude:.digits$}");

	// Only a value whose scaled fraction is close to one half can be a tie;
	// skip the slow exact expansion for everything else.
	let scaled = magnitude * 10f64.powi(digits as i32);
	if (scaled.fract() - 0.5).abs() > 1e-4 {
		return format!("{sign}{rounded}");
	}

	// An exact tie has a 5 right after the last kept digit and nothing but
	// zeros after it. Twenty-five more digits reach past the precision of any
	// value large enough to tie at the few decimals the engine writes.
	let precise = format!("{magnitude:.precision$}", precision = digits + 25);
	let (kept, rest) = precise.split_at(precise.len() - 25);
	let kept = kept.strip_suffix('.').unwrap_or(kept);
	let is_tie = rest.starts_with('5') && rest[1..].bytes().all(|byte| byte == b'0');

	// Rust kept the truncated digits, so it rounded the tie down to even.
	if is_tie && rounded == kept {
		format!("{sign}{}", increment_last_digit(kept))
	} else {
		format!("{sign}{rounded}")
	}
}

/// Adds one unit in the last place to a decimal string such as `"9.99"`.
fn increment_last_digit(decimal: &str) -> String {
	let mut bytes = decimal.as_bytes().to_vec();
	for index in (0..bytes.len()).rev() {
		match bytes[index] {
			b'.' => {}
			b'9' => bytes[index] = b'0',
			digit => {
				bytes[index] = digit + 1;
				return String::from_utf8(bytes).expect("decimal digits are ASCII");
			}
		}
	}
	bytes.insert(0, b'1');
	String::from_utf8(bytes).expect("decimal digits are ASCII")
}

/// The shortest round-tripping decimal, written as JavaScript's
/// `Number.prototype.toString` and Dart's `double.toString` write it.
fn shortest_decimal(value: f64) -> String {
	if value.is_nan() {
		return "NaN".to_owned();
	}
	if value.is_infinite() {
		return if value > 0.0 { "Infinity" } else { "-Infinity" }.to_owned();
	}

	// `{:e}` gives the shortest round-tripping digits and an exponent.
	let scientific = format!("{:e}", value.abs());
	let (mantissa, exponent) = scientific
		.split_once('e')
		.expect("`{:e}` always writes an exponent");
	let exponent: i32 = exponent.parse().expect("`{:e}` writes an integer exponent");
	let digits: String = mantissa.chars().filter(char::is_ascii_digit).collect();
	let count = digits.len() as i32;
	let sign = if value < 0.0 { "-" } else { "" };

	// The decimal point sits after `point` digits.
	let point = exponent + 1;
	let body = if (-5..=21).contains(&point) {
		if point <= 0 {
			format!("0.{}{digits}", "0".repeat(point.unsigned_abs() as usize))
		} else if point >= count {
			format!("{digits}{}", "0".repeat((point - count) as usize))
		} else {
			let (whole, fraction) = digits.split_at(point as usize);
			format!("{whole}.{fraction}")
		}
	} else {
		let (first, rest) = digits.split_at(1);
		let fraction = if rest.is_empty() {
			String::new()
		} else {
			format!(".{rest}")
		};
		let exponent_sign = if exponent < 0 { "-" } else { "+" };
		format!("{first}{fraction}e{exponent_sign}{}", exponent.abs())
	};

	format!("{sign}{body}")
}

#[cfg(test)]
mod tests {
	use super::*;

	#[test]
	fn fixed_rounds_exact_ties_away_from_zero() {
		assert_eq!(to_fixed(0.25, 1), "0.3");
		assert_eq!(to_fixed(0.125, 2), "0.13");
		assert_eq!(to_fixed(-0.125, 2), "-0.13");
		assert_eq!(to_fixed(2.5, 0), "3");
		assert_eq!(to_fixed(9.995, 2), "9.99");
		assert_eq!(to_fixed(99.5, 0), "100");
		assert_eq!(to_fixed(1.005, 2), "1.00");
	}

	#[test]
	fn format_number_trims_zeros_and_negative_zero() {
		assert_eq!(format_number(4.0, 2), "4");
		assert_eq!(format_number(4.5, 2), "4.5");
		assert_eq!(format_number(-0.001, 2), "0");
		assert_eq!(format_number(123.456, 2), "123.46");
		assert_eq!(format_number(f64::NAN, 2), "NaN");
		assert_eq!(format_number(f64::INFINITY, 2), "Infinity");
		assert_eq!(format_number(f64::NEG_INFINITY, 3), "-Infinity");
	}

	#[test]
	fn double_to_string_matches_dart() {
		assert_eq!(dart_double_to_string(1.0), "1.0");
		assert_eq!(dart_double_to_string(-0.0), "-0.0");
		assert_eq!(dart_double_to_string(0.1), "0.1");
		assert_eq!(dart_double_to_string(-12.375), "-12.375");
		assert_eq!(dart_double_to_string(1e-7), "1e-7");
		assert_eq!(dart_double_to_string(1.5e-7), "1.5e-7");
		assert_eq!(dart_double_to_string(0.000_001), "0.000001");
		assert_eq!(dart_double_to_string(1.5e21), "1.5e+21");
	}

	#[test]
	fn short_lists_sort_like_dart() {
		let mut values = vec![3.0, -0.0, 0.0, 1.0, -2.0];
		dart_sort(&mut values, |a, b| compare_doubles(*a, *b));
		assert_eq!(values, vec![-2.0, -0.0, 0.0, 1.0, 3.0]);
		assert!(values[1].is_sign_negative());
	}
}
