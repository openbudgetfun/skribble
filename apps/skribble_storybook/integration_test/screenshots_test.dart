import 'dart:io';
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:skribble_storybook/app.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  final screenshotsDir = '${Directory.current.path}/.screenshots';

  Future<void> takeScreenshot(String name) async {
    final dir = Directory('$screenshotsDir/${name.split('/').first}');
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }
    await binding.takeScreenshot(name);
  }

  Future<void> openCategory(WidgetTester tester, String category) async {
    final finder = find.text(category);
    if (finder.evaluate().isEmpty) {
      await tester.scrollUntilVisible(finder, 200);
      await tester.pumpAndSettle();
    }
    await tester.tap(finder.first);
    await tester.pumpAndSettle();
  }

  Future<void> capturePageAndWidgets(
    WidgetTester tester, {
    required String category,
    required String pageShot,
    required List<String> widgetShots,
  }) async {
    await tester.pumpWidget(const SkribbleStorybookApp());
    await tester.pumpAndSettle();

    await openCategory(tester, category);

    await takeScreenshot(pageShot);

    for (final widgetShot in widgetShots) {
      await takeScreenshot(widgetShot);
    }
  }

  group('Screenshots', () {
    testWidgets('capture home page', (tester) async {
      await tester.pumpWidget(const SkribbleStorybookApp());
      await tester.pumpAndSettle();

      await takeScreenshot('home/home');
    });

    testWidgets('capture buttons page and widgets', (tester) async {
      await capturePageAndWidgets(
        tester,
        category: 'Buttons',
        pageShot: 'buttons/buttons',
        widgetShots: const [
          'buttons/wired-button',
          'buttons/wired-elevated-button',
          'buttons/wired-outlined-button',
          'buttons/wired-text-button',
          'buttons/wired-icon-button',
          'buttons/wired-fab',
          'buttons/wired-segmented-button',
        ],
      );
    });

    testWidgets('capture inputs page and widgets', (tester) async {
      await capturePageAndWidgets(
        tester,
        category: 'Inputs',
        pageShot: 'inputs/inputs',
        widgetShots: const [
          'inputs/wired-input',
          'inputs/wired-text-area',
          'inputs/wired-search-bar',
          'inputs/wired-checkbox',
          'inputs/wired-radio',
          'inputs/wired-slider',
          'inputs/wired-range-slider',
          'inputs/wired-toggle',
          'inputs/wired-switch',
          'inputs/wired-progress',
          'inputs/wired-circular-progress',
        ],
      );
    });

    testWidgets('capture navigation page and widgets', (tester) async {
      await capturePageAndWidgets(
        tester,
        category: 'Navigation',
        pageShot: 'navigation/navigation',
        widgetShots: const [
          'navigation/wired-app-bar',
          'navigation/wired-bottom-nav',
          'navigation/wired-navigation-bar',
          'navigation/wired-navigation-rail',
          'navigation/wired-drawer',
          'navigation/wired-popup-menu',
          'navigation/wired-tab-bar',
        ],
      );
    });

    testWidgets('capture selection page and widgets', (tester) async {
      await capturePageAndWidgets(
        tester,
        category: 'Selection',
        pageShot: 'selection/selection',
        widgetShots: const [
          'selection/wired-chip',
          'selection/wired-choice-chip',
          'selection/wired-filter-chip',
          'selection/wired-checkbox-list-tile',
          'selection/wired-radio-list-tile',
          'selection/wired-switch-list-tile',
        ],
      );
    });

    testWidgets('capture feedback page and widgets', (tester) async {
      await capturePageAndWidgets(
        tester,
        category: 'Feedback',
        pageShot: 'feedback/feedback',
        widgetShots: const [
          'feedback/wired-dialog',
          'feedback/wired-snack-bar',
          'feedback/wired-popup-menu',
          'feedback/wired-tooltip',
          'feedback/wired-badge',
        ],
      );
    });

    testWidgets('capture layout page and widgets', (tester) async {
      await capturePageAndWidgets(
        tester,
        category: 'Layout',
        pageShot: 'layout/layout',
        widgetShots: const [
          'layout/wired-card',
          'layout/wired-divider',
          'layout/wired-list-tile',
          'layout/wired-expansion-tile',
          'layout/wired-bottom-sheet',
          'layout/wired-data-table',
        ],
      );
    });

    testWidgets('capture data display page and widgets', (tester) async {
      await capturePageAndWidgets(
        tester,
        category: 'Data Display',
        pageShot: 'data-display/data-display',
        widgetShots: const [
          'data-display/wired-calendar',
          'data-display/wired-date-picker',
          'data-display/wired-time-picker',
          'data-display/wired-stepper',
        ],
      );
    });

    testWidgets('capture rough icons gallery', (tester) async {
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = const Size(2400, 4200);

      await tester.pumpWidget(const SkribbleStorybookApp());
      await tester.pumpAndSettle();

      await openCategory(tester, 'Rough Icons');
      await takeScreenshot('rough-icons/rough-icons');
    });
  });
}
