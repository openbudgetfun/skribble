import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';
import 'package:skribble_docs_site/src/examples/catalog.dart';
import 'package:skribble_docs_site/src/examples/example.dart';

Future<void> pumpExample(WidgetTester tester, String id) async {
  await tester.pumpWidget(
    WiredMaterialApp(
      wiredTheme: WiredThemeData(motionEnabled: false),
      home: WiredScaffold(
        body: SingleChildScrollView(
          child: examples[id]!.builder(ExampleSettings()),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('sample form validates before showing success', (tester) async {
    await pumpExample(tester, 'validated-form');
    await tester.tap(find.text('Check the form'));
    await tester.pumpAndSettle();
    expect(find.text('Enter an email address.'), findsOneWidget);
    await tester.enterText(find.byType(EditableText), 'hello@example.com');
    await tester.tap(find.text('Check the form'));
    await tester.pumpAndSettle();
    expect(find.text('Enter an email address.'), findsNothing);
    expect(
      find.text('The sample form is valid. Nothing was sent.'),
      findsOneWidget,
    );
  });

  testWidgets(
    'search combines text and category and recovers from no results',
    (
      tester,
    ) async {
      await pumpExample(tester, 'search-pattern');
      await tester.enterText(find.byType(EditableText), 'sketch');
      await tester.pumpAndSettle();
      expect(find.text('Buy sketchbooks'), findsOneWidget);
      expect(find.text('Write a proposal'), findsNothing);
      await tester.tap(find.widgetWithText(WiredChoiceChip, 'Work'));
      await tester.pumpAndSettle();
      expect(find.text('No matching sample tasks.'), findsOneWidget);
      await tester.enterText(find.byType(EditableText), '');
      await tester.pumpAndSettle();
      expect(find.text('Write a proposal'), findsOneWidget);
      expect(find.text('No matching sample tasks.'), findsNothing);
    },
  );

  testWidgets('task list supports checking, dismissal, and reset', (
    tester,
  ) async {
    await pumpExample(tester, 'task-list-pattern');
    await tester.tap(find.text('Buy paper'));
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<WiredCheckboxListTile>(
            find.widgetWithText(WiredCheckboxListTile, 'Buy paper'),
          )
          .value,
      isTrue,
    );
    await tester.drag(find.text('Buy paper'), const Offset(800, 0));
    await tester.pumpAndSettle();
    expect(find.text('Buy paper'), findsNothing);
    await tester.tap(find.text('Reset the sample list'));
    await tester.pumpAndSettle();
    expect(find.text('Buy paper'), findsOneWidget);
  });

  testWidgets('loading finishes and safely tolerates removal while pending', (
    tester,
  ) async {
    await pumpExample(tester, 'loading-pattern');
    await tester.tap(find.text('Load sample notes'));
    await tester.pump();
    expect(find.byType(WiredCircularProgress), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();
    expect(find.text('Possibility'), findsOneWidget);
    await tester.tap(find.text('Load sample notes'));
    await tester.pump();
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 400));
    expect(tester.takeException(), isNull);
  });
}
