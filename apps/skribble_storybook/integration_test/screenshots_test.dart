import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:skribble_storybook/app.dart';

class WidgetShot {
  final String name;
  final String anchor;

  const WidgetShot({required this.name, required this.anchor});
}

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    // Font is now bundled directly in the skribble package — no runtime
    // fetching needed.
  });

  final screenshotsDir = '${Directory.current.path}/.screenshots';
  final captureBoundaryKey = GlobalKey();

  Future<void> pumpStorybook(WidgetTester tester) async {
    await tester.pumpWidget(
      RepaintBoundary(
        key: captureBoundaryKey,
        child: const SkribbleStorybookApp(),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> takeScreenshot(WidgetTester tester, String name) async {
    final dir = Directory('$screenshotsDir/${name.split('/').first}');
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }

    final screenshotFile = File('$screenshotsDir/$name.png');
    var useFallbackCapture = false;

    try {
      await binding.takeScreenshot(name);
      useFallbackCapture = !screenshotFile.existsSync();
    } on MissingPluginException {
      useFallbackCapture = true;
    }

    if (!useFallbackCapture) {
      return;
    }

    final boundary =
        captureBoundaryKey.currentContext?.findRenderObject()
            as RenderRepaintBoundary?;
    if (boundary == null) {
      fail('Unable to locate RepaintBoundary for screenshot fallback: $name');
    }

    final image = await boundary.toImage(
      pixelRatio: tester.view.devicePixelRatio,
    );
    final byteData = await image.toByteData(format: ImageByteFormat.png);
    image.dispose();

    if (byteData == null) {
      fail('Failed to encode screenshot bytes for: $name');
    }

    await screenshotFile.writeAsBytes(byteData.buffer.asUint8List());
  }

  Future<void> focusOnText(WidgetTester tester, String text) async {
    final finder = find.text(text);
    if (finder.evaluate().isEmpty) {
      final scrollableElements = find.byType(Scrollable).evaluate().toList();
      if (scrollableElements.isEmpty) {
        fail('Could not find a scrollable while searching for "$text".');
      }

      final targetScrollable = scrollableElements.reduce((current, next) {
        final currentBox = current.renderObject as RenderBox?;
        final nextBox = next.renderObject as RenderBox?;

        final currentArea =
            (currentBox?.size.width ?? 0) * (currentBox?.size.height ?? 0);
        final nextArea =
            (nextBox?.size.width ?? 0) * (nextBox?.size.height ?? 0);

        return currentArea >= nextArea ? current : next;
      });

      final scrollable = find.byElementPredicate(
        (element) => identical(element, targetScrollable),
      );

      var attempts = 0;
      while (finder.evaluate().isEmpty && attempts < 100) {
        final origin = tester.getTopLeft(scrollable) + const Offset(16, 120);
        await tester.dragFrom(origin, const Offset(0, -350));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 50));
        attempts++;
      }
      await tester.pumpAndSettle();
    }

    expect(
      finder,
      findsWidgets,
      reason: 'Could not find "$text" in storybook page.',
    );
    await tester.ensureVisible(finder.first);
    await tester.pumpAndSettle();
  }

  Future<void> openCategory(WidgetTester tester, String category) async {
    await focusOnText(tester, category);
    await tester.tap(find.text(category).first, warnIfMissed: false);
    await tester.pumpAndSettle();
  }

  Future<void> capturePageAndWidgets(
    WidgetTester tester, {
    required String category,
    required String pageShot,
    required List<WidgetShot> widgetShots,
  }) async {
    await pumpStorybook(tester);

    await openCategory(tester, category);

    await takeScreenshot(tester, pageShot);

    for (final widgetShot in widgetShots) {
      await focusOnText(tester, widgetShot.anchor);
      await takeScreenshot(tester, widgetShot.name);
    }
  }

  group('Screenshots', () {
    testWidgets('capture home page', (tester) async {
      await pumpStorybook(tester);

      await takeScreenshot(tester, 'home/home');
    });

    testWidgets('capture buttons page and widgets', (tester) async {
      await capturePageAndWidgets(
        tester,
        category: 'Buttons',
        pageShot: 'buttons/buttons',
        widgetShots: const [
          WidgetShot(name: 'buttons/wired-button', anchor: 'WiredButton'),
          WidgetShot(
            name: 'buttons/wired-elevated-button',
            anchor: 'WiredElevatedButton',
          ),
          WidgetShot(
            name: 'buttons/wired-outlined-button',
            anchor: 'WiredOutlinedButton',
          ),
          WidgetShot(
            name: 'buttons/wired-text-button',
            anchor: 'WiredTextButton',
          ),
          WidgetShot(name: 'buttons/wired-icon', anchor: 'WiredIcon'),
          WidgetShot(
            name: 'buttons/wired-icon-button',
            anchor: 'WiredIconButton',
          ),
          WidgetShot(
            name: 'buttons/wired-fab',
            anchor: 'WiredFloatingActionButton',
          ),
          WidgetShot(
            name: 'buttons/wired-filled-button',
            anchor: 'WiredFilledButton',
          ),
          WidgetShot(
            name: 'buttons/wired-toggle-buttons',
            anchor: 'WiredToggleButtons',
          ),
          WidgetShot(
            name: 'buttons/wired-cupertino-button',
            anchor: 'WiredCupertinoButton',
          ),
          WidgetShot(
            name: 'buttons/wired-segmented-button',
            anchor: 'WiredSegmentedButton',
          ),
        ],
      );
    });

    testWidgets('capture inputs page and widgets', (tester) async {
      await capturePageAndWidgets(
        tester,
        category: 'Inputs',
        pageShot: 'inputs/inputs',
        widgetShots: const [
          WidgetShot(name: 'inputs/wired-input', anchor: 'WiredInput'),
          WidgetShot(name: 'inputs/wired-text-area', anchor: 'WiredTextArea'),
          WidgetShot(name: 'inputs/wired-form', anchor: 'WiredForm'),
          WidgetShot(name: 'inputs/wired-checkbox', anchor: 'WiredCheckbox'),
          WidgetShot(name: 'inputs/wired-radio', anchor: 'WiredRadio'),
          WidgetShot(name: 'inputs/wired-toggle', anchor: 'WiredToggle'),
          WidgetShot(name: 'inputs/wired-switch', anchor: 'WiredSwitch'),
          WidgetShot(
            name: 'inputs/wired-cupertino-switch',
            anchor: 'WiredCupertinoSwitch',
          ),
          WidgetShot(name: 'inputs/wired-slider', anchor: 'WiredSlider'),
          WidgetShot(name: 'inputs/wired-combo', anchor: 'WiredCombo'),
          WidgetShot(
            name: 'inputs/wired-autocomplete',
            anchor: 'WiredAutocomplete',
          ),
          WidgetShot(
            name: 'inputs/wired-cupertino-text-field',
            anchor: 'WiredCupertinoTextField',
          ),
          WidgetShot(
            name: 'inputs/wired-cupertino-slider',
            anchor: 'WiredCupertinoSlider',
          ),
          WidgetShot(
            name: 'inputs/wired-search-bar',
            anchor: 'WiredSearchBar',
          ),
        ],
      );
    });

    testWidgets('capture navigation page and widgets', (tester) async {
      await capturePageAndWidgets(
        tester,
        category: 'Navigation',
        pageShot: 'navigation/navigation',
        widgetShots: const [
          WidgetShot(name: 'navigation/wired-app-bar', anchor: 'WiredAppBar'),
          WidgetShot(
            name: 'navigation/wired-bottom-nav',
            anchor: 'WiredBottomNavigationBar',
          ),
          WidgetShot(name: 'navigation/wired-tab-bar', anchor: 'WiredTabBar'),
          WidgetShot(
            name: 'navigation/wired-navigation-bar',
            anchor: 'WiredNavigationBar',
          ),
          WidgetShot(
            name: 'navigation/wired-navigation-rail',
            anchor: 'WiredNavigationRail',
          ),
          WidgetShot(
            name: 'navigation/wired-popup-menu',
            anchor: 'WiredPopupMenuButton',
          ),
          WidgetShot(
            name: 'navigation/wired-cupertino-navigation-bar',
            anchor: 'WiredCupertinoNavigationBar',
          ),
          WidgetShot(
            name: 'navigation/wired-cupertino-tab-bar',
            anchor: 'WiredCupertinoTabBar',
          ),
          WidgetShot(
            name: 'navigation/wired-bottom-app-bar',
            anchor: 'WiredBottomAppBar',
          ),
          WidgetShot(
            name: 'navigation/wired-menu-bar',
            anchor: 'WiredMenuBar',
          ),
          WidgetShot(
            name: 'navigation/wired-dropdown-menu',
            anchor: 'WiredDropdownMenu',
          ),
          WidgetShot(
            name: 'navigation/wired-drawer-header',
            anchor: 'WiredDrawerHeader',
          ),
          WidgetShot(
            name: 'navigation/wired-user-accounts-drawer-header',
            anchor: 'User Accounts Header',
          ),
          WidgetShot(name: 'navigation/wired-drawer', anchor: 'WiredDrawer'),
          WidgetShot(
            name: 'navigation/wired-navigation-drawer',
            anchor: 'WiredNavigationDrawer',
          ),
        ],
      );
    });

    testWidgets('capture selection page and widgets', (tester) async {
      await capturePageAndWidgets(
        tester,
        category: 'Selection',
        pageShot: 'selection/selection',
        widgetShots: const [
          WidgetShot(name: 'selection/wired-chip', anchor: 'WiredChip'),
          WidgetShot(
            name: 'selection/wired-filter-chip',
            anchor: 'WiredFilterChip',
          ),
          WidgetShot(
            name: 'selection/wired-choice-chip',
            anchor: 'WiredChoiceChip',
          ),
          WidgetShot(
            name: 'selection/wired-input-chip',
            anchor: 'WiredInputChip',
          ),
          WidgetShot(
            name: 'selection/wired-action-chip',
            anchor: 'WiredActionChip',
          ),
          WidgetShot(
            name: 'selection/wired-cupertino-picker',
            anchor: 'WiredCupertinoPicker',
          ),
          WidgetShot(
            name: 'selection/wired-cupertino-date-picker',
            anchor: 'WiredCupertinoDatePicker',
          ),
          WidgetShot(
            name: 'selection/wired-cupertino-segmented-control',
            anchor: 'Segmented Control',
          ),
          WidgetShot(
            name: 'selection/wired-sliding-segmented-control',
            anchor: 'WiredSlidingSegmentedControl',
          ),
          WidgetShot(
            name: 'selection/wired-color-picker',
            anchor: 'WiredColorPicker',
          ),
        ],
      );
    });

    testWidgets('capture feedback page and widgets', (tester) async {
      await capturePageAndWidgets(
        tester,
        category: 'Feedback',
        pageShot: 'feedback/feedback',
        widgetShots: const [
          WidgetShot(
            name: 'feedback/wired-animated-icon',
            anchor: 'WiredAnimatedIcon',
          ),
          WidgetShot(
            name: 'feedback/wired-material-banner',
            anchor: 'WiredMaterialBanner',
          ),
          WidgetShot(name: 'feedback/wired-progress', anchor: 'WiredProgress'),
          WidgetShot(
            name: 'feedback/wired-circular-progress',
            anchor: 'WiredCircularProgress',
          ),
          WidgetShot(name: 'feedback/wired-dialog', anchor: 'WiredDialog'),
          WidgetShot(
            name: 'feedback/wired-snack-bar',
            anchor: 'WiredSnackBar',
          ),
          WidgetShot(
            name: 'feedback/wired-bottom-sheet',
            anchor: 'WiredBottomSheet',
          ),
          WidgetShot(name: 'feedback/wired-tooltip', anchor: 'WiredTooltip'),
          WidgetShot(name: 'feedback/wired-badge', anchor: 'WiredBadge'),
          WidgetShot(
            name: 'feedback/wired-cupertino-alert-dialog',
            anchor: 'WiredCupertinoAlertDialog',
          ),
          WidgetShot(
            name: 'feedback/wired-cupertino-action-sheet',
            anchor: 'WiredCupertinoActionSheet',
          ),
          WidgetShot(
            name: 'feedback/wired-context-menu',
            anchor: 'WiredContextMenu',
          ),
          WidgetShot(
            name: 'feedback/wired-scrollbar',
            anchor: 'WiredScrollbar',
          ),
          WidgetShot(
            name: 'feedback/wired-about-dialog',
            anchor: 'WiredAboutDialog',
          ),
        ],
      );
    });

    testWidgets('capture layout page and widgets', (tester) async {
      await capturePageAndWidgets(
        tester,
        category: 'Layout',
        pageShot: 'layout/layout',
        widgetShots: const [
          WidgetShot(name: 'layout/wired-avatar', anchor: 'WiredAvatar'),
          WidgetShot(name: 'layout/wired-card', anchor: 'WiredCard'),
          WidgetShot(name: 'layout/wired-divider', anchor: 'WiredDivider'),
          WidgetShot(name: 'layout/wired-list-tile', anchor: 'WiredListTile'),
          WidgetShot(
            name: 'layout/wired-checkbox-list-tile',
            anchor: 'WiredCheckboxListTile',
          ),
          WidgetShot(
            name: 'layout/wired-radio-list-tile',
            anchor: 'WiredRadioListTile',
          ),
          WidgetShot(
            name: 'layout/wired-switch-list-tile',
            anchor: 'WiredSwitchListTile',
          ),
          WidgetShot(
            name: 'layout/wired-reorderable-list-view',
            anchor: 'WiredReorderableListView',
          ),
          WidgetShot(
            name: 'layout/wired-expansion-tile',
            anchor: 'WiredExpansionTile',
          ),
          WidgetShot(
            name: 'layout/wired-page-scaffold',
            anchor: 'WiredPageScaffold',
          ),
          WidgetShot(
            name: 'layout/wired-tab-scaffold',
            anchor: 'WiredTabScaffold',
          ),
          WidgetShot(
            name: 'layout/wired-sliver-app-bar',
            anchor: 'WiredSliverAppBar',
          ),
          WidgetShot(
            name: 'layout/wired-dismissible',
            anchor: 'WiredDismissible',
          ),
        ],
      );
    });

    testWidgets('capture data display page and widgets', (tester) async {
      await capturePageAndWidgets(
        tester,
        category: 'Data Display',
        pageShot: 'data-display/data-display',
        widgetShots: const [
          WidgetShot(
            name: 'data-display/wired-calendar',
            anchor: 'WiredCalendar',
          ),
          WidgetShot(
            name: 'data-display/wired-calendar-date-picker',
            anchor: 'WiredCalendarDatePicker',
          ),
          WidgetShot(
            name: 'data-display/wired-date-picker',
            anchor: 'WiredDatePicker',
          ),
          WidgetShot(
            name: 'data-display/wired-time-picker',
            anchor: 'WiredTimePicker',
          ),
          WidgetShot(
            name: 'data-display/wired-stepper',
            anchor: 'WiredStepper',
          ),
          WidgetShot(
            name: 'data-display/wired-data-table',
            anchor: 'WiredDataTable',
          ),
          WidgetShot(
            name: 'data-display/wired-range-slider',
            anchor: 'WiredRangeSlider',
          ),
          WidgetShot(
            name: 'data-display/wired-selectable-text',
            anchor: 'WiredSelectableText',
          ),
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

      await pumpStorybook(tester);

      await openCategory(tester, 'Rough Icons');
      await takeScreenshot(tester, 'rough-icons/rough-icons');
    });
  });
}
