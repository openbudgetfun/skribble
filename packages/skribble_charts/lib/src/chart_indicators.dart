import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:skribble_charts/src/chart_data.dart';

/// A technical indicator calculated from closing prices.
@immutable
sealed class WiredChartIndicator {
  /// Creates an indicator description.
  const WiredChartIndicator();

  /// A concise label suitable for chart legends.
  String get label;

  /// Calculates values aligned one-for-one with [candles].
  ///
  /// Values that need more history are represented by `null`. Calculations use
  /// double precision after reading each exact candle close. Extreme magnitudes
  /// are scaled during calculation to avoid intermediate overflow. Inputs that
  /// overflow or underflow a double, and nonfinite outputs, throw [ArgumentError].
  WiredIndicatorResult calculate(List<WiredChartCandle> candles) {
    _validate();

    return _calculate(_IndicatorInput(candles));
  }

  void _validate();

  WiredIndicatorResult _calculate(_IndicatorInput input);

  /// Encodes this indicator as a JSON-compatible map.
  Map<String, Object?> toJson();

  /// Decodes and validates an indicator description.
  ///
  /// Throws a [FormatException] when a required field is missing or invalid.
  static WiredChartIndicator fromJson(Map<String, Object?> json) {
    final type = json['type'];

    if (type is! String) {
      throw const FormatException('Indicator type must be a string');
    }

    return switch (type) {
      'sma' => WiredSma(period: _readPositiveInt(json, 'period')),
      'ema' => WiredEma(period: _readPositiveInt(json, 'period')),
      'rsi' => WiredRsi(period: _readPositiveInt(json, 'period')),
      'macd' => WiredMacd(
        fastPeriod: _readPositiveInt(json, 'fastPeriod'),
        slowPeriod: _readPositiveInt(json, 'slowPeriod'),
        signalPeriod: _readPositiveInt(json, 'signalPeriod'),
      ),
      'bollingerBands' => WiredBollingerBands(
        period: _readPositiveInt(json, 'period'),
        deviations: _readNonNegativeDouble(json, 'deviations'),
      ),
      _ => throw FormatException('Unknown indicator type: $type'),
    };
  }
}

/// Calculates several indicators with one validated close-price projection.
///
/// This is an internal rendering entry point. Call [WiredChartIndicator.calculate]
/// when calculating one indicator directly.
@internal
Map<WiredChartIndicator, WiredIndicatorResult> calculateWiredChartIndicators(
  List<WiredChartCandle> candles,
  Iterable<WiredChartIndicator> indicators,
) {
  final unique = <WiredChartIndicator>[];
  final seen = <WiredChartIndicator>{};

  for (final indicator in indicators) {
    if (seen.add(indicator)) {
      indicator._validate();
      unique.add(indicator);
    }
  }

  if (unique.isEmpty) {
    return const {};
  }

  final input = _IndicatorInput(candles);

  return Map.unmodifiable({
    for (final indicator in unique) indicator: indicator._calculate(input),
  });
}

/// A simple moving average over the latest [period] closing prices.
final class WiredSma extends WiredChartIndicator {
  /// Creates a simple moving average description.
  const WiredSma({this.period = 20});

  /// Number of closing prices in each average.
  final int period;

  @override
  String get label => 'SMA $period';

  @override
  void _validate() => _validatePositivePeriod(period, 'period');

  @override
  WiredIndicatorResult _calculate(_IndicatorInput input) {
    final closes = input.closes;
    final values = _simpleMovingAverage(closes, period);

    return WiredIndicatorResult(
      lines: [
        WiredIndicatorLine(
          label: label,
          values: _restoreScale(values, input.scale),
        ),
      ],
    );
  }

  @override
  Map<String, Object?> toJson() => {'type': 'sma', 'period': period};

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is WiredSma && period == other.period;

  @override
  int get hashCode => Object.hash(WiredSma, period);
}

/// An exponential moving average seeded by a simple moving average.
final class WiredEma extends WiredChartIndicator {
  /// Creates an exponential moving average description.
  const WiredEma({this.period = 20});

  /// Number of closing prices used by the smoothing factor.
  final int period;

  @override
  String get label => 'EMA $period';

  @override
  void _validate() => _validatePositivePeriod(period, 'period');

  @override
  WiredIndicatorResult _calculate(_IndicatorInput input) {
    final closes = input.closes;
    final values = _exponentialMovingAverage(closes, period);

    return WiredIndicatorResult(
      lines: [
        WiredIndicatorLine(
          label: label,
          values: _restoreScale(values, input.scale),
        ),
      ],
    );
  }

  @override
  Map<String, Object?> toJson() => {'type': 'ema', 'period': period};

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is WiredEma && period == other.period;

  @override
  int get hashCode => Object.hash(WiredEma, period);
}

/// Wilder's relative strength index over closing-price changes.
final class WiredRsi extends WiredChartIndicator {
  /// Creates a relative strength index description.
  const WiredRsi({this.period = 14});

  /// Number of price changes used by Wilder smoothing.
  final int period;

  @override
  String get label => 'RSI $period';

  @override
  void _validate() => _validatePositivePeriod(period, 'period');

  @override
  WiredIndicatorResult _calculate(_IndicatorInput input) {
    final closes = input.closes;
    final values = List<double?>.filled(closes.length, null);

    if (closes.length <= period) {
      return WiredIndicatorResult(
        lines: [WiredIndicatorLine(label: label, values: values)],
      );
    }

    var averageGain = 0.0;
    var averageLoss = 0.0;

    for (var index = 1; index <= period; index++) {
      final change = closes[index] - closes[index - 1];
      averageGain += math.max(change, 0);
      averageLoss += math.max(-change, 0);
    }

    averageGain /= period;
    averageLoss /= period;
    values[period] = _relativeStrengthIndex(averageGain, averageLoss);

    for (var index = period + 1; index < closes.length; index++) {
      final change = closes[index] - closes[index - 1];
      final gain = math.max(change, 0);
      final loss = math.max(-change, 0);

      averageGain = (averageGain * (period - 1) + gain) / period;
      averageLoss = (averageLoss * (period - 1) + loss) / period;
      values[index] = _relativeStrengthIndex(averageGain, averageLoss);
    }

    return WiredIndicatorResult(
      lines: [WiredIndicatorLine(label: label, values: values)],
    );
  }

  @override
  Map<String, Object?> toJson() => {'type': 'rsi', 'period': period};

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is WiredRsi && period == other.period;

  @override
  int get hashCode => Object.hash(WiredRsi, period);
}

/// Moving average convergence divergence with a signal line and histogram.
final class WiredMacd extends WiredChartIndicator {
  /// Creates a MACD description.
  const WiredMacd({
    this.fastPeriod = 12,
    this.slowPeriod = 26,
    this.signalPeriod = 9,
  });

  /// Period of the faster exponential moving average.
  final int fastPeriod;

  /// Period of the slower exponential moving average.
  final int slowPeriod;

  /// Period of the exponential average over MACD values.
  final int signalPeriod;

  @override
  String get label => 'MACD $fastPeriod, $slowPeriod, $signalPeriod';

  @override
  void _validate() {
    _validatePositivePeriod(fastPeriod, 'fastPeriod');
    _validatePositivePeriod(slowPeriod, 'slowPeriod');
    _validatePositivePeriod(signalPeriod, 'signalPeriod');
  }

  @override
  WiredIndicatorResult _calculate(_IndicatorInput input) {
    final closes = input.closes;
    final fast = _exponentialMovingAverage(closes, fastPeriod);
    final slow = _exponentialMovingAverage(closes, slowPeriod);
    final macd = List<double?>.filled(closes.length, null);

    for (var index = 0; index < closes.length; index++) {
      final fastValue = fast[index];
      final slowValue = slow[index];

      if (fastValue != null && slowValue != null) {
        macd[index] = fastValue - slowValue;
      }
    }

    final signal = _emaOfNullable(macd, signalPeriod);
    final histogram = List<double?>.filled(closes.length, null);

    for (var index = 0; index < closes.length; index++) {
      final macdValue = macd[index];
      final signalValue = signal[index];

      if (macdValue != null && signalValue != null) {
        histogram[index] = macdValue - signalValue;
      }
    }

    return WiredIndicatorResult(
      lines: [
        WiredIndicatorLine(
          label: 'MACD',
          values: _restoreScale(macd, input.scale),
        ),
        WiredIndicatorLine(
          label: 'Signal',
          values: _restoreScale(signal, input.scale),
        ),
      ],
      histogram: _restoreScale(histogram, input.scale),
    );
  }

  @override
  Map<String, Object?> toJson() => {
    'type': 'macd',
    'fastPeriod': fastPeriod,
    'slowPeriod': slowPeriod,
    'signalPeriod': signalPeriod,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WiredMacd &&
          fastPeriod == other.fastPeriod &&
          slowPeriod == other.slowPeriod &&
          signalPeriod == other.signalPeriod;

  @override
  int get hashCode => Object.hash(
    WiredMacd,
    fastPeriod,
    slowPeriod,
    signalPeriod,
  );
}

/// A moving average surrounded by population-standard-deviation bands.
final class WiredBollingerBands extends WiredChartIndicator {
  /// Creates a Bollinger Bands description.
  const WiredBollingerBands({this.period = 20, this.deviations = 2.0});

  /// Number of closing prices in each rolling population.
  final int period;

  /// Population-standard-deviation multiplier for the outer bands.
  final double deviations;

  @override
  String get label => 'Bollinger Bands $period, $deviations';

  @override
  void _validate() {
    _validatePositivePeriod(period, 'period');
    _validateDeviations(deviations);
  }

  @override
  WiredIndicatorResult _calculate(_IndicatorInput input) {
    final closes = input.closes;
    final upper = List<double?>.filled(closes.length, null);
    final middle = List<double?>.filled(closes.length, null);
    final lower = List<double?>.filled(closes.length, null);
    final window = _RollingPopulation();

    for (var index = 0; index < closes.length; index++) {
      window.add(closes[index]);

      if (window.length > period) {
        window.remove(closes[index - period]);
      }

      if (window.length == period) {
        final mean = window.mean;
        final distance = math.sqrt(window.variance) * deviations;
        upper[index] = mean + distance;
        middle[index] = mean;
        lower[index] = mean - distance;
      }
    }

    return WiredIndicatorResult(
      lines: [
        WiredIndicatorLine(
          label: 'Upper',
          values: _restoreScale(upper, input.scale),
        ),
        WiredIndicatorLine(
          label: 'Middle',
          values: _restoreScale(middle, input.scale),
        ),
        WiredIndicatorLine(
          label: 'Lower',
          values: _restoreScale(lower, input.scale),
        ),
      ],
    );
  }

  @override
  Map<String, Object?> toJson() => {
    'type': 'bollingerBands',
    'period': period,
    'deviations': deviations,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WiredBollingerBands &&
          period == other.period &&
          deviations == other.deviations;

  @override
  int get hashCode => Object.hash(WiredBollingerBands, period, deviations);
}

final class _IndicatorInput {
  factory _IndicatorInput(List<WiredChartCandle> candles) {
    final closes = _finiteCloses(candles);

    return _IndicatorInput._(closes, _normalizeCloses(closes));
  }

  const _IndicatorInput._(this.closes, this.scale);

  final List<double> closes;
  final double scale;
}

/// The aligned line and optional histogram values produced by an indicator.
@immutable
final class WiredIndicatorResult {
  /// Creates an immutable indicator result; nonfinite histogram values throw.
  WiredIndicatorResult({
    required List<WiredIndicatorLine> lines,
    List<double?>? histogram,
  }) : lines = List.unmodifiable(lines),
       histogram = histogram == null ? null : List.unmodifiable(histogram) {
    if (histogram != null) _validateFiniteValues(histogram, 'histogram');
  }

  /// Indicator lines in legend and paint order.
  final List<WiredIndicatorLine> lines;

  /// Optional histogram values aligned with the input candles.
  final List<double?>? histogram;
}

/// One named sequence of indicator values aligned with the input candles.
@immutable
final class WiredIndicatorLine {
  /// Creates an immutable indicator line; nonfinite values throw.
  WiredIndicatorLine({required this.label, required List<double?> values})
    : values = List.unmodifiable(values) {
    _validateFiniteValues(values, label);
  }

  /// Text shown for this line in legends and accessibility output.
  final String label;

  /// Values aligned with input candles, with `null` during warmup.
  final List<double?> values;
}

List<double> _finiteCloses(List<WiredChartCandle> candles) {
  final closes = List<double>.filled(candles.length, 0);

  for (var index = 0; index < candles.length; index++) {
    final close = candles[index].close.toDouble();

    if (!close.isFinite || (close == 0 && !candles[index].close.isZero)) {
      throw ArgumentError.value(
        close,
        'candles[$index].close',
        'Indicator inputs require a finite double without underflow',
      );
    }

    closes[index] = close;
  }

  return closes;
}

// Normal market values retain their original arithmetic and rounding. Scaling
// only extreme magnitudes leaves ample room for squared distances and seeds.
double _normalizeCloses(List<double> closes) {
  var magnitude = 0.0;
  for (final close in closes) {
    magnitude = math.max(magnitude, close.abs());
  }
  if (magnitude == 0 || (magnitude >= 1e-100 && magnitude <= 1e100)) return 1;
  for (var index = 0; index < closes.length; index++) {
    closes[index] /= magnitude;
  }
  return magnitude;
}

List<double?> _restoreScale(List<double?> values, double scale) => scale == 1
    ? values
    : values.map((value) => value == null ? null : value * scale).toList();

void _validateFiniteValues(List<double?> values, String label) {
  for (var index = 0; index < values.length; index++) {
    final value = values[index];
    if (value != null && !value.isFinite) {
      throw ArgumentError.value(
        value,
        '$label[$index]',
        'Indicator output exceeds double precision',
      );
    }
  }
}

List<double?> _simpleMovingAverage(List<double> values, int period) {
  final averages = List<double?>.filled(values.length, null);
  var sum = 0.0;

  for (var index = 0; index < values.length; index++) {
    sum += values[index];

    if (index >= period) {
      sum -= values[index - period];
    }

    if (index >= period - 1) {
      averages[index] = sum / period;
    }
  }

  return averages;
}

List<double?> _exponentialMovingAverage(List<double> values, int period) {
  final averages = List<double?>.filled(values.length, null);

  if (values.length < period) {
    return averages;
  }

  var seed = 0.0;

  for (var index = 0; index < period; index++) {
    seed += values[index];
  }

  var average = seed / period;
  final multiplier = 2 / (period + 1);
  averages[period - 1] = average;

  for (var index = period; index < values.length; index++) {
    average += (values[index] - average) * multiplier;
    averages[index] = average;
  }

  return averages;
}

List<double?> _emaOfNullable(List<double?> values, int period) {
  final averages = List<double?>.filled(values.length, null);
  var seen = 0;
  var seed = 0.0;
  var average = 0.0;
  final multiplier = 2 / (period + 1);

  for (var index = 0; index < values.length; index++) {
    final value = values[index];

    if (value == null) {
      continue;
    }

    seen++;

    if (seen <= period) {
      seed += value;

      if (seen == period) {
        average = seed / period;
        averages[index] = average;
      }

      continue;
    }

    average += (value - average) * multiplier;
    averages[index] = average;
  }

  return averages;
}

double _relativeStrengthIndex(double averageGain, double averageLoss) {
  if (averageGain == 0 && averageLoss == 0) {
    return 50;
  }

  if (averageLoss == 0) {
    return 100;
  }

  if (averageGain == 0) {
    return 0;
  }

  final relativeStrength = averageGain / averageLoss;

  return 100 - 100 / (1 + relativeStrength);
}

void _validatePositivePeriod(int period, String name) {
  if (period <= 0) {
    throw ArgumentError.value(period, name, 'Must be greater than zero');
  }
}

void _validateDeviations(double deviations) {
  if (!deviations.isFinite || deviations < 0) {
    throw ArgumentError.value(
      deviations,
      'deviations',
      'Must be finite and non-negative',
    );
  }
}

int _readPositiveInt(Map<String, Object?> json, String name) {
  final value = json[name];

  if (value is! int || value <= 0) {
    throw FormatException('$name must be a positive integer');
  }

  return value;
}

double _readNonNegativeDouble(Map<String, Object?> json, String name) {
  final value = json[name];

  if (value is! num) {
    throw FormatException('$name must be a number');
  }

  final result = value.toDouble();

  if (!result.isFinite || result < 0) {
    throw FormatException('$name must be finite and non-negative');
  }

  return result;
}

class _RollingPopulation {
  var _length = 0;
  var _mean = 0.0;
  var _sumOfSquaredDistances = 0.0;

  int get length => _length;

  double get mean => _mean;

  double get variance {
    if (_length == 0) {
      return 0;
    }

    // Floating-point removal can leave a tiny negative residual for a flat
    // window. Variance is non-negative by definition.
    return math.max(0, _sumOfSquaredDistances / _length);
  }

  void add(double value) {
    _length++;
    final delta = value - _mean;
    _mean += delta / _length;
    final nextDelta = value - _mean;
    _sumOfSquaredDistances += delta * nextDelta;
  }

  void remove(double value) {
    if (_length == 1) {
      _length = 0;
      _mean = 0;
      _sumOfSquaredDistances = 0;

      return;
    }

    final nextLength = _length - 1;
    final nextMean = (_length * _mean - value) / nextLength;
    _sumOfSquaredDistances -= (value - _mean) * (value - nextMean);
    _length = nextLength;
    _mean = nextMean;
  }
}
