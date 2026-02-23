import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';

void main() {
  group('WiredNavigationRail', () {
    const testDestinations = [
      WiredNavigationRailDestination(icon: Icons.home, label: 'Home'),
      WiredNavigationRailDestination(icon: Icons.search, label: 'Search'),
      WiredNavigationRailDestination(
        icon: Icons.person_outline,
        selectedIcon: Icons.person,
        label: 'Profile',
      ),
    ];

    testWidgets('renders without error', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Row(
              children: const [
                WiredNavigationRail(destinations: testDestinations),
                Expanded(child: SizedBox()),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(WiredNavigationRail), findsOneWidget);
    });

    testWidgets('renders all destination labels', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Row(
              children: const [
                WiredNavigationRail(destinations: testDestinations),
                Expanded(child: SizedBox()),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Search'), findsOneWidget);
      expect(find.text('Profile'), findsOneWidget);
    });

    testWidgets('renders all destination icons', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Row(
              children: const [
                WiredNavigationRail(destinations: testDestinations),
                Expanded(child: SizedBox()),
              ],
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.home), findsOneWidget);
      expect(find.byIcon(Icons.search), findsOneWidget);
    });

    testWidgets('default selectedIndex is 0', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Row(
              children: const [
                WiredNavigationRail(destinations: testDestinations),
                Expanded(child: SizedBox()),
              ],
            ),
          ),
        ),
      );

      final widget = tester.widget<WiredNavigationRail>(
        find.byType(WiredNavigationRail),
      );

      expect(widget.selectedIndex, 0);
    });

    testWidgets('calls onDestinationSelected with correct index',
        (tester) async {
      int? selectedIndex;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Row(
              children: [
                WiredNavigationRail(
                  destinations: testDestinations,
                  onDestinationSelected: (index) => selectedIndex = index,
                ),
                const Expanded(child: SizedBox()),
              ],
            ),
          ),
        ),
      );

      await tester.tap(find.text('Search'));
      await tester.pump();

      expect(selectedIndex, 1);
    });

    testWidgets('calls onDestinationSelected for last item', (tester) async {
      int? selectedIndex;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Row(
              children: [
                WiredNavigationRail(
                  destinations: testDestinations,
                  onDestinationSelected: (index) => selectedIndex = index,
                ),
                const Expanded(child: SizedBox()),
              ],
            ),
          ),
        ),
      );

      await tester.tap(find.text('Profile'));
      await tester.pump();

      expect(selectedIndex, 2);
    });

    testWidgets('does not crash when onDestinationSelected is null',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Row(
              children: const [
                WiredNavigationRail(destinations: testDestinations),
                Expanded(child: SizedBox()),
              ],
            ),
          ),
        ),
      );

      await tester.tap(find.text('Home'));
      await tester.pump();

      expect(find.byType(WiredNavigationRail), findsOneWidget);
    });

    testWidgets('renders hand-drawn right border via WiredCanvas',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Row(
              children: const [
                WiredNavigationRail(destinations: testDestinations),
                Expanded(child: SizedBox()),
              ],
            ),
          ),
        ),
      );

      expect(
        find.descendant(
          of: find.byType(WiredNavigationRail),
          matching: find.byType(WiredCanvas),
        ),
        findsWidgets,
      );
    });

    testWidgets('selected item shows rounded rect indicator', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Row(
              children: const [
                WiredNavigationRail(
                  destinations: testDestinations,
                  selectedIndex: 1,
                ),
                Expanded(child: SizedBox()),
              ],
            ),
          ),
        ),
      );

      // The selected item should have a WiredCanvas for the rounded rectangle
      // indicator plus the vertical border line WiredCanvas.
      expect(
        find.descendant(
          of: find.byType(WiredNavigationRail),
          matching: find.byType(WiredCanvas),
        ),
        findsWidgets,
      );
    });

    testWidgets('uses selectedIcon when provided and item is selected',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Row(
              children: const [
                WiredNavigationRail(
                  destinations: testDestinations,
                  selectedIndex: 2,
                ),
                Expanded(child: SizedBox()),
              ],
            ),
          ),
        ),
      );

      // Profile destination has selectedIcon: Icons.person.
      expect(find.byIcon(Icons.person), findsOneWidget);
    });

    testWidgets('uses regular icon when item is not selected', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Row(
              children: const [
                WiredNavigationRail(
                  destinations: testDestinations,
                  selectedIndex: 0,
                ),
                Expanded(child: SizedBox()),
              ],
            ),
          ),
        ),
      );

      // Profile (index 2) is not selected, so it uses person_outline.
      expect(find.byIcon(Icons.person_outline), findsOneWidget);
    });

    testWidgets('renders leading widget', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Row(
              children: const [
                WiredNavigationRail(
                  destinations: testDestinations,
                  leading: FloatingActionButton(
                    onPressed: null,
                    child: Icon(Icons.add),
                  ),
                ),
                Expanded(child: SizedBox()),
              ],
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.add), findsOneWidget);
      expect(find.byType(FloatingActionButton), findsOneWidget);
    });

    testWidgets('renders trailing widget', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Row(
              children: const [
                Expanded(
                  child: Row(
                    children: [
                      WiredNavigationRail(
                        destinations: testDestinations,
                        trailing: Icon(Icons.settings),
                      ),
                      Expanded(child: SizedBox()),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.settings), findsOneWidget);
    });

    testWidgets('each destination is wrapped in GestureDetector',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Row(
              children: const [
                WiredNavigationRail(destinations: testDestinations),
                Expanded(child: SizedBox()),
              ],
            ),
          ),
        ),
      );

      expect(
        find.descendant(
          of: find.byType(WiredNavigationRail),
          matching: find.byType(GestureDetector),
        ),
        findsNWidgets(3),
      );
    });

    testWidgets('rebuilds when selectedIndex changes', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Row(
              children: const [
                WiredNavigationRail(
                  destinations: testDestinations,
                  selectedIndex: 0,
                ),
                Expanded(child: SizedBox()),
              ],
            ),
          ),
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Row(
              children: const [
                WiredNavigationRail(
                  destinations: testDestinations,
                  selectedIndex: 2,
                ),
                Expanded(child: SizedBox()),
              ],
            ),
          ),
        ),
      );

      final widget = tester.widget<WiredNavigationRail>(
        find.byType(WiredNavigationRail),
      );

      expect(widget.selectedIndex, 2);
    });

    testWidgets('renders with two destinations', (tester) async {
      const twoDestinations = [
        WiredNavigationRailDestination(icon: Icons.home, label: 'Home'),
        WiredNavigationRailDestination(
          icon: Icons.settings,
          label: 'Settings',
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Row(
              children: const [
                WiredNavigationRail(destinations: twoDestinations),
                Expanded(child: SizedBox()),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
    });

    testWidgets('rail has 72px width for destination area', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Row(
              children: const [
                WiredNavigationRail(destinations: testDestinations),
                Expanded(child: SizedBox()),
              ],
            ),
          ),
        ),
      );

      // The rail main column is 72px wide, plus the 2px border line.
      final railSize = tester.getSize(find.byType(WiredNavigationRail));
      expect(railSize.width, 74.0);
    });
  });
}
