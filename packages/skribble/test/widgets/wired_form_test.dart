import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';

import '../helpers/pump_app.dart';

void main() {
  group('WiredForm', () {
    testWidgets('renders child content', (tester) async {
      await pumpApp(tester, SizedBox(
              width: 320,
              child: WiredForm(child: Text('Form body')),
            ));

      expect(find.byType(WiredForm), findsOneWidget);
      expect(find.text('Form body'), findsOneWidget);
      expect(find.byType(Form), findsOneWidget);
      expect(find.byType(RepaintBoundary), findsWidgets);
    });

    testWidgets('forwards validation through provided form key', (
      tester,
    ) async {
      final formKey = GlobalKey<FormState>();

      await pumpApp(tester, SizedBox(
              width: 320,
              child: WiredForm(
                formKey: formKey,
                child: TextFormField(
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Required' : null,
                ),
              ),
            ));

      expect(formKey.currentState!.validate(), isFalse);
      await tester.pumpAndSettle();

      expect(find.text('Required'), findsOneWidget);
    });

    testWidgets('calls onChanged when form fields change', (tester) async {
      var changed = 0;

      await pumpApp(tester, SizedBox(
              width: 320,
              child: WiredForm(
                onChanged: () => changed += 1,
                child: TextFormField(),
              ),
            ));

      await tester.enterText(find.byType(TextFormField), 'wired');
      await tester.pumpAndSettle();

      expect(changed, greaterThan(0));
    });

    testWidgets('supports autovalidate mode', (tester) async {
      await pumpApp(tester, SizedBox(
              width: 320,
              child: WiredForm(
                autovalidateMode: AutovalidateMode.always,
                child: TextFormField(
                  validator: (value) =>
                      value == null || value.length < 3 ? 'Too short' : null,
                ),
              ),
            ));

      await tester.pumpAndSettle();

      expect(find.text('Too short'), findsOneWidget);
    });

    testWidgets('applies default padding around form body', (tester) async {
      await pumpApp(tester, SizedBox(width: 320, child: WiredForm(child: Placeholder())));

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

    testWidgets('applies custom padding', (tester) async {
      await pumpApp(tester, SizedBox(
              width: 320,
              child: WiredForm(
                padding: EdgeInsets.all(8),
                child: Placeholder(),
              ),
            ));

      final padding = tester.widget<Padding>(
        find
            .descendant(
              of: find.byType(WiredForm),
              matching: find.byType(Padding),
            )
            .first,
      );

      expect(padding.padding, const EdgeInsets.all(8));
    });

    testWidgets('renders with custom border radius', (tester) async {
      await pumpApp(tester, SizedBox(
              width: 320,
              child: WiredForm(
                borderRadius: BorderRadius.zero,
                child: Text('Custom radius'),
              ),
            ));

      expect(find.text('Custom radius'), findsOneWidget);
    });
  });
}
