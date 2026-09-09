import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';
import 'package:skribble_docs_site/src/docs_keys.dart';
import 'package:skribble_docs_site/src/font_comparison.dart';

void main() {
  testWidgets(
    'specimens resolve their own font family and share edits and styles',
    (tester) async {
      tester.view.physicalSize = const Size(390, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        WiredMaterialApp(
          wiredTheme: WiredThemeData(),
          home: const WiredScaffold(
            body: SingleChildScrollView(
              child: DefaultTextStyle(
                style: TextStyle(
                  fontFamily: 'SkribblePlayful',
                  package: 'skribble',
                ),
                child: FontComparison(),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.enterText(
        find.descendant(
          of: find.byKey(DocsKeys.fontSample),
          matching: find.byType(EditableText),
        ),
        'Ink & paper 0123',
      );
      await tester.tap(find.text('72 px'));
      await tester.tap(find.text('Bold'));
      await tester.tap(find.text('Italic'));
      await tester.pumpAndSettle();
      final specimens = tester
          .widgetList(find.text('Ink & paper 0123'))
          .whereType<Text>()
          .where((text) => text.style?.inherit == false)
          .toList();
      expect(specimens, hasLength(8));
      expect(specimens.map((text) => text.style!.fontFamily).toSet(), {
        'RecursiveCasualOriginal',
        'RecursiveLinearOriginal',
        'packages/skribble/SkribbleGentle',
        'packages/skribble/SkribblePlayful',
        'packages/skribble/Skribble',
        'SkribbleLinearGentle',
        'SkribbleLinearPlayful',
        'SkribbleLinearExpressive',
      });
      for (final text in specimens) {
        expect(text.style!.fontSize, 72);
        expect(text.style!.fontWeight, FontWeight.bold);
        expect(text.style!.fontStyle, FontStyle.italic);
      }
      expect(tester.takeException(), isNull);
    },
  );
}
