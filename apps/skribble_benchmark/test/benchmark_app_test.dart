import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';
import 'package:skribble_benchmark/benchmark_app.dart';
import 'package:skribble_benchmark/widgets/precomputed_icon.dart';

/// The benchmark app itself: its home page opens each benchmark, and each
/// benchmark draws its icons both ways. The timings are measured on a
/// device, not here.
void main() {
  for (final (title, appBar) in const [
    ('Single Icon', 'Single Icon Bench'),
    ('Grid of Icons', 'Grid Bench'),
    ('Scrolling List', 'Scroll Bench'),
  ]) {
    testWidgets('"$title" opens a page that draws both kinds of icon', (
      tester,
    ) async {
      await tester.pumpWidget(const BenchmarkApp());
      await tester.pumpAndSettle();

      await tester.tap(find.text(title));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text(appBar), findsOneWidget);
      expect(find.byType(WiredSvgIcon), findsWidgets);

      await tester.tap(find.text('Pre-computed'));
      await tester.pumpAndSettle();
      expect(find.byType(PrecomputedIcon), findsWidgets);
      expect(tester.takeException(), isNull);
    });
  }
}
