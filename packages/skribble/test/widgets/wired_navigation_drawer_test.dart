import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';

void main() {
  group('WiredNavigationDrawer', () {
    testWidgets('renders destinations', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            drawer: WiredNavigationDrawer(
              destinations: const [
                WiredNavigationDrawerDestination(
                  icon: Icons.home,
                  label: 'Home',
                ),
                WiredNavigationDrawerDestination(
                  icon: Icons.settings,
                  label: 'Settings',
                ),
              ],
            ),
            body: const SizedBox.expand(),
          ),
        ),
      );

      // Open drawer
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

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            drawer: WiredNavigationDrawer(
              destinations: const [
                WiredNavigationDrawerDestination(
                  icon: Icons.home,
                  label: 'Home',
                ),
                WiredNavigationDrawerDestination(
                  icon: Icons.search,
                  label: 'Search',
                ),
              ],
              onDestinationSelected: (i) => tappedIndex = i,
            ),
            body: const SizedBox.expand(),
          ),
        ),
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
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            drawer: WiredNavigationDrawer(
              header: const Text('My App'),
              destinations: const [
                WiredNavigationDrawerDestination(
                  icon: Icons.home,
                  label: 'Home',
                ),
              ],
            ),
            body: const SizedBox.expand(),
          ),
        ),
      );

      final scaffoldState = tester.firstState<ScaffoldState>(
        find.byType(Scaffold),
      );
      scaffoldState.openDrawer();
      await tester.pumpAndSettle();

      expect(find.text('My App'), findsOneWidget);
    });

    testWidgets('selected item has hachure fill', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            drawer: WiredNavigationDrawer(
              selectedIndex: 0,
              destinations: const [
                WiredNavigationDrawerDestination(
                  icon: Icons.inbox,
                  selectedIcon: Icons.inbox_rounded,
                  label: 'Inbox',
                ),
                WiredNavigationDrawerDestination(
                  icon: Icons.send,
                  label: 'Sent',
                ),
              ],
            ),
            body: const SizedBox.expand(),
          ),
        ),
      );

      final scaffoldState = tester.firstState<ScaffoldState>(
        find.byType(Scaffold),
      );
      scaffoldState.openDrawer();
      await tester.pumpAndSettle();

      expect(find.text('Inbox'), findsOneWidget);
      expect(find.text('Sent'), findsOneWidget);
      // WiredCanvas should be present for the selected item
      expect(find.byType(WiredCanvas), findsWidgets);
    });
  });
}
