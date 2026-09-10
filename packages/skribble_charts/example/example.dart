import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:skribble/skribble.dart';
import 'package:skribble_charts/skribble_charts.dart';

/// Embeds exact illustrative candles in a normal Skribble application.
void main() => runApp(
  WiredMaterialApp(wiredTheme: WiredThemeData(), home: const ChartExample()),
);

/// A small example of caller-owned controller lifecycle.
class ChartExample extends HookWidget {
  /// Creates the example screen.
  const ChartExample({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = useMemoized(() {
      final time = DateTime.utc(2026, 9, 10);
      final candle = WiredChartCandle(
        time: time,
        open: WiredChartDecimal.parse('142.50'),
        high: WiredChartDecimal.parse('143.12'),
        low: WiredChartDecimal.parse('141.87'),
        close: WiredChartDecimal.parse('142.98'),
        volume: WiredChartDecimal.parse('1234.56'),
      );

      return WiredChartController(
        instrument: WiredChartInstrument(id: 'SOL / USDC'),
        candles: [candle],
        visibleCount: 10,
      );
    });
    useEffect(() => controller.dispose, [controller]);

    return WiredScaffold(
      appBar: const WiredAppBar(title: Text('Illustrative financial chart')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: WiredFinancialChart(
          controller: controller,
          panes: const [WiredVolumePane()],
        ),
      ),
    );
  }
}
