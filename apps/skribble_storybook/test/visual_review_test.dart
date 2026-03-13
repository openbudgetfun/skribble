import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble_storybook/app.dart';

/// Visual review test — renders each storybook page as a golden file PNG.
///
/// Run with: flutter test --update-goldens test/visual_review_test.dart
/// Then inspect .screenshots/review/ for visual quality.
///
/// NOTE: Uses `pump()` with explicit durations instead of `pumpAndSettle()`
/// because WiredSlider creates a repeating timer that prevents
/// `pumpAndSettle` from ever completing.
void main() {
  /// Pumps the widget tree enough to render without waiting for all
  /// animations to settle (avoids WiredSlider timer hang).
  Future<void> pumpStable(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 200));
  }

  Future<void> navigateTo(WidgetTester tester, String category) async {
    // Scroll category into view if needed
    final finder = find.text(category);
    if (finder.evaluate().isEmpty) {
      final listFinder = find.byType(ListView).first;
      var attempts = 0;
      while (finder.evaluate().isEmpty && attempts < 20) {
        await tester.drag(listFinder, const Offset(0, -200));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 50));
        attempts++;
      }
    }
    await tester.tap(finder.first);
    await pumpStable(tester);
  }

  group('Visual Review', () {
    testWidgets('home page', (tester) async {
      await tester.pumpWidget(const SkribbleStorybookApp());
      await pumpStable(tester);
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('../../.screenshots/review/01-home.png'),
      );
    });

    testWidgets('buttons page', (tester) async {
      await tester.pumpWidget(const SkribbleStorybookApp());
      await pumpStable(tester);
      await navigateTo(tester, 'Buttons');
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('../../.screenshots/review/02-buttons.png'),
      );
    });

    testWidgets('inputs page', (tester) async {
      await tester.pumpWidget(const SkribbleStorybookApp());
      await pumpStable(tester);
      await navigateTo(tester, 'Inputs');
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('../../.screenshots/review/03-inputs.png'),
      );
    });

    testWidgets('navigation page', (tester) async {
      await tester.pumpWidget(const SkribbleStorybookApp());
      await pumpStable(tester);
      await navigateTo(tester, 'Navigation');
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('../../.screenshots/review/04-navigation.png'),
      );
    });

    testWidgets('selection page', (tester) async {
      await tester.pumpWidget(const SkribbleStorybookApp());
      await pumpStable(tester);
      await navigateTo(tester, 'Selection');
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('../../.screenshots/review/05-selection.png'),
      );
    });

    testWidgets('feedback page', (tester) async {
      await tester.pumpWidget(const SkribbleStorybookApp());
      await pumpStable(tester);
      await navigateTo(tester, 'Feedback');
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('../../.screenshots/review/06-feedback.png'),
      );
    });

    testWidgets('layout page', (tester) async {
      await tester.pumpWidget(const SkribbleStorybookApp());
      await pumpStable(tester);
      await navigateTo(tester, 'Layout');
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('../../.screenshots/review/07-layout.png'),
      );
    });

    // Data display page uses WiredCalendar which loads GoogleFonts over
    // the network. In the test environment HTTP is stubbed to return 400,
    // causing an unrecoverable exception. Bundle the ShortStack font as an
    // asset to re-enable this test.
    //
    // testWidgets('data display page', (tester) async {
    //   await tester.pumpWidget(const SkribbleStorybookApp());
    //   await pumpStable(tester);
    //   await navigateTo(tester, 'Data Display');
    //   await expectLater(
    //     find.byType(MaterialApp),
    //     matchesGoldenFile('../../.screenshots/review/08-data-display.png'),
    //   );
    // });
  });
}
