import 'dart:ui' show PictureRecorder;

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble_charts/src/chart_annotations.dart';
import 'package:skribble_charts/src/chart_data.dart';
import 'package:skribble_charts/src/chart_geometry.dart';
import 'package:skribble_charts/src/chart_indicators.dart';
import 'package:skribble_charts/src/chart_painter.dart';
import 'package:skribble_charts/src/chart_theme.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('drawing interpolation rounds only beyond storage precision', () {
    final tiny = WiredChartDecimal.parse('1e-1000');
    final triple = WiredChartDecimal.parse('3e-1000');
    expect(tiny.interpolate(triple, 0), same(tiny));
    expect(tiny.interpolate(triple, 1), same(triple));
    expect(tiny.interpolate(triple, .5), WiredChartDecimal.parse('2e-1000'));
    expect(tiny.interpolate(triple, .236), tiny);
    expect(() => tiny * WiredChartDecimal.parse('.06'), throwsRangeError);
  });

  test('opposite maximum magnitudes map without storing an oversized span', () {
    final max = WiredChartDecimal.parse('9' * 2000);
    final transform = WiredChartPriceTransform(
      min: -max,
      max: max,
      top: 0,
      bottom: 100,
    );
    expect(transform.yForPrice(WiredChartDecimal.zero), closeTo(50, 1e-10));
    expect(transform.priceForY(50), WiredChartDecimal.zero);
    expect(transform.priceForY(0), max);
    expect(transform.priceForY(100), -max);
  });

  test(
    'mixed extreme scales interpolate within supported coefficient size',
    () {
      final large = WiredChartDecimal.parse('1${'0' * 1499}');
      final tiny = WiredChartDecimal.parse('1e-1000');
      final transform = WiredChartPriceTransform(
        min: tiny,
        max: large,
        top: 0,
        bottom: 100,
      );
      final middle = transform.priceForY(50);
      expect(middle.ratio(large), closeTo(.5, 1e-14));
      expect(transform.yForPrice(middle), closeTo(50, 1e-10));
      expect(middle.coefficient.toString().length, lessThanOrEqualTo(2000));
    },
  );

  test(
    '1500-digit logarithmic inverse avoids scientific input exponent cap',
    () {
      final min = WiredChartDecimal.parse('1${'0' * 1499}');
      final max = WiredChartDecimal.parse('9${'0' * 1499}');
      final transform = WiredChartPriceTransform(
        min: min,
        max: max,
        top: 0,
        bottom: 100,
        scale: WiredChartPriceScale.logarithmic,
      );
      final middle = transform.priceForY(50);
      expect(middle.ratio(min), closeTo(3, 1e-9));
      expect(transform.yForPrice(middle), closeTo(50, 1e-8));
    },
  );

  test('scale1000 scene, inverse coordinates, and Fibonacci paint', () {
    final a = WiredChartDecimal.parse('1e-1000');
    final b = WiredChartDecimal.parse('3e-1000');
    final candle = _candle(0, a, b);
    final scene = _scene(
      [candle],
      annotations: [
        WiredChartFibonacci(
          id: 'tiny',
          start: WiredChartAnchor(time: candle.time, price: a),
          end: WiredChartAnchor(time: candle.time, price: b),
        ),
      ],
    );
    expect(
      scene.priceForY(scene.priceRect.center.dy),
      WiredChartDecimal.parse('2e-1000'),
    );
    expect(scene.yForPrice(a), greaterThan(scene.yForPrice(b)));
    final recorder = PictureRecorder();
    ChartPainter(scene).paint(Canvas(recorder), scene.size);
    recorder.endRecording().dispose();
  });

  test('1500-digit logarithmic scene paints axes', () {
    final a = WiredChartDecimal.parse('1${'0' * 1499}');
    final b = WiredChartDecimal.parse('9${'0' * 1499}');
    final scene = _scene([
      _candle(0, a, b),
    ], scale: WiredChartPriceScale.logarithmic);
    final recorder = PictureRecorder();
    ChartPainter(scene).paint(Canvas(recorder), scene.size);
    recorder.endRecording().dispose();
  });

  test('explicit percentage baseline stays unchanged on prepend', () {
    final baseline = WiredChartDecimal.fromInt(100);
    final current = _candle(1, baseline, WiredChartDecimal.fromInt(110));
    final before = _scene(
      [current],
      scale: WiredChartPriceScale.percentage,
      reference: baseline,
    );
    final after = _scene(
      [
        _candle(
          0,
          WiredChartDecimal.fromInt(10),
          WiredChartDecimal.fromInt(20),
        ),
        current,
      ],
      scale: WiredChartPriceScale.percentage,
      reference: baseline,
    );
    expect(before.transform.valueForPrice(current.close), closeTo(10, 1e-12));
    expect(after.transform.valueForPrice(current.close), closeTo(10, 1e-12));
    expect(
      () => _scene([current], scale: WiredChartPriceScale.percentage),
      throwsArgumentError,
    );
  });

  test('all indicators retain finite results for constant 1e308 closes', () {
    final value = WiredChartDecimal.parse('1e308');
    final candles = List.generate(50, (index) => _candle(index, value, value));
    for (final indicator in [
      const WiredSma(),
      const WiredEma(),
      const WiredRsi(),
      const WiredMacd(),
      const WiredBollingerBands(),
    ]) {
      final result = indicator.calculate(candles);
      for (final line in result.lines) {
        expect(line.values.whereType<double>(), isNotEmpty);
        expect(
          line.values.whereType<double>().every((value) => value.isFinite),
          isTrue,
        );
      }
    }
    expect(const WiredSma().calculate(candles).lines.single.values.last, 1e308);
    expect(const WiredRsi().calculate(candles).lines.single.values.last, 50);
  });

  test(
    'extreme varying finite values keep mean and variance representable',
    () {
      final candles = List.generate(30, (index) {
        final price = WiredChartDecimal.parse(index.isEven ? '1e308' : '9e307');
        return _candle(index, price, price);
      });
      final result = const WiredBollingerBands(
        period: 2,
        deviations: 1,
      ).calculate(candles);
      expect(result.lines[1].values.last! / 1e308, closeTo(.95, 1e-12));
      expect(result.lines[0].values.last! / 1e308, closeTo(1, 1e-12));
      expect(result.lines[2].values.last! / 1e308, closeTo(.9, 1e-12));
      final scene = _scene(
        candles,
        panes: const [
          WiredIndicatorPane(
            indicator: WiredBollingerBands(period: 2, deviations: 1),
          ),
        ],
      );
      final recorder = PictureRecorder();
      ChartPainter(scene).paint(Canvas(recorder), scene.size);
      recorder.endRecording().dispose();
    },
  );

  test(
    'underflowing inputs and unrepresentable indicator outputs fail explicitly',
    () {
      final tiny = WiredChartDecimal.parse('1e-1000');
      expect(
        () => const WiredSma(period: 1).calculate([_candle(0, tiny, tiny)]),
        throwsArgumentError,
      );
      final positive = WiredChartDecimal.parse('1e308');
      final negative = -positive;
      expect(
        () => const WiredBollingerBands(period: 2).calculate([
          _candle(0, positive, positive),
          _candle(1, negative, negative),
        ]),
        throwsArgumentError,
      );
      expect(
        () => WiredIndicatorLine(label: 'bad', values: const [double.infinity]),
        throwsArgumentError,
      );
      expect(
        () => WiredIndicatorResult(
          lines: const [],
          histogram: const [double.nan],
        ),
        throwsArgumentError,
      );
    },
  );
}

WiredChartCandle _candle(
  int index,
  WiredChartDecimal open,
  WiredChartDecimal close,
) => WiredChartCandle(
  time: DateTime.utc(2026, 9, 10).add(Duration(minutes: index)),
  open: open,
  close: close,
  high: open > close ? open : close,
  low: open < close ? open : close,
);

ChartScene _scene(
  List<WiredChartCandle> candles, {
  WiredChartPriceScale scale = WiredChartPriceScale.linear,
  WiredChartDecimal? reference,
  List<WiredChartAnnotation> annotations = const [],
  List<WiredChartPane> panes = const [],
}) => ChartScene(
  candles: candles,
  instrument: WiredChartInstrument(id: 'limits'),
  firstVisible: 0,
  visibleCount: candles.length.toDouble(),
  size: const Size(640, 400),
  series: WiredPriceSeries.candlesticks,
  scale: scale,
  style: const WiredChartStyle(),
  percentageReference: reference,
  annotations: annotations,
  panes: panes,
);
