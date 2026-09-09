import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';
import 'package:skribble_docs_site/src/code_view.dart';
import 'package:skribble_docs_site/src/docs_keys.dart';
import 'package:skribble_docs_site/src/examples/catalog.dart';
import 'package:skribble_docs_site/src/examples/example.dart';

void main() {
  testWidgets('invalid parameters keep the last valid preview and source', (
    tester,
  ) async {
    await tester.pumpWidget(
      WiredMaterialApp(
        wiredTheme: WiredThemeData(),
        home: WiredScaffold(
          body: SingleChildScrollView(
            child: LiveExample(
              id: 'filled-button',
              definition: examples['filled-button']!,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    Finder editor(String name) => find.descendant(
      of: find.byKey(DocsKeys.parameter('filled-button', name)),
      matching: find.byType(EditableText),
    );
    WiredFilledButton preview() => tester.widget<WiredFilledButton>(
      find.descendant(
        of: find.byKey(DocsKeys.preview('filled-button')),
        matching: find.byType(WiredFilledButton),
      ),
    );
    await tester.enterText(editor('radius'), '12');
    await tester.enterText(editor('color'), '#b9d6ad');
    await tester.pumpAndSettle();
    expect(preview().borderRadius, BorderRadius.circular(12));
    expect(preview().fillColor, const Color(0xffb9d6ad));
    final source = tester.widget<CodeView>(find.byType(CodeView)).code;
    for (final invalid in ['-1', '49', 'NaN', 'Infinity', 'oops', '']) {
      await tester.enterText(editor('radius'), invalid);
      await tester.pumpAndSettle();
      expect(preview().borderRadius, BorderRadius.circular(12));
      expect(tester.widget<CodeView>(find.byType(CodeView)).code, source);
      expect(find.text('Enter a number from 0 to 48.'), findsOneWidget);
    }
    await tester.enterText(editor('color'), '#ff');
    await tester.pumpAndSettle();
    expect(preview().fillColor, const Color(0xffb9d6ad));
    expect(find.text('Use a colour such as #e8957d.'), findsOneWidget);
    await tester.enterText(editor('radius'), '0');
    await tester.enterText(editor('color'), '#102030');
    await tester.pumpAndSettle();
    expect(preview().borderRadius, BorderRadius.zero);
    expect(preview().fillColor, const Color(0xff102030));
    expect(find.text('Enter a number from 0 to 48.'), findsNothing);
    expect(find.text('Use a colour such as #e8957d.'), findsNothing);
  });
}
