# Skribble Charts

Financial charts with hand-drawn candle textures and exact price geometry for Flutter. Includes candlesticks, OHLC bars, line/area charts, volume, SMA, EMA, RSI, MACD, Bollinger Bands, and editable annotations.

The renderer uses Flutter's canvas on Android, iOS, desktop, and web. It does not embed TradingView or require a browser engine on mobile.

## Create a chart

```dart
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:skribble_charts/skribble_charts.dart';

class PriceChart extends HookWidget {
  const PriceChart({required this.candles, super.key});

  final List<WiredChartCandle> candles;

  @override
  Widget build(BuildContext context) {
    final controller = useMemoized(
      () => WiredChartController(
        instrument: WiredChartInstrument(id: 'SOL / USDC'),
      ),
    );
    useEffect(() => controller.dispose, [controller]);
    useEffect(() {
      controller.replaceCandles(candles);
      return null;
    }, [controller, candles]);

    return SizedBox(
      height: 440,
      child: WiredFinancialChart(
        controller: controller,
        overlays: const [WiredSma(period: 20)],
        panes: const [WiredVolumePane()],
        semanticLabel: 'SOL price in USDC',
      ),
    );
  }
}
```

Parse prices from exact decimal strings or integer atomic units:

```dart
final candle = WiredChartCandle(
  time: DateTime.utc(2026, 9, 10, 12),
  open: WiredChartDecimal.parse('142.5000'),
  high: WiredChartDecimal.parse('143.1250'),
  low: WiredChartDecimal.parse('141.8750'),
  close: WiredChartDecimal.parse('142.9875'),
  volume: WiredChartDecimal.parse('1234.56789'),
);
```

## Interaction and ownership

Constrain the chart's width and height. The application owns and disposes its controller. It can supply an annotation editor to retain drawings across route changes; otherwise the widget owns a local editor.

Drag to pan, pinch or scroll to zoom, and tap/long press to inspect. Keyboard arrows select candles, plus/minus zoom, and End returns to the latest candle. Ctrl/Cmd+Z undoes drawing edits, Ctrl/Cmd+Shift+Z redoes, Delete removes the selected drawing, and Escape cancels an unfinished edit. Screen-reader zoom actions expose their next values. Selected OHLC values remain visible as text.

Price boundaries and wick endpoints do not move with roughness. Candle textures have stable seeds and reduce detail at dense zoom levels. Price geometry does not animate. `WiredChartStyle` supplies paper, ink, up/down, grid, and indicator colors independently of the host's theme.

## History, streams, and intervals

`mergeCandles` upserts immutable candles by UTC timestamp, rejects older revisions, and preserves viewport and selection across prepends. Equal revisions use the latest caller update. A viewport follows new candles only while already at the latest candle. `replaceCandles` installs a complete snapshot.

`WiredChartFeed` optionally coordinates a caller-provided snapshot loader and stream. It buffers stream updates while history loads, cancels obsolete generations, and reports failures and closed streams. Applications own transport connections, retries, and the presentation of errors.

`aggregateWiredChartCandles` derives larger UTC intervals from a declared source interval, preserving exact OHLC and volume. It does not synthesize missing prices or certify complete intervals. Recompute and replace derived snapshots after historical corrections; source revisions cannot order aggregate revisions.

## Indicators and scales

Price scales include linear, logarithmic, and percentage. Logarithmic inputs must be positive and distinguishable at the numerical precision of the transform. Percentage labels use the controller's exact `percentageReference`. It starts from the first candle's close when that close is positive and stays fixed through prepends, corrections, and snapshot replacements. Pass an explicit positive reference to the controller constructor or call `setPercentageReference` to change it. Empty or initially nonpositive data needs a positive reference before displaying a nonempty percentage chart. Time slots are uniformly spaced; absent intervals are compressed, not filled.

`WiredSma`, `WiredEma`, `WiredRsi`, `WiredMacd`, and `WiredBollingerBands` are pure, linear-time calculations. Use them as price `overlays` or in a `WiredIndicatorPane`. EMA uses an SMA seed; RSI uses Wilder smoothing; Bollinger Bands use population standard deviation. Warm-up samples are null. Indicators use double precision without changing exact source prices and reject values outside their representable range.

## Performance and live-update policy

A single-timestamp correction uses a binary search, then creates a new immutable candle snapshot. Batch merges and every indicator remain linear in the active history length. When a scene needs several indicators, it converts exact closes to doubles once for the group. Indicator results are cached for that immutable candle snapshot, so pointer and viewport changes reuse them.

Keep the active history near 20,000 candles or less when showing the common SMA, EMA, RSI, and MACD set. This is a measured working set, not a hard API limit: the controller never discards history. Aggregate or page older candles deliberately, and coalesce rapid transport events into one `mergeCandles` call per UI update. Larger snapshots and more indicators need application-specific profiling because each accepted data revision recalculates the full configured indicator history.

The opt-in native Flutter benchmark reports controller-only, per-indicator, and composed scene costs without an unstable wall-clock CI gate:

```console
flutter test benchmark/chart_live_update_benchmark.dart \
  --dart-define=chartBenchmarkHistory=20000 \
  --dart-define=chartBenchmarkCorrections=100
```

## Numerical precision and dense views

Source decimals support up to 1000 fractional places and 2000 coefficient digits. Exact arithmetic rejects results beyond those limits. Drawing interpolation and inverse pointer coordinates preserve endpoints and round only when an intermediate coordinate exceeds storage precision. This also applies to Fibonacci retracements. Chart padding uses pixels, so it does not expand source prices beyond the accepted decimal range.

Indicators require closes representable as finite, non-underflowing doubles. Extreme magnitudes are normalized before calculating averages and variances. An indicator whose mathematical output cannot fit in a double throws an error; the renderer does not silently omit overflowed results. Indicators retain double precision rather than exact source arithmetic.

When several candles occupy one horizontal pixel, the chart draws cached envelopes preserving the first open, last close, highest high, and lowest low. Line and indicator sampling retains each bucket's first, last, minimum, and maximum points. Dense volume bars display the largest source volume in each bucket and are labeled `Volume · peak`. Inspection always selects an original candle. Initial summarization reads the visible history; subsequent pan gestures reuse a bounded cache. Replace source lists instead of mutating snapshots. Custom `WiredChartStyle.indicatorColors` lists must also remain immutable.

## Drawings and persistence

`WiredChartAnnotations` owns trend lines, horizontal levels, rectangles, text, and Fibonacci retracements. Each anchor holds a timestamp and exact price. Use the chart's `tool` to create a drawing; select it in navigation mode and drag its handles to edit. One completed drag creates one undo entry. Feed updates do not enter drawing history. Logarithmic views retain but hide nonpositive anchors.

```dart
final snapshot = WiredChartWorkspace.capture(
  controller,
  annotations,
  series: WiredPriceSeries.candlesticks,
  overlays: const [WiredSma()],
  panes: const [WiredVolumePane()],
);
final encoded = snapshot.encode(); // Store with your application's preferences.
final restored = WiredChartWorkspace.decode(encoded);
restored.restore(controller: controller, annotations: annotations);
// Also pass restored.series, scale, overlays, panes, and handDrawn to your UI.
```

Workspace decoding validates versions, instrument identity/precision, options, and drawings before restoration. Saved view anchors require matching history to be loaded. Workspaces preserve the exact percentage reference and actual visible candle count. A previously full view rejects partial trailing history; a chart captured with fewer candles than viewport slots can restore those same candles. An uninitialized saved reference retains the target's baseline from data loading. Custom palette colors remain owned by the host theme.

## Examples and verification

The repository's Flutter documentation has a live chart at `/widgets/charts`. Storybook's `/charts` route demonstrates timeframe aggregation, streaming sample data, all indicators, annotation editing, and session-local workspace storage. The generated prices are explicitly illustrative.

Tests cover exact arithmetic, scale inverses, revisions, feed races, aggregation, indicator reference values, persistence, pointer/keyboard/semantics behavior, and image comparisons of precise candle boundaries.

The package does not supply exchange data, order execution, persistent alerts, backtesting, or a scripting language. It is a charting library for applications that own those services.
