import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
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
  final runningInCi = Platform.environment['CI'] == 'true';
  final goldensAvailable =
      File('${Directory.current.path}/../../.screenshots/review/01-home.png')
          .existsSync();

  setUpAll(() {
    // Use bundled ShortStack font instead of fetching over HTTP.
    GoogleFonts.config.allowRuntimeFetching = false;
  });

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

  void goldenTest(String description, WidgetTesterCallback body) {
    testWidgets(description, body, skip: runningInCi || !goldensAvailable);
  }

  group('Visual Review', () {
    goldenTest('home page', (tester) async {
      await tester.pumpWidget(const SkribbleStorybookApp());
      await pumpStable(tester);
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('../../.screenshots/review/01-home.png'),
      );
    });

    goldenTest('buttons page', (tester) async {
      await tester.pumpWidget(const SkribbleStorybookApp());
      await pumpStable(tester);
      await navigateTo(tester, 'Buttons');
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('../../.screenshots/review/02-buttons.png'),
      );
    });

    goldenTest('inputs page', (tester) async {
      await tester.pumpWidget(const SkribbleStorybookApp());
      await pumpStable(tester);
      await navigateTo(tester, 'Inputs');
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('../../.screenshots/review/03-inputs.png'),
      );
    });

    goldenTest('navigation page', (tester) async {
      await tester.pumpWidget(const SkribbleStorybookApp());
      await pumpStable(tester);
      await navigateTo(tester, 'Navigation');
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('../../.screenshots/review/04-navigation.png'),
      );
    });

    goldenTest('selection page', (tester) async {
      await tester.pumpWidget(const SkribbleStorybookApp());
      await pumpStable(tester);
      await navigateTo(tester, 'Selection');
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('../../.screenshots/review/05-selection.png'),
      );
    });

    goldenTest('feedback page', (tester) async {
      await tester.pumpWidget(const SkribbleStorybookApp());
      await pumpStable(tester);
      await navigateTo(tester, 'Feedback');
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('../../.screenshots/review/06-feedback.png'),
      );
    });

    goldenTest('layout page', (tester) async {
      await tester.pumpWidget(const SkribbleStorybookApp());
      await pumpStable(tester);
      await navigateTo(tester, 'Layout');
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('../../.screenshots/review/07-layout.png'),
      );
    });

    goldenTest('data display page', (tester) async {
      await tester.pumpWidget(const SkribbleStorybookApp());
      await pumpStable(tester);
      await navigateTo(tester, 'Data Display');
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('../../.screenshots/review/08-data-display.png'),
      );
    });
  });
}
