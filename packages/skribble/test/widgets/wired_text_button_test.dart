import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';

import '../helpers/pump_app.dart';

void main() {
  group('WiredTextButton', () {
    testWidgets('renders without error', (tester) async {
      await pumpApp(
        tester,
        WiredTextButton(onPressed: () {}, child: const Text('Hello')),
      );

      expect(find.byType(WiredTextButton), findsOneWidget);
    });

    testWidgets('renders child text widget', (tester) async {
      await pumpApp(
        tester,
        WiredTextButton(onPressed: () {}, child: const Text('Press me')),
      );

      expect(find.text('Press me'), findsOneWidget);
    });

    testWidgets('renders child icon widget', (tester) async {
      await pumpApp(
        tester,
        WiredTextButton(onPressed: () {}, child: const Icon(Icons.star)),
      );

      expect(find.byIcon(Icons.star), findsOneWidget);
    });

    testWidgets('calls onPressed callback when tapped', (tester) async {
      var pressed = false;

      await pumpApp(
        tester,
        WiredTextButton(
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
        WiredTextButton(onPressed: null, child: const Text('Disabled')),
      );

      expect(find.byType(WiredTextButton), findsOneWidget);
      expect(find.text('Disabled'), findsOneWidget);
    });

    testWidgets('does not call callback when onPressed is null', (
      tester,
    ) async {
      const pressed = false;

      await pumpApp(
        tester,
        WiredTextButton(onPressed: null, child: const Text('Disabled')),
      );

      await tester.tap(find.text('Disabled'));
      await tester.pump();

      expect(pressed, isFalse);
    });

    testWidgets('onPressed defaults to null', (tester) async {
      const button = WiredTextButton(child: Text('Default'));

      expect(button.onPressed, isNull);
    });

    testWidgets('contains TextButton internally', (tester) async {
      await pumpApp(
        tester,
        WiredTextButton(onPressed: () {}, child: const Text('Button')),
      );

      expect(
        find.descendant(
          of: find.byType(WiredTextButton),
          matching: find.byType(TextButton),
        ),
        findsOneWidget,
      );
    });

    testWidgets('uses IntrinsicWidth to size to content', (tester) async {
      await pumpApp(
        tester,
        WiredTextButton(onPressed: () {}, child: const Text('Intrinsic')),
      );

      expect(
        find.descendant(
          of: find.byType(WiredTextButton),
          matching: find.byType(IntrinsicWidth),
        ),
        findsOneWidget,
      );
    });

    testWidgets('contains WiredCanvas for underline', (tester) async {
      await pumpApp(
        tester,
        WiredTextButton(onPressed: () {}, child: const Text('Underline')),
      );

      expect(
        find.descendant(
          of: find.byType(WiredTextButton),
          matching: find.byType(WiredCanvas),
        ),
        findsOneWidget,
      );
    });

    testWidgets('has RepaintBoundary wrapper', (tester) async {
      await pumpApp(
        tester,
        WiredTextButton(onPressed: () {}, child: const Text('Repaint')),
      );

      expect(
        find.descendant(
          of: find.byType(WiredTextButton),
          matching: find.byType(RepaintBoundary),
        ),
        findsOneWidget,
      );
    });

    testWidgets('uses Column layout with button and underline', (tester) async {
      await pumpApp(
        tester,
        WiredTextButton(onPressed: () {}, child: const Text('Layout')),
      );

      expect(
        find.descendant(
          of: find.byType(WiredTextButton),
          matching: find.byType(Column),
        ),
        findsOneWidget,
      );
    });

    testWidgets('tracks multiple rapid taps', (tester) async {
      var tapCount = 0;

      await pumpApp(
        tester,
        WiredTextButton(
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
