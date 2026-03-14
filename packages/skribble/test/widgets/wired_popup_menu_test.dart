import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';

import '../helpers/pump_app.dart';

void main() {
  group('WiredPopupMenuButton', () {
    testWidgets('renders without error', (tester) async {
      await pumpApp(
        tester,
        WiredPopupMenuButton<String>(
          items: const [WiredPopupMenuItem(value: 'a', child: Text('Item A'))],
        ),
      );

      expect(find.byType(WiredPopupMenuButton<String>), findsOneWidget);
    });

    testWidgets('renders default more_vert icon', (tester) async {
      await pumpApp(
        tester,
        WiredPopupMenuButton<String>(
          items: const [WiredPopupMenuItem(value: 'a', child: Text('Item A'))],
        ),
      );

      expect(find.byIcon(Icons.more_vert), findsOneWidget);
    });

    testWidgets('renders custom icon when provided', (tester) async {
      await pumpApp(
        tester,
        WiredPopupMenuButton<String>(
          icon: const Icon(Icons.menu),
          items: const [WiredPopupMenuItem(value: 'a', child: Text('Item A'))],
        ),
      );

      expect(find.byIcon(Icons.menu), findsOneWidget);
      expect(find.byIcon(Icons.more_vert), findsNothing);
    });

    testWidgets('shows popup menu items on tap', (tester) async {
      await pumpApp(
        tester,
        WiredPopupMenuButton<String>(
          items: const [
            WiredPopupMenuItem(value: 'a', child: Text('Item A')),
            WiredPopupMenuItem(value: 'b', child: Text('Item B')),
          ],
        ),
      );

      // Tap the popup menu button to open it.
      await tester.tap(find.byType(PopupMenuButton<String>));
      await tester.pumpAndSettle();

      expect(find.text('Item A'), findsOneWidget);
      expect(find.text('Item B'), findsOneWidget);
    });

    testWidgets('calls onSelected when item is tapped', (tester) async {
      String? selectedValue;

      await pumpApp(
        tester,
        WiredPopupMenuButton<String>(
          items: const [
            WiredPopupMenuItem(value: 'a', child: Text('Item A')),
            WiredPopupMenuItem(value: 'b', child: Text('Item B')),
          ],
          onSelected: (value) {
            selectedValue = value;
          },
        ),
      );

      // Open the popup menu.
      await tester.tap(find.byType(PopupMenuButton<String>));
      await tester.pumpAndSettle();

      // Select Item B.
      await tester.tap(find.text('Item B'));
      await tester.pumpAndSettle();

      expect(selectedValue, 'b');
    });

    testWidgets('has RepaintBoundary wrapper', (tester) async {
      await pumpApp(
        tester,
        WiredPopupMenuButton<String>(
          items: const [WiredPopupMenuItem(value: 'a', child: Text('Item A'))],
        ),
      );

      expect(
        find.descendant(
          of: find.byType(WiredPopupMenuButton<String>),
          matching: find.byType(RepaintBoundary),
        ),
        findsOneWidget,
      );
    });

    testWidgets('contains PopupMenuButton internally', (tester) async {
      await pumpApp(
        tester,
        WiredPopupMenuButton<String>(
          items: const [WiredPopupMenuItem(value: 'a', child: Text('Item A'))],
        ),
      );

      expect(
        find.descendant(
          of: find.byType(WiredPopupMenuButton<String>),
          matching: find.byType(PopupMenuButton<String>),
        ),
        findsOneWidget,
      );
    });

    testWidgets('renders with integer value type', (tester) async {
      int? selectedValue;

      await pumpApp(
        tester,
        WiredPopupMenuButton<int>(
          items: const [
            WiredPopupMenuItem(value: 1, child: Text('One')),
            WiredPopupMenuItem(value: 2, child: Text('Two')),
          ],
          onSelected: (value) {
            selectedValue = value;
          },
        ),
      );

      // Open the popup menu.
      await tester.tap(find.byType(PopupMenuButton<int>));
      await tester.pumpAndSettle();

      // Select item.
      await tester.tap(find.text('Two'));
      await tester.pumpAndSettle();

      expect(selectedValue, 2);
    });

    testWidgets('does not call onSelected when null', (tester) async {
      await pumpApp(
        tester,
        WiredPopupMenuButton<String>(
          items: const [WiredPopupMenuItem(value: 'a', child: Text('Item A'))],
          onSelected: null,
        ),
      );

      // Open and select; should not throw.
      await tester.tap(find.byType(PopupMenuButton<String>));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Item A'));
      await tester.pumpAndSettle();

      // No assertion needed; test passes if no error is thrown.
    });
  });

  group('WiredPopupMenuItem', () {
    test('stores value and child', () {
      const item = WiredPopupMenuItem<String>(
        value: 'test',
        child: Text('Test item'),
      );

      expect(item.value, 'test');
      expect(item.child, isA<Text>());
    });
  });
}
