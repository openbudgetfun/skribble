import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble_charts/src/chart_annotations.dart';
import 'package:skribble_charts/src/chart_controller.dart';
import 'package:skribble_charts/src/chart_data.dart';
import 'package:skribble_charts/src/chart_geometry.dart';
import 'package:skribble_charts/src/chart_indicators.dart';
import 'package:skribble_charts/src/chart_painter.dart';
import 'package:skribble_charts/src/chart_theme.dart';
import 'package:skribble_charts/src/wired_financial_chart.dart';

final _epoch = DateTime.utc(2026);
const Key _plotKey = ValueKey<String>('chart-plot');
const Key _detailsKey = ValueKey<String>('chart-selection-details');

WiredChartCandle _candle(
  int index, {
  int revision = 0,
  int offset = 0,
  bool flat = false,
}) {
  final price = 100 + index % 20 + offset;
  return WiredChartCandle(
    time: _epoch.add(Duration(minutes: index)),
    open: WiredChartDecimal.fromInt(price),
    high: WiredChartDecimal.fromInt(flat ? price : price + 5),
    low: WiredChartDecimal.fromInt(flat ? price : price - 3),
    close: WiredChartDecimal.fromInt(flat ? price : price + 2),
    volume: WiredChartDecimal.fromInt(flat ? 0 : 1000 + index),
    revision: revision,
  );
}

WiredChartController _controller({
  int length = 120,
  int offset = 0,
  double visibleCount = 40,
}) => WiredChartController(
  instrument: WiredChartInstrument(id: 'SOL/USD'),
  candles: [
    for (var index = 0; index < length; index++) _candle(index, offset: offset),
  ],
  visibleCount: visibleCount,
);

Future<void> _pumpChart(
  WidgetTester tester,
  WiredChartController controller, {
  WiredChartAnnotations? annotations,
  WiredChartDrawingTool tool = WiredChartDrawingTool.none,
  WiredPriceSeries series = WiredPriceSeries.candlesticks,
  WiredChartPriceScale scale = WiredChartPriceScale.linear,
  List<WiredChartIndicator> overlays = const [],
  List<WiredChartPane> panes = const [],
  Size size = const Size(700, 500),
  double textScale = 1,
  String annotationLabel = '',
  bool showDetails = true,
  ValueChanged<WiredChartCandle?>? onSelected,
}) async {
  await tester.pumpWidget(
    WidgetsApp(
      color: const Color(0xfffffcf5),
      builder: (context, child) => MediaQuery(
        data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
        child: DefaultTextStyle(
          style: const TextStyle(fontSize: 12, color: Color(0xff302e2a)),
          child: Center(
            child: SizedBox.fromSize(
              size: size,
              child: WiredFinancialChart(
                controller: controller,
                annotations: annotations,
                tool: tool,
                series: series,
                scale: scale,
                overlays: overlays,
                panes: panes,
                annotationLabel: annotationLabel,
                semanticLabel: 'SOL price in US dollars',
                showSelectionDetails: showDetails,
                onCandleSelected: onSelected,
              ),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pump();
}

ChartScene _scene(WidgetTester tester) =>
    (tester.widget<CustomPaint>(find.byKey(_plotKey)).painter! as ChartPainter)
        .scene;

Offset _point(WidgetTester tester, double x, double y) {
  final rect = _scene(tester).priceRect;
  return tester.getTopLeft(find.byKey(_plotKey)) +
      Offset(rect.left + rect.width * x, rect.top + rect.height * y);
}

String _details(WidgetTester tester) =>
    tester.widget<Text>(find.byKey(_detailsKey)).data!;

Future<void> _command(
  WidgetTester tester,
  LogicalKeyboardKey key, {
  bool shift = false,
}) async {
  await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
  if (shift) await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
  await tester.sendKeyEvent(key);
  if (shift) await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
  await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
  await tester.pump();
}

void main() {
  for (final series in WiredPriceSeries.values) {
    for (final scale in WiredChartPriceScale.values) {
      testWidgets(
        '$series renders and inspects candles on $scale with indicator panes',
        (tester) async {
          final controller = _controller();
          addTearDown(controller.dispose);
          await _pumpChart(
            tester,
            controller,
            series: series,
            scale: scale,
            overlays: const [WiredSma(), WiredEma(), WiredBollingerBands()],
            panes: const [
              WiredVolumePane(),
              WiredIndicatorPane(indicator: WiredRsi()),
              WiredIndicatorPane(indicator: WiredMacd()),
            ],
          );
          expect(_details(tester), 'SOL/USD. 120 candles.');
          await tester.tapAt(_point(tester, .5, .5));
          await tester.pump();
          expect(
            _details(tester),
            contains('O 100  H 105  L 97  C 102  V 1100'),
          );
          expect(tester.takeException(), isNull);
        },
      );
    }
  }

  testWidgets(
    'empty history is readable and ignores drawing and keyboard selection',
    (tester) async {
      final controller = _controller(length: 0);
      final editor = WiredChartAnnotations();
      addTearDown(controller.dispose);
      addTearDown(editor.dispose);
      await _pumpChart(
        tester,
        controller,
        annotations: editor,
        tool: WiredChartDrawingTool.text,
      );
      expect(_details(tester), 'SOL/USD. 0 candles.');
      await tester.tapAt(_point(tester, .5, .5));
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();
      expect(editor.annotations, isEmpty);
      expect(controller.selectedIndex, isNull);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'a single flat zero-volume candle remains selectable in every scale',
    (tester) async {
      final controller = _controller(length: 0, visibleCount: 1)
        ..replaceCandles([_candle(0, flat: true)]);
      addTearDown(controller.dispose);
      for (final scale in WiredChartPriceScale.values) {
        await _pumpChart(
          tester,
          controller,
          scale: scale,
          panes: const [WiredVolumePane()],
        );
        await tester.tapAt(_point(tester, .5, .5));
        await tester.pump();
        expect(_details(tester), contains('O 100  H 100  L 100  C 100  V 0'));
        expect(tester.takeException(), isNull);
      }
    },
  );

  testWidgets('selected details wrap on narrow screens with large text', (
    tester,
  ) async {
    final controller = _controller();
    addTearDown(controller.dispose);
    await _pumpChart(
      tester,
      controller,
      size: const Size(280, 420),
      textScale: 2,
    );
    await tester.tapAt(_point(tester, .5, .5));
    await tester.pump();
    expect(_details(tester), contains('SOL/USD'));
    expect(tester.getSize(find.byKey(_plotKey)).height, greaterThan(40));
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'tap and mouse hover inspect exact candles and update accessible values',
    (tester) async {
      final semantics = tester.ensureSemantics();
      final controller = _controller();
      WiredChartCandle? selected;
      addTearDown(controller.dispose);
      await _pumpChart(
        tester,
        controller,
        onSelected: (value) => selected = value,
      );
      await tester.tapAt(_point(tester, .25, .5));
      await tester.pump();
      expect(selected?.time, _epoch.add(const Duration(minutes: 90)));
      expect(_details(tester), contains(selected!.time.toIso8601String()));
      final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await mouse.addPointer(location: _point(tester, .25, .5));
      await mouse.moveTo(_point(tester, .75, .5));
      await tester.pump();
      expect(selected?.time, _epoch.add(const Duration(minutes: 110)));
      expect(
        tester
            .getSemantics(
              find.bySemanticsLabel(RegExp('SOL price in US dollars')),
            )
            .value,
        contains(selected!.time.toIso8601String()),
      );
      await mouse.removePointer();
      semantics.dispose();
    },
  );

  testWidgets(
    'long press inspects and moving the press selects another candle',
    (tester) async {
      final controller = _controller();
      addTearDown(controller.dispose);
      await _pumpChart(tester, controller);
      final gesture = await tester.startGesture(_point(tester, .25, .5));
      await tester.pump(kLongPressTimeout + const Duration(milliseconds: 1));
      expect(controller.selectedIndex, 90);
      await gesture.moveTo(_point(tester, .75, .5));
      await tester.pump();
      expect(
        _details(tester),
        contains(_epoch.add(const Duration(minutes: 110)).toIso8601String()),
      );
      await gesture.up();
    },
  );

  testWidgets('dragging toward the right reveals older candles', (
    tester,
  ) async {
    final controller = _controller();
    addTearDown(controller.dispose);
    await _pumpChart(tester, controller);
    await tester.dragFrom(_point(tester, .5, .5), const Offset(140, 0));
    await tester.pump();
    expect(controller.firstVisible, lessThan(80));
    expect(controller.isFollowingLatest, isFalse);
    await tester.tapAt(_point(tester, .5, .5));
    await tester.pump();
    expect(controller.selectedIndex, lessThan(100));
    expect(tester.takeException(), isNull);
  });

  testWidgets('mouse wheel zoom preserves the time beneath the pointer', (
    tester,
  ) async {
    final controller = _controller()..setViewport(40, 40);
    addTearDown(controller.dispose);
    await _pumpChart(tester, controller);
    final point = _point(tester, .3, .5);
    final before = _scene(tester)
        .timeForX(point.dx - tester.getTopLeft(find.byKey(_plotKey)).dx);
    await tester.sendEventToBinding(
      PointerScrollEvent(position: point, scrollDelta: const Offset(0, -120)),
    );
    await tester.pump();
    final after = _scene(tester)
        .timeForX(point.dx - tester.getTopLeft(find.byKey(_plotKey)).dx);
    expect(controller.visibleCount, lessThan(40));
    expect(after.difference(before).inMicroseconds.abs(), lessThanOrEqualTo(1));
    expect(tester.takeException(), isNull);
  });

  testWidgets('pinch zoom changes the viewport without losing its center', (
    tester,
  ) async {
    final controller = _controller()..setViewport(40, 40);
    addTearDown(controller.dispose);
    await _pumpChart(tester, controller);
    final center = _point(tester, .5, .5);
    final first = await tester.startGesture(
      center - const Offset(40, 0),
      pointer: 1,
    );
    final second = await tester.startGesture(
      center + const Offset(40, 0),
      pointer: 2,
    );
    await tester.pump();
    await first.moveTo(center - const Offset(80, 0));
    await second.moveTo(center + const Offset(80, 0));
    await tester.pump();
    await first.moveTo(center - const Offset(120, 0));
    await second.moveTo(center + const Offset(120, 0));
    await tester.pump();
    await first.up();
    await second.up();
    await tester.pump();
    expect(controller.visibleCount, lessThan(40));
    expect(
      controller.firstVisible + controller.visibleCount / 2,
      closeTo(60, 1),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'keyboard selects previous and next candles, zooms, and returns to latest',
    (tester) async {
      final controller = _controller()..setViewport(20, 40);
      addTearDown(controller.dispose);
      await _pumpChart(tester, controller);
      await tester.tapAt(_point(tester, .5, .5));
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await tester.pump();
      expect(
        _details(tester),
        contains(_epoch.add(const Duration(minutes: 39)).toIso8601String()),
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.sendKeyEvent(LogicalKeyboardKey.equal);
      await tester.pump();
      expect(controller.visibleCount, 32);
      await tester.sendKeyEvent(LogicalKeyboardKey.minus);
      await tester.sendKeyEvent(LogicalKeyboardKey.end);
      await tester.pump();
      expect(controller.visibleCount, 40);
      expect(controller.isFollowingLatest, isTrue);
      expect(
        _details(tester),
        contains(_epoch.add(const Duration(minutes: 40)).toIso8601String()),
      );
    },
  );

  testWidgets('repeated keyboard zoom stops safely at the controller limits', (
    tester,
  ) async {
    final controller = _controller(visibleCount: 1);
    addTearDown(controller.dispose);
    await _pumpChart(tester, controller);
    await tester.tapAt(_point(tester, .5, .5));
    for (var index = 0; index < 5; index++) {
      await tester.sendKeyEvent(LogicalKeyboardKey.equal);
      await tester.pump();
    }
    expect(controller.visibleCount, 1);
    expect(tester.takeException(), isNull);
    controller.setViewport(0, 1000000);
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.minus);
    await tester.pump();
    expect(controller.visibleCount, 1000000);
    expect(tester.takeException(), isNull);
  });

  for (final tool in WiredChartDrawingTool.values.where(
    (tool) => tool != WiredChartDrawingTool.none,
  )) {
    testWidgets(
      '$tool can be drawn, selected, edited, undone, redone, and deleted',
      (tester) async {
        final controller = _controller();
        final editor = WiredChartAnnotations();
        addTearDown(controller.dispose);
        addTearDown(editor.dispose);
        await _pumpChart(
          tester,
          controller,
          annotations: editor,
          tool: tool,
          annotationLabel: 'My level',
        );
        final start = _point(tester, .3, .35);
        final end = _point(tester, .65, .65);
        await tester.tapAt(start);
        await tester.pump();
        final twoPoints =
            tool == WiredChartDrawingTool.trendLine ||
            tool == WiredChartDrawingTool.rectangle ||
            tool == WiredChartDrawingTool.fibonacci;
        if (twoPoints) {
          expect(find.text('Tap the second point'), findsOneWidget);
          await tester.tapAt(end);
          await tester.pump();
        }
        expect(find.text('Tap the second point'), findsNothing);
        expect(editor.annotations.single.tool, tool);
        expect(editor.annotations.single.label, 'My level');
        final drawing = editor.annotations.single;
        await _pumpChart(tester, controller, annotations: editor);
        final handle =
            tester.getTopLeft(find.byKey(_plotKey)) +
            _scene(tester).positionForAnchor(drawing.anchors.first);
        await tester.tapAt(handle);
        await tester.pump();
        expect(editor.selectedId, drawing.id);
        final before = drawing.anchors.first;
        await tester.dragFrom(handle, const Offset(40, 35));
        await tester.pump();
        expect(editor.annotations.single.anchors.first, isNot(before));
        final changed = editor.annotations.single.anchors.first;
        await _command(tester, LogicalKeyboardKey.keyZ);
        expect(editor.annotations.single.anchors.first, before);
        await _command(tester, LogicalKeyboardKey.keyZ, shift: true);
        expect(editor.annotations.single.anchors.first, changed);
        await tester.sendKeyEvent(LogicalKeyboardKey.delete);
        await tester.pump();
        expect(editor.annotations, isEmpty);
        await _command(tester, LogicalKeyboardKey.keyZ);
        expect(editor.annotations.single.id, drawing.id);
        expect(tester.takeException(), isNull);
      },
    );
  }

  for (final action in ['Delete', 'Backspace', 'remove', 'replace', 'editor']) {
    testWidgets('$action invalidates an active handle drag safely', (
      tester,
    ) async {
      final controller = _controller();
      final editor = WiredChartAnnotations();
      final otherEditor = WiredChartAnnotations();
      addTearDown(controller.dispose);
      addTearDown(editor.dispose);
      addTearDown(otherEditor.dispose);
      await _pumpChart(
        tester,
        controller,
        annotations: editor,
        tool: WiredChartDrawingTool.horizontalLine,
      );
      await tester.tapAt(_point(tester, .5, .4));
      await tester.pump();
      await _pumpChart(tester, controller, annotations: editor);
      final drawing = editor.annotations.single;
      final anchor = drawing.anchors.single;
      final replacement = drawing.withAnchor(
        0,
        WiredChartAnchor(
          time: anchor.time,
          price: anchor.price + WiredChartDecimal.fromInt(2),
        ),
      );
      final handle =
          tester.getTopLeft(find.byKey(_plotKey)) +
          _scene(tester).positionForAnchor(anchor);
      final gesture = await tester.startGesture(handle);
      await gesture.moveBy(const Offset(0, 45));
      await tester.pump();
      expect(_scene(tester).annotations.single.anchors.single, isNot(anchor));
      switch (action) {
        case 'Delete':
          await tester.sendKeyEvent(LogicalKeyboardKey.delete);
        case 'Backspace':
          await tester.sendKeyEvent(LogicalKeyboardKey.backspace);
        case 'remove':
          editor.remove(drawing.id);
        case 'replace':
          editor.replaceAll([replacement], selectedId: replacement.id);
        case 'editor':
          otherEditor.add(replacement);
          await _pumpChart(tester, controller, annotations: otherEditor);
      }
      await tester.pump();
      await gesture.up();
      await tester.pump();
      if (action == 'replace') {
        expect(editor.annotations.single, same(replacement));
        expect(_scene(tester).annotations.single, same(replacement));
      } else if (action == 'editor') {
        expect(editor.annotations.single, same(drawing));
        expect(otherEditor.annotations.single, same(replacement));
        expect(_scene(tester).annotations.single, same(replacement));
      } else {
        expect(editor.annotations, isEmpty);
        expect(_scene(tester).annotations, isEmpty);
      }
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('Escape cancels a pending drawing and clears its selection', (
    tester,
  ) async {
    final controller = _controller();
    final editor = WiredChartAnnotations();
    addTearDown(controller.dispose);
    addTearDown(editor.dispose);
    await _pumpChart(
      tester,
      controller,
      annotations: editor,
      tool: WiredChartDrawingTool.trendLine,
    );
    await tester.tapAt(_point(tester, .3, .3));
    await tester.pump();
    expect(find.text('Tap the second point'), findsOneWidget);
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pump();
    expect(find.text('Tap the second point'), findsNothing);
    expect(editor.annotations, isEmpty);
    await tester.tapAt(_point(tester, .5, .5));
    await tester.pump();
    expect(find.text('Tap the second point'), findsOneWidget);
    expect(editor.annotations, isEmpty);
  });

  testWidgets(
    'changing tools cancels incomplete drawings and empty text becomes Note',
    (tester) async {
      final controller = _controller();
      final editor = WiredChartAnnotations();
      addTearDown(controller.dispose);
      addTearDown(editor.dispose);
      await _pumpChart(
        tester,
        controller,
        annotations: editor,
        tool: WiredChartDrawingTool.rectangle,
      );
      await tester.tapAt(_point(tester, .3, .3));
      await tester.pump();
      await _pumpChart(
        tester,
        controller,
        annotations: editor,
        tool: WiredChartDrawingTool.text,
      );
      expect(find.text('Tap the second point'), findsNothing);
      await tester.tapAt(_point(tester, .6, .6));
      await tester.pump();
      expect(editor.annotations.single.label, 'Note');
      expect(editor.annotations.single.tool, WiredChartDrawingTool.text);
    },
  );

  testWidgets(
    'replacing the controller updates rendered data even with matching revisions',
    (tester) async {
      final old = _controller();
      final replacement = _controller(offset: 500);
      addTearDown(old.dispose);
      addTearDown(replacement.dispose);
      await _pumpChart(tester, old);
      await _pumpChart(tester, replacement);
      expect(_scene(tester).candles.first.open.toString(), '600');
      await tester.tapAt(_point(tester, .5, .5));
      await tester.pump();
      expect(_details(tester), contains('O 600  H 605  L 597  C 602'));
      old.mergeCandles([_candle(120)]);
      await tester.pump();
      expect(_details(tester), contains('C 602'));
    },
  );

  testWidgets(
    'unmounting and replacing borrowed editors leaves their owners usable',
    (tester) async {
      final controller = _controller();
      final first = WiredChartAnnotations();
      final second = WiredChartAnnotations();
      addTearDown(controller.dispose);
      addTearDown(first.dispose);
      addTearDown(second.dispose);
      await _pumpChart(
        tester,
        controller,
        annotations: first,
        tool: WiredChartDrawingTool.text,
      );
      await tester.tapAt(_point(tester, .5, .5));
      await tester.pump();
      await _pumpChart(
        tester,
        controller,
        annotations: second,
        tool: WiredChartDrawingTool.text,
      );
      await tester.tapAt(_point(tester, .6, .5));
      await tester.pump();
      expect(first.annotations, hasLength(1));
      expect(second.annotations, hasLength(1));
      await tester.pumpWidget(const SizedBox.shrink());
      first.undo();
      second.undo();
      controller.mergeCandles([_candle(120)]);
      expect(first.annotations, isEmpty);
      expect(second.annotations, isEmpty);
      expect(controller.candles, hasLength(121));
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'live corrections and earlier history retain selected timestamps and undo history',
    (tester) async {
      final controller = _controller();
      final editor = WiredChartAnnotations();
      addTearDown(controller.dispose);
      addTearDown(editor.dispose);
      await _pumpChart(tester, controller, annotations: editor);
      await tester.tapAt(_point(tester, .5, .5));
      await tester.pump();
      final selected = controller.candles[controller.selectedIndex!].time;
      for (var index = 0; index < 10; index++) {
        controller.mergeCandles([
          _candle(-index - 1),
          _candle(120 + index),
          _candle(100, revision: index + 1, offset: index),
        ]);
        await tester.pump();
        expect(controller.candles[controller.selectedIndex!].time, selected);
        expect(_details(tester), contains(selected.toIso8601String()));
        expect(editor.canUndo, isFalse);
      }
      expect(_details(tester), contains('C 111'));
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'selection remains accessible when the visual details are hidden',
    (tester) async {
      final semantics = tester.ensureSemantics();
      final controller = _controller();
      addTearDown(controller.dispose);
      await _pumpChart(tester, controller, showDetails: false);
      await tester.tapAt(_point(tester, .5, .5));
      await tester.pump();
      expect(find.byKey(_detailsKey), findsNothing);
      expect(
        tester
            .getSemantics(
              find.bySemanticsLabel(RegExp('SOL price in US dollars')),
            )
            .value,
        contains('C 102'),
      );
      semantics.dispose();
    },
  );

  testWidgets(
    'logarithmic mode hides invalid saved drawings without deleting them',
    (
      tester,
    ) async {
      final controller = _controller();
      final editor = WiredChartAnnotations()
        ..add(
          WiredChartHorizontalLine(
            id: 'negative-level',
            anchor: WiredChartAnchor(
              time: _epoch.add(const Duration(minutes: 100)),
              price: WiredChartDecimal.fromInt(-10),
            ),
          ),
        )
        ..select('negative-level');
      addTearDown(controller.dispose);
      addTearDown(editor.dispose);
      await _pumpChart(tester, controller, annotations: editor);
      await _pumpChart(
        tester,
        controller,
        annotations: editor,
        scale: WiredChartPriceScale.logarithmic,
      );
      expect(_scene(tester).annotations, isEmpty);
      expect(editor.annotations.single.id, 'negative-level');
      await tester.tapAt(_point(tester, .5, .5));
      await tester.pump();
      expect(editor.selectedId, isNull);
      expect(tester.takeException(), isNull);
      await _pumpChart(tester, controller, annotations: editor);
      expect(_scene(tester).annotations.single.id, 'negative-level');
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Fibonacci levels can be selected at their actual logarithmic price',
    (
      tester,
    ) async {
      final controller = _controller();
      final editor = WiredChartAnnotations()
        ..add(
          WiredChartFibonacci(
            id: 'retracement',
            start: WiredChartAnchor(
              time: _epoch.add(const Duration(minutes: 90)),
              price: WiredChartDecimal.fromInt(10),
            ),
            end: WiredChartAnchor(
              time: _epoch.add(const Duration(minutes: 110)),
              price: WiredChartDecimal.fromInt(900),
            ),
          ),
        );
      addTearDown(controller.dispose);
      addTearDown(editor.dispose);
      controller.replaceCandles([
        for (var index = 0; index < 120; index++)
          WiredChartCandle(
            time: _epoch.add(Duration(minutes: index)),
            open: WiredChartDecimal.fromInt(index.isEven ? 1 : 1000),
            high: WiredChartDecimal.fromInt(index.isEven ? 1 : 1000),
            low: WiredChartDecimal.fromInt(index.isEven ? 1 : 1000),
            close: WiredChartDecimal.fromInt(index.isEven ? 1 : 1000),
          ),
      ]);
      await _pumpChart(
        tester,
        controller,
        annotations: editor,
        scale: WiredChartPriceScale.logarithmic,
      );
      final position =
          tester.getTopLeft(find.byKey(_plotKey)) +
          _scene(tester).positionForAnchor(
            WiredChartAnchor(
              time: _epoch.add(const Duration(minutes: 100)),
              price: WiredChartDecimal.fromInt(455),
            ),
          );
      await tester.tapAt(position);
      await tester.pump();
      expect(editor.selectedId, 'retracement');
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'log scale tolerates a retained nonpositive selection outside the viewport',
    (
      tester,
    ) async {
      final controller = _controller()
        ..mergeCandles([_candle(0, offset: -200, revision: 1)])
        ..selectIndex(0);
      addTearDown(controller.dispose);
      await _pumpChart(tester, controller);
      await _pumpChart(
        tester,
        controller,
        scale: WiredChartPriceScale.logarithmic,
      );
      expect(_details(tester), contains('C -98'));
      expect(tester.takeException(), isNull);
    },
  );
}
