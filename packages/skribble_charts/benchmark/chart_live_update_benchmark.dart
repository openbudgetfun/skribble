import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble_charts/src/chart_controller.dart';
import 'package:skribble_charts/src/chart_data.dart';
import 'package:skribble_charts/src/chart_geometry.dart';
import 'package:skribble_charts/src/chart_indicators.dart';
import 'package:skribble_charts/src/chart_painter.dart';
import 'package:skribble_charts/src/chart_theme.dart';

const _historyLength = int.fromEnvironment(
  'chartBenchmarkHistory',
  defaultValue: 20000,
);
const _measuredCorrections = int.fromEnvironment(
  'chartBenchmarkCorrections',
  defaultValue: 100,
);
const _warmupCorrections = 10;
final _start = DateTime.utc(2026);

void main() {
  test('controller correction cost at configured history', () {
    final controller = _controller();
    addTearDown(controller.dispose);

    for (var revision = 1; revision <= _warmupCorrections; revision++) {
      _correct(controller, revision);
    }

    const corrections = 1000;
    final stopwatch = Stopwatch()..start();
    for (
      var revision = _warmupCorrections + 1;
      revision <= _warmupCorrections + corrections;
      revision++
    ) {
      _correct(controller, revision);
    }
    stopwatch.stop();
    _printMeasurement('controller', stopwatch, corrections);

    expect(controller.candles, hasLength(_historyLength));
    expect(controller.candles.last.revision, _warmupCorrections + corrections);
  });

  test('indicator calculation breakdown', () {
    final candles = List<WiredChartCandle>.unmodifiable(
      List.generate(_historyLength, _candle),
    );
    const indicators = <WiredChartIndicator>[
      WiredSma(),
      WiredEma(),
      WiredRsi(),
      WiredMacd(),
    ];
    var checksum = 0.0;

    for (final indicator in indicators) {
      indicator.calculate(candles);
      final stopwatch = Stopwatch()..start();
      for (var iteration = 0; iteration < _measuredCorrections; iteration++) {
        final result = indicator.calculate(candles);
        checksum += result.lines
            .map((line) => line.values.last)
            .whereType<double>()
            .fold<double>(0, (sum, value) => sum + value);
      }
      stopwatch.stop();
      _printMeasurement(indicator.label, stopwatch, _measuredCorrections);
    }

    expect(checksum.isFinite, isTrue);
  });

  test('live corrections with four common indicators', () {
    final controller = _controller();
    addTearDown(controller.dispose);

    var checksum = 0.0;
    for (var revision = 1; revision <= _warmupCorrections; revision++) {
      checksum += _correctAndLayout(controller, revision);
    }

    final stopwatch = Stopwatch()..start();
    for (
      var revision = _warmupCorrections + 1;
      revision <= _warmupCorrections + _measuredCorrections;
      revision++
    ) {
      checksum += _correctAndLayout(controller, revision);
    }
    stopwatch.stop();
    _printMeasurement(
      'controllerAndIndicators',
      stopwatch,
      _measuredCorrections,
    );

    expect(controller.candles, hasLength(_historyLength));
    expect(
      controller.candles.last.revision,
      _warmupCorrections + _measuredCorrections,
    );
    expect(checksum.isFinite, isTrue);
  });
}

WiredChartController _controller() => WiredChartController(
  instrument: WiredChartInstrument(id: 'SOL-USDC'),
  candles: List.generate(_historyLength, _candle),
  visibleCount: 120,
);

void _printMeasurement(String operation, Stopwatch stopwatch, int iterations) {
  // Keep output machine-readable enough to compare local runs. This file is
  // opt-in because elapsed-time gates are unreliable on shared CI hosts.
  // Run: flutter test benchmark/chart_live_update_benchmark.dart
  // ignore: avoid_print
  print({
    'operation': operation,
    'historyLength': _historyLength,
    'iterations': iterations,
    'elapsedMilliseconds': stopwatch.elapsedMilliseconds,
    'microsecondsPerIteration': stopwatch.elapsedMicroseconds / iterations,
  });
}

void _correct(WiredChartController controller, int revision) {
  final index = controller.candles.length - 1;
  controller.mergeCandles([_candle(index, revision: revision)]);
}

double _correctAndLayout(WiredChartController controller, int revision) {
  _correct(controller, revision);
  final scene = ChartScene(
    candles: controller.candles,
    instrument: controller.instrument,
    firstVisible: controller.firstVisible,
    visibleCount: controller.visibleCount,
    size: const Size(900, 540),
    series: WiredPriceSeries.candlesticks,
    scale: WiredChartPriceScale.linear,
    style: const WiredChartStyle(handDrawn: false),
    overlays: const [WiredSma(), WiredEma()],
    panes: const [
      WiredIndicatorPane(indicator: WiredRsi()),
      WiredIndicatorPane(indicator: WiredMacd()),
    ],
  );

  return scene.results.values.fold<double>(0, (total, result) {
    final lastLines = result.lines
        .map((line) => line.values.last)
        .whereType<double>();
    final histogram = result.histogram?.last;

    return total +
        lastLines.fold<double>(0, (sum, value) => sum + value) +
        (histogram ?? 0);
  });
}

WiredChartCandle _candle(int index, {int revision = 0}) {
  final center = 10000 + index % 89 + revision % 7;
  final open = WiredChartDecimal.fromInt(center);
  final close = WiredChartDecimal.fromInt(center + (index.isEven ? 3 : -2));

  return WiredChartCandle(
    time: _start.add(Duration(minutes: index)),
    open: open,
    high: WiredChartDecimal.fromInt(
      math.max(center, center + (index.isEven ? 3 : -2)) + 4,
    ),
    low: WiredChartDecimal.fromInt(
      math.min(center, center + (index.isEven ? 3 : -2)) - 4,
    ),
    close: close,
    volume: WiredChartDecimal.fromInt(1000 + index % 300),
    revision: revision,
  );
}
