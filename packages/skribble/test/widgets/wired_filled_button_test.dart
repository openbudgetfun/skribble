import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';

void main() {
  group('WiredFilledButton', () {
    testWidgets('renders with child text', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WiredFilledButton(
              onPressed: () {},
              child: const Text('Filled'),
            ),
          ),
        ),
      );

      expect(find.byType(WiredFilledButton), findsOneWidget);
      expect(find.text('Filled'), findsOneWidget);
      expect(find.byType(RepaintBoundary), findsWidgets);
    });

    testWidgets('calls onPressed when tapped', (tester) async {
      var tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WiredFilledButton(
              onPressed: () => tapped = true,
              child: const Text('Tap me'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Tap me'));
      expect(tapped, isTrue);
    });

    testWidgets('renders with custom fill color', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WiredFilledButton(
              onPressed: () {},
              fillColor: Colors.blue,
              child: const Text('Blue'),
            ),
          ),
        ),
      );

      expect(find.byType(WiredFilledButton), findsOneWidget);
    });

    testWidgets('disabled when onPressed is null', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: WiredFilledButton(child: Text('Disabled'))),
        ),
      );

      final button = tester.widget<TextButton>(find.byType(TextButton));
      expect(button.onPressed, isNull);
    });
  });
}
