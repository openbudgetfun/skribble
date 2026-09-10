import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:skribble/skribble.dart';
import 'package:skribble_charts/skribble_charts.dart';
import 'package:skribble_storybook/testing/chart_keys.dart';

/// A complete chart workspace using deterministic illustrative market data.
class ChartsPage extends HookWidget {
  /// Creates the Storybook financial chart route.
  const ChartsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = useMemoized(
      () => WiredChartController(
        instrument: WiredChartInstrument(id: 'SOL / USDC', volumeDecimals: 0),
        candles: chartExampleCandles(360),
      ),
    );
    final annotations = useMemoized(WiredChartAnnotations.new);
    final series = useState(WiredPriceSeries.candlesticks);
    final scale = useState(WiredChartPriceScale.linear);
    final interval = useState(1);
    final overlays = useState<List<WiredChartIndicator>>(const [WiredSma()]);
    final panes = useState<List<WiredChartPane>>(const [WiredVolumePane()]);
    final tool = useState(WiredChartDrawingTool.none);
    final handDrawn = useState(true);
    final night = useState(false);
    final live = useState(false);
    final count = useRef(360);
    final note = useTextEditingController(text: 'Watch this level');
    final saved = useState<WiredChartWorkspace?>(null);
    final savedInterval = useState(1);
    final status = useState(
      'Illustrative prices. No live exchange connection.',
    );
    useListenable(annotations);
    useListenable(note);

    useEffect(() {
      return () {
        controller.dispose();
        annotations.dispose();
      };
    }, [controller, annotations]);

    void refresh() {
      final candles = chartExampleCandles(count.value);
      controller.mergeCandles(
        interval.value == 1
            ? candles
            : aggregateWiredChartCandles(
                candles,
                interval: Duration(minutes: interval.value),
                sourceInterval: const Duration(minutes: 1),
              ),
      );
    }

    useEffect(() {
      if (!live.value) return null;
      final timer = Timer.periodic(const Duration(seconds: 2), (_) {
        count.value += 1;
        refresh();
      });
      return timer.cancel;
    }, [live.value, interval.value]);

    final style = night.value
        ? WiredChartStyle(
            handDrawn: handDrawn.value,
            background: const Color(0xFF20292C),
            foreground: const Color(0xFFF7EFDB),
            grid: const Color(0xFF3B494B),
            rise: const Color(0xFF85C7A0),
            fall: const Color(0xFFE39A87),
            indicatorColors: const [
              Color(0xFF9FBEEB),
              Color(0xFFDEC18C),
              Color(0xFFD1A9E8),
            ],
          )
        : WiredChartStyle(handDrawn: handDrawn.value);

    return WiredScaffold(
      appBar: WiredAppBar(
        leading: WiredButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Back'),
        ),
        title: const Text('Financial charts'),
      ),
      body: SingleChildScrollView(
        key: ChartDemoKeys.scroll,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Markets, in ink.',
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            const Text('SOL / USDC · generated example data · UTC'),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final value in WiredPriceSeries.values)
                  _ChartChoice(
                    label: _seriesLabel(value),
                    selected: series.value == value,
                    onPressed: () => series.value = value,
                  ),
                _ChartChoice(
                  label: 'Ink',
                  selected: handDrawn.value,
                  onPressed: () => handDrawn.value = !handDrawn.value,
                ),
                _ChartChoice(
                  label: 'Night',
                  selected: night.value,
                  onPressed: () => night.value = !night.value,
                ),
              ],
            ),
            const SizedBox(height: 12),
            ColoredBox(
              color: style.background,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: SizedBox(
                  height: 380 + panes.value.length * 110,
                  child: WiredFinancialChart(
                    key: ChartDemoKeys.chart,
                    controller: controller,
                    annotations: annotations,
                    series: series.value,
                    scale: scale.value,
                    overlays: overlays.value,
                    panes: panes.value,
                    style: style,
                    tool: tool.value,
                    annotationLabel: note.text,
                    semanticLabel: 'SOL price in USDC, illustrative data',
                    onAnnotationCreated: (_) {
                      tool.value = WiredChartDrawingTool.none;
                      status.value =
                          'Drawing added. Drag its handles to adjust it.';
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                WiredButton(
                  onPressed: () => controller.zoom(1.4),
                  semanticLabel: 'Zoom chart in',
                  child: const Text('Zoom in'),
                ),
                WiredButton(
                  onPressed: () => controller.zoom(1 / 1.4),
                  semanticLabel: 'Zoom chart out',
                  child: const Text('Zoom out'),
                ),
                WiredButton(
                  onPressed: controller.scrollToLatest,
                  child: const Text('Latest'),
                ),
                for (final minutes in [1, 5, 15])
                  _ChartChoice(
                    label: '${minutes}m',
                    selected: interval.value == minutes,
                    onPressed: () {
                      interval.value = minutes;
                      final candles = chartExampleCandles(count.value);
                      controller.replaceCandles(
                        minutes == 1
                            ? candles
                            : aggregateWiredChartCandles(
                                candles,
                                interval: Duration(minutes: minutes),
                                sourceInterval: const Duration(minutes: 1),
                              ),
                      );
                      controller.scrollToLatest();
                    },
                  ),
                WiredButton(
                  onPressed: () {
                    count.value += 1;
                    refresh();
                  },
                  child: const Text('Add candle'),
                ),
                _ChartChoice(
                  label: 'Stream demo',
                  selected: live.value,
                  onPressed: () => live.value = !live.value,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Semantics(
              liveRegion: true,
              child: Text(
                status.value,
                key: ChartDemoKeys.status,
              ),
            ),
            const SizedBox(height: 12),
            WiredExpansionTile(
              title: const Text('Indicators and scales'),
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final value in WiredChartPriceScale.values)
                      _ChartChoice(
                        label: value.name,
                        selected: scale.value == value,
                        onPressed: () => scale.value = value,
                      ),
                    for (final indicator in const <WiredChartIndicator>[
                      WiredSma(),
                      WiredEma(),
                      WiredBollingerBands(),
                    ])
                      _ChartChoice(
                        label: indicator.label,
                        selected: overlays.value.any(
                          (value) => value.runtimeType == indicator.runtimeType,
                        ),
                        onPressed: () {
                          final exists = overlays.value.any(
                            (value) =>
                                value.runtimeType == indicator.runtimeType,
                          );
                          overlays.value = exists
                              ? overlays.value
                                    .where(
                                      (value) =>
                                          value.runtimeType !=
                                          indicator.runtimeType,
                                    )
                                    .toList()
                              : [...overlays.value, indicator];
                        },
                      ),
                    _ChartChoice(
                      label: 'Volume',
                      selected: panes.value.any(
                        (pane) => pane is WiredVolumePane,
                      ),
                      onPressed: () {
                        panes.value =
                            panes.value.any((pane) => pane is WiredVolumePane)
                            ? panes.value
                                  .where((pane) => pane is! WiredVolumePane)
                                  .toList()
                            : [...panes.value, const WiredVolumePane()];
                      },
                    ),
                    for (final indicator in const <WiredChartIndicator>[
                      WiredRsi(),
                      WiredMacd(),
                    ])
                      _ChartChoice(
                        label: indicator.label,
                        selected: panes.value
                            .whereType<WiredIndicatorPane>()
                            .any(
                              (pane) =>
                                  pane.indicator.runtimeType ==
                                  indicator.runtimeType,
                            ),
                        onPressed: () {
                          final exists = panes.value
                              .whereType<WiredIndicatorPane>()
                              .any(
                                (pane) =>
                                    pane.indicator.runtimeType ==
                                    indicator.runtimeType,
                              );
                          panes.value = exists
                              ? panes.value
                                    .where(
                                      (pane) =>
                                          pane is! WiredIndicatorPane ||
                                          pane.indicator.runtimeType !=
                                              indicator.runtimeType,
                                    )
                                    .toList()
                              : [
                                  ...panes.value,
                                  WiredIndicatorPane(indicator: indicator),
                                ];
                        },
                      ),
                  ],
                ),
              ],
            ),
            WiredExpansionTile(
              title: const Text('Draw and save', key: ChartDemoKeys.drawings),
              children: [
                const Text(
                  'Choose a tool, then tap the chart. Lines, rectangles, and Fibonacci use two points. Select a drawing to move its handles.',
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final value in WiredChartDrawingTool.values)
                      _ChartChoice(
                        label: _toolLabel(value),
                        selected: tool.value == value,
                        onPressed: () => tool.value = value,
                      ),
                    WiredButton(
                      onPressed: annotations.undo,
                      child: const Text('Undo'),
                    ),
                    WiredButton(
                      onPressed: annotations.redo,
                      child: const Text('Redo'),
                    ),
                    WiredButton(
                      onPressed: () {
                        final id = annotations.selectedId;
                        if (id != null) annotations.remove(id);
                      },
                      child: const Text('Delete drawing'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                WiredInput(controller: note, labelText: 'Annotation text'),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    WiredButton(
                      key: ChartDemoKeys.save,
                      onPressed: () {
                        saved.value = WiredChartWorkspace.capture(
                          controller,
                          annotations,
                          series: series.value,
                          scale: scale.value,
                          overlays: overlays.value,
                          panes: panes.value,
                          handDrawn: handDrawn.value,
                        );
                        savedInterval.value = interval.value;
                        status.value = 'Workspace saved in this demo session.';
                      },
                      child: const Text('Save workspace'),
                    ),
                    WiredButton(
                      key: ChartDemoKeys.restore,
                      onPressed: () {
                        final snapshot = saved.value;
                        if (snapshot == null) {
                          status.value = 'Save a workspace first.';
                          return;
                        }
                        final restored = WiredChartWorkspace.fromJson(
                          snapshot.toJson(),
                        );
                        if (interval.value != savedInterval.value) {
                          interval.value = savedInterval.value;
                          final candles = chartExampleCandles(count.value);
                          controller.replaceCandles(
                            interval.value == 1
                                ? candles
                                : aggregateWiredChartCandles(
                                    candles,
                                    interval: Duration(minutes: interval.value),
                                    sourceInterval: const Duration(minutes: 1),
                                  ),
                          );
                        }
                        restored.restore(
                          controller: controller,
                          annotations: annotations,
                        );
                        series.value = restored.series;
                        scale.value = restored.scale;
                        overlays.value = restored.overlays;
                        panes.value = restored.panes;
                        handDrawn.value = restored.handDrawn;
                        status.value =
                            'Workspace restored, including your drawings.';
                      },
                      child: const Text('Restore workspace'),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'Keyboard: arrows select candles, + / − zoom, End returns to the latest candle. Ctrl/Cmd+Z undoes a drawing; Delete removes the selection.',
            ),
          ],
        ),
      ),
    );
  }
}

class _ChartChoice extends HookWidget {
  const _ChartChoice({
    required this.label,
    required this.selected,
    required this.onPressed,
  });

  final String label;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Semantics(
    selected: selected,
    child: WiredButton(
      key: ChartDemoKeys.choice(label),
      onPressed: onPressed,
      child: Text(selected ? '✓ $label' : label),
    ),
  );
}

String _seriesLabel(WiredPriceSeries series) => switch (series) {
  WiredPriceSeries.candlesticks => 'Candles',
  WiredPriceSeries.line => 'Line',
  WiredPriceSeries.area => 'Area',
  WiredPriceSeries.bars => 'OHLC',
};

String _toolLabel(WiredChartDrawingTool tool) => switch (tool) {
  WiredChartDrawingTool.none => 'Navigate',
  WiredChartDrawingTool.trendLine => 'Trend line',
  WiredChartDrawingTool.horizontalLine => 'Price level',
  WiredChartDrawingTool.rectangle => 'Rectangle',
  WiredChartDrawingTool.text => 'Text note',
  WiredChartDrawingTool.fibonacci => 'Fibonacci',
};

/// Deterministic synthetic candles for the gallery and its integration tests.
List<WiredChartCandle> chartExampleCandles(int count) {
  final start = DateTime.utc(2026, 9, 10, 9);
  var previous = 14000;

  return List.generate(count, (index) {
    final close =
        14000 +
        (math.sin(index * .19) * 190 +
                math.sin(index * .051) * 350 +
                index * 1.2)
            .round();
    final open = previous;
    previous = close;
    WiredChartDecimal price(int cents) =>
        WiredChartDecimal(BigInt.from(cents), 2);

    return WiredChartCandle(
      time: start.add(Duration(minutes: index)),
      open: price(open),
      high: price(math.max(open, close) + 15 + index % 51),
      low: price(math.min(open, close) - 12 - index % 37),
      close: price(close),
      volume: WiredChartDecimal.fromInt(
        100 + (math.sin(index * .3).abs() * 900).round(),
      ),
      revision: count,
    );
  });
}
