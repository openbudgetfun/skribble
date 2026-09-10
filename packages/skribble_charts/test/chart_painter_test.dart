import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/services.dart';
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

  setUpAll(() async {
    // Flutter tests can start from the package directory or workspace root.
    // Read the checked-in font directly so unrelated test asset bundles do not
    // decide whether golden labels use the real font or Ahem rectangles.
    const fontPath = 'assets/fonts/SkribbleMonoGentle-Regular.ttf';
    final packageFont = File('../skribble/$fontPath');
    final font = packageFont.existsSync()
        ? packageFont
        : File('packages/skribble/$fontPath');
    final loader = FontLoader('ChartTestFont')
      ..addFont(
        font.readAsBytes().then(ByteData.sublistView),
      );
    await loader.load();
  });

  group('ChartScene coordinates', () {
    test('timestamps round trip across irregular candle intervals', () {
      final candles = [_candle(0), _candle(1), _candle(5), _candle(8)];
      final scene = _scene(candles: candles, visibleCount: 4);
      for (final minute in [-2, 0, 1, 3, 5, 7, 8, 10]) {
        final time = _epoch.add(Duration(minutes: minute));
        expect(scene.timeForX(scene.xForTime(time)), time);
      }
      for (var index = 0; index < candles.length; index++) {
        expect(scene.indexForX(scene.xForTime(candles[index].time)), index);
      }
      expect(scene.indexForX(scene.priceRect.left - 1), isNull);
      expect(scene.indexForX(scene.priceRect.right + 1), isNull);
    });

    test(
      'fractional viewport uses identical candle centers for hit testing',
      () {
        final candles = List.generate(30, _candle);
        final scene = _scene(
          candles: candles,
          firstVisible: 7.25,
          visibleCount: 12.5,
        );
        expect(scene.start, 7);
        expect(scene.end, 20);
        expect(
          scene.xForTime(candles[7].time),
          closeTo(
            scene.priceRect.left + scene.priceRect.width * 0.25 / 12.5,
            1e-8,
          ),
        );
        expect(scene.indexForX(scene.xForTime(candles[13].time)), 13);
      },
    );

    test(
      'source price differences smaller than double resolution stay visible',
      () {
        final base = WiredChartDecimal.parse('10000000000000000.000000001');
        final unit = WiredChartDecimal.parse('0.000000001');
        final candle = WiredChartCandle(
          time: _epoch,
          open: base,
          high: base + unit * WiredChartDecimal.fromInt(3),
          low: base - unit,
          close: base + unit,
        );
        final scene = _scene(candles: [candle]);
        expect(
          scene.yForPrice(candle.high),
          lessThan(scene.yForPrice(candle.close)),
        );
        expect(
          scene.yForPrice(candle.close),
          lessThan(scene.yForPrice(candle.open)),
        );
        expect(
          scene.yForPrice(candle.open),
          lessThan(scene.yForPrice(candle.low)),
        );
        expect(
          (scene.priceForY(scene.yForPrice(candle.close)) - candle.close)
              .abs()
              .ratio(unit),
          lessThan(1e-8),
        );
      },
    );

    test('style never changes OHLC geometry', () {
      final candles = List.generate(20, _candle);
      final crisp = _scene(
        candles: candles,
        style: const WiredChartStyle(handDrawn: false),
      );
      final rough = _scene(
        candles: candles,
        style: const WiredChartStyle(roughness: 2),
      );
      expect(crisp.priceRect, rough.priceRect);
      for (final candle in candles) {
        for (final price in [
          candle.open,
          candle.high,
          candle.low,
          candle.close,
        ]) {
          expect(crisp.yForPrice(price), rough.yForPrice(price));
        }
      }
    });

    test('offscreen candles do not compress visible price bounds', () {
      final candles = [
        _candle(0, close: '1000000'),
        ...List.generate(10, (i) => _candle(i + 1)),
      ];
      final scene = _scene(candles: candles, firstVisible: 1, visibleCount: 10);
      expect(scene.transform.max < WiredChartDecimal.fromInt(1000), isTrue);
      expect(scene.transform.min > WiredChartDecimal.zero, isTrue);
    });

    test('overlay values expand visible bounds', () {
      final candles = [
        _candle(0, close: '1000'),
        ...List.generate(10, (i) => _candle(i + 1)),
      ];
      final scene = _scene(
        candles: candles,
        firstVisible: 1,
        visibleCount: 5,
        overlays: const [WiredSma(period: 2)],
      );
      final value = scene.results.values.single.lines.single.values[1]!;
      expect(
        scene.yForPrice(WiredChartDecimal.parse(value.toString())),
        inInclusiveRange(scene.priceRect.top, scene.priceRect.bottom),
      );
      expect(scene.transform.max > WiredChartDecimal.fromInt(500), isTrue);
    });

    test(
      'indicator cache survives viewport changes but refreshes with data',
      () {
        final candles = List<WiredChartCandle>.unmodifiable(
          List.generate(30, _candle),
        );
        const indicator = WiredSma(period: 4);
        final before = _scene(candles: candles, overlays: const [indicator]);
        final after = _scene(
          candles: candles,
          firstVisible: 5,
          overlays: const [indicator],
        );
        expect(
          identical(before.results[indicator], after.results[indicator]),
          isTrue,
        );
        final changed = _scene(
          candles: List.unmodifiable([...candles, _candle(30)]),
          overlays: const [indicator],
        );
        expect(
          identical(before.results[indicator], changed.results[indicator]),
          isFalse,
        );
      },
    );

    test('lower panes share time scale and allocate requested weights', () {
      final scene = _scene(
        panes: const [
          WiredVolumePane(),
          WiredIndicatorPane(indicator: WiredRsi(), weight: 2),
        ],
      );
      expect(scene.paneRects, hasLength(2));
      expect(scene.paneRects.first.left, scene.priceRect.left);
      expect(scene.paneRects.last.right, scene.priceRect.right);
      expect(scene.paneRects.first.top, scene.priceRect.bottom);
      expect(scene.paneRects.last.top, scene.paneRects.first.bottom);
      expect(
        scene.paneRects.last.height,
        closeTo(scene.paneRects.first.height * 2, 1e-8),
      );
    });

    test('flat, zero, negative, and tiny prices keep finite linear scales', () {
      for (final price in ['0', '-4', '2', '1e-100']) {
        final value = WiredChartDecimal.parse(price);
        final candle = WiredChartCandle(
          time: _epoch,
          open: value,
          high: value,
          low: value,
          close: value,
        );
        final scene = _scene(candles: [candle]);
        expect(scene.yForPrice(value).isFinite, isTrue);
        expect(
          scene.yForPrice(value),
          closeTo(scene.priceRect.center.dy, 1e-8),
        );
      }
    });

    test('invalid log and percentage domains fail clearly', () {
      final zero = WiredChartDecimal.zero;
      final candle = WiredChartCandle(
        time: _epoch,
        open: zero,
        high: zero,
        low: zero,
        close: zero,
      );
      expect(
        () =>
            _scene(candles: [candle], scale: WiredChartPriceScale.logarithmic),
        throwsArgumentError,
      );
      expect(
        () => _scene(candles: [candle], scale: WiredChartPriceScale.percentage),
        throwsArgumentError,
      );
      expect(
        () => _scene(scale: WiredChartPriceScale.logarithmic),
        returnsNormally,
      );
      expect(
        () => _scene(scale: WiredChartPriceScale.percentage),
        returnsNormally,
      );
    });

    test('invalid layout parameters fail validation', () {
      expect(
        () => _scene(size: const Size(double.infinity, 200)),
        throwsArgumentError,
      );
      expect(() => _scene(size: const Size(-1, 200)), throwsArgumentError);
      expect(() => _scene(visibleCount: 0), throwsArgumentError);
      expect(() => _scene(firstVisible: double.nan), throwsArgumentError);
    });

    test('empty and single-candle time mappings stay deterministic', () {
      final empty = _scene(candles: []);
      expect(empty.indexForX(empty.priceRect.center.dx), isNull);
      expect(
        empty.timeForX(0),
        DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
      );
      final single = _scene(candles: [_candle(0)]);
      expect(single.timeForX(10), _epoch);
      expect(single.xForTime(_epoch), single.xForIndex(0));
    });
  });

  group('ChartPainter pixels', () {
    test('repainting a scene produces identical bytes', () async {
      final scene = _scene();
      expect(await _pixels(scene), orderedEquals(await _pixels(scene)));
    });

    test(
      'instrument identity changes texture while preserving bounds',
      () async {
        final first = _scene(instrument: WiredChartInstrument(id: 'SOL/USDC'));
        final second = _scene(instrument: WiredChartInstrument(id: 'BTC/USDC'));
        expect(first.transform.min, second.transform.min);
        expect(first.transform.max, second.transform.max);
        expect(
          await _pixels(first),
          isNot(orderedEquals(await _pixels(second))),
        );
      },
    );

    test('wick pixels match exactly in crisp and rough modes', () async {
      final candles = [
        _candle(0, open: '90', close: '110', low: '70', high: '130'),
      ];
      final crisp = _scene(
        candles: candles,
        visibleCount: 1,
        style: const WiredChartStyle(handDrawn: false),
      );
      final rough = _scene(
        candles: candles,
        visibleCount: 1,
        style: const WiredChartStyle(roughness: 2),
      );
      final a = await _pixels(crisp);
      final b = await _pixels(rough);
      final center = crisp.xForIndex(0).round();
      final candle = candles.first;
      for (final range in [
        (
          crisp.yForPrice(candle.high).floor() - 2,
          crisp.yForPrice(candle.close).floor() - 2,
        ),
        (
          crisp.yForPrice(candle.open).ceil() + 2,
          crisp.yForPrice(candle.low).ceil() + 2,
        ),
      ]) {
        for (var y = range.$1; y <= range.$2; y++) {
          for (var x = center - 2; x <= center + 2; x++) {
            final offset = (y * crisp.size.width.toInt() + x) * 4;
            expect(
              a.sublist(offset, offset + 4),
              b.sublist(offset, offset + 4),
              reason: 'Wick pixel at $x,$y must remain fixed',
            );
          }
        }
      }
    });

    test('doji is identical in both styles without an invented body', () async {
      final candles = [
        _candle(0, open: '100', close: '100', high: '120', low: '80'),
      ];
      final crisp = _scene(
        candles: candles,
        style: const WiredChartStyle(handDrawn: false),
      );
      expect(
        await _pixels(crisp),
        orderedEquals(await _pixels(_scene(candles: candles))),
      );
    });

    test('candle texture stays attached when the viewport pans', () async {
      final candles = List.generate(
        12,
        (index) =>
            _candle(index, open: '90', close: '110', high: '120', low: '80'),
      );
      final before = _scene(
        candles: candles,
        size: const Size(722, 400),
        visibleCount: 8,
      );
      final after = _scene(
        candles: candles,
        size: const Size(722, 400),
        firstVisible: 1,
        visibleCount: 8,
      );
      final a = await _pixels(before);
      final b = await _pixels(after);
      final oldX = before.xForIndex(3).round();
      final newX = after.xForIndex(3).round();
      final top = before.yForPrice(candles[3].close).ceil() + 2;
      final bottom = before.yForPrice(candles[3].open).floor() - 2;
      for (var y = top; y < bottom; y++) {
        for (var offset = -8; offset <= 8; offset++) {
          final oldPixel = (y * 722 + oldX + offset) * 4;
          final newPixel = (y * 722 + newX + offset) * 4;
          expect(
            a.sublist(oldPixel, oldPixel + 4),
            b.sublist(newPixel, newPixel + 4),
          );
        }
      }
    });

    test(
      'invalid logarithmic drawing anchors stay hidden and unmodified',
      () async {
        final annotation = WiredChartHorizontalLine(
          id: 'negative',
          anchor: WiredChartAnchor(
            time: _epoch,
            price: WiredChartDecimal.fromInt(-1),
          ),
        );
        final plain = _scene(scale: WiredChartPriceScale.logarithmic);
        final annotated = _scene(
          scale: WiredChartPriceScale.logarithmic,
          annotations: [annotation],
        );
        expect(await _pixels(annotated), orderedEquals(await _pixels(plain)));
        expect(annotated.annotations.single, same(annotation));
        expect(annotation.anchor.price, WiredChartDecimal.fromInt(-1));
      },
    );

    test('all series paint at tiny, mobile, and desktop sizes', () async {
      for (final size in [
        const Size(1, 1),
        const Size(80, 60),
        const Size(320, 280),
        const Size(1100, 600),
      ]) {
        for (final series in WiredPriceSeries.values) {
          final image = await _image(
            _scene(
              size: size,
              series: series,
              panes: const [
                WiredVolumePane(),
                WiredIndicatorPane(indicator: WiredMacd()),
              ],
            ),
          );
          expect(image.width, size.width);
          expect(image.height, size.height);
          image.dispose();
        }
      }
    });

    test('empty data paints every series and pane configuration', () async {
      for (final series in WiredPriceSeries.values) {
        final image = await _image(
          _scene(
            candles: [],
            series: series,
            panes: const [
              WiredVolumePane(),
              WiredIndicatorPane(indicator: WiredRsi()),
            ],
          ),
        );
        expect(image.width, 720);
        image.dispose();
      }
    });

    test('log and percentage charts paint with annotations', () async {
      for (final scale in [
        WiredChartPriceScale.logarithmic,
        WiredChartPriceScale.percentage,
      ]) {
        final image = await _image(
          _scene(scale: scale, annotations: _annotations()),
        );
        image.dispose();
      }
    });

    test('candles, indicators, volume, and drawings match golden', () async {
      final image = await _image(
        _scene(
          size: const Size(960, 640),
          overlays: const [
            WiredSma(period: 5),
            WiredBollingerBands(period: 12),
          ],
          panes: const [
            WiredVolumePane(),
            WiredIndicatorPane(indicator: WiredRsi(period: 8)),
          ],
          annotations: _annotations(),
        ),
      );
      await expectLater(
        image,
        matchesGoldenFile('goldens/financial_chart.png'),
      );
      image.dispose();
    });

    test('same scene avoids repaint but a changed viewport repaints', () {
      final scene = _scene();
      final painter = ChartPainter(scene);
      expect(painter.shouldRepaint(ChartPainter(scene)), isFalse);
      expect(
        painter.shouldRepaint(ChartPainter(_scene(firstVisible: 2))),
        isTrue,
      );
    });
  });
}

final _epoch = DateTime.utc(2026, 9, 10, 12);

WiredChartCandle _candle(
  int minute, {
  String? open,
  String? close,
  String? high,
  String? low,
}) {
  final opening = WiredChartDecimal.parse(
    open ??
        (100 + minute * 0.5 + math.sin(minute * 0.7) * 6).toStringAsFixed(3),
  );
  final closing = WiredChartDecimal.parse(
    close ??
        (100 + minute * 0.5 + math.sin((minute + 1) * 0.7) * 6).toStringAsFixed(
          3,
        ),
  );
  return WiredChartCandle(
    time: _epoch.add(Duration(minutes: minute)),
    open: opening,
    close: closing,
    high: high == null
        ? (opening > closing ? opening : closing) + WiredChartDecimal.fromInt(3)
        : WiredChartDecimal.parse(high),
    low: low == null
        ? (opening < closing ? opening : closing) - WiredChartDecimal.fromInt(2)
        : WiredChartDecimal.parse(low),
    volume: WiredChartDecimal.fromInt(100 + minute * 17 % 250),
  );
}

ChartScene _scene({
  List<WiredChartCandle>? candles,
  double firstVisible = 0,
  double visibleCount = 40,
  Size size = const Size(720, 400),
  WiredPriceSeries series = WiredPriceSeries.candlesticks,
  WiredChartPriceScale scale = WiredChartPriceScale.linear,
  WiredChartStyle style = const WiredChartStyle(),
  WiredChartInstrument? instrument,
  WiredChartDecimal? percentageReference,
  List<WiredChartIndicator> overlays = const [],
  List<WiredChartPane> panes = const [],
  List<WiredChartAnnotation> annotations = const [],
}) => ChartScene(
  candles: candles ?? List.generate(40, _candle),
  instrument: instrument ?? WiredChartInstrument(id: 'SOL/USDC'),
  firstVisible: firstVisible,
  visibleCount: visibleCount,
  size: size,
  series: series,
  scale: scale,
  style: style,
  percentageReference:
      percentageReference ??
      (candles == null ? _candle(0).close : candles.firstOrNull?.close),
  overlays: overlays,
  panes: panes,
  annotations: annotations,
  textStyle: const TextStyle(fontFamily: 'ChartTestFont', fontSize: 11),
);

List<WiredChartAnnotation> _annotations() {
  WiredChartAnchor anchor(int minute, String price) => WiredChartAnchor(
    time: _epoch.add(Duration(minutes: minute)),
    price: WiredChartDecimal.parse(price),
  );
  return [
    WiredChartTrendLine(
      id: 'trend',
      start: anchor(1, '94'),
      end: anchor(38, '113'),
      label: 'Trend',
    ),
    WiredChartHorizontalLine(
      id: 'level',
      anchor: anchor(20, '124'),
      label: 'Resistance',
    ),
    WiredChartRectangle(
      id: 'zone',
      start: anchor(10, '107'),
      end: anchor(16, '111'),
    ),
    WiredChartText(id: 'note', anchor: anchor(5, '120'), label: 'Market study'),
    WiredChartFibonacci(
      id: 'fib',
      start: anchor(27, '123'),
      end: anchor(37, '104'),
    ),
  ];
}

Future<ui.Image> _image(ChartScene scene) async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  ChartPainter(scene).paint(canvas, scene.size);
  final picture = recorder.endRecording();
  final image = await picture.toImage(
    scene.size.width.toInt(),
    scene.size.height.toInt(),
  );
  picture.dispose();
  return image;
}

Future<Uint8List> _pixels(ChartScene scene) async {
  final image = await _image(scene);
  final bytes = await image.toByteData();
  image.dispose();
  return bytes!.buffer.asUint8List();
}
