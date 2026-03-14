import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';

import '../helpers/pump_app.dart';

Finder findWiredIcon(IconData icon) {
  return find.byWidgetPredicate(
    (widget) => widget is WiredIcon && widget.icon == icon,
    description: 'WiredIcon($icon)',
  );
}

void main() {
  group('WiredContextMenu', () {
    testWidgets('renders child', (tester) async {
      await pumpApp(
        tester,
        WiredContextMenu(
          actions: const [WiredContextMenuAction(label: 'Copy')],
          child: const Text('Long press me'),
        ),
      );
      expect(find.text('Long press me'), findsOneWidget);
    });

    testWidgets('shows menu on long press', (tester) async {
      await pumpApp(
        tester,
        Center(
          child: WiredContextMenu(
            actions: const [
              WiredContextMenuAction(label: 'Cut', icon: Icons.cut),
              WiredContextMenuAction(label: 'Copy', icon: Icons.copy),
              WiredContextMenuAction(
                label: 'Delete',
                icon: Icons.delete,
                isDestructive: true,
              ),
            ],
            child: const SizedBox(
              width: 100,
              height: 50,
              child: Center(child: Text('Target')),
            ),
          ),
        ),
      );

      await tester.longPress(find.text('Target'));
      await tester.pumpAndSettle();

      expect(find.text('Cut'), findsOneWidget);
      expect(find.text('Copy'), findsOneWidget);
      expect(find.text('Delete'), findsOneWidget);
    });

    testWidgets('calls action onPressed and dismisses', (tester) async {
      var pressed = false;

      await pumpApp(
        tester,
        Center(
          child: WiredContextMenu(
            actions: [
              WiredContextMenuAction(
                label: 'Action',
                onPressed: () => pressed = true,
              ),
            ],
            child: const SizedBox(
              width: 100,
              height: 50,
              child: Center(child: Text('Item')),
            ),
          ),
        ),
      );

      await tester.longPress(find.text('Item'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Action'));
      await tester.pumpAndSettle();

      expect(pressed, isTrue);
      // Menu should be dismissed
      expect(find.text('Action'), findsNothing);
    });

    testWidgets('dismisses when tapping outside', (tester) async {
      await pumpApp(
        tester,
        Center(
          child: WiredContextMenu(
            actions: const [WiredContextMenuAction(label: 'Option')],
            child: const SizedBox(
              width: 100,
              height: 50,
              child: Center(child: Text('Box')),
            ),
          ),
        ),
      );

      await tester.longPress(find.text('Box'));
      await tester.pumpAndSettle();
      expect(find.text('Option'), findsOneWidget);

      // Tap the background to dismiss
      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();
      expect(find.text('Option'), findsNothing);
    });

    testWidgets('shows icons when provided', (tester) async {
      await pumpApp(
        tester,
        Center(
          child: WiredContextMenu(
            actions: const [
              WiredContextMenuAction(label: 'Edit', icon: Icons.edit),
              WiredContextMenuAction(label: 'Share', icon: Icons.share),
            ],
            child: const SizedBox(
              width: 100,
              height: 50,
              child: Center(child: Text('Press me')),
            ),
          ),
        ),
      );

      await tester.longPress(find.text('Press me'));
      await tester.pumpAndSettle();

      expect(findWiredIcon(Icons.edit), findsOneWidget);
      expect(findWiredIcon(Icons.share), findsOneWidget);
    });

    testWidgets('contains RepaintBoundary', (tester) async {
      await pumpApp(
        tester,
        WiredContextMenu(
          actions: const [WiredContextMenuAction(label: 'Test')],
          child: const Text('Content'),
        ),
      );

      expect(find.byType(RepaintBoundary), findsWidgets);
    });

    testWidgets('renders within WiredTheme', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: WiredTheme(
            data: WiredThemeData(borderColor: Colors.brown),
            child: Scaffold(
              body: WiredContextMenu(
                actions: [
                  WiredContextMenuAction(label: 'Action', onPressed: () {}),
                ],
                child: const Text('Long press me'),
              ),
            ),
          ),
        ),
      );
      expect(find.text('Long press me'), findsOneWidget);
    });
  });
}
