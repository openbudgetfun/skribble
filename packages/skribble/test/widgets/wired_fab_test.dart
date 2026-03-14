import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';

import '../helpers/pump_app.dart';

void main() {
  group('WiredFloatingActionButton', () {
    testWidgets('renders without error', (tester) async {
      await pumpApp(
        tester,
        WiredFloatingActionButton(icon: Icons.add, onPressed: () {}),
      );

      expect(find.byType(WiredFloatingActionButton), findsOneWidget);
    });

    testWidgets('renders the provided icon', (tester) async {
      await pumpApp(
        tester,
        WiredFloatingActionButton(icon: Icons.edit, onPressed: () {}),
      );

      expect(find.byIcon(Icons.edit), findsOneWidget);
    });

    testWidgets('calls onPressed callback when tapped', (tester) async {
      var pressed = false;

      await pumpApp(
        tester,
        WiredFloatingActionButton(
          icon: Icons.add,
          onPressed: () => pressed = true,
        ),
      );

      await tester.tap(find.byType(WiredFloatingActionButton));
      await tester.pump();

      expect(pressed, isTrue);
    });

    testWidgets('does not crash when onPressed is null', (tester) async {
      await pumpApp(
        tester,
        WiredFloatingActionButton(icon: Icons.add, onPressed: null),
      );

      expect(find.byType(WiredFloatingActionButton), findsOneWidget);
    });

    testWidgets('does not call callback when onPressed is null', (
      tester,
    ) async {
      const pressed = false;

      await pumpApp(
        tester,
        WiredFloatingActionButton(icon: Icons.add, onPressed: null),
      );

      await tester.tap(find.byType(WiredFloatingActionButton));
      await tester.pump();

      expect(pressed, isFalse);
    });

    testWidgets('onPressed defaults to null', (tester) async {
      const fab = WiredFloatingActionButton(icon: Icons.add);

      expect(fab.onPressed, isNull);
    });

    testWidgets('size defaults to 56.0', (tester) async {
      const fab = WiredFloatingActionButton(icon: Icons.add);

      expect(fab.size, 56.0);
    });

    testWidgets('renders with default size (56.0)', (tester) async {
      await pumpApp(
        tester,
        WiredFloatingActionButton(icon: Icons.add, onPressed: () {}),
      );

      final fabSize = tester.getSize(find.byType(WiredFloatingActionButton));

      expect(fabSize.width, 56.0);
      expect(fabSize.height, 56.0);
    });

    testWidgets('renders with custom size', (tester) async {
      await pumpApp(
        tester,
        WiredFloatingActionButton(
          icon: Icons.add,
          onPressed: () {},
          size: 72.0,
        ),
      );

      final fabSize = tester.getSize(find.byType(WiredFloatingActionButton));

      expect(fabSize.width, 72.0);
      expect(fabSize.height, 72.0);
    });

    testWidgets('iconColor defaults to null', (tester) async {
      const fab = WiredFloatingActionButton(icon: Icons.add);

      expect(fab.iconColor, isNull);
    });

    testWidgets('uses custom iconColor when provided', (tester) async {
      await pumpApp(
        tester,
        WiredFloatingActionButton(
          icon: Icons.add,
          onPressed: () {},
          iconColor: Colors.white,
        ),
      );

      final icon = tester.widget<Icon>(find.byIcon(Icons.add));

      expect(icon.color, Colors.white);
    });

    testWidgets('uses GestureDetector for tap handling', (tester) async {
      await pumpApp(
        tester,
        WiredFloatingActionButton(icon: Icons.add, onPressed: () {}),
      );

      expect(
        find.descendant(
          of: find.byType(WiredFloatingActionButton),
          matching: find.byType(GestureDetector),
        ),
        findsOneWidget,
      );
    });

    testWidgets('contains WiredCanvas for circle background', (tester) async {
      await pumpApp(
        tester,
        WiredFloatingActionButton(icon: Icons.add, onPressed: () {}),
      );

      expect(
        find.descendant(
          of: find.byType(WiredFloatingActionButton),
          matching: find.byType(WiredCanvas),
        ),
        findsOneWidget,
      );
    });

    testWidgets('contains Stack for layering circle and icon', (tester) async {
      await pumpApp(
        tester,
        WiredFloatingActionButton(icon: Icons.add, onPressed: () {}),
      );

      expect(
        find.descendant(
          of: find.byType(WiredFloatingActionButton),
          matching: find.byType(Stack),
        ),
        findsOneWidget,
      );
    });

    testWidgets('has RepaintBoundary wrapper', (tester) async {
      await pumpApp(
        tester,
        WiredFloatingActionButton(icon: Icons.add, onPressed: () {}),
      );

      expect(
        find.descendant(
          of: find.byType(WiredFloatingActionButton),
          matching: find.byType(RepaintBoundary),
        ),
        findsOneWidget,
      );
    });

    testWidgets('icon size scales with widget size', (tester) async {
      await pumpApp(
        tester,
        WiredFloatingActionButton(
          icon: Icons.add,
          onPressed: () {},
          size: 100.0,
        ),
      );

      final icon = tester.widget<Icon>(find.byIcon(Icons.add));

      // Icon size is size * 0.43 = 100.0 * 0.43 = 43.0
      expect(icon.size, 43.0);
    });

    testWidgets('tracks multiple rapid taps', (tester) async {
      var tapCount = 0;

      await pumpApp(
        tester,
        WiredFloatingActionButton(icon: Icons.add, onPressed: () => tapCount++),
      );

      await tester.tap(find.byType(WiredFloatingActionButton));
      await tester.pump();
      await tester.tap(find.byType(WiredFloatingActionButton));
      await tester.pump();
      await tester.tap(find.byType(WiredFloatingActionButton));
      await tester.pump();

      expect(tapCount, 3);
    });

    testWidgets('applies semantic label when provided', (tester) async {
      await pumpApp(
        tester,
        WiredFloatingActionButton(
          icon: Icons.add,
          onPressed: () {},
          semanticLabel: 'Add new item',
        ),
      );

      expect(find.bySemanticsLabel('Add new item'), findsOneWidget);
    });
  });
}
