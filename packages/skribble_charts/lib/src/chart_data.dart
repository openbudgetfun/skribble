import 'dart:math' as math;

import 'package:flutter/foundation.dart';

/// An exact decimal represented as [coefficient] × 10⁻[scale].
///
/// Only conversion to [double] loses decimal precision. Input scale is bounded
/// to 1000 places so malformed persisted values cannot allocate arbitrary powers.
@immutable
final class WiredChartDecimal implements Comparable<WiredChartDecimal> {
  /// Creates a normalized value with a [scale] between zero and 1000 and at
  /// most 2000 coefficient digits. Canonical strings always parse again.
  factory WiredChartDecimal(BigInt coefficient, int scale) {
    if (scale < 0 || scale > 1000) {
      throw RangeError.range(scale, 0, 1000, 'scale');
    }
    var normalizedCoefficient = coefficient;
    var normalizedScale = scale;
    while (normalizedScale > 0 &&
        normalizedCoefficient.remainder(_ten) == BigInt.zero) {
      normalizedCoefficient ~/= _ten;
      normalizedScale--;
    }
    if (normalizedCoefficient.abs().toString().length > 2000) {
      throw ArgumentError.value(
        coefficient,
        'coefficient',
        'At most 2000 digits are supported',
      );
    }
    return WiredChartDecimal._(normalizedCoefficient, normalizedScale);
  }

  const WiredChartDecimal._(this.coefficient, this.scale);

  /// Converts an integer without floating point arithmetic.
  factory WiredChartDecimal.fromInt(int value) =>
      WiredChartDecimal(BigInt.from(value), 0);

  /// Parses decimal or scientific notation, with at most 4096 input characters
  /// and an exponent between −1000 and 1000.
  factory WiredChartDecimal.parse(String value) {
    final match = _pattern.firstMatch(value);
    if (match == null || value.length > 4096) {
      throw FormatException('Invalid chart decimal', value);
    }
    final whole = match.group(2) ?? '0';
    final fraction = match.group(3) ?? match.group(4) ?? '';
    final digits = '$whole$fraction';
    final exponent = int.tryParse(match.group(5) ?? '0');
    if (exponent == null || exponent.abs() > 1000) {
      throw FormatException('Chart decimal exceeds supported precision', value);
    }
    final scale = fraction.length - exponent;
    if (scale > 1000) {
      throw FormatException('Chart decimal exceeds supported scale', value);
    }
    final coefficient = BigInt.parse(
      '${match.group(1) == '-' ? '-' : ''}$digits',
    );
    if (coefficient.abs().toString().length + (scale < 0 ? -scale : 0) > 2000) {
      throw FormatException(
        'Chart decimal exceeds supported coefficient size',
        value,
      );
    }
    return scale < 0
        ? WiredChartDecimal(coefficient * _ten.pow(-scale), 0)
        : WiredChartDecimal(coefficient, scale);
  }

  /// Approximates a positive drawing coordinate from its base-ten logarithm.
  ///
  /// Rounding follows [interpolate]. The returned number can exceed the range
  /// of a double. Values outside the supported decimal range throw.
  factory WiredChartDecimal.fromLog10(double logarithm) {
    if (!logarithm.isFinite || logarithm < -1000 || logarithm >= 2000) {
      throw ArgumentError.value(
        logarithm,
        'logarithm',
        'Outside the supported decimal range',
      );
    }
    final exponent = logarithm.floor();
    final mantissa = WiredChartDecimal.parse(
      math.pow(10, logarithm - exponent).toString(),
    );
    return WiredChartDecimal._rounded(
      mantissa.coefficient,
      mantissa.scale - exponent,
    );
  }

  factory WiredChartDecimal._rounded(BigInt coefficient, int scale) {
    if (scale < 0) return WiredChartDecimal(coefficient * _ten.pow(-scale), 0);
    final digits = coefficient.abs().toString().length;
    final discard = math.max(0, math.max(scale - 1000, digits - 2000));
    if (discard > scale) {
      throw ArgumentError('Drawing coordinate exceeds 2000 integer digits');
    }
    if (discard == 0) return WiredChartDecimal(coefficient, scale);
    final divisor = _ten.pow(discard);
    var rounded = coefficient ~/ divisor;
    if (coefficient.abs().remainder(divisor) * BigInt.two >= divisor) {
      rounded += coefficient.isNegative ? -BigInt.one : BigInt.one;
    }
    return WiredChartDecimal(rounded, scale - discard);
  }

  static final _ten = BigInt.from(10);
  static final _pattern = RegExp(
    r'^([+-]?)(?:(\d+)(?:\.(\d*))?|\.(\d+))(?:[eE]([+-]?\d+))?$',
  );

  /// Exact zero.
  static final zero = WiredChartDecimal.fromInt(0);

  /// Integer digits of the normalized value.
  final BigInt coefficient;

  /// Number of fractional places.
  final int scale;

  /// Whether this is zero.
  bool get isZero => coefficient == BigInt.zero;

  /// Whether this is negative.
  bool get isNegative => coefficient.isNegative;

  /// Returns the exact absolute value.
  WiredChartDecimal abs() => WiredChartDecimal(coefficient.abs(), scale);
  BigInt _atScale(int target) =>
      target == scale ? coefficient : coefficient * _ten.pow(target - scale);

  /// Adds exact values.
  WiredChartDecimal operator +(WiredChartDecimal other) {
    final target = math.max(scale, other.scale);
    return WiredChartDecimal(_atScale(target) + other._atScale(target), target);
  }

  /// Subtracts exact values.
  WiredChartDecimal operator -(WiredChartDecimal other) => this + -other;

  /// Negates this value.
  WiredChartDecimal operator -() => WiredChartDecimal(-coefficient, scale);

  /// Multiplies exactly, subject to the 1000-place scale limit.
  WiredChartDecimal operator *(WiredChartDecimal other) =>
      WiredChartDecimal(coefficient * other.coefficient, scale + other.scale);

  /// Interpolates drawing coordinates, rounding halves away from zero only
  /// when the result would exceed 1000 fractional places or 2000 digits.
  ///
  /// Both endpoints remain exact. Source arithmetic operators remain exact and
  /// continue to reject unrepresentable results. Extrapolation is allowed when
  /// its result fits the supported integer range.
  WiredChartDecimal interpolate(WiredChartDecimal other, double fraction) {
    if (!fraction.isFinite) {
      throw ArgumentError.value(fraction, 'fraction', 'Must be finite');
    }
    if (fraction == 0 || this == other) return this;
    if (fraction == 1) return other;
    final factor = WiredChartDecimal.parse(fraction.toString());
    final commonScale = math.max(scale, other.scale);
    final start = _atScale(commonScale);
    final end = other._atScale(commonScale);
    return WiredChartDecimal._rounded(
      start * _ten.pow(factor.scale) + (end - start) * factor.coefficient,
      commonScale + factor.scale,
    );
  }

  /// Returns this value's position between exact [start] and [end] prices.
  ///
  /// Intermediate differences may be wider than a stored decimal. They are
  /// kept as integers, so opposite extremes and mixed scales stay drawable.
  double fractionBetween(WiredChartDecimal start, WiredChartDecimal end) {
    final commonScale = math.max(scale, math.max(start.scale, end.scale));
    final origin = start._atScale(commonScale);
    return _integerRatio(
      _atScale(commonScale) - origin,
      end._atScale(commonScale) - origin,
    );
  }

  /// Returns the relative change from [reference], preserving exact subtraction.
  double relativeChangeFrom(WiredChartDecimal reference) {
    final commonScale = math.max(scale, reference.scale);
    final baseline = reference._atScale(commonScale);
    return _integerRatio(_atScale(commonScale) - baseline, baseline);
  }

  static double _integerRatio(BigInt numerator, BigInt denominator) {
    if (denominator == BigInt.zero) {
      throw ArgumentError('Ratio denominator must be nonzero');
    }
    if (numerator == BigInt.zero) return 0;
    final a = numerator.abs().toString();
    final b = denominator.abs().toString();
    final headA = a.substring(0, math.min(16, a.length));
    final headB = b.substring(0, math.min(16, b.length));
    final mantissa = double.parse(headA) / double.parse(headB);
    final exponent = a.length - headA.length - b.length + headB.length;
    final sign = numerator.isNegative == denominator.isNegative ? 1 : -1;
    return double.parse('${sign * mantissa}e$exponent');
  }

  /// Divides for drawing without first overflowing either operand to double.
  ///
  /// A zero denominator throws. The result can overflow or underflow double.
  double ratio(WiredChartDecimal other) {
    if (other.isZero) {
      throw ArgumentError.value(other, 'other', 'Must be nonzero');
    }
    if (isZero) return 0;
    final numerator = coefficient.abs().toString();
    final denominator = other.coefficient.abs().toString();
    final a = math.min(16, numerator.length);
    final b = math.min(16, denominator.length);
    final mantissa =
        double.parse('${numerator[0]}.${numerator.substring(1, a)}') /
        double.parse('${denominator[0]}.${denominator.substring(1, b)}');
    final exponent =
        numerator.length - scale - denominator.length + other.scale;
    final sign = isNegative == other.isNegative ? 1 : -1;
    return double.parse('${sign * mantissa}e$exponent');
  }

  /// Converts to a floating point approximation; extremes may become infinity.
  double toDouble() => double.parse(toString());

  /// Formats [fractionDigits] places, rounding halves away from zero.
  String toStringAsFixed(int fractionDigits) {
    if (fractionDigits < 0 || fractionDigits > 1000) {
      throw RangeError.range(fractionDigits, 0, 1000, 'fractionDigits');
    }
    var digits = coefficient;
    if (fractionDigits >= scale) {
      digits *= _ten.pow(fractionDigits - scale);
    } else {
      final divisor = _ten.pow(scale - fractionDigits);
      final remainder = digits.abs().remainder(divisor);
      digits ~/= divisor;
      if (remainder * BigInt.two >= divisor) {
        digits += isNegative ? -BigInt.one : BigInt.one;
      }
    }
    return _format(digits, fractionDigits);
  }

  static String _format(BigInt coefficient, int scale) {
    final sign = coefficient.isNegative ? '-' : '';
    final digits = coefficient.abs().toString().padLeft(scale + 1, '0');
    if (scale == 0) return '$sign$digits';
    final split = digits.length - scale;
    return '$sign${digits.substring(0, split)}.${digits.substring(split)}';
  }

  @override
  String toString() => _format(coefficient, scale);

  @override
  int compareTo(WiredChartDecimal other) {
    if (identical(this, other)) return 0;
    if (scale == other.scale) return coefficient.compareTo(other.coefficient);
    final target = math.max(scale, other.scale);
    return _atScale(target).compareTo(other._atScale(target));
  }

  /// Compares exact values.
  bool operator <(WiredChartDecimal other) => compareTo(other) < 0;

  /// Compares exact values.
  bool operator <=(WiredChartDecimal other) => compareTo(other) <= 0;

  /// Compares exact values.
  bool operator >(WiredChartDecimal other) => compareTo(other) > 0;

  /// Compares exact values.
  bool operator >=(WiredChartDecimal other) => compareTo(other) >= 0;

  @override
  bool operator ==(Object other) =>
      other is WiredChartDecimal &&
      coefficient == other.coefficient &&
      scale == other.scale;

  @override
  int get hashCode => Object.hash(coefficient, scale);
}

/// Instrument identity and display precision independent of an exchange API.
final class WiredChartInstrument {
  /// Creates a nonempty [id] and decimal counts between zero and 1000.
  WiredChartInstrument({
    required this.id,
    this.priceDecimals = 2,
    this.volumeDecimals = 2,
  }) {
    if (id.trim().isEmpty) {
      throw ArgumentError.value(id, 'id', 'Must be nonempty');
    }
    for (final (name, value) in [
      ('priceDecimals', priceDecimals),
      ('volumeDecimals', volumeDecimals),
    ]) {
      if (value < 0 || value > 1000) {
        throw RangeError.range(value, 0, 1000, name);
      }
    }
  }

  /// Stable symbol or market identifier.
  final String id;

  /// Fractional places shown for prices.
  final int priceDecimals;

  /// Fractional places shown for volume.
  final int volumeDecimals;
}

/// An immutable OHLC candle with exact prices and volume.
@immutable
final class WiredChartCandle {
  /// Creates a candle, normalizing [time] to UTC.
  ///
  /// High/low must contain open/close. [volume] and [revision] are nonnegative.
  /// Validation remains active in release builds.
  WiredChartCandle({
    required DateTime time,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
    WiredChartDecimal? volume,
    this.revision = 0,
  }) : time = time.toUtc(),
       volume = volume ?? WiredChartDecimal.zero {
    if (low > high ||
        open < low ||
        open > high ||
        close < low ||
        close > high) {
      throw ArgumentError('Candle high/low must contain open and close');
    }
    if (this.volume.isNegative) {
      throw ArgumentError.value(volume, 'volume', 'Must be nonnegative');
    }
    if (revision < 0) {
      throw RangeError.value(revision, 'revision', 'Must be nonnegative');
    }
  }

  /// Start of the trading interval, in UTC.
  final DateTime time;

  /// First price in the interval.
  final WiredChartDecimal open;

  /// Highest price in the interval.
  final WiredChartDecimal high;

  /// Lowest price in the interval.
  final WiredChartDecimal low;

  /// Latest price in the interval.
  final WiredChartDecimal close;

  /// Traded amount; the consuming app defines its unit.
  final WiredChartDecimal volume;

  /// Monotonic revision per timestamp. Older revisions cannot replace newer data.
  final int revision;

  /// Whether close is greater than or equal to open.
  bool get isBullish => close >= open;

  @override
  bool operator ==(Object other) =>
      other is WiredChartCandle &&
      time == other.time &&
      open == other.open &&
      high == other.high &&
      low == other.low &&
      close == other.close &&
      volume == other.volume &&
      revision == other.revision;

  @override
  int get hashCode =>
      Object.hash(time, open, high, low, close, volume, revision);
}
