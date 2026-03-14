import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';

import '../helpers/pump_app.dart';

void main() {
  List<BottomNavigationBarItem> defaultItems() => const [
    BottomNavigationBarItem(icon: Icon(CupertinoIcons.home), label: 'Home'),
    BottomNavigationBarItem(icon: Icon(CupertinoIcons.search), label: 'Search'),
    BottomNavigationBarItem(
      icon: Icon(CupertinoIcons.settings),
      label: 'Settings',
    ),
  ];

  Future<void> pumpSubject(
    WidgetTester tester, {
    List<BottomNavigationBarItem>? items,
    int currentIndex = 0,
    ValueChanged<int>? onTap,
    Color? activeColor,
    Color? inactiveColor,
    Color? backgroundColor,
  }) {
    return pumpApp(
      tester,
      WiredCupertinoTabBar(
        items: items ?? defaultItems(),
        currentIndex: currentIndex,
        onTap: onTap,
        activeColor: activeColor ?? CupertinoColors.activeBlue,
        inactiveColor: inactiveColor ?? CupertinoColors.inactiveGray,
        backgroundColor: backgroundColor,
      ),
      asBottomNav: true,
    );
  }

  group('WiredCupertinoTabBar', () {
    testWidgets('renders without error', (tester) async {
      await pumpSubject(tester);
      expect(find.byType(WiredCupertinoTabBar), findsOneWidget);
    });

    testWidgets('renders all tab labels', (tester) async {
      await pumpSubject(tester);
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Search'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
    });

    testWidgets('calls onTap with correct index', (tester) async {
      int? tappedIndex;
      await pumpSubject(tester, onTap: (i) => tappedIndex = i);
      await tester.tap(find.text('Search'));
      expect(tappedIndex, 1);
    });

    testWidgets('highlights active tab', (tester) async {
      await pumpSubject(tester, currentIndex: 1);
      expect(find.byType(WiredCupertinoTabBar), findsOneWidget);
    });

    testWidgets('tapping first tab calls onTap with 0', (tester) async {
      int? tappedIndex;
      await pumpSubject(tester, currentIndex: 2, onTap: (i) => tappedIndex = i);
      await tester.tap(find.text('Home'));
      expect(tappedIndex, 0);
    });

    testWidgets('renders with custom colors', (tester) async {
      await pumpSubject(
        tester,
        activeColor: Colors.red,
        inactiveColor: Colors.grey,
      );
      expect(find.byType(WiredCupertinoTabBar), findsOneWidget);
    });

    testWidgets('renders with custom background', (tester) async {
      await pumpSubject(tester, backgroundColor: Colors.amber);
      expect(find.byType(WiredCupertinoTabBar), findsOneWidget);
    });

    testWidgets('renders icons for each item', (tester) async {
      await pumpSubject(tester);
      expect(find.byType(Icon), findsAtLeast(3));
    });
  });
}
