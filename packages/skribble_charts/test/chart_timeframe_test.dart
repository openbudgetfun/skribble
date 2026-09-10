import 'package:flutter_test/flutter_test.dart';
import 'package:skribble_charts/src/chart_data.dart';
import 'package:skribble_charts/src/chart_timeframe.dart';

void main() {
  List<WiredChartCandle> aggregate(Iterable<WiredChartCandle> candles) =>
      aggregateWiredChartCandles(
        candles,
        interval: const Duration(minutes: 5),
        sourceInterval: const Duration(minutes: 1),
      );

  test('aggregates exact OHLC and volume in time order', () {
    final result = aggregate([
      _candle(
        2,
        open: '3',
        close: '4',
        high: '6',
        low: '2',
        volume: '0.000000003',
      ),
      _candle(
        0,
        close: '2',
        high: '3',
        volume: '0.000000001',
      ),
      _candle(
        1,
        open: '2',
        close: '3',
        high: '4',
        low: '1',
        volume: '0.000000002',
      ),
    ]);
    expect(result, hasLength(1));
    expect(result.single.open.toString(), '1');
    expect(result.single.close.toString(), '4');
    expect(result.single.high.toString(), '6');
    expect(result.single.low.toString(), '0');
    expect(result.single.volume.toString(), '0.000000006');
    expect(result.single.time, DateTime.utc(2026));
    expect(result.clear, throwsUnsupportedError);
  });

  test(
    'missing intervals remain missing and partial intervals remain partial',
    () {
      final result = aggregate([_candle(1), _candle(3), _candle(15)]);
      expect(result.map((c) => c.time), [
        DateTime.utc(2026),
        DateTime.utc(2026).add(const Duration(minutes: 15)),
      ]);
      expect(result.first.volume, WiredChartDecimal.fromInt(2));
      expect(aggregate([]), isEmpty);
    },
  );

  test('duplicate source timestamps choose highest revision and avoid double volume', () {
    final result = aggregate([
      _candle(0, close: '2', revision: 2),
      _candle(0, revision: 1),
      _candle(0, close: '3', revision: 2),
    ]);
    expect(result.single.close.toString(), '3');
    expect(result.single.volume, WiredChartDecimal.fromInt(1));
    expect(result.single.revision, 0);
  });

  test('interval boundaries including dates before epoch use UTC floor', () {
    final beforeEpoch = _candle(0, time: DateTime.utc(1969, 12, 31, 23, 59));
    final result = aggregate([beforeEpoch, _candle(5), _candle(4)]);
    expect(result.first.time, DateTime.utc(1969, 12, 31, 23, 55));
    expect(result[1].time, DateTime.utc(2026));
    expect(result[2].time, DateTime.utc(2026).add(const Duration(minutes: 5)));
  });

  test('rejects misaligned source times and incompatible intervals', () {
    expect(
      () => aggregate([_candle(0, time: DateTime.utc(2026, 1, 1, 0, 0, 1))]),
      throwsArgumentError,
    );
    for (final (interval, source) in [
      (Duration.zero, const Duration(minutes: 1)),
      (const Duration(minutes: 1), Duration.zero),
      (const Duration(minutes: 3), const Duration(minutes: 2)),
      (const Duration(minutes: 1), const Duration(minutes: 2)),
    ]) {
      expect(
        () => aggregateWiredChartCandles(
          [],
          interval: interval,
          sourceInterval: source,
        ),
        throwsArgumentError,
      );
    }
  });
}

WiredChartCandle _candle(
  int minute, {
  String open = '1',
  String close = '1',
  String high = '10',
  String low = '0',
  String volume = '1',
  int revision = 0,
  DateTime? time,
}) => WiredChartCandle(
  time: time ?? DateTime.utc(2026).add(Duration(minutes: minute)),
  open: WiredChartDecimal.parse(open),
  high: WiredChartDecimal.parse(high),
  low: WiredChartDecimal.parse(low),
  close: WiredChartDecimal.parse(close),
  volume: WiredChartDecimal.parse(volume),
  revision: revision,
);
