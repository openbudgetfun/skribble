import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/testing.dart';
import 'package:skribble_example/app.dart';

import 'support/skribble_fonts.dart';

/// A phone, a tablet, a desktop, and a phone with larger text.
const List<({double width, double textScale})> _screens = [
  (width: 360, textScale: 1),
  (width: 768, textScale: 1),
  (width: 1280, textScale: 1),
  (width: 360, textScale: 1.3),
];

void main() {
  setUpAll(loadSkribbleFonts);

  for (final screen in _screens) {
    for (final route in const ['/', '/edit', '/settings']) {
      testWidgets(
        '$route keeps the ink padding at ${screen.width.toInt()} pixels '
        'and ${screen.textScale}x text',
        (tester) async {
          tester.view
            ..physicalSize = Size(screen.width, 2400)
            ..devicePixelRatio = 1;
          tester.platformDispatcher.textScaleFactorTestValue = screen.textScale;
          addTearDown(tester.view.reset);
          addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

          await tester.pumpWidget(const SketchNotesApp());
          await tester.pump(const Duration(milliseconds: 300));
          if (route != '/') {
            tester
                .state<NavigatorState>(find.byType(Navigator).first)
                .pushNamedAndRemoveUntil(route, (_) => false);
            await tester.pump();
            await tester.pump(const Duration(seconds: 1));
          }

          expect(tester.takeException(), isNull);
          final root = tester.binding.renderViews.first;
          expect(crampedText(root), isEmpty);
          expect(squeezedText(root), isEmpty);
        },
      );
    }
  }
}
