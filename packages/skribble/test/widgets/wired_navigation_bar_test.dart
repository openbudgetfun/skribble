import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';

void main() {
  group('WiredNavigationBar', () {
    const testDestinations = [
      WiredNavigationDestination(icon: Icons.home, label: 'Home'),
      WiredNavigationDestination(icon: Icons.search, label: 'Search'),
      WiredNavigationDestination(
        icon: Icons.person_outline,
        selectedIcon: Icons.person,
        label: 'Profile',
      ),
    ];

    testWidgets('renders without error', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: const SizedBox(),
            bottomNavigationBar: WiredNavigationBar(
              destinations: testDestinations,
            ),
          ),
        ),
      );

      expect(find.byType(WiredNavigationBar), findsOneWidget);
    });

    testWidgets('renders all destination labels', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: const SizedBox(),
            bottomNavigationBar: WiredNavigationBar(
              destinations: testDestinations,
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
            body: const SizedBox(),
            bottomNavigationBar: WiredNavigationBar(
              destinations: testDestinations,
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
            body: const SizedBox(),
            bottomNavigationBar: WiredNavigationBar(
              destinations: testDestinations,
            ),
          ),
        ),
      );

      final widget = tester.widget<WiredNavigationBar>(
        find.byType(WiredNavigationBar),
      );

      expect(widget.selectedIndex, 0);
    });

    testWidgets('calls onDestinationSelected with correct index',
        (tester) async {
      int? selectedIndex;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: const SizedBox(),
            bottomNavigationBar: WiredNavigationBar(
              destinations: testDestinations,
              onDestinationSelected: (index) => selectedIndex = index,
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
            body: const SizedBox(),
            bottomNavigationBar: WiredNavigationBar(
              destinations: testDestinations,
              onDestinationSelected: (index) => selectedIndex = index,
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
            body: const SizedBox(),
            bottomNavigationBar: WiredNavigationBar(
              destinations: testDestinations,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Home'));
      await tester.pump();

      expect(find.byType(WiredNavigationBar), findsOneWidget);
    });

    testWidgets('renders hand-drawn top line via WiredCanvas', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: const SizedBox(),
            bottomNavigationBar: WiredNavigationBar(
              destinations: testDestinations,
            ),
          ),
        ),
      );

      expect(
        find.descendant(
          of: find.byType(WiredNavigationBar),
          matching: find.byType(WiredCanvas),
        ),
        findsWidgets,
      );
    });

    testWidgets('selected item shows rounded rect indicator', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: const SizedBox(),
            bottomNavigationBar: WiredNavigationBar(
              destinations: testDestinations,
              selectedIndex: 1,
            ),
          ),
        ),
      );

      // The selected item at index 1 should have an additional WiredCanvas
      // for the rounded rectangle indicator.
      expect(
        find.descendant(
          of: find.byType(WiredNavigationBar),
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
            body: const SizedBox(),
            bottomNavigationBar: WiredNavigationBar(
              destinations: testDestinations,
              selectedIndex: 2,
            ),
          ),
        ),
      );

      // Profile destination has selectedIcon: Icons.person.
      // When selected (index 2), it should show Icons.person.
      expect(find.byIcon(Icons.person), findsOneWidget);
    });

    testWidgets('uses regular icon when item is not selected', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: const SizedBox(),
            bottomNavigationBar: WiredNavigationBar(
              destinations: testDestinations,
              selectedIndex: 0,
            ),
          ),
        ),
      );

      // Profile (index 2) is not selected, so it uses person_outline.
      expect(find.byIcon(Icons.person_outline), findsOneWidget);
    });

    testWidgets('each destination is wrapped in GestureDetector',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: const SizedBox(),
            bottomNavigationBar: WiredNavigationBar(
              destinations: testDestinations,
            ),
          ),
        ),
      );

      expect(
        find.descendant(
          of: find.byType(WiredNavigationBar),
          matching: find.byType(GestureDetector),
        ),
        findsNWidgets(3),
      );
    });

    testWidgets('rebuilds when selectedIndex changes', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: const SizedBox(),
            bottomNavigationBar: WiredNavigationBar(
              destinations: testDestinations,
              selectedIndex: 0,
            ),
          ),
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: const SizedBox(),
            bottomNavigationBar: WiredNavigationBar(
              destinations: testDestinations,
              selectedIndex: 2,
            ),
          ),
        ),
      );

      final widget = tester.widget<WiredNavigationBar>(
        find.byType(WiredNavigationBar),
      );

      expect(widget.selectedIndex, 2);
    });

    testWidgets('renders with two destinations', (tester) async {
      const twoDestinations = [
        WiredNavigationDestination(icon: Icons.home, label: 'Home'),
        WiredNavigationDestination(icon: Icons.settings, label: 'Settings'),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: const SizedBox(),
            bottomNavigationBar: WiredNavigationBar(
              destinations: twoDestinations,
            ),
          ),
        ),
      );

      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
    });
  });
}
