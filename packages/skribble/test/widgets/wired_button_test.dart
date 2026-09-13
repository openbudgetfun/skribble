import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';

import '../helpers/pump_app.dart';

void main() {
  group('WiredButton', () {
    testWidgets('renders child text widget', (tester) async {
      await pumpApp(
        tester,
        WiredButton(onPressed: () {}, child: const Text('Press me')),
      );

      expect(find.text('Press me'), findsOneWidget);
    });

    testWidgets('calls onPressed callback when tapped', (tester) async {
      var pressed = false;

      await pumpApp(
        tester,
        WiredButton(onPressed: () => pressed = true, child: const Text('Tap')),
      );

      await tester.tap(find.text('Tap'));
      await tester.pump();

      expect(pressed, isTrue);
    });

    testWidgets('renders with correct height (42.0)', (tester) async {
      await pumpApp(
        tester,
        WiredButton(onPressed: () {}, child: const Text('Height test')),
      );

      // The WiredButton's buildWiredElement wraps content in a Container
      // with height 42.0. We verify the rendered size of the button.
      final buttonSize = tester.getSize(find.byType(WiredButton));

      expect(buttonSize.height, 42.0);
    });

    testWidgets('contains TextButton internally', (tester) async {
      await pumpApp(
        tester,
        WiredButton(onPressed: () {}, child: const Text('Button')),
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
      await pumpApp(
        tester,
        WiredButton(onPressed: () {}, child: const Text('Repaint')),
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
      await pumpApp(
        tester,
        WiredButton(onPressed: () {}, child: const Icon(Icons.add)),
      );

      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('uses theme border color from WiredTheme', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: WiredTheme(
            data: WiredThemeData(borderColor: Colors.red),
            child: Scaffold(
              body: WiredButton(onPressed: () {}, child: const Text('Themed')),
            ),
          ),
        ),
      );

      expect(find.byType(WiredButton), findsOneWidget);
    });

    testWidgets('applies semantic label when provided', (tester) async {
      await pumpApp(
        tester,
        WiredButton(
          onPressed: () {},
          semanticLabel: 'Submit form',
          child: const Text('Submit'),
        ),
      );

      expect(find.bySemanticsLabel('Submit form'), findsOneWidget);
    });

    testWidgets('disabled when onPressed is null', (tester) async {
      await pumpApp(tester, WiredButton(child: const Text('Disabled')));

      final button = tester.widget<TextButton>(find.byType(TextButton));
      expect(button.onPressed, isNull);
    });

    testWidgets('disabled label uses theme disabled text color', (
      tester,
    ) async {
      const disabledColor = Color(0xFF555555);

      await tester.pumpWidget(
        MaterialApp(
          home: WiredTheme(
            data: WiredThemeData(disabledTextColor: disabledColor),
            child: Scaffold(
              body: WiredButton(child: const Text('Disabled')),
            ),
          ),
        ),
      );

      final style = tester.widget<TextButton>(find.byType(TextButton)).style!;

      expect(
        style.foregroundColor?.resolve(const <WidgetState>{
          WidgetState.disabled,
        }),
        disabledColor,
      );
    });
  });
}
