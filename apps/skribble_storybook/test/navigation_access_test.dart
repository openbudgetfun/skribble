import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';
import 'package:skribble_storybook/app.dart';
import 'package:skribble_storybook/widgets/roughness_picker.dart';
import 'package:skribble_storybook/widgets/storybook_back_button.dart';

/// Every page pushed over the home page. Maps needs its platform channels
/// mocked, which `pages/maps_page_test.dart` does.
const _pages = [
  '/buttons',
  '/inputs',
  '/navigation',
  '/selection',
  '/feedback',
  '/layout',
  '/data-display',
  '/drawing',
  '/motion',
  '/loading',
  '/skribble-icons',
  '/rough-icons',
  '/emoji',
  '/font-specimen',
  '/variable-fonts',
  '/promo',
];

Future<void> _pumpAt(WidgetTester tester, String route) async {
  await tester.pumpWidget(const SkribbleStorybookApp());
  await tester.pump(const Duration(milliseconds: 300));
  if (route == '/') return;
  tester.state<NavigatorState>(find.byType(Navigator).first).pushNamed(route);
  await tester.pump();
  await tester.pump(const Duration(seconds: 1));
}

/// A storybook reader on a desktop, with only a keyboard, or on a small
/// phone with large text can still get around.
void main() {
  group('every page', () {
    for (final route in _pages) {
      testWidgets('$route has a back button that returns home', (
        tester,
      ) async {
        await _pumpAt(tester, route);

        expect(find.byType(StorybookBackButton), findsOneWidget);
        expect(find.bySemanticsLabel('Back'), findsWidgets);

        await tester.tap(find.byType(StorybookBackButton));
        await tester.pump();
        await tester.pump(const Duration(seconds: 1));
        expect(find.text('Hand-drawn UI components for Flutter'), findsOne);
      });
    }
  });

  testWidgets('the toolbar leaves at least half a small screen to the page', (
    tester,
  ) async {
    tester.view
      ..physicalSize = const Size(320, 640)
      ..devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await _pumpAt(tester, '/');

    Color paper() => WiredTheme.of(
      tester.element(find.text('Hand-drawn UI components for Flutter')),
    ).fillColor;
    final day = paper();
    final toolbar = tester.getSize(find.byType(WiredRoughnessPicker));
    expect(toolbar.height, lessThanOrEqualTo(640 / 2));
    expect(tester.takeException(), isNull);

    // The chips that no longer fit scroll into reach.
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('paper-Night')),
      40,
      scrollable: find
          .descendant(
            of: find.byType(WiredRoughnessPicker),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    await tester.tap(find.byKey(const ValueKey('paper-Night')));
    await tester.pump();
    expect(paper(), isNot(day));
  });

  testWidgets('a category card shows when the keyboard focuses it', (
    tester,
  ) async {
    tester.view
      ..physicalSize = const Size(1280, 900)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await _pumpAt(tester, '/');

    WiredCard card(String title) => tester.widget<WiredCard>(
      find.ancestor(of: find.text(title), matching: find.byType(WiredCard)),
    );
    expect(card('The reel').fill, isFalse);

    // Ship it, the switch, the checkbox, and the slider come first.
    for (var i = 0; i < 5; i++) {
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump(const Duration(milliseconds: 100));
    }

    expect(card('The reel').fill, isTrue);
    expect(card('The sketchbook').fill, isFalse);
  });
}
