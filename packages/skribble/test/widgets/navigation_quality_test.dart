import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';
import 'package:skribble/testing.dart';

/// Layout, safe-area, keyboard, and semantics checks shared by the
/// navigation widgets: app bar, tab bar, bottom navigation, navigation bar,
/// rail, and drawer.
void main() {
  void useScreen(
    WidgetTester tester, {
    double width = 320,
    double textScale = 1,
    FakeViewPadding padding = FakeViewPadding.zero,
  }) {
    tester.view
      ..physicalSize = Size(width, 800)
      ..devicePixelRatio = 1
      ..padding = padding;
    tester.platformDispatcher.textScaleFactorTestValue = textScale;
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
  }

  /// The height of one line of [finder]'s text, as laid out.
  double lineHeight(WidgetTester tester, Finder finder) {
    final paragraph = tester.renderObject<RenderParagraph>(finder);
    return paragraph.getFullHeightForCaret(const TextPosition(offset: 0));
  }

  const longTitle = 'A rather long heading that keeps going on narrow phones';

  group('WiredAppBar', () {
    testWidgets('keeps a long title on one line at 320 pixels and 2x text', (
      tester,
    ) async {
      useScreen(tester, textScale: 2);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: WiredAppBar(
              title: const Text(longTitle),
              actions: const [Icon(Icons.search)],
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      final title = find.text(longTitle);
      // One line, ending in an ellipsis, inside the bar.
      expect(
        tester.getSize(title).height,
        lessThanOrEqualTo(lineHeight(tester, title) + .5),
      );
      final bar = tester.getRect(find.byType(WiredAppBar));
      expect(bar.contains(tester.getRect(title).bottomCenter), isTrue);
    });

    testWidgets('a text button in leading keeps its padding at 2x text', (
      tester,
    ) async {
      useScreen(tester, width: 800, textScale: 2);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: WiredAppBar(
              leading: WiredButton(onPressed: () {}, child: const Text('Back')),
              title: const Text('Financial charts'),
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      final root = tester.binding.renderViews.first;
      expect(crampedText(root, lines: true), isEmpty);
    });

    testWidgets('announces its title as a header', (tester) async {
      final semantics = tester.ensureSemantics();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(appBar: WiredAppBar(title: const Text('Inbox'))),
        ),
      );

      expect(
        tester.getSemantics(find.text('Inbox')),
        matchesSemantics(label: 'Inbox', isHeader: true),
      );
      semantics.dispose();
    });
  });

  group('WiredTabBar', () {
    const tabs = ['Overview', 'Specifications', 'Reviews', 'Questions'];

    testWidgets('labels stay on one line at 320 pixels and 2x text', (
      tester,
    ) async {
      useScreen(tester, textScale: 2);
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: WiredTabBar(tabs: tabs, selectedIndex: 1),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      for (final label in tabs) {
        final text = find.text(label);
        expect(
          tester.getSize(text).height,
          lessThanOrEqualTo(lineHeight(tester, text) + .5),
          reason: label,
        );
      }
    });

    testWidgets('grows with large text outside a fixed slot', (tester) async {
      useScreen(tester, textScale: 2);
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: WiredTabBar(tabs: tabs)),
        ),
      );

      expect(tester.takeException(), isNull);
      final bar = tester.getRect(find.byType(WiredTabBar));
      expect(bar.height, greaterThan(48));
      for (final label in tabs) {
        // The ink padding between every label and the underline below it.
        expect(
          bar.bottom - tester.getRect(find.text(label)).bottom,
          greaterThanOrEqualTo(8),
          reason: label,
        );
      }
    });

    testWidgets('is exactly its preferred height in an app bar', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: AppBar(bottom: const WiredTabBar(tabs: tabs)),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(tester.getSize(find.byType(WiredTabBar)).height, 48);
    });

    testWidgets('the underline stays below the selected label', (
      tester,
    ) async {
      useScreen(tester, textScale: 2);
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: WiredTabBar(tabs: tabs, selectedIndex: 2)),
        ),
      );

      final label = tester.getRect(find.text('Reviews'));
      final underline = tester
          .getRect(
            find
                .descendant(
                  of: find.byType(WiredTabBar),
                  matching: find.byType(WiredCanvas),
                )
                .first,
          )
          .top;
      expect(underline, greaterThanOrEqualTo(label.bottom - .5));
    });

    testWidgets('names each tab, its position, and its selection', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: WiredTabBar(tabs: tabs, selectedIndex: 2)),
        ),
      );

      expect(
        tester.getSemantics(find.bySemanticsLabel('Reviews, tab 3 of 4')),
        matchesSemantics(
          label: 'Reviews, tab 3 of 4',
          isButton: true,
          hasSelectedState: true,
          isSelected: true,
          isInMutuallyExclusiveGroup: true,
          isFocusable: true,
          hasTapAction: true,
          hasFocusAction: true,
        ),
      );
      semantics.dispose();
    });

    testWidgets('tabs take focus and activate from the keyboard', (
      tester,
    ) async {
      final taps = <int>[];
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WiredTabBar(tabs: tabs, onTap: taps.add),
          ),
        ),
      );

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pump();

      expect(taps, [0, 1]);
    });
  });

  group('WiredBottomNavigationBar', () {
    const items = [
      WiredBottomNavItem(icon: Icons.home, label: 'Home'),
      WiredBottomNavItem(icon: Icons.search, label: 'Search'),
      WiredBottomNavItem(icon: Icons.person, label: 'Profile'),
    ];

    testWidgets('grows with 2x text instead of overflowing', (tester) async {
      useScreen(tester, textScale: 2);
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            bottomNavigationBar: WiredBottomNavigationBar(items: items),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
    });

    testWidgets('sits above the home indicator', (tester) async {
      useScreen(tester, padding: const FakeViewPadding(bottom: 34));
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            bottomNavigationBar: WiredBottomNavigationBar(items: items),
          ),
        ),
      );

      expect(tester.getRect(find.text('Home')).bottom, lessThan(800 - 34));
    });

    testWidgets('announces items as selectable buttons', (tester) async {
      final semantics = tester.ensureSemantics();
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            bottomNavigationBar: WiredBottomNavigationBar(
              items: items,
              currentIndex: 1,
            ),
          ),
        ),
      );

      expect(
        tester.getSemantics(find.bySemanticsLabel('Search')),
        matchesSemantics(
          label: 'Search',
          isButton: true,
          hasSelectedState: true,
          isSelected: true,
          isInMutuallyExclusiveGroup: true,
          isFocusable: true,
          hasTapAction: true,
          hasFocusAction: true,
        ),
      );
      semantics.dispose();
    });
  });

  group('WiredNavigationBar', () {
    const destinations = [
      WiredNavigationDestination(icon: Icons.home, label: 'Home'),
      WiredNavigationDestination(icon: Icons.search, label: 'Explore'),
      WiredNavigationDestination(icon: Icons.person, label: 'Profile'),
    ];

    testWidgets('sits above the home indicator and grows with text', (
      tester,
    ) async {
      useScreen(
        tester,
        textScale: 2,
        padding: const FakeViewPadding(bottom: 34),
      );
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            bottomNavigationBar: WiredNavigationBar(destinations: destinations),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(tester.getRect(find.text('Home')).bottom, lessThan(800 - 34));
    });

    testWidgets('announces the selected destination', (tester) async {
      final semantics = tester.ensureSemantics();
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            bottomNavigationBar: WiredNavigationBar(
              destinations: destinations,
              selectedIndex: 2,
            ),
          ),
        ),
      );

      expect(
        tester.getSemantics(find.bySemanticsLabel('Profile')),
        matchesSemantics(
          label: 'Profile',
          isButton: true,
          hasSelectedState: true,
          isSelected: true,
          isInMutuallyExclusiveGroup: true,
          isFocusable: true,
          hasTapAction: true,
          hasFocusAction: true,
        ),
      );
      semantics.dispose();
    });
  });

  group('WiredNavigationRail', () {
    testWidgets('destinations are selectable from the keyboard', (
      tester,
    ) async {
      final selected = <int>[];
      final semantics = tester.ensureSemantics();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Row(
              children: [
                WiredNavigationRail(
                  destinations: const [
                    WiredNavigationRailDestination(
                      icon: Icons.home,
                      label: 'Home',
                    ),
                    WiredNavigationRailDestination(
                      icon: Icons.star,
                      label: 'Starred',
                    ),
                  ],
                  onDestinationSelected: selected.add,
                ),
                const Expanded(child: SizedBox()),
              ],
            ),
          ),
        ),
      );

      expect(
        tester.getSemantics(find.bySemanticsLabel('Home')),
        matchesSemantics(
          label: 'Home',
          isButton: true,
          hasSelectedState: true,
          isSelected: true,
          isInMutuallyExclusiveGroup: true,
          isFocusable: true,
          hasTapAction: true,
          hasFocusAction: true,
        ),
      );

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      expect(selected, [1]);
      semantics.dispose();
    });
  });

  group('WiredNavigationDrawer', () {
    testWidgets('announces the selected destination', (tester) async {
      final semantics = tester.ensureSemantics();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WiredNavigationDrawer(
              selectedIndex: 1,
              destinations: const [
                WiredNavigationDrawerDestination(
                  icon: Icons.inbox,
                  label: 'Inbox',
                ),
                WiredNavigationDrawerDestination(
                  icon: Icons.send,
                  label: 'Sent',
                ),
              ],
              onDestinationSelected: (_) {},
            ),
          ),
        ),
      );

      expect(
        tester.getSemantics(find.bySemanticsLabel('Sent')),
        matchesSemantics(
          label: 'Sent',
          isButton: true,
          hasSelectedState: true,
          isSelected: true,
          isInMutuallyExclusiveGroup: true,
          isFocusable: true,
          hasTapAction: true,
          hasFocusAction: true,
        ),
      );
      semantics.dispose();
    });
  });
}
