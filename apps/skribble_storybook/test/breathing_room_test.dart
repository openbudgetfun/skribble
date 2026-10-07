import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/testing.dart';
import 'package:skribble_storybook/app.dart';

import 'support/skribble_fonts.dart';

/// Every storybook page. Maps needs its platform channels mocked, which
/// `pages/maps_page_test.dart` does; the rest render as they are.
const _routes = [
  '/',
  '/buttons',
  '/inputs',
  '/navigation',
  '/selection',
  '/feedback',
  '/layout',
  '/data-display',
  '/studio',
  '/drawing',
  '/motion',
  '/loading',
  '/skribble-icons',
  '/emoji',
  '/charts',
  '/font-specimen',
  '/variable-fonts',
];

/// A phone, a tablet, a desktop, and a phone with larger text.
const List<({double width, double textScale})> _screens = [
  (width: 360.0, textScale: 1.0),
  (width: 768.0, textScale: 1.0),
  (width: 1280.0, textScale: 1.0),
  (width: 360.0, textScale: 1.3),
];

void main() {
  setUpAll(loadSkribbleFonts);

  for (final screen in _screens) {
    for (final route in _routes) {
      testWidgets(
        '$route keeps the ink padding at ${screen.width.toInt()} pixels '
        'and ${screen.textScale}x text',
        (tester) async {
          // Tall enough that every section is laid out, not just the first.
          tester.view
            ..physicalSize = Size(screen.width, 7000)
            ..devicePixelRatio = 1;
          tester.platformDispatcher.textScaleFactorTestValue = screen.textScale;
          addTearDown(tester.view.reset);
          addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

          await tester.pumpWidget(const SkribbleStorybookApp());
          await tester.pump(const Duration(milliseconds: 300));
          tester
              .state<NavigatorState>(find.byType(Navigator).first)
              .pushNamedAndRemoveUntil(route, (_) => false);
          await tester.pump();
          await tester.pump(const Duration(seconds: 1));

          expect(tester.takeException(), isNull);
          final root = tester.binding.renderViews.first;
          expect(crampedText(root), isEmpty);
          expect(squeezedText(root), isEmpty);
        },
      );
    }
  }
}
