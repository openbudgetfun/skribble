import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';

void main() {
  group('WiredTabBar', () {
    const testTabs = ['Tab 1', 'Tab 2', 'Tab 3'];

    testWidgets('renders without error', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: WiredTabBar(tabs: testTabs)),
        ),
      );

      expect(find.byType(WiredTabBar), findsOneWidget);
    });

    testWidgets('renders all tab labels', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: WiredTabBar(tabs: testTabs)),
        ),
      );

      expect(find.text('Tab 1'), findsOneWidget);
      expect(find.text('Tab 2'), findsOneWidget);
      expect(find.text('Tab 3'), findsOneWidget);
    });

    testWidgets('default selectedIndex is 0', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: WiredTabBar(tabs: testTabs)),
        ),
      );

      final widget = tester.widget<WiredTabBar>(find.byType(WiredTabBar));

      expect(widget.selectedIndex, 0);
    });

    testWidgets('default height is 48.0', (tester) async {
      const tabBar = WiredTabBar(tabs: ['A', 'B']);
      expect(tabBar.preferredSize.height, 48.0);
    });

    testWidgets('accepts custom height', (tester) async {
      const tabBar = WiredTabBar(tabs: ['A', 'B'], height: 64.0);
      expect(tabBar.preferredSize.height, 64.0);
    });

    testWidgets('implements PreferredSizeWidget', (tester) async {
      const tabBar = WiredTabBar(tabs: ['A', 'B']);
      expect(tabBar, isA<PreferredSizeWidget>());
      expect(tabBar.preferredSize, const Size.fromHeight(48.0));
    });

    testWidgets('calls onTap with correct index when tab is tapped', (
      tester,
    ) async {
      int? tappedIndex;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WiredTabBar(
              tabs: testTabs,
              onTap: (index) => tappedIndex = index,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Tab 2'));
      await tester.pump();

      expect(tappedIndex, 1);
    });

    testWidgets('calls onTap for the first tab', (tester) async {
      int? tappedIndex;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WiredTabBar(
              tabs: testTabs,
              onTap: (index) => tappedIndex = index,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Tab 1'));
      await tester.pump();

      expect(tappedIndex, 0);
    });

    testWidgets('calls onTap for the last tab', (tester) async {
      int? tappedIndex;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WiredTabBar(
              tabs: testTabs,
              onTap: (index) => tappedIndex = index,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Tab 3'));
      await tester.pump();

      expect(tappedIndex, 2);
    });

    testWidgets('does not crash when onTap is null', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: WiredTabBar(tabs: testTabs)),
        ),
      );

      await tester.tap(find.text('Tab 1'));
      await tester.pump();

      expect(find.byType(WiredTabBar), findsOneWidget);
    });

    testWidgets('renders bottom line via WiredCanvas', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: WiredTabBar(tabs: testTabs)),
        ),
      );

      expect(
        find.descendant(
          of: find.byType(WiredTabBar),
          matching: find.byType(WiredCanvas),
        ),
        findsWidgets,
      );
    });

    testWidgets('selected tab has underline indicator WiredCanvas', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: WiredTabBar(tabs: testTabs, selectedIndex: 0)),
        ),
      );

      // Selected tab at index 0 should have a WiredCanvas for the underline
      // indicator, plus the bottom line WiredCanvas. Total at least 2.
      expect(
        find.descendant(
          of: find.byType(WiredTabBar),
          matching: find.byType(WiredCanvas),
        ),
        findsAtLeastNWidgets(2),
      );
    });

    testWidgets('each tab is wrapped in GestureDetector', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: WiredTabBar(tabs: testTabs)),
        ),
      );

      expect(
        find.descendant(
          of: find.byType(WiredTabBar),
          matching: find.byType(GestureDetector),
        ),
        findsNWidgets(3),
      );
    });

    testWidgets('tabs use Expanded for equal width distribution', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: WiredTabBar(tabs: testTabs)),
        ),
      );

      // Each tab is wrapped in Expanded inside the Row.
      expect(
        find.descendant(
          of: find.byType(WiredTabBar),
          matching: find.byType(Expanded),
        ),
        findsWidgets,
      );
    });

    testWidgets('rebuilds when selectedIndex changes', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: WiredTabBar(tabs: testTabs, selectedIndex: 0)),
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: WiredTabBar(tabs: testTabs, selectedIndex: 2)),
        ),
      );

      final widget = tester.widget<WiredTabBar>(find.byType(WiredTabBar));

      expect(widget.selectedIndex, 2);
    });

    testWidgets('renders with two tabs', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: WiredTabBar(tabs: const ['Alpha', 'Beta'])),
        ),
      );

      expect(find.text('Alpha'), findsOneWidget);
      expect(find.text('Beta'), findsOneWidget);
    });

    testWidgets('can be used as AppBar bottom', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: AppBar(
              title: const Text('Title'),
              bottom: WiredTabBar(tabs: testTabs),
            ),
            body: const SizedBox(),
          ),
        ),
      );

      expect(find.byType(WiredTabBar), findsOneWidget);
      expect(find.text('Tab 1'), findsOneWidget);
    });

    testWidgets('selected tab has bold font weight', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: WiredTabBar(tabs: testTabs, selectedIndex: 1)),
        ),
      );

      // Find the Text widget for 'Tab 2' which should be selected (bold).
      final selectedText = tester.widget<Text>(find.text('Tab 2'));
      expect(selectedText.style?.fontWeight, FontWeight.bold);
    });

    testWidgets('unselected tab has normal font weight', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: WiredTabBar(tabs: testTabs, selectedIndex: 1)),
        ),
      );

      // 'Tab 1' is unselected (index 0), should have normal weight.
      final unselectedText = tester.widget<Text>(find.text('Tab 1'));
      expect(unselectedText.style?.fontWeight, FontWeight.normal);
    });
  });
}
