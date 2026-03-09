import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';

void main() {
  group('WiredDrawer', () {
    testWidgets('renders without error', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            drawer: WiredDrawer(child: const Text('Drawer content')),
            body: const SizedBox(),
          ),
        ),
      );

      // Open the drawer.
      final scaffoldState =
          tester.firstState<ScaffoldState>(find.byType(Scaffold));
      scaffoldState.openDrawer();
      await tester.pumpAndSettle();

      expect(find.byType(WiredDrawer), findsOneWidget);
    });

    testWidgets('renders child content', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            drawer: WiredDrawer(child: const Text('My Items')),
            body: const SizedBox(),
          ),
        ),
      );

      final scaffoldState =
          tester.firstState<ScaffoldState>(find.byType(Scaffold));
      scaffoldState.openDrawer();
      await tester.pumpAndSettle();

      expect(find.text('My Items'), findsOneWidget);
    });

    testWidgets('default width is 304.0', (tester) async {
      const drawer = WiredDrawer(child: Text('Width'));
      expect(drawer.width, 304.0);
    });

    testWidgets('accepts custom width', (tester) async {
      const drawer = WiredDrawer(width: 250.0, child: Text('Custom'));
      expect(drawer.width, 250.0);
    });

    testWidgets('contains a Drawer widget', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            drawer: WiredDrawer(child: const Text('Content')),
            body: const SizedBox(),
          ),
        ),
      );

      final scaffoldState =
          tester.firstState<ScaffoldState>(find.byType(Scaffold));
      scaffoldState.openDrawer();
      await tester.pumpAndSettle();

      expect(
        find.descendant(
          of: find.byType(WiredDrawer),
          matching: find.byType(Drawer),
        ),
        findsOneWidget,
      );
    });

    testWidgets('renders hand-drawn right edge via WiredCanvas',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            drawer: WiredDrawer(child: const Text('Edge')),
            body: const SizedBox(),
          ),
        ),
      );

      final scaffoldState =
          tester.firstState<ScaffoldState>(find.byType(Scaffold));
      scaffoldState.openDrawer();
      await tester.pumpAndSettle();

      expect(
        find.descendant(
          of: find.byType(WiredDrawer),
          matching: find.byType(WiredCanvas),
        ),
        findsOneWidget,
      );
    });

    testWidgets('renders complex child widget tree', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            drawer: WiredDrawer(
              child: ListView(
                children: const [
                  ListTile(title: Text('Item 1')),
                  ListTile(title: Text('Item 2')),
                  ListTile(title: Text('Item 3')),
                ],
              ),
            ),
            body: const SizedBox(),
          ),
        ),
      );

      final scaffoldState =
          tester.firstState<ScaffoldState>(find.byType(Scaffold));
      scaffoldState.openDrawer();
      await tester.pumpAndSettle();

      expect(find.text('Item 1'), findsOneWidget);
      expect(find.text('Item 2'), findsOneWidget);
      expect(find.text('Item 3'), findsOneWidget);
    });

    testWidgets('uses Stack to layer border and child', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            drawer: WiredDrawer(child: const Text('Stack')),
            body: const SizedBox(),
          ),
        ),
      );

      final scaffoldState =
          tester.firstState<ScaffoldState>(find.byType(Scaffold));
      scaffoldState.openDrawer();
      await tester.pumpAndSettle();

      expect(
        find.descendant(
          of: find.byType(WiredDrawer),
          matching: find.byType(Stack),
        ),
        findsOneWidget,
      );
    });

    testWidgets('can be closed by dragging', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            drawer: WiredDrawer(child: const Text('Close me')),
            body: const SizedBox(),
          ),
        ),
      );

      final scaffoldState =
          tester.firstState<ScaffoldState>(find.byType(Scaffold));
      scaffoldState.openDrawer();
      await tester.pumpAndSettle();

      expect(find.byType(WiredDrawer), findsOneWidget);

      // Drag from right to left to close the drawer.
      await tester.drag(find.byType(Drawer), const Offset(-300, 0));
      await tester.pumpAndSettle();

      expect(find.byType(WiredDrawer), findsNothing);
    });

    testWidgets('drawer width is passed to underlying Drawer', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            drawer: WiredDrawer(width: 200.0, child: const Text('Narrow')),
            body: const SizedBox(),
          ),
        ),
      );

      final scaffoldState =
          tester.firstState<ScaffoldState>(find.byType(Scaffold));
      scaffoldState.openDrawer();
      await tester.pumpAndSettle();

      final drawer = tester.widget<Drawer>(
        find.descendant(
          of: find.byType(WiredDrawer),
          matching: find.byType(Drawer),
        ),
      );

      expect(drawer.width, 200.0);
    });
  });
}
