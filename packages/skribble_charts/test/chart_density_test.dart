import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble_charts/src/chart_data.dart';
import 'package:skribble_charts/src/chart_geometry.dart';
import 'package:skribble_charts/src/chart_painter.dart';
import 'package:skribble_charts/src/chart_theme.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('one million visible candles preserve spikes with pixel-bounded drawing', () {
    final open = WiredChartDecimal.fromInt(100);
    final high = WiredChartDecimal.fromInt(110);
    final low = WiredChartDecimal.fromInt(90);
    final spikeHigh = WiredChartDecimal.fromInt(50000);
    final spikeLow = WiredChartDecimal.fromInt(1);
    const count = 1000000;
    const spike = 543211;
    final candles = List<WiredChartCandle>.unmodifiable(
      List.generate(
        count,
        (index) => WiredChartCandle(
          time: DateTime.fromMillisecondsSinceEpoch(index * 60000, isUtc: true),
          open: open,
          close: open,
          high: index == spike ? spikeHigh : high,
          low: index == spike ? spikeLow : low,
          volume: index == spike ? spikeHigh : open,
        ),
      ),
    );
    final timer = Stopwatch()..start();
    final scene = _scene(candles, 0, count.toDouble());
    final coldMicroseconds = timer.elapsedMicroseconds;
    timer.reset();
    final panned = _scene(candles, 128, count - 128);
    final warmMicroseconds = timer.elapsedMicroseconds;
    timer.stop();
    expect(
      scene.visibleBucketCount,
      lessThanOrEqualTo(scene.priceRect.width.ceil() + 2),
    );
    expect(
      panned.visibleBucketCount,
      lessThanOrEqualTo(panned.priceRect.width.ceil() + 2),
    );
    expect(scene.transform.min, spikeLow);
    expect(scene.transform.max, spikeHigh);
    expect(panned.transform.min, spikeLow);
    expect(panned.transform.max, spikeHigh);
    expect(scene.indexForX(scene.xForTime(candles[spike].time)), spike);

    final canvas = _CountingCanvas();
    ChartPainter(scene).paint(canvas, scene.size);
    expect(canvas.rectangles, lessThan(scene.priceRect.width * 4 + 10));
    expect(canvas.lines, lessThan(scene.priceRect.width * 4 + 10));
    expect(canvas.rectangles, greaterThan(100));
    debugPrint(
      'Dense viewport: $count candles, ${scene.visibleBucketCount} envelopes, '
      '${canvas.rectangles} rectangles, ${canvas.lines} lines; cold ${coldMicroseconds / 1000}ms, warm ${warmMicroseconds / 1000}ms.',
    );
  });

  test(
    'sampled lines retain first, last, minimum, and maximum source points',
    () {
      final value = WiredChartDecimal.fromInt(100);
      final candles = List.generate(
        4096,
        (index) => WiredChartCandle(
          time: DateTime.fromMillisecondsSinceEpoch(index * 60000, isUtc: true),
          open: value,
          close: value,
          high: value,
          low: value,
        ),
      );
      final values = List<double?>.filled(candles.length, 10);
      values[1001] = -1000;
      values[1003] = 1000;
      final scene = _scene(candles, 0, candles.length.toDouble());
      final indices = scene.sampledValueIndices(List.unmodifiable(values));
      expect(indices, containsAll([0, 1001, 1003, candles.length - 1]));
      expect(indices.length, lessThanOrEqualTo(scene.visibleBucketCount * 4));
      expect(indices, orderedEquals([...indices]..sort()));
    },
  );
}

ChartScene _scene(List<WiredChartCandle> candles, double first, double count) =>
    ChartScene(
      candles: candles,
      instrument: WiredChartInstrument(id: 'density'),
      firstVisible: first,
      visibleCount: count,
      size: const Size(640, 400),
      series: WiredPriceSeries.candlesticks,
      scale: WiredChartPriceScale.linear,
      style: const WiredChartStyle(),
      panes: const [WiredVolumePane()],
    );

class _CountingCanvas implements Canvas {
  int rectangles = 0;
  int lines = 0;

  @override
  void drawRect(Rect rect, Paint paint) => rectangles++;

  @override
  void drawLine(Offset start, Offset end, Paint paint) => lines++;

  @override
  Object? noSuchMethod(Invocation invocation) => null;
}
