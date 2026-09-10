import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble_charts/skribble_charts.dart';
import 'package:skribble_charts/src/chart_painter.dart';
import 'package:skribble_storybook/app.dart';

const Key _chartKey = ValueKey<String>('storybook-financial-chart');
const Key _scrollKey = ValueKey<String>('charts-page-scroll');

Finder _label(String text) => find.textContaining(
  RegExp(
    '^(?:✓ )?${RegExp.escape(text)}'
    r'$',
  ),
);
Finder get _scrollable => find
    .descendant(
      of: find.byKey(_scrollKey),
      matching: find.byType(Scrollable),
    )
    .first;

Future<void> _openCharts(WidgetTester tester) async {
  await tester.pumpWidget(const SkribbleStorybookApp());
  await tester.pumpAndSettle();
  await tester.scrollUntilVisible(find.text('Financial charts'), 250);
  await tester.tap(find.text('Financial charts'));
  await tester.pumpAndSettle();
}

Future<void> _tap(WidgetTester tester, String text, {bool up = false}) async {
  await tester.scrollUntilVisible(
    _label(text),
    up ? -250 : 250,
    scrollable: _scrollable,
  );
  await tester.pumpAndSettle();
  await tester.ensureVisible(_label(text));
  await tester.pumpAndSettle();
  await tester.tap(_label(text));
  await tester.pumpAndSettle();
}

Future<WiredFinancialChart> _chart(WidgetTester tester) async {
  await tester.scrollUntilVisible(
    find.byKey(_chartKey),
    -250,
    scrollable: _scrollable,
  );
  await tester.pumpAndSettle();
  return tester.widget<WiredFinancialChart>(find.byKey(_chartKey));
}

Offset _plotPoint(WidgetTester tester, double x, double y) {
  final finder = find.descendant(
    of: find.byKey(_chartKey),
    matching: find.byKey(const ValueKey('chart-plot')),
  );
  final scene =
      (tester.widget<CustomPaint>(finder).painter! as ChartPainter).scene;
  return tester.getTopLeft(finder) +
      Offset(
        scene.priceRect.left + x * scene.priceRect.width,
        scene.priceRect.top + y * scene.priceRect.height,
      );
}

void main() {
  testWidgets(
    'the home category opens the complete chart workspace and returns',
    (tester) async {
      await _openCharts(tester);
      expect(find.text('Markets, in ink.'), findsOneWidget);
      final chart = await _chart(tester);
      expect(chart.controller.candles, hasLength(360));
      expect(chart.series, WiredPriceSeries.candlesticks);
      expect(chart.style.handDrawn, isTrue);
      expect(chart.panes.single, isA<WiredVolumePane>());
      await tester.tap(find.text('Back'));
      await tester.pumpAndSettle();
      expect(find.text('Skribble Storybook'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('series, ink, and night choices update the actual chart', (
    tester,
  ) async {
    await _openCharts(tester);
    for (final entry in {
      'Line': WiredPriceSeries.line,
      'Area': WiredPriceSeries.area,
      'OHLC': WiredPriceSeries.bars,
      'Candles': WiredPriceSeries.candlesticks,
    }.entries) {
      await _tap(tester, entry.key, up: true);
      expect(find.text('✓ ${entry.key}'), findsOneWidget);
      expect((await _chart(tester)).series, entry.value);
    }
    await _tap(tester, 'Ink', up: true);
    expect((await _chart(tester)).style.handDrawn, isFalse);
    await _tap(tester, 'Night', up: true);
    final night = await _chart(tester);
    expect(night.style.background, const Color(0xff20292c));
    expect(night.style.handDrawn, isFalse);
    await _tap(tester, 'Ink', up: true);
    expect((await _chart(tester)).style.handDrawn, isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'scales and indicator choices update overlays and independent panes',
    (tester) async {
      await _openCharts(tester);
      await _tap(tester, 'Indicators and scales');
      for (final scale in WiredChartPriceScale.values) {
        await _tap(tester, scale.name);
        expect((await _chart(tester)).scale, scale);
      }
      for (final label in ['EMA 20', 'Bollinger Bands 20, 2.0']) {
        await _tap(tester, label);
        expect(
          (await _chart(tester)).overlays.map((value) => value.label),
          contains(label),
        );
      }
      await _tap(tester, 'SMA 20');
      expect((await _chart(tester)).overlays.whereType<WiredSma>(), isEmpty);
      await _tap(tester, 'RSI 14');
      await _tap(tester, 'MACD 12, 26, 9');
      final panes = (await _chart(tester)).panes;
      expect(panes, hasLength(3));
      expect(
        panes.whereType<WiredIndicatorPane>().map(
          (pane) => pane.indicator.label,
        ),
        containsAll(['RSI 14', 'MACD 12, 26, 9']),
      );
      await _tap(tester, 'Volume');
      expect(
        (await _chart(tester)).panes.whereType<WiredVolumePane>(),
        isEmpty,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'timeframe changes aggregate exact data and adding a candle updates its interval',
    (tester) async {
      await _openCharts(tester);
      final source = (await _chart(tester)).controller.candles;
      await _tap(tester, '5m');
      final controller = (await _chart(tester)).controller;
      expect(controller.candles, hasLength(72));
      expect(controller.candles.first.open, source.first.open);
      expect(controller.candles.first.close, source[4].close);
      await _tap(tester, 'Add candle');
      await _chart(tester);
      expect(controller.candles, hasLength(73));
      await _tap(tester, '15m');
      await _chart(tester);
      expect(controller.candles, hasLength(25));
      await _tap(tester, '1m');
      await _chart(tester);
      expect(controller.candles, hasLength(361));
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'workspace restore recovers timeframe, visual settings, selection and viewport',
    (tester) async {
      await _openCharts(tester);
      await _tap(tester, '5m');
      await _tap(tester, 'Line', up: true);
      await _tap(tester, 'Ink', up: true);
      await _tap(tester, 'Zoom in');
      final chart = await _chart(tester);
      await tester.tapAt(_plotPoint(tester, .5, .35));
      await tester.pumpAndSettle();
      final selected =
          chart.controller.candles[chart.controller.selectedIndex!].time;
      final count = chart.controller.visibleCount;
      final first = chart.controller.firstVisible;
      await _tap(tester, 'Draw and save');
      await _tap(tester, 'Save workspace');
      await _tap(tester, '15m', up: true);
      await _tap(tester, 'Area', up: true);
      await _tap(tester, 'Restore workspace');
      final restored = await _chart(tester);
      expect(restored.controller.candles, hasLength(72));
      expect(restored.controller.visibleCount, count);
      expect(restored.controller.firstVisible, first);
      expect(
        restored.controller.candles[restored.controller.selectedIndex!].time,
        selected,
      );
      expect(restored.series, WiredPriceSeries.line);
      expect(restored.style.handDrawn, isFalse);
      await tester.scrollUntilVisible(
        find.text('Workspace restored, including your drawings.'),
        250,
        scrollable: _scrollable,
      );
      expect(
        find.text('Workspace restored, including your drawings.'),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('restore explains that a workspace must first be saved', (
    tester,
  ) async {
    await _openCharts(tester);
    await _tap(tester, 'Draw and save');
    await _tap(tester, 'Restore workspace');
    await tester.scrollUntilVisible(
      find.text('Save a workspace first.'),
      -200,
      scrollable: _scrollable,
    );
    expect(find.text('Save a workspace first.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'a price annotation can be edited, undone, restored and deleted through the page',
    (tester) async {
      await _openCharts(tester);
      await _tap(tester, 'Draw and save');
      await _tap(tester, 'Price level');
      final chart = await _chart(tester);
      await tester.tapAt(_plotPoint(tester, .5, .35));
      await tester.pumpAndSettle();
      final editor = chart.annotations!;
      expect(editor.annotations.single.label, 'Watch this level');
      expect(
        tester.widget<WiredFinancialChart>(find.byKey(_chartKey)).tool,
        WiredChartDrawingTool.none,
      );
      final anchor = editor.annotations.single.anchors.single;
      final chartTop = tester.getTopLeft(find.byKey(_chartKey));
      await tester.dragFrom(_plotPoint(tester, .5, .35), const Offset(0, 45));
      await tester.pumpAndSettle();
      expect(editor.annotations.single.anchors.single, isNot(anchor));
      expect(tester.getTopLeft(find.byKey(_chartKey)), chartTop);
      await _tap(tester, 'Undo');
      expect(editor.annotations.single.anchors.single, anchor);
      await _tap(tester, 'Redo');
      expect(editor.annotations.single.anchors.single, isNot(anchor));
      await _tap(tester, 'Save workspace');
      await _tap(tester, 'Delete drawing', up: true);
      expect(editor.annotations, isEmpty);
      await _tap(tester, 'Restore workspace');
      expect(editor.annotations, hasLength(1));
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('vertical scrolling outside a selected handle moves the page', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await _openCharts(tester);
    await _tap(tester, 'Draw and save');
    await _tap(tester, 'Price level');
    final chart = await _chart(tester);
    await tester.tapAt(_plotPoint(tester, .5, .35));
    await tester.pumpAndSettle();
    final annotation = chart.annotations!.annotations.single;
    expect(chart.annotations!.selectedId, annotation.id);
    final scroll = tester.state<ScrollableState>(_scrollable).position;
    final before = scroll.pixels;
    await tester.dragFrom(_plotPoint(tester, .75, .6), const Offset(0, -100));
    await tester.pumpAndSettle();
    expect(scroll.pixels, greaterThan(before));
    expect(chart.annotations!.annotations.single, annotation);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'demo stream appends on the timer, pauses, and cancels on navigation',
    (tester) async {
      await _openCharts(tester);
      final controller = (await _chart(tester)).controller;
      await _tap(tester, 'Stream demo');
      await tester.pump(const Duration(seconds: 4));
      expect(controller.candles, hasLength(362));
      await _tap(tester, 'Stream demo');
      await tester.pump(const Duration(seconds: 4));
      expect(controller.candles, hasLength(362));
      await _tap(tester, 'Stream demo');
      await tester.tap(find.text('Back'));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 6));
      expect(find.text('Skribble Storybook'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  for (final size in [
    const Size(320, 740),
    const Size(390, 844),
    const Size(844, 390),
  ]) {
    testWidgets('production workspace remains usable at $size', (tester) async {
      await tester.binding.setSurfaceSize(size);
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await _openCharts(tester);
      await _tap(tester, 'Line', up: true);
      expect((await _chart(tester)).series, WiredPriceSeries.line);
      await _tap(tester, 'Draw and save');
      await _tap(tester, 'Save workspace');
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets(
    'large text keeps chart controls and workspace actions reachable',
    (tester) async {
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await _openCharts(tester);
      await _tap(tester, 'Area', up: true);
      expect((await _chart(tester)).series, WiredPriceSeries.area);
      await _tap(tester, 'Draw and save');
      await _tap(tester, 'Save workspace');
      expect(tester.takeException(), isNull);
    },
  );
}
