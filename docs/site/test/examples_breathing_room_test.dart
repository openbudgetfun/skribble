import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';
import 'package:skribble/testing.dart';
import 'package:skribble_docs_site/src/examples/catalog.dart';
import 'package:skribble_docs_site/src/examples/example.dart';

import 'support/skribble_fonts.dart';

/// Every live example, in its docs frame with its parameter editors, keeps
/// the ink padding at a phone's and a desktop's content width.
void main() {
  setUpAll(loadSkribbleFonts);

  for (final width in const [340.0, 720.0]) {
    for (final MapEntry(key: id, value: definition) in examples.entries) {
      testWidgets('$id keeps the ink padding at ${width.toInt()} pixels', (
        tester,
      ) async {
        tester.view
          ..physicalSize = const Size(1000, 3000)
          ..devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        await tester.pumpWidget(
          WiredMaterialApp(
            wiredTheme: WiredThemeData.cuddly(),
            home: Material(
              type: MaterialType.transparency,
              child: SingleChildScrollView(
                child: Center(
                  child: SizedBox(
                    width: width,
                    child: LiveExample(id: id, definition: definition),
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pump(const Duration(milliseconds: 500));

        expect(tester.takeException(), isNull);
        final root = tester.binding.renderViews.first;
        expect(crampedText(root), isEmpty);
        expect(squeezedText(root), isEmpty);

        // Let looping examples and their timers wind down.
        await tester.pumpWidget(const SizedBox());
        await tester.pump(const Duration(seconds: 5));
      });
    }
  }
}
