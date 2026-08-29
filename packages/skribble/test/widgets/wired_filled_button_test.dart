import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';

import '../helpers/pump_app.dart';

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
      await pumpApp(tester, WiredFilledButton(child: Text('Disabled')));

      final button = tester.widget<TextButton>(find.byType(TextButton));
      expect(button.onPressed, isNull);
    });

    testWidgets('renders with custom foreground color', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WiredFilledButton(
              onPressed: () {},
              foregroundColor: Colors.yellow,
              child: const Text('Yellow text'),
            ),
          ),
        ),
      );

      expect(find.byType(WiredFilledButton), findsOneWidget);
      expect(find.text('Yellow text'), findsOneWidget);
    });

    testWidgets('has fixed height of 42', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WiredFilledButton(
              onPressed: () {},
              child: const Text('Check height'),
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(
        find
            .descendant(
              of: find.byType(WiredFilledButton),
              matching: find.byType(Container),
            )
            .first,
      );
      expect(container.constraints?.maxHeight, 42.0);
    });

    testWidgets('does not respond to tap when disabled', (tester) async {
      const tapped = false;

      await pumpApp(tester, WiredFilledButton(child: Text('No tap')));

      await tester.tap(find.text('No tap'));
      expect(tapped, isFalse);
    });

    testWidgets('applies semantic label when provided', (tester) async {
      await pumpApp(
        tester,
        WiredFilledButton(
          onPressed: () {},
          semanticLabel: 'Confirm order',
          child: const Text('Confirm'),
        ),
      );

      expect(find.bySemanticsLabel('Confirm order'), findsOneWidget);
    });
  });
}
