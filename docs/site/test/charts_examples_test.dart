import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble_charts/skribble_charts.dart';
import 'package:skribble_charts/src/chart_painter.dart';
import 'package:skribble_docs_site/src/app.dart';
import 'package:skribble_docs_site/src/code_view.dart';
import 'package:skribble_docs_site/src/docs_keys.dart';
import 'package:skribble_docs_site/src/document.dart';
import 'package:skribble_docs_site/src/examples/catalog.dart';
import 'package:skribble_docs_site/src/examples/example.dart';

const Key _chartKey = ValueKey<String>('docs-financial-chart');
const Key _scrollKey = ValueKey<String>('document-scroll');

Finder get _scrollable => find
    .descendant(of: find.byKey(_scrollKey), matching: find.byType(Scrollable))
    .first;

Future<void> _openCharts(WidgetTester tester) async {
  final root = Directory('content').existsSync() ? '' : 'docs/site/';
  final document = DocDocument.parse(
    'content/widgets/charts.md',
    File('${root}content/widgets/charts.md').readAsStringSync(),
  );
  await tester.pumpWidget(
    DocsApp(documents: [document], initialLocation: '/widgets/charts'),
  );
  await tester.pumpAndSettle();
  await tester.scrollUntilVisible(
    find.byKey(_chartKey),
    200,
    scrollable: _scrollable,
  );
  await tester.pumpAndSettle();
}

Future<void> _tap(WidgetTester tester, String label) async {
  await tester.scrollUntilVisible(
    find.text(label),
    200,
    scrollable: _scrollable,
  );
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
}

Future<WiredFinancialChart> _chart(WidgetTester tester) async {
  await tester.scrollUntilVisible(
    find.byKey(_chartKey),
    -200,
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
        scene.priceRect.left + scene.priceRect.width * x,
        scene.priceRect.top + scene.priceRect.height * y,
      );
}

void main() {
  testWidgets(
    'canonical chart documentation renders the compiled financial example',
    (tester) async {
      await _openCharts(tester);
      final chart = await _chart(tester);
      expect(chart.controller.candles, hasLength(24));
      expect(chart.controller.candles.first.open.toString(), '141.9');
      expect(chart.controller.candles.last.close.toString(), '146.05');
      expect(chart.overlays.single.label, 'SMA 5');
      expect(chart.panes.single, isA<WiredVolumePane>());
      expect(chart.series, WiredPriceSeries.candlesticks);
      expect(chart.style.roughness, .3);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'documentation controls change series, texture, and average while keeping data',
    (tester) async {
      await _openCharts(tester);
      final controller = (await _chart(tester)).controller;
      await _tap(tester, 'Show line');
      expect((await _chart(tester)).series, WiredPriceSeries.line);
      await _tap(tester, 'Crisp strokes');
      expect((await _chart(tester)).style.handDrawn, isFalse);
      await _tap(tester, 'Hide average');
      expect((await _chart(tester)).overlays, isEmpty);
      await _tap(tester, 'Show candles');
      await _tap(tester, 'Hand-drawn strokes');
      await _tap(tester, 'Show average');
      final chart = await _chart(tester);
      expect(chart.controller, same(controller));
      expect(chart.controller.candles, hasLength(24));
      expect(chart.series, WiredPriceSeries.candlesticks);
      expect(chart.style.handDrawn, isTrue);
      expect(chart.overlays.single.label, 'SMA 5');
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('the documentation creates and undoes a real price annotation', (
    tester,
  ) async {
    await _openCharts(tester);
    await _tap(tester, 'Mark a price');
    final chart = await _chart(tester);
    await tester.tapAt(_plotPoint(tester, .5, .3));
    await tester.pumpAndSettle();
    expect(chart.annotations!.annotations.single.label, 'My level');
    expect(
      chart.annotations!.annotations.single.tool,
      WiredChartDrawingTool.horizontalLine,
    );
    expect(
      tester.widget<WiredFinancialChart>(find.byKey(_chartKey)).tool,
      WiredChartDrawingTool.none,
    );
    await _tap(tester, 'Undo drawing');
    expect(chart.annotations!.annotations, isEmpty);
    expect(tester.takeException(), isNull);
  });

  testWidgets('zoom and Latest navigate the same documentation data', (
    tester,
  ) async {
    await _openCharts(tester);
    final controller = (await _chart(tester)).controller;
    await _tap(tester, 'Zoom in');
    await _chart(tester);
    expect(controller.visibleCount, lessThan(24));
    await tester.dragFrom(_plotPoint(tester, .5, .3), const Offset(70, 0));
    await tester.pumpAndSettle();
    expect(controller.isFollowingLatest, isFalse);
    await _tap(tester, 'Latest');
    expect(controller.isFollowingLatest, isTrue);
    expect(controller.candles, hasLength(24));
  });

  testWidgets(
    'editing roughness changes both the rendered chart and copied source',
    (tester) async {
      String? copied;
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (call) async {
          if (call.method == 'Clipboard.setData') {
            copied =
                (call.arguments as Map<Object?, Object?>)['text'] as String?;
          }
          return null;
        },
      );
      addTearDown(
        () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.platform,
          null,
        ),
      );
      await _openCharts(tester);
      final input = find.descendant(
        of: find.byKey(DocsKeys.parameter('chart-interactive', 'amount')),
        matching: find.byType(EditableText),
      );
      await tester.scrollUntilVisible(input, 200, scrollable: _scrollable);
      await tester.enterText(input, '1');
      await tester.pumpAndSettle();
      expect((await _chart(tester)).style.roughness, .5);
      final code = find.byKey(DocsKeys.exampleCode('chart-interactive'));
      await tester.scrollUntilVisible(code, 200, scrollable: _scrollable);
      final source = tester.widget<CodeView>(code).code;
      expect(source, contains('roughness: 1.0 / 2'));
      expect(source, isNot(contains('settings.amount')));
      expect(
        source,
        examples['chart-interactive']!.sourceFor(ExampleSettings()..amount = 1),
      );
      final copy = find.descendant(
        of: code,
        matching: find.byKey(DocsKeys.copyCode),
      );
      await tester.ensureVisible(copy);
      await tester.tap(copy);
      await tester.pumpAndSettle();
      expect(copied, source);
      expect(tester.takeException(), isNull);
    },
  );

  for (final size in [
    const Size(320, 740),
    const Size(390, 844),
    const Size(844, 390),
  ]) {
    testWidgets('the actual chart document works at $size', (tester) async {
      await tester.binding.setSurfaceSize(size);
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await _openCharts(tester);
      await _tap(tester, 'Show line');
      expect((await _chart(tester)).series, WiredPriceSeries.line);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('the chart document keeps controls reachable with large text', (
    tester,
  ) async {
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await _openCharts(tester);
    await _tap(tester, 'Hide average');
    expect((await _chart(tester)).overlays, isEmpty);
    expect(tester.takeException(), isNull);
  });
}
