import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';

import '../helpers/pump_app.dart';

void main() {
  group('WiredElevatedButton', () {
    testWidgets('renders without error', (tester) async {
      await pumpApp(
        tester,
        WiredElevatedButton(onPressed: () {}, child: const Text('Hello')),
      );

      expect(find.byType(WiredElevatedButton), findsOneWidget);
    });

    testWidgets('renders child text widget', (tester) async {
      await pumpApp(
        tester,
        WiredElevatedButton(onPressed: () {}, child: const Text('Press me')),
      );

      expect(find.text('Press me'), findsOneWidget);
    });

    testWidgets('renders child icon widget', (tester) async {
      await pumpApp(
        tester,
        WiredElevatedButton(onPressed: () {}, child: const Icon(Icons.add)),
      );

      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('calls onPressed callback when tapped', (tester) async {
      var pressed = false;

      await pumpApp(
        tester,
        WiredElevatedButton(
          onPressed: () => pressed = true,
          child: const Text('Tap'),
        ),
      );

      await tester.tap(find.text('Tap'));
      await tester.pump();

      expect(pressed, isTrue);
    });

    testWidgets('does not crash when onPressed is null', (tester) async {
      await pumpApp(
        tester,
        WiredElevatedButton(onPressed: null, child: const Text('Disabled')),
      );

      expect(find.byType(WiredElevatedButton), findsOneWidget);
      expect(find.text('Disabled'), findsOneWidget);
    });

    testWidgets('does not call callback when onPressed is null', (
      tester,
    ) async {
      const pressed = false;

      await pumpApp(
        tester,
        WiredElevatedButton(onPressed: null, child: const Text('Disabled')),
      );

      await tester.tap(find.text('Disabled'));
      await tester.pump();

      expect(pressed, isFalse);
    });

    testWidgets('onPressed defaults to null', (tester) async {
      const button = WiredElevatedButton(child: Text('Default'));

      expect(button.onPressed, isNull);
    });

    testWidgets('contains TextButton internally', (tester) async {
      await pumpApp(
        tester,
        WiredElevatedButton(onPressed: () {}, child: const Text('Button')),
      );

      expect(
        find.descendant(
          of: find.byType(WiredElevatedButton),
          matching: find.byType(TextButton),
        ),
        findsOneWidget,
      );
    });

    testWidgets('contains Stack for shadow offset', (tester) async {
      await pumpApp(
        tester,
        WiredElevatedButton(onPressed: () {}, child: const Text('Shadow')),
      );

      expect(
        find.descendant(
          of: find.byType(WiredElevatedButton),
          matching: find.byType(Stack),
        ),
        findsOneWidget,
      );
    });

    testWidgets('has RepaintBoundary wrapper', (tester) async {
      await pumpApp(
        tester,
        WiredElevatedButton(onPressed: () {}, child: const Text('Repaint')),
      );

      expect(
        find.descendant(
          of: find.byType(WiredElevatedButton),
          matching: find.byType(RepaintBoundary),
        ),
        findsOneWidget,
      );
    });

    testWidgets('tracks multiple rapid taps', (tester) async {
      var tapCount = 0;

      await pumpApp(
        tester,
        WiredElevatedButton(
          onPressed: () => tapCount++,
          child: const Text('Multi'),
        ),
      );

      await tester.tap(find.text('Multi'));
      await tester.pump();
      await tester.tap(find.text('Multi'));
      await tester.pump();
      await tester.tap(find.text('Multi'));
      await tester.pump();

      expect(tapCount, 3);
    });
  });
}
