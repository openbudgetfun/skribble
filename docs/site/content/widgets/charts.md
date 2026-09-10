---
title: Financial charts
description: Precise hand-drawn candlesticks, indicators, and editable annotations in Flutter.
---

# Financial charts

`skribble_charts` draws candles, OHLC bars, lines, areas, and volume with exact price geometry and restrained ink texture. It is a native Flutter companion to Skribble, with the same renderer on Android, iOS, desktop, and web.

The green and red bodies span open and close. Wick endpoints mark high and low. Hatching stays inside the bodies. Price labels and selected values use the original decimal values, regardless of the visual style.

## Try it

These are deterministic illustrative candles, not exchange prices. Tap a candle to inspect its exact values, drag to pan, and pinch or use the wheel to zoom. Select **Mark a price**, then tap the plot to add a horizontal annotation.

```dart
// Live example: chart-interactive
HookBuilder(
  builder: (context) {
    final controller = useMemoized(() {
      const closes = [
        14220,
        14268,
        14240,
        14304,
        14380,
        14355,
        14295,
        14210,
        14178,
        14230,
        14295,
        14368,
        14420,
        14380,
        14405,
        14475,
        14520,
        14490,
        14430,
        14485,
        14540,
        14512,
        14580,
        14605,
      ];
      final start = DateTime.utc(2026, 9, 10, 12);
      WiredChartDecimal price(int cents) =>
          WiredChartDecimal(BigInt.from(cents), 2);

      return WiredChartController(
        instrument: WiredChartInstrument(id: 'SOL / USDC', volumeDecimals: 0),
        visibleCount: 24,
        candles: List.generate(closes.length, (index) {
          final open = index == 0 ? 14190 : closes[index - 1];
          final close = closes[index];

          return WiredChartCandle(
            time: start.add(Duration(minutes: index)),
            open: price(open),
            high: price((open > close ? open : close) + 25),
            low: price((open < close ? open : close) - 18),
            close: price(close),
            volume: WiredChartDecimal.fromInt(100 + (close - open).abs() * 8),
          );
        }),
      );
    });
    final annotations = useMemoized(WiredChartAnnotations.new);
    final lines = useState(false);
    final ink = useState(true);
    final indicators = useState(true);
    final tool = useState(WiredChartDrawingTool.none);
    useEffect(() {
      return () {
        controller.dispose();
        annotations.dispose();
      };
    }, [controller, annotations]);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text('SOL / USDC · illustrative candles · UTC'),
        const SizedBox(height: 8),
        SizedBox(
          height: 420,
          child: WiredFinancialChart(
            key: const ValueKey('docs-financial-chart'),
            controller: controller,
            annotations: annotations,
            series: lines.value
                ? WiredPriceSeries.line
                : WiredPriceSeries.candlesticks,
            overlays: indicators.value ? const [WiredSma(period: 5)] : const [],
            panes: const [WiredVolumePane()],
            style: WiredChartStyle(
              handDrawn: ink.value,
              roughness: .6 / 2,
            ),
            tool: tool.value,
            annotationLabel: 'My level',
            onAnnotationCreated: (_) => tool.value = WiredChartDrawingTool.none,
            semanticLabel: 'Illustrative SOL price chart',
          ),
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            WiredButton(
              onPressed: () => lines.value = !lines.value,
              child: Text(lines.value ? 'Show candles' : 'Show line'),
            ),
            WiredButton(
              onPressed: () => ink.value = !ink.value,
              child: Text(ink.value ? 'Crisp strokes' : 'Hand-drawn strokes'),
            ),
            WiredButton(
              onPressed: () => indicators.value = !indicators.value,
              child: Text(indicators.value ? 'Hide average' : 'Show average'),
            ),
            WiredButton(
              onPressed: () => controller.zoom(1.3),
              child: const Text('Zoom in'),
            ),
            WiredButton(
              onPressed: controller.scrollToLatest,
              child: const Text('Latest'),
            ),
            WiredButton(
              onPressed: () =>
                  tool.value = WiredChartDrawingTool.horizontalLine,
              child: const Text('Mark a price'),
            ),
            WiredButton(
              onPressed: annotations.undo,
              child: const Text('Undo drawing'),
            ),
          ],
        ),
      ],
    );
  },
)
```

The Storybook **Financial charts** page also includes 1-, 5-, and 15-minute aggregation, paper/night palettes, simulated streaming, all five indicators, editable drawing tools, and saved workspaces. Its save action stays in the current demo session; production apps choose their own storage.

## Install and create candles

```bash
dart pub add skribble_charts
```

```dart
// Static example: setup
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:skribble_charts/skribble_charts.dart';

final candle = WiredChartCandle(
  time: DateTime.utc(2026, 9, 10, 12),
  open: WiredChartDecimal.parse('142.5000'),
  high: WiredChartDecimal.parse('143.1250'),
  low: WiredChartDecimal.parse('141.8750'),
  close: WiredChartDecimal.parse('142.9875'),
  volume: WiredChartDecimal.parse('1234.56789'),
);
```

Create decimals from strings or integer atomic units. Converting an already rounded `double` to a string cannot recover its original precision. Candles validate OHLC ordering, nonnegative volume, and revision numbers at runtime.

## Ownership and live updates

The application creates and disposes `WiredChartController`. Pass a bounded width and height to `WiredFinancialChart`. Pass `WiredChartAnnotations` when drawings should survive removing the chart widget. Otherwise the widget creates and disposes a local annotation editor.

`mergeCandles` upserts by UTC timestamp. Higher revisions replace lower ones; equal revisions use the latest caller update. Prepending history preserves the visible time anchor and selection. New candles follow the latest price only while the viewport is already at the end. `replaceCandles` accepts a complete replacement snapshot.

`WiredChartFeed` optionally coordinates a snapshot loader and a live stream. It subscribes before loading history, buffers updates within a configured bound, and exposes connecting, live, closed, failed, and disconnected states. Disconnect and reconnect invalidate old asynchronous work. The host owns transport retry policy and should display feed failures to the user.

`aggregateWiredChartCandles` creates larger UTC intervals from known source intervals with exact OHLC and volume. Supply both `interval` and `sourceInterval`. Missing source candles remain missing; aggregation does not claim that an interval is complete. After a correction, recompute the affected aggregation and replace the chart snapshot. Source revisions do not establish the revision order of derived candles.

## Price scales and time

`WiredChartPriceScale` supports linear, logarithmic, and percentage scales. Logarithmic data must be positive and distinguishable at the transform's floating-point precision. Percentage labels use the controller's exact `percentageReference`. The first candle's positive close initializes it; history prepends, price corrections, and snapshot replacements keep it unchanged. Supply a positive reference in the controller constructor or call `setPercentageReference` to choose another baseline. A nonempty percentage chart requires an established reference. Invalid scale inputs produce errors rather than silently changing the selected scale.

Candle slots have uniform spacing. Timestamps remain exact identities; missing intervals are compressed rather than filled with invented prices. Time labels use UTC. Annotations interpolate positions between existing timestamps.

## Indicators and panes

Use `overlays` for indicators on the price pane. Add `WiredVolumePane` or `WiredIndicatorPane` to `panes` for independent vertical scales sharing time.

| Indicator             | Convention                                             |
| --------------------- | ------------------------------------------------------ |
| `WiredSma`            | Mean of the trailing period                            |
| `WiredEma`            | SMA seed, smoothing factor `2 / (period + 1)`          |
| `WiredRsi`            | Wilder smoothing; unchanged prices use a neutral value |
| `WiredMacd`           | Fast/slow EMAs, EMA signal, difference histogram       |
| `WiredBollingerBands` | Trailing mean and population standard deviation        |

Warm-up values are absent, not zero. Calculations use double precision and do not change the exact source candles. Indicator configurations serialize with the workspace. Large values outside the numerical range are rejected. Results cache per immutable candle snapshot so crosshair and viewport gestures avoid recalculating history.

## Performance and update batching

A single-timestamp correction finds its candle by binary search, then creates a new immutable snapshot. Batch merges and indicator calculations are linear in active history. A scene shares one exact-close conversion across its indicators, and it reuses indicator results while only the viewport or crosshair changes.

Treat 20,000 active candles as the measured operating envelope for the common SMA, EMA, RSI, and MACD combination. It is guidance rather than a controller limit; no candles are silently removed. Page or aggregate older data explicitly, batch rapid transport events into one `mergeCandles` call per UI update, and profile larger histories with the package benchmark. Every accepted data revision recalculates the complete configured indicator history.

## Precision and dense chart views

Source decimals allow 1000 fractional places and 2000 coefficient digits. Exact arithmetic rejects larger results. Drawing interpolation, inverse pointer coordinates, and Fibonacci levels preserve endpoints, rounding only beyond those storage limits. The chart adds padding in pixels so extreme source values do not require larger decimal bounds.

Indicators normalize extreme magnitudes before calculating averages and variances. Closes that overflow or underflow doubles and indicator results that cannot fit in a finite double produce explicit errors. Exact source prices remain unchanged.

At subpixel candle density, cached envelopes preserve first open, last close, highest high, and lowest low. Lines and indicators retain first, last, minimum, and maximum points per bucket. Dense volume bars show peak source volume and are labeled `Volume · peak`. Pointer inspection still reads the original candle. Initial summarization reads visible history; panning reuses bounded caches. Provide immutable data snapshots and immutable custom `indicatorColors` lists.

## Drawings and saved workspaces

The drawing tools are trend line, horizontal price level, rectangle, text, and Fibonacci retracement. A level or text needs one tap. The other tools need two. New drawings are selected immediately. In navigation mode, drag a selected handle to edit it; vertical drags outside handles continue scrolling the containing page. One finished drag is one undo operation; incoming market data never enters undo history. Storybook keeps its expanded drawing and indicator panels open when you scroll away and return.

All anchors store UTC timestamps and exact prices. Logarithmic views preserve but hide drawings with nonpositive anchors. Switching back makes them visible.

Removing or replacing a drawing, selecting another drawing, or replacing its annotation editor cancels any active handle edit. Releasing the pointer cannot overwrite the newer drawing state.

`WiredChartWorkspace.capture` records the instrument, viewport, selection, series, scale, exact percentage reference, actual visible candle count, indicators, panes, drawing state, and ink mode. Store its `encode()` string wherever your app stores preferences. `decode()` validates before restoring. Restore the returned widget options as well as calling `restore` on the controllers. Unknown formats, mismatched instruments, disposed controllers, and unavailable saved history fail without partially applying the document. Load missing history and retry when needed. A previously full viewport cannot restore with fewer visible candles, even when its anchor is the first loaded candle. Sparse captures can restore the candles they originally contained. A saved null percentage reference retains the target's baseline established during data loading. Custom theme colors belong to the host theme and are not saved by the workspace.

## Accessibility

Selected OHLC and volume appear as text beneath the chart. Keyboard arrows move selection, plus/minus zoom, and End returns to the latest candle. Ctrl/Cmd+Z and Ctrl/Cmd+Shift+Z undo and redo drawings. Delete removes the selected drawing; Escape cancels a pending drawing or edit. Screen-reader increase/decrease actions adjust zoom. Supply `semanticLabel` with the instrument and price units.

Chart geometry does not animate between prices. Repeated paints and live updates retain stable candle texture. At narrow candle widths the renderer removes interior detail to preserve legibility.

## Package boundaries

The package does not provide exchange credentials, trade execution, market-data hosting, persistent alerts, backtesting, or a scripting language. Those belong to the consuming trading product. The examples use generated data explicitly.
