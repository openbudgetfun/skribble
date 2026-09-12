import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';
import 'package:skribble_docs_site/src/doodle_playground.dart';

void main() {
  testWidgets('chooses drawings and seeds on narrow and wide pages', (
    tester,
  ) async {
    for (final width in [320.0, 900.0]) {
      await tester.pumpWidget(
        WiredMaterialApp(
          wiredTheme: WiredThemeData.cuddly(),
          home: Center(
            child: SizedBox(
              width: width,
              child: const SingleChildScrollView(child: DoodlePlayground()),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('heart'));
      await tester.pumpAndSettle();
      final seed = tester.widget<WiredDoodle>(find.byType(WiredDoodle)).seed;
      await tester.ensureVisible(find.text('Draw another'));
      await tester.tap(find.text('Draw another'));
      await tester.pumpAndSettle();
      final drawing = tester.widget<WiredDoodle>(find.byType(WiredDoodle));
      expect(drawing.kind, WiredDoodleKind.heart);
      expect(drawing.seed, seed + 1);
      expect(find.textContaining('seed: ${seed + 1},'), findsOneWidget);
      expect(tester.takeException(), isNull);
    }
  });
}
