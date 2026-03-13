import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';

void main() {
  group('WiredForm', () {
    testWidgets('renders child content', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 320,
              child: WiredForm(child: Text('Form body')),
            ),
          ),
        ),
      );

      expect(find.byType(WiredForm), findsOneWidget);
      expect(find.text('Form body'), findsOneWidget);
      expect(find.byType(Form), findsOneWidget);
      expect(find.byType(RepaintBoundary), findsWidgets);
    });

    testWidgets('forwards validation through provided form key', (
      tester,
    ) async {
      final formKey = GlobalKey<FormState>();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 320,
              child: WiredForm(
                formKey: formKey,
                child: TextFormField(
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Required' : null,
                ),
              ),
            ),
          ),
        ),
      );

      expect(formKey.currentState!.validate(), isFalse);
      await tester.pumpAndSettle();

      expect(find.text('Required'), findsOneWidget);
    });

    testWidgets('calls onChanged when form fields change', (tester) async {
      var changed = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 320,
              child: WiredForm(
                onChanged: () => changed += 1,
                child: TextFormField(),
              ),
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextFormField), 'wired');
      await tester.pumpAndSettle();

      expect(changed, greaterThan(0));
    });

    testWidgets('supports autovalidate mode', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 320,
              child: WiredForm(
                autovalidateMode: AutovalidateMode.always,
                child: TextFormField(
                  validator: (value) =>
                      value == null || value.length < 3 ? 'Too short' : null,
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Too short'), findsOneWidget);
    });

    testWidgets('applies default padding around form body', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(width: 320, child: WiredForm(child: Placeholder())),
          ),
        ),
      );

      final padding = tester.widget<Padding>(
        find
            .descendant(
              of: find.byType(WiredForm),
              matching: find.byType(Padding),
            )
            .first,
      );

      expect(padding.padding, const EdgeInsets.all(16));
    });
  });
}
