import 'dart:math' as math;

import 'package:skribble_charts/src/chart_data.dart';

/// Candle-index coordinates shared by data rendering and pointer inspection.
final class WiredChartViewport {
  /// Creates an index mapping with positive [width] and [visibleCount].
  WiredChartViewport({
    required this.firstVisible,
    required this.visibleCount,
    required this.width,
  }) {
    if (!firstVisible.isFinite ||
        !visibleCount.isFinite ||
        visibleCount <= 0 ||
        !width.isFinite ||
        width <= 0) {
      throw ArgumentError(
        'Viewport coordinates must be finite; width and count must be positive',
      );
    }
  }

  /// Fractional candle slot at the left boundary.
  final double firstVisible;

  /// Candle slots across this viewport.
  final double visibleCount;

  /// Logical pixel width of the plot.
  final double width;

  /// Center of a candle slot, including fractional indices.
  double xForIndex(double index) =>
      (index - firstVisible + 0.5) / visibleCount * width;

  /// Fractional candle index at a plot-relative x position.
  double indexForX(double x) => x / width * visibleCount + firstVisible - 0.5;
}

/// Price axis mapping policies.
enum WiredChartPriceScale {
  /// Equal price differences occupy equal distances.
  linear,

  /// Equal price ratios occupy equal distances; prices must be positive.
  logarithmic,

  /// Linear positions, with percentage labels relative to a positive reference.
  percentage,
}

/// Maps exact prices to a pane, subtracting the origin before double conversion.
final class WiredChartPriceTransform {
  /// Creates a price mapping. Equal [min] and [max] map to the pane center.
  ///
  /// Logarithmic scales require positive bounds. Percentage scales require a
  /// positive [reference]. [top] must be less than [bottom].
  WiredChartPriceTransform({
    required this.min,
    required this.max,
    required this.top,
    required this.bottom,
    this.scale = WiredChartPriceScale.linear,
    this.reference,
  }) {
    if (min > max) throw ArgumentError('Price minimum must not exceed maximum');
    if (!top.isFinite || !bottom.isFinite || top >= bottom) {
      throw ArgumentError(
        'Pane bounds must be finite and top must be less than bottom',
      );
    }
    if (scale == WiredChartPriceScale.logarithmic &&
        min <= WiredChartDecimal.zero) {
      throw ArgumentError('Logarithmic price bounds must be positive');
    }
    if (scale == WiredChartPriceScale.percentage &&
        (reference == null || reference! <= WiredChartDecimal.zero)) {
      throw ArgumentError('Percentage scale requires a positive reference');
    }
    _isFlat = min == max;
    _logMin = scale == WiredChartPriceScale.logarithmic ? _log(min) : 0;
    _logRange = scale == WiredChartPriceScale.logarithmic
        ? _log(max) - _logMin
        : 0;
    if (scale == WiredChartPriceScale.logarithmic &&
        !_isFlat &&
        _logRange == 0) {
      throw ArgumentError(
        'Logarithmic bounds are too close for floating point resolution',
      );
    }
  }

  /// Smallest visible price.
  final WiredChartDecimal min;

  /// Largest visible price.
  final WiredChartDecimal max;

  /// Top logical pixel of the pane.
  final double top;

  /// Bottom logical pixel of the pane.
  final double bottom;

  /// Selected axis mapping.
  final WiredChartPriceScale scale;

  /// Percentage baseline, required only for percentage mode.
  final WiredChartDecimal? reference;
  late final bool _isFlat;
  late final double _logMin;
  late final double _logRange;

  static double _log(WiredChartDecimal value) {
    if (value <= WiredChartDecimal.zero) {
      throw ArgumentError.value(
        value,
        'price',
        'Logarithmic prices must be positive',
      );
    }
    final digits = value.coefficient.toString();
    final head = digits.substring(0, math.min(16, digits.length));
    return math.log(double.parse(head)) +
        (digits.length - head.length - value.scale) * math.ln10;
  }

  /// Maps exact price to pixels, without clamping values outside the pane.
  double yForPrice(WiredChartDecimal price) {
    if (scale == WiredChartPriceScale.logarithmic &&
        price <= WiredChartDecimal.zero) {
      throw ArgumentError.value(price, 'price', 'Must be positive');
    }
    if (_isFlat) return (top + bottom) / 2;
    final fraction = scale == WiredChartPriceScale.logarithmic
        ? (_log(price) - _logMin) / _logRange
        : price.fractionBetween(min, max);
    return bottom - fraction * (bottom - top);
  }

  /// Inverts pixels to a decimal approximation; exact endpoints are preserved.
  /// Fractional coordinates round to the decimal precision limits. Extrapolated
  /// coordinates outside the supported integer range throw [ArgumentError].
  WiredChartDecimal priceForY(double y) {
    if (!y.isFinite) throw ArgumentError.value(y, 'y', 'Must be finite');
    if (_isFlat || y == bottom) return min;
    if (y == top) return max;
    final fraction = (bottom - y) / (bottom - top);
    if (scale == WiredChartPriceScale.logarithmic) {
      final logarithm = (_logMin + fraction * _logRange) / math.ln10;
      return WiredChartDecimal.fromLog10(logarithm);
    }
    return min.interpolate(max, fraction);
  }

  /// Returns a percentage for percentage axes, otherwise an approximate price.
  double valueForPrice(WiredChartDecimal price) =>
      scale == WiredChartPriceScale.percentage
      ? price.relativeChangeFrom(reference!) * 100
      : price.toDouble();
}
