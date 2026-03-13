import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';

void main() {
  group('WiredInput', () {
    testWidgets('renders TextField', (tester) async {
      await tester.pumpWidget(MaterialApp(home: Scaffold(body: WiredInput())));

      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('accepts text input via controller', (tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: WiredInput(controller: controller)),
        ),
      );

      await tester.enterText(find.byType(TextField), 'hello world');

      expect(controller.text, 'hello world');
    });

    testWidgets('shows label text when provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: WiredInput(labelText: 'Username')),
        ),
      );

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
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: WiredInput(hintText: 'Enter email')),
        ),
      );

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
  });
}
