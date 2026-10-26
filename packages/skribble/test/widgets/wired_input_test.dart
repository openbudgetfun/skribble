import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';

import '../helpers/pump_app.dart';

void main() {
  group('WiredInput', () {
    testWidgets('renders TextField', (tester) async {
      await tester.pumpWidget(MaterialApp(home: Scaffold(body: WiredInput())));

      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('accepts text input via controller', (tester) async {
      final controller = TextEditingController();

      await pumpApp(tester, WiredInput(controller: controller));

      await tester.enterText(find.byType(TextField), 'hello world');

      expect(controller.text, 'hello world');
    });

    testWidgets('shows label text when provided', (tester) async {
      await pumpApp(tester, WiredInput(labelText: 'Username'));

      expect(find.text('Username'), findsOneWidget);
    });

    testWidgets('does not show label when labelText is null', (tester) async {
      await tester.pumpWidget(MaterialApp(home: Scaffold(body: WiredInput())));

      // With no labelText, Row should not contain a Text widget for the label.
      // Only the TextField and its internal hint text should be present.
      expect(
        find.descendant(
          of: find.byType(WiredInput),
          matching: find.byType(Text),
        ),
        findsNothing,
      );
    });

    testWidgets('shows hint text', (tester) async {
      await pumpApp(tester, WiredInput(hintText: 'Enter email'));

      // The hint text is rendered inside the TextField decoration.
      expect(find.text('Enter email'), findsOneWidget);
    });

    testWidgets('calls onChanged callback', (tester) async {
      String? changedValue;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WiredInput(onChanged: (value) => changedValue = value),
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), 'test input');

      expect(changedValue, 'test input');
    });

    testWidgets('supports obscureText', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: WiredInput(obscureText: true))),
      );

      final textField = tester.widget<TextField>(find.byType(TextField));

      expect(textField.obscureText, isTrue);
    });

    testWidgets('obscureText defaults to false', (tester) async {
      await tester.pumpWidget(MaterialApp(home: Scaffold(body: WiredInput())));

      final textField = tester.widget<TextField>(find.byType(TextField));

      expect(textField.obscureText, isFalse);
    });

    testWidgets('applies custom label style', (tester) async {
      const labelStyle = TextStyle(fontSize: 20.0, color: Colors.red);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WiredInput(labelText: 'Styled', labelStyle: labelStyle),
          ),
        ),
      );

      final text = tester.widget<Text>(find.text('Styled'));

      expect(text.style?.fontSize, 20.0);
      expect(text.style?.color, Colors.red);
    });

    testWidgets('disables editing when enabled is false', (tester) async {
      await pumpApp(tester, WiredInput(enabled: false, hintText: 'Locked'));

      final field = tester.widget<TextField>(find.byType(TextField));
      expect(field.enabled, isFalse);
      await tester.enterText(find.byType(TextField), 'nope');
      expect(find.text('nope'), findsNothing);
    });

    testWidgets('forwards keyboard configuration', (tester) async {
      await pumpApp(
        tester,
        WiredInput(
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.send,
        ),
      );

      final field = tester.widget<TextField>(find.byType(TextField));
      expect(field.keyboardType, TextInputType.emailAddress);
      expect(field.textInputAction, TextInputAction.send);
    });

    testWidgets('applies input formatters', (tester) async {
      final controller = TextEditingController();
      addTearDown(controller.dispose);

      await pumpApp(
        tester,
        WiredInput(
          controller: controller,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        ),
      );

      await tester.enterText(find.byType(TextField), 'a1b2');
      expect(controller.text, '12');
    });

    testWidgets('calls onSubmitted', (tester) async {
      String? submitted;

      await pumpApp(
        tester,
        WiredInput(onSubmitted: (value) => submitted = value),
      );

      await tester.enterText(find.byType(TextField), 'hello');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();

      expect(submitted, 'hello');
    });

    testWidgets('shows a maxLength counter', (tester) async {
      await pumpApp(tester, WiredInput(maxLength: 8));

      await tester.enterText(find.byType(TextField), '12345678');
      await tester.pump();
      expect(find.text('8/8'), findsOneWidget);
    });

    testWidgets('shows prefix and suffix widgets and icons', (tester) async {
      await pumpApp(
        tester,
        WiredInput(
          prefix: const Text('EUR'),
          suffix: const Text('.00'),
          prefixIcon: const Icon(Icons.attach_money),
          suffixIcon: const Icon(Icons.clear),
        ),
      );

      expect(find.text('EUR'), findsOneWidget);
      expect(find.text('.00'), findsOneWidget);
      expect(find.byIcon(Icons.attach_money), findsOneWidget);
      expect(find.byIcon(Icons.clear), findsOneWidget);
    });

    testWidgets('draws the error ink and error text while errorText is set', (
      tester,
    ) async {
      await pumpApp(tester, WiredInput(errorText: 'Required'));

      expect(find.text('Required'), findsOneWidget);
      final field = tester.widget<TextField>(find.byType(TextField));
      expect(field.decoration?.errorText, 'Required');
    });

    testWidgets('autofocuses when requested', (tester) async {
      await pumpApp(tester, WiredInput(autofocus: true));

      final field = tester.widget<TextField>(find.byType(TextField));
      expect(field.autofocus, isTrue);
    });
  });
}
