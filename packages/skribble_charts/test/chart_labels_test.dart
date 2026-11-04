import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble_charts/src/chart_data.dart';
import 'package:skribble_charts/src/chart_geometry.dart';
import 'package:skribble_charts/src/chart_indicators.dart';
import 'package:skribble_charts/src/chart_painter.dart';
import 'package:skribble_charts/src/chart_theme.dart';

/// The default skribble typeface, read from its package so labels are
/// measured with real glyph metrics rather than the test font.
const _font = 'ChartLabelFont';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    const path =
        'skribble_font_noto_sketch/assets/fonts/SkribbleNotoSketch-Regular.ttf';
    final sibling = File('../$path');
    final file = sibling.existsSync() ? sibling : File('packages/$path');
    final loader = FontLoader(_font)
      ..addFont(file.readAsBytes().then(ByteData.sublistView));
    await loader.load();
  });

  group('axis labels', () {
    for (final size in const [
      Size(320, 200),
      Size(320, 420),
      Size(1280, 260),
      Size(1280, 640),
    ]) {
      final width = size.width;
      for (final scale in [1.0, 2.0]) {
        for (final (name, base) in [
          ('small', 0.0042),
          ('negative', -40.0),
          ('cents', 142.0),
          ('millions', 12345678.0),
          ('billions', 123456789012.0),
        ]) {
          test(
            '$name prices at ${width.toInt()}x${size.height.toInt()} and '
            '${scale}x text neither collide nor leave the chart',
            () {
              final scene = _scene(
                candles: _candles(base),
                size: size,
                textScaler: TextScaler.linear(scale),
                instrument: WiredChartInstrument(
                  id: 'TEST',
                  priceDecimals: base.abs() < 1 ? 6 : 2,
                ),
              );
              final labels = _paintLabels(scene);
              final bounds = Offset.zero & scene.size;

              expect(labels, isNotEmpty);

              for (final label in labels) {
                expect(
                  bounds.inflate(0.5).contains(label.rect.topLeft) &&
                      bounds.inflate(0.5).contains(label.rect.bottomRight),
                  isTrue,
                  reason: 'label at ${label.rect} leaves $bounds',
                );
              }

              for (var a = 0; a < labels.length; a++) {
                for (var b = a + 1; b < labels.length; b++) {
                  final overlap = labels[a].rect
                      .deflate(0.5)
                      .intersect(labels[b].rect.deflate(0.5));
                  expect(
                    overlap.width <= 0 || overlap.height <= 0,
                    isTrue,
                    reason:
                        'labels at ${labels[a].rect} and ${labels[b].rect} '
                        'overlap',
                  );
                }
              }

              // The right gutter widens to fit price labels instead of
              // shortening them, while still leaving most width for prices.
              final priceLabels = labels.where(
                (label) => label.rect.left >= scene.priceRect.right,
              );
              if (width >= 1280 || scale == 1) {
                expect(
                  priceLabels.where((label) => label.ellipsized),
                  isEmpty,
                );
              }
              expect(scene.priceRect.width, greaterThan(width * 0.5));
            },
          );
        }
      }
    }

    test('labels scale with the reader text size', () {
      final small = _scene(candles: _candles(142));
      final large = _scene(
        candles: _candles(142),
        textScaler: const TextScaler.linear(2),
      );
      final smallHeight = _paintLabels(small)
          .map((l) => l.rect.height)
          .reduce(
            math.max,
          );
      final largeHeight = _paintLabels(large)
          .map((l) => l.rect.height)
          .reduce(
            math.max,
          );

      expect(largeHeight, greaterThan(smallHeight * 1.6));
      expect(large.size.height - large.plotBottom, greaterThan(28));
      expect(large.timeTickCount, lessThanOrEqualTo(small.timeTickCount));
    });

    test(
      'a short pane leaves its scale and title off instead of overlapping',
      () {
        final scene = _scene(
          candles: _candles(142),
          size: const Size(320, 200),
          textScaler: const TextScaler.linear(2),
        );
        final labels = _paintLabels(scene);

        for (final pane in scene.paneRects) {
          expect(pane.height, lessThan(40));
          expect(
            labels.where((label) => label.rect.overlaps(pane.deflate(1))),
            isEmpty,
          );
        }
      },
    );

    test('empty history centres its message in the price pane', () {
      final scene = _scene(candles: const []);
      final labels = _paintLabels(scene);
      final message = labels.singleWhere(
        (label) => scene.priceRect.contains(label.rect.center),
      );

      expect(
        (message.rect.center - scene.priceRect.center).distance,
        lessThan(1),
      );
    });
  });

  group('compactChartNumber', () {
    test('rounds before choosing a unit', () {
      expect(compactChartNumber(0), '0.00');
      expect(compactChartNumber(999.99), '999.99');
      expect(compactChartNumber(999.996), '1.0k');
      expect(compactChartNumber(1500), '1.5k');
      expect(compactChartNumber(-1500), '-1.5k');
      expect(compactChartNumber(999949), '999.9k');
      expect(compactChartNumber(999999), '1.0M');
      expect(compactChartNumber(999949999), '999.9M');
      expect(compactChartNumber(999999999), '1.00e+9');
      expect(compactChartNumber(0.004), '4.00e-3');
      expect(compactChartNumber(double.nan), '—');
      expect(compactChartNumber(double.infinity), '—');
    });
  });
}

final _epoch = DateTime.utc(2026, 9, 10, 22);

List<WiredChartCandle> _candles(double base) {
  final amplitude = base == 0 ? 0.0003 : (base.abs() * 0.04).clamp(0.5, 1e12);
  final decimals = base.abs() < 1 ? 6 : 2;
  WiredChartDecimal price(double value) =>
      WiredChartDecimal.parse(value.toStringAsFixed(decimals));

  return List.generate(80, (index) {
    final open = base + math.sin(index * .3) * amplitude;
    final close = base + math.sin((index + 1) * .3) * amplitude;
    return WiredChartCandle(
      time: _epoch.add(Duration(minutes: 15 * index)),
      open: price(open),
      close: price(close),
      high: price(math.max(open, close) + amplitude * .2),
      low: price(math.min(open, close) - amplitude * .2),
      volume: WiredChartDecimal.fromInt(98765432 + index * 1000),
    );
  });
}

ChartScene _scene({
  required List<WiredChartCandle> candles,
  Size size = const Size(720, 480),
  TextScaler textScaler = TextScaler.noScaling,
  WiredChartInstrument? instrument,
}) => ChartScene(
  candles: candles,
  instrument: instrument ?? WiredChartInstrument(id: 'TEST'),
  firstVisible: 0,
  visibleCount: 60,
  size: size,
  series: WiredPriceSeries.candlesticks,
  scale: WiredChartPriceScale.linear,
  style: const WiredChartStyle(),
  overlays: const [WiredSma(period: 5)],
  panes: const [
    WiredVolumePane(),
    WiredIndicatorPane(indicator: WiredMacd()),
  ],
  textStyle: const TextStyle(fontFamily: _font, fontSize: 11),
  textScaler: textScaler,
);

typedef _Label = ({Rect rect, bool ellipsized});

List<_Label> _paintLabels(ChartScene scene) {
  final canvas = _LabelCanvas();
  ChartPainter(scene).paint(canvas, scene.size);
  return canvas.labels;
}

/// Records where every line of text lands, ignoring all other drawing.
class _LabelCanvas implements Canvas {
  final labels = <_Label>[];

  @override
  void drawParagraph(ui.Paragraph paragraph, Offset offset) {
    labels.add((
      rect: offset & Size(paragraph.longestLine, paragraph.height),
      ellipsized: paragraph.didExceedMaxLines,
    ));
  }

  @override
  Object? noSuchMethod(Invocation invocation) => null;
}
