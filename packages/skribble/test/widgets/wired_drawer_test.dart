import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';

import '../helpers/finders.dart';
import '../helpers/pump_app.dart';

void main() {
  group('WiredDrawer', () {
    testWidgets('renders without error', (tester) async {
      await pumpApp(
        tester,
        WiredDrawer(child: const Text('Drawer content')),
        asDrawer: true,
      );

      final scaffoldState = tester.firstState<ScaffoldState>(
        find.byType(Scaffold),
      );
      scaffoldState.openDrawer();
      await tester.pumpAndSettle();

      expect(find.byType(WiredDrawer), findsOneWidget);
    });

    testWidgets('renders child content', (tester) async {
      await pumpApp(
        tester,
        WiredDrawer(child: const Text('My Items')),
        asDrawer: true,
      );

      final scaffoldState = tester.firstState<ScaffoldState>(
        find.byType(Scaffold),
      );
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
      await pumpApp(
        tester,
        WiredDrawer(child: const Text('Content')),
        asDrawer: true,
      );

      final scaffoldState = tester.firstState<ScaffoldState>(
        find.byType(Scaffold),
      );
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

    testWidgets('renders hand-drawn right edge via WiredCanvas', (
      tester,
    ) async {
      await pumpApp(
        tester,
        WiredDrawer(child: const Text('Edge')),
        asDrawer: true,
      );

      final scaffoldState = tester.firstState<ScaffoldState>(
        find.byType(Scaffold),
      );
      scaffoldState.openDrawer();
      await tester.pumpAndSettle();

      expect(
        find.descendant(
          of: find.byType(WiredDrawer),
          matching: findWiredCanvas,
        ),
        findsOneWidget,
      );
    });

    testWidgets('renders complex child widget tree', (tester) async {
      await pumpApp(
        tester,
        WiredDrawer(
          child: ListView(
            children: const [
              ListTile(title: Text('Item 1')),
              ListTile(title: Text('Item 2')),
              ListTile(title: Text('Item 3')),
            ],
          ),
        ),
        asDrawer: true,
      );

      final scaffoldState = tester.firstState<ScaffoldState>(
        find.byType(Scaffold),
      );
      scaffoldState.openDrawer();
      await tester.pumpAndSettle();

      expect(find.text('Item 1'), findsOneWidget);
      expect(find.text('Item 2'), findsOneWidget);
      expect(find.text('Item 3'), findsOneWidget);
    });

    testWidgets('uses Stack to layer border and child', (tester) async {
      await pumpApp(
        tester,
        WiredDrawer(child: const Text('Stack')),
        asDrawer: true,
      );

      final scaffoldState = tester.firstState<ScaffoldState>(
        find.byType(Scaffold),
      );
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
      await pumpApp(
        tester,
        WiredDrawer(child: const Text('Close me')),
        asDrawer: true,
      );

      final scaffoldState = tester.firstState<ScaffoldState>(
        find.byType(Scaffold),
      );
      scaffoldState.openDrawer();
      await tester.pumpAndSettle();

      expect(find.byType(WiredDrawer), findsOneWidget);

      await tester.drag(find.byType(Drawer), const Offset(-300, 0));
      await tester.pumpAndSettle();

      expect(find.byType(WiredDrawer), findsNothing);
    });

    testWidgets('drawer width is passed to underlying Drawer', (tester) async {
      await pumpApp(
        tester,
        WiredDrawer(width: 200.0, child: const Text('Narrow')),
        asDrawer: true,
      );

      final scaffoldState = tester.firstState<ScaffoldState>(
        find.byType(Scaffold),
      );
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
