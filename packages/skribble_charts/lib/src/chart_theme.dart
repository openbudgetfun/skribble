import 'package:flutter/widgets.dart';
import 'package:skribble_charts/src/chart_indicators.dart';

/// The price representation used by a financial chart.
enum WiredPriceSeries {
  /// Open and close bodies with exact high and low wicks.
  candlesticks,

  /// Connected closing prices.
  line,

  /// Connected closing prices shaded down to the pane boundary.
  area,

  /// OHLC bars with open ticks on the left and close ticks on the right.
  bars,
}

/// Ink, paper, and drawing policy shared by every chart pane.
@immutable
final class WiredChartStyle {
  /// Creates a chart palette.
  ///
  /// [roughness] controls decorative sideways displacement in logical pixels.
  /// Price boundaries and wick endpoints never move. [indicatorColors] cycles
  /// across indicator lines; an empty list uses [foreground]. Supply an
  /// immutable list, such as a const list or [List.unmodifiable], and create a
  /// new style to change it. Mutating an existing palette is unsupported.
  const WiredChartStyle({
    this.background = const Color(0xFFFFFCF5),
    this.foreground = const Color(0xFF302E2A),
    this.grid = const Color(0xFFDCD8CF),
    this.rise = const Color(0xFF267755),
    this.fall = const Color(0xFFBA4945),
    this.indicatorColors = const [
      Color(0xFF4864A4),
      Color(0xFFB47627),
      Color(0xFF845596),
      Color(0xFF31818A),
    ],
    this.handDrawn = true,
    this.roughness = 0.35,
  }) : assert(
         roughness >= 0 && roughness <= 2,
         'Roughness must be between zero and two.',
       );

  /// Background paper color.
  final Color background;

  /// Axis text and annotation ink.
  final Color foreground;

  /// Subtle grid line ink.
  final Color grid;

  /// Ink for candles closing at or above their open.
  final Color rise;

  /// Ink for candles closing below their open.
  final Color fall;

  /// Immutable colors assigned successively to indicator lines.
  final List<Color> indicatorColors;

  /// Whether candle sides and interior hatching have hand-drawn texture.
  final bool handDrawn;

  /// Maximum decorative displacement in logical pixels, from zero to two.
  final double roughness;

  /// Returns a palette color without requiring a nonempty indicator palette.
  Color indicatorColor(int index) => indicatorColors.isEmpty
      ? foreground
      : indicatorColors[index % indicatorColors.length];
}

/// A pane below the main price chart with the same horizontal time scale.
@immutable
sealed class WiredChartPane {
  /// Sets the relative height of this pane compared with other lower panes.
  const WiredChartPane({this.weight = 1})
    : assert(weight > 0, 'Pane weight must be positive.');

  /// Relative share of the lower-pane area.
  final double weight;
}

/// Volume bars colored by each candle's price direction.
final class WiredVolumePane extends WiredChartPane {
  /// Creates a volume pane with optional relative [weight].
  const WiredVolumePane({super.weight});
}

/// A separate indicator scale, for example RSI or MACD.
final class WiredIndicatorPane extends WiredChartPane {
  /// Creates a pane for [indicator] with optional relative [weight].
  const WiredIndicatorPane({required this.indicator, super.weight});

  /// Indicator whose lines and optional histogram fill this pane.
  final WiredChartIndicator indicator;
}
