import 'package:skribble_charts/src/chart_data.dart';

/// Aggregates smaller candles into fixed UTC intervals using exact OHLC values.
///
/// [interval] must be a whole multiple of [sourceInterval]. Source timestamps
/// must align to their interval relative to the Unix epoch. Duplicate source
/// timestamps use the highest revision, with the last equal revision winning.
/// Missing intervals remain absent; incomplete groups contain only observed
/// data. Recompute from retained source candles after corrections and replace
/// the aggregate snapshot, since source revisions are local to each timestamp.
List<WiredChartCandle> aggregateWiredChartCandles(
  Iterable<WiredChartCandle> candles, {
  required Duration interval,
  required Duration sourceInterval,
}) {
  final width = interval.inMicroseconds;
  final sourceWidth = sourceInterval.inMicroseconds;
  if (sourceWidth <= 0 || width <= 0 || width % sourceWidth != 0) {
    throw ArgumentError(
      'Aggregation interval must be a positive whole multiple of the source interval',
    );
  }
  final byTime = <DateTime, WiredChartCandle>{};
  for (final candle in candles) {
    if (candle.time.microsecondsSinceEpoch % sourceWidth != 0) {
      throw ArgumentError.value(
        candle.time,
        'time',
        'Source candle is not aligned to its interval',
      );
    }
    final existing = byTime[candle.time];
    if (existing == null || candle.revision >= existing.revision) {
      byTime[candle.time] = candle;
    }
  }
  final ordered = byTime.values.toList()
    ..sort((a, b) => a.time.compareTo(b.time));
  final result = <WiredChartCandle>[];
  for (final candle in ordered) {
    final timestamp = candle.time.microsecondsSinceEpoch;
    // Euclidean modulo also aligns dates before the Unix epoch correctly.
    final start = DateTime.fromMicrosecondsSinceEpoch(
      timestamp - timestamp % width,
      isUtc: true,
    );
    if (result.isEmpty || result.last.time != start) {
      result.add(
        WiredChartCandle(
          time: start,
          open: candle.open,
          high: candle.high,
          low: candle.low,
          close: candle.close,
          volume: candle.volume,
        ),
      );
      continue;
    }
    final previous = result.removeLast();
    result.add(
      WiredChartCandle(
        time: start,
        open: previous.open,
        high: candle.high > previous.high ? candle.high : previous.high,
        low: candle.low < previous.low ? candle.low : previous.low,
        close: candle.close,
        volume: previous.volume + candle.volume,
      ),
    );
  }
  return List.unmodifiable(result);
}
