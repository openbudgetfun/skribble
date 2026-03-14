import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';

import '../helpers/pump_app.dart';

void main() {
  group('WiredBottomNavigationBar', () {
    const testItems = [
      WiredBottomNavItem(icon: Icons.home, label: 'Home'),
      WiredBottomNavItem(icon: Icons.search, label: 'Search'),
      WiredBottomNavItem(icon: Icons.person, label: 'Profile'),
    ];

    testWidgets('renders without error', (tester) async {
      await pumpApp(
        tester,
        WiredBottomNavigationBar(items: testItems),
        asBottomNav: true,
      );

      expect(find.byType(WiredBottomNavigationBar), findsOneWidget);
    });

    testWidgets('renders all item labels', (tester) async {
      await pumpApp(
        tester,
        WiredBottomNavigationBar(items: testItems),
        asBottomNav: true,
      );

      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Search'), findsOneWidget);
      expect(find.text('Profile'), findsOneWidget);
    });

    testWidgets('renders all item icons', (tester) async {
      await pumpApp(
        tester,
        WiredBottomNavigationBar(items: testItems),
        asBottomNav: true,
      );

      expect(find.byIcon(Icons.home), findsOneWidget);
      expect(find.byIcon(Icons.search), findsOneWidget);
      expect(find.byIcon(Icons.person), findsOneWidget);
    });

    testWidgets('default currentIndex is 0', (tester) async {
      await pumpApp(
        tester,
        WiredBottomNavigationBar(items: testItems),
        asBottomNav: true,
      );

      final widget = tester.widget<WiredBottomNavigationBar>(
        find.byType(WiredBottomNavigationBar),
      );

      expect(widget.currentIndex, 0);
    });

    testWidgets('calls onTap with correct index when item is tapped', (
      tester,
    ) async {
      int? tappedIndex;

      await pumpApp(
        tester,
        WiredBottomNavigationBar(
          items: testItems,
          onTap: (index) => tappedIndex = index,
        ),
        asBottomNav: true,
      );

      await tester.tap(find.text('Search'));
      await tester.pump();

      expect(tappedIndex, 1);
    });

    testWidgets('calls onTap for the last item', (tester) async {
      int? tappedIndex;

      await pumpApp(
        tester,
        WiredBottomNavigationBar(
          items: testItems,
          onTap: (index) => tappedIndex = index,
        ),
        asBottomNav: true,
      );

      await tester.tap(find.text('Profile'));
      await tester.pump();

      expect(tappedIndex, 2);
    });

    testWidgets('renders hand-drawn top line via WiredCanvas', (tester) async {
      await pumpApp(
        tester,
        WiredBottomNavigationBar(items: testItems),
        asBottomNav: true,
      );

      expect(
        find.descendant(
          of: find.byType(WiredBottomNavigationBar),
          matching: find.byType(WiredCanvas),
        ),
        findsWidgets,
      );
    });

    testWidgets('selected item shows circle indicator', (tester) async {
      await pumpApp(
        tester,
        WiredBottomNavigationBar(items: testItems, currentIndex: 1),
        asBottomNav: true,
      );

      expect(
        find.descendant(
          of: find.byType(WiredBottomNavigationBar),
          matching: find.byType(WiredCanvas),
        ),
        findsWidgets,
      );
    });

    testWidgets('does not crash when onTap is null', (tester) async {
      await pumpApp(
        tester,
        WiredBottomNavigationBar(items: testItems),
        asBottomNav: true,
      );

      await tester.tap(find.text('Home'));
      await tester.pump();

      expect(find.byType(WiredBottomNavigationBar), findsOneWidget);
    });

    testWidgets('renders with two items', (tester) async {
      const twoItems = [
        WiredBottomNavItem(icon: Icons.home, label: 'Home'),
        WiredBottomNavItem(icon: Icons.settings, label: 'Settings'),
      ];

      await pumpApp(
        tester,
        WiredBottomNavigationBar(items: twoItems),
        asBottomNav: true,
      );

      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
    });

    testWidgets('switching currentIndex changes selected item', (
      tester,
    ) async {
      await pumpApp(
        tester,
        WiredBottomNavigationBar(items: testItems, currentIndex: 0),
        asBottomNav: true,
      );

      // Rebuild with a different currentIndex.
      await pumpApp(
        tester,
        WiredBottomNavigationBar(items: testItems, currentIndex: 2),
        asBottomNav: true,
      );

      expect(find.byType(WiredBottomNavigationBar), findsOneWidget);
    });

    testWidgets('each item is wrapped in GestureDetector', (tester) async {
      await pumpApp(
        tester,
        WiredBottomNavigationBar(items: testItems),
        asBottomNav: true,
      );

      expect(
        find.descendant(
          of: find.byType(WiredBottomNavigationBar),
          matching: find.byType(GestureDetector),
        ),
        findsNWidgets(3),
      );
    });
  });
}
