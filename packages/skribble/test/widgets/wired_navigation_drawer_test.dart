import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';

import '../helpers/finders.dart';
import '../helpers/pump_app.dart';

void main() {
  group('WiredNavigationDrawer', () {
    testWidgets('renders destinations', (tester) async {
      await pumpApp(
        tester,
        WiredNavigationDrawer(
          destinations: const [
            WiredNavigationDrawerDestination(icon: Icons.home, label: 'Home'),
            WiredNavigationDrawerDestination(
              icon: Icons.settings,
              label: 'Settings',
            ),
          ],
        ),
        asDrawer: true,
      );

      final scaffoldState = tester.firstState<ScaffoldState>(
        find.byType(Scaffold),
      );
      scaffoldState.openDrawer();
      await tester.pumpAndSettle();

      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
    });

    testWidgets('calls onDestinationSelected', (tester) async {
      int? tappedIndex;

      await pumpApp(
        tester,
        WiredNavigationDrawer(
          destinations: const [
            WiredNavigationDrawerDestination(icon: Icons.home, label: 'Home'),
            WiredNavigationDrawerDestination(
              icon: Icons.search,
              label: 'Search',
            ),
          ],
          onDestinationSelected: (i) => tappedIndex = i,
        ),
        asDrawer: true,
      );

      final scaffoldState = tester.firstState<ScaffoldState>(
        find.byType(Scaffold),
      );
      scaffoldState.openDrawer();
      await tester.pumpAndSettle();

      await tester.tap(find.text('Search'));
      await tester.pumpAndSettle();

      expect(tappedIndex, 1);
    });

    testWidgets('renders header when provided', (tester) async {
      await pumpApp(
        tester,
        WiredNavigationDrawer(
          header: const Text('My App'),
          destinations: const [
            WiredNavigationDrawerDestination(icon: Icons.home, label: 'Home'),
          ],
        ),
        asDrawer: true,
      );

      final scaffoldState = tester.firstState<ScaffoldState>(
        find.byType(Scaffold),
      );
      scaffoldState.openDrawer();
      await tester.pumpAndSettle();

      expect(find.text('My App'), findsOneWidget);
    });

    testWidgets('selected item has hachure fill', (tester) async {
      await pumpApp(
        tester,
        WiredNavigationDrawer(
          selectedIndex: 0,
          destinations: const [
            WiredNavigationDrawerDestination(
              icon: Icons.inbox,
              selectedIcon: Icons.inbox_rounded,
              label: 'Inbox',
            ),
            WiredNavigationDrawerDestination(icon: Icons.send, label: 'Sent'),
          ],
        ),
        asDrawer: true,
      );

      final scaffoldState = tester.firstState<ScaffoldState>(
        find.byType(Scaffold),
      );
      scaffoldState.openDrawer();
      await tester.pumpAndSettle();

      expect(find.text('Inbox'), findsOneWidget);
      expect(find.text('Sent'), findsOneWidget);
      expect(findWiredCanvas, findsWidgets);
    });

    testWidgets('respects custom width', (tester) async {
      await pumpApp(
        tester,
        WiredNavigationDrawer(
          width: 250,
          destinations: const [
            WiredNavigationDrawerDestination(icon: Icons.home, label: 'Home'),
          ],
        ),
        asDrawer: true,
      );

      final scaffoldState = tester.firstState<ScaffoldState>(
        find.byType(Scaffold),
      );
      scaffoldState.openDrawer();
      await tester.pumpAndSettle();

      final drawer = tester.widget<Drawer>(find.byType(Drawer));
      expect(drawer.width, 250);
    });

    testWidgets('renders icons for destinations', (tester) async {
      await pumpApp(
        tester,
        WiredNavigationDrawer(
          destinations: const [
            WiredNavigationDrawerDestination(
              icon: Icons.star,
              label: 'Starred',
            ),
            WiredNavigationDrawerDestination(
              icon: Icons.archive,
              label: 'Archive',
            ),
          ],
        ),
        asDrawer: true,
      );

      final scaffoldState = tester.firstState<ScaffoldState>(
        find.byType(Scaffold),
      );
      scaffoldState.openDrawer();
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.star), findsOneWidget);
      expect(find.byIcon(Icons.archive), findsOneWidget);
    });

    testWidgets('renders within WiredTheme', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: WiredTheme(
            data: WiredThemeData(borderColor: Colors.pink),
            child: Scaffold(
              drawer: WiredNavigationDrawer(
                selectedIndex: 0,
                onDestinationSelected: (_) {},
                destinations: const [
                  WiredNavigationDrawerDestination(
                    icon: Icons.home,
                    label: 'Home',
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      final scaffoldState = tester.state<ScaffoldState>(find.byType(Scaffold));
      scaffoldState.openDrawer();
      await tester.pumpAndSettle();
      expect(find.text('Home'), findsOneWidget);
    });
  });
}
