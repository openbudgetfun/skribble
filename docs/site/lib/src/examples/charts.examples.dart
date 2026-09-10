part of 'catalog.dart';

/// @docs-example chart-interactive
Widget _chartInteractive(ExampleSettings settings) => HookBuilder(
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
              roughness: settings.amount / 2,
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
);
