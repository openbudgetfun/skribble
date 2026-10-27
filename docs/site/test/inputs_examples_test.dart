import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';
import 'package:skribble_docs_site/src/examples/catalog.dart';
import 'package:skribble_docs_site/src/examples/example.dart';

Future<void> _pumpExample(WidgetTester tester, String id) async {
  await tester.pumpWidget(
    WiredMaterialApp(
      wiredTheme: WiredThemeData(),
      home: WiredScaffold(
        body: SingleChildScrollView(
          child: LiveExample(id: id, definition: examples[id]!),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('the toggle example follows its own state', (tester) async {
    await _pumpExample(tester, 'toggle');

    final toggle = find.byType(WiredToggle);
    expect(toggle, findsOneWidget);

    await tester.tap(toggle);
    await tester.pumpAndSettle();

    expect(
      tester.widget<WiredToggle>(toggle).value,
      isTrue,
      reason: 'the example owns its state through the onChanged callback',
    );
  });

  testWidgets('the radio example follows its own selection', (tester) async {
    await _pumpExample(tester, 'radio');

    final radios = find.byType(WiredRadio<String>);
    expect(radios, findsNWidgets(2));
    expect(tester.widget<WiredRadio<String>>(radios.first).groupValue, 'paper');

    await tester.tap(radios.last);
    await tester.pumpAndSettle();

    expect(
      tester.widget<WiredRadio<String>>(radios.first).groupValue,
      'ink',
      reason: 'the example owns its selection through the onChanged callback',
    );
  });
}
