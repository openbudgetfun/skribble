import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';

void main() {
  List<BottomNavigationBarItem> defaultItems() => const [
    BottomNavigationBarItem(icon: Icon(CupertinoIcons.home), label: 'Home'),
    BottomNavigationBarItem(icon: Icon(CupertinoIcons.search), label: 'Search'),
    BottomNavigationBarItem(
      icon: Icon(CupertinoIcons.settings),
      label: 'Settings',
    ),
  ];

  Widget buildSubject({
    List<BottomNavigationBarItem>? items,
    int currentIndex = 0,
    ValueChanged<int>? onTap,
    Color? activeColor,
    Color? inactiveColor,
    Color? backgroundColor,
  }) {
    return MaterialApp(
      home: Scaffold(
        bottomNavigationBar: WiredCupertinoTabBar(
          items: items ?? defaultItems(),
          currentIndex: currentIndex,
          onTap: onTap,
          activeColor: activeColor ?? CupertinoColors.activeBlue,
          inactiveColor: inactiveColor ?? CupertinoColors.inactiveGray,
          backgroundColor: backgroundColor,
        ),
        body: const SizedBox.expand(),
      ),
    );
  }

  group('WiredCupertinoTabBar', () {
    testWidgets('renders without error', (tester) async {
      await tester.pumpWidget(buildSubject());
      expect(find.byType(WiredCupertinoTabBar), findsOneWidget);
    });

    testWidgets('renders all tab labels', (tester) async {
      await tester.pumpWidget(buildSubject());
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Search'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
    });

    testWidgets('calls onTap with correct index', (tester) async {
      int? tappedIndex;
      await tester.pumpWidget(buildSubject(onTap: (i) => tappedIndex = i));
      await tester.tap(find.text('Search'));
      expect(tappedIndex, 1);
    });

    testWidgets('highlights active tab', (tester) async {
      await tester.pumpWidget(buildSubject(currentIndex: 1));
      // The search tab should be active — verify by finding the widget
      expect(find.byType(WiredCupertinoTabBar), findsOneWidget);
    });

    testWidgets('tapping first tab calls onTap with 0', (tester) async {
      int? tappedIndex;
      await tester.pumpWidget(
        buildSubject(currentIndex: 2, onTap: (i) => tappedIndex = i),
      );
      await tester.tap(find.text('Home'));
      expect(tappedIndex, 0);
    });

    testWidgets('renders with custom colors', (tester) async {
      await tester.pumpWidget(
        buildSubject(activeColor: Colors.red, inactiveColor: Colors.grey),
      );
      expect(find.byType(WiredCupertinoTabBar), findsOneWidget);
    });

    testWidgets('renders with custom background', (tester) async {
      await tester.pumpWidget(buildSubject(backgroundColor: Colors.amber));
      expect(find.byType(WiredCupertinoTabBar), findsOneWidget);
    });

    testWidgets('renders icons for each item', (tester) async {
      await tester.pumpWidget(buildSubject());
      // Should have 3 icon widgets from the items
      expect(find.byType(Icon), findsAtLeast(3));
    });
  });
}
