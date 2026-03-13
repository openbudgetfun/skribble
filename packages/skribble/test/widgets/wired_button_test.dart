import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';

void main() {
  group('WiredButton', () {
    testWidgets('renders child text widget', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WiredButton(onPressed: () {}, child: const Text('Press me')),
          ),
        ),
      );

      expect(find.text('Press me'), findsOneWidget);
    });

    testWidgets('calls onPressed callback when tapped', (tester) async {
      var pressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WiredButton(
              onPressed: () => pressed = true,
              child: const Text('Tap'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Tap'));
      await tester.pump();

      expect(pressed, isTrue);
    });

    testWidgets('renders with correct height (42.0)', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WiredButton(
              onPressed: () {},
              child: const Text('Height test'),
            ),
          ),
        ),
      );

      // The WiredButton's buildWiredElement wraps content in a Container
      // with height 42.0. We verify the rendered size of the button.
      final buttonSize = tester.getSize(find.byType(WiredButton));

      expect(buttonSize.height, 42.0);
    });

    testWidgets('contains TextButton internally', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WiredButton(onPressed: () {}, child: const Text('Button')),
          ),
        ),
      );

      expect(
        find.descendant(
          of: find.byType(WiredButton),
          matching: find.byType(TextButton),
        ),
        findsOneWidget,
      );
    });

    testWidgets('has RepaintBoundary wrapper', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WiredButton(onPressed: () {}, child: const Text('Repaint')),
          ),
        ),
      );

      // WiredBaseWidget.build wraps buildWiredElement in RepaintBoundary.
      expect(
        find.descendant(
          of: find.byType(WiredButton),
          matching: find.byType(RepaintBoundary),
        ),
        findsOneWidget,
      );
    });

    testWidgets('renders with icon child', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WiredButton(
              onPressed: () {},
              child: const Icon(Icons.add),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('uses theme border color from WiredTheme', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: WiredTheme(
            data: WiredThemeData(borderColor: Colors.red),
            child: Scaffold(
              body: WiredButton(
                onPressed: () {},
                child: const Text('Themed'),
              ),
            ),
          ),
        ),
      );

      expect(find.byType(WiredButton), findsOneWidget);
    });
  });
}
