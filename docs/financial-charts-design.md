# Financial chart architecture

## Scope and caller usage

`skribble_charts` is a Flutter companion package for financial visualization. It owns coordinate conversion, precise candle values, rendering, interaction, indicators, and annotations. Applications own market-data transports, persistent storage, accounts, and trade execution.

```dart
final controller = WiredChartController(
  instrument: WiredChartInstrument(id: 'SOL / USDC', priceDecimals: 4),
  candles: history,
);
final annotations = WiredChartAnnotations();

WiredFinancialChart(
  controller: controller,
  annotations: annotations,
  overlays: const [WiredSma(period: 20)],
  panes: const [
    WiredVolumePane(),
    WiredIndicatorPane(indicator: WiredRsi()),
  ],
);
```

## Grounding

The existing Maps package establishes independently versioned companion packages. The Flutter docs compile real example widgets from annotated Dart expressions and generate their Markdown snippets from that source. Storybook uses a route per category.

Skribble's generic rough line renderer displaces endpoints. Its rectangles also reserve room for ink bleed. These behaviors are appropriate for controls but must not determine candle prices. The chart clips hatching to exact body bounds and preserves every OHLC position. Themes contribute appearance, not geometry.

## Alternatives and synthesis

Two independent designs were compared before implementation. A controller-owned session offers concise updates and viewport anchoring. A fully declarative document/data/view design offers explicit snapshots, but requires applications to coordinate callbacks for every pointer event and live update.

The chosen design uses an immutable financial data model and declarative chart options, with one controller for data, viewport, and selection. Annotation history has a separate owner so market updates never enter undo history. Workspace serialization captures both owners and chart options into a validated document. There are no public render-stage managers or pass-through services.

The architecture skill's optional arena helper was unavailable. Two independent agents supplied the alternative designs directly, using GPT-6 and GPT-5.6 Sol.

## Ownership

| Module                       | Owns                                                               |
| ---------------------------- | ------------------------------------------------------------------ |
| `chart_data.dart`            | Exact decimal strings, instrument metadata, validated OHLC candles |
| `chart_controller.dart`      | Ordered revision-aware updates, viewport anchoring, selection      |
| `chart_geometry.dart`        | Forward/inverse price and time/index transforms                    |
| `chart_feed.dart`            | Optional snapshot/stream lifecycle and interval aggregation        |
| `chart_indicators.dart`      | Pure calculations, warm-up and numerical conventions               |
| `chart_annotations.dart`     | Typed market anchors, editing history, annotation codec            |
| `chart_workspace.dart`       | Versioned workspace snapshots, validation and restoration          |
| `chart_theme.dart`           | Appearance and pane declarations                                   |
| `chart_painter.dart`         | Private layout, visible-data rendering and indicator caches        |
| `wired_financial_chart.dart` | Hooks, gesture arbitration, focus, semantics and selection         |

## Contracts

- OHLC values and annotation prices retain exact decimal coefficients. Linear geometry subtracts an exact origin before converting relative values to screen coordinates. Indicators use documented double-precision arithmetic.
- Timestamps are UTC identities. Candle-index spacing compresses missing intervals without inventing prices. Drawings store market coordinates.
- A lower revision never replaces a higher revision. Equal revisions use the latest accepted caller update. Prepending history preserves the visible timestamp and selection.
- Moving the crosshair does not reconstruct the main scene. Indicator results cache by immutable data snapshot. Painting visits visible candles only.
- A single correction uses a binary search and creates one immutable snapshot. Batch merges and indicators are linear in active history. One scene shares close-price projection across its indicators.
- The measured operating envelope is 20,000 active candles with SMA, EMA, RSI, and MACD. Applications coalesce rapid updates and page or aggregate older data explicitly; the controller never truncates history.
- Each completed annotation edit creates one undo entry. Restore validates the entire document before changing the target state.
- The consuming app owns borrowed controllers and annotation editors. The widget disposes only editors that it creates itself.
- New package code imports Flutter widgets and lower layers, never Material or Cupertino libraries.

## Verification requirements

Numerical tests cover decimal round trips, tiny/large prices, transforms, indicator reference values, revisions, interval aggregation, and feed races. Widget tests cover input, keyboard and semantics, all series/scale modes, annotations, controller replacement, narrow screens, and large text. Renderer tests inspect actual pixels and deterministic candle boundaries. Docs and Storybook tests use production compositions. Final verification must include live Android, iOS simulator, and browser interactions with captured evidence, followed by all repository checks and GitHub CI before merging.

`packages/skribble_charts/benchmark/chart_live_update_benchmark.dart` is an opt-in native Flutter benchmark. It records controller-only corrections, each common indicator, and a complete correction plus scene calculation at a configurable history size. It asserts data and result validity but deliberately has no elapsed-time CI assertion because shared runners cannot provide a stable latency guarantee.
