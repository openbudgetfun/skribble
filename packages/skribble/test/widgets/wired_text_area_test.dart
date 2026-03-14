import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';

import '../helpers/finders.dart';
import '../helpers/pump_app.dart';

void main() {
  group('WiredTextArea', () {
    testWidgets('renders without error', (tester) async {
      await pumpApp(tester, WiredTextArea());

      expect(find.byType(WiredTextArea), findsOneWidget);
    });

    testWidgets('contains TextField internally', (tester) async {
      await pumpApp(tester, WiredTextArea());

      expect(
        find.descendant(
          of: find.byType(WiredTextArea),
          matching: find.byType(TextField),
        ),
        findsOneWidget,
      );
    });

    testWidgets('displays hint text', (tester) async {
      await pumpApp(tester, WiredTextArea(hintText: 'Enter description...'));

      expect(find.text('Enter description...'), findsOneWidget);
    });

    testWidgets('accepts text input', (tester) async {
      await pumpApp(tester, WiredTextArea());

      await tester.enterText(find.byType(TextField), 'Hello World');
      await tester.pump();

      expect(find.text('Hello World'), findsOneWidget);
    });

    testWidgets('calls onChanged callback', (tester) async {
      String? changedText;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WiredTextArea(
              onChanged: (value) {
                changedText = value;
              },
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), 'Typed text');
      await tester.pump();

      expect(changedText, 'Typed text');
    });

    testWidgets('uses provided TextEditingController', (tester) async {
      final controller = TextEditingController(text: 'Initial');

      await pumpApp(tester, WiredTextArea(controller: controller));

      expect(find.text('Initial'), findsOneWidget);

      controller.dispose();
    });

    testWidgets('maxLines defaults to 5', (tester) async {
      await pumpApp(tester, WiredTextArea());

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.maxLines, 5);
    });

    testWidgets('minLines defaults to 3', (tester) async {
      await pumpApp(tester, WiredTextArea());

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.minLines, 3);
    });

    testWidgets('accepts custom maxLines', (tester) async {
      await pumpApp(tester, WiredTextArea(maxLines: 10));

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.maxLines, 10);
    });

    testWidgets('accepts custom minLines', (tester) async {
      await pumpApp(tester, WiredTextArea(minLines: 1));

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.minLines, 1);
    });

    testWidgets('has no input border decoration', (tester) async {
      await pumpApp(tester, WiredTextArea());

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.decoration?.border, InputBorder.none);
    });

    testWidgets('contains Stack for layered layout', (tester) async {
      await pumpApp(tester, WiredTextArea());

      expect(
        find.descendant(
          of: find.byType(WiredTextArea),
          matching: find.byType(Stack),
        ),
        findsOneWidget,
      );
    });

    testWidgets('contains WiredCanvas background', (tester) async {
      await pumpApp(tester, WiredTextArea());

      expect(
        find.descendant(
          of: find.byType(WiredTextArea),
          matching: findWiredCanvas,
        ),
        findsOneWidget,
      );
    });

    testWidgets('applies custom style', (tester) async {
      const customStyle = TextStyle(fontSize: 20, color: Colors.red);

      await pumpApp(tester, WiredTextArea(style: customStyle));

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.style?.fontSize, 20);
      expect(textField.style?.color, Colors.red);
    });
  });
}
