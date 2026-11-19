import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';

import '../helpers/finders.dart';
import '../helpers/pump_app.dart';
import '../helpers/semantics.dart';

Finder findWiredIcon(IconData icon) {
  return find.byWidgetPredicate(
    (widget) => widget is WiredIcon && widget.icon == icon,
    description: 'WiredIcon($icon)',
  );
}

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
      await pumpApp(
        tester,
        WiredNavigationBar(destinations: testDestinations),
        asBottomNav: true,
      );

      expect(find.byType(WiredNavigationBar), findsOneWidget);
    });

    testWidgets('renders all destination labels', (tester) async {
      await pumpApp(
        tester,
        WiredNavigationBar(destinations: testDestinations),
        asBottomNav: true,
      );

      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Search'), findsOneWidget);
      expect(find.text('Profile'), findsOneWidget);
    });

    testWidgets('renders all destination icons', (tester) async {
      await pumpApp(
        tester,
        WiredNavigationBar(destinations: testDestinations),
        asBottomNav: true,
      );

      expect(find.byType(WiredIcon), findsNWidgets(3));
      expect(findWiredIcon(Icons.home), findsOneWidget);
      expect(findWiredIcon(Icons.search), findsOneWidget);
    });

    testWidgets('default selectedIndex is 0', (tester) async {
      await pumpApp(
        tester,
        WiredNavigationBar(destinations: testDestinations),
        asBottomNav: true,
      );

      final widget = tester.widget<WiredNavigationBar>(
        find.byType(WiredNavigationBar),
      );

      expect(widget.selectedIndex, 0);
    });

    testWidgets('calls onDestinationSelected with correct index', (
      tester,
    ) async {
      int? selectedIndex;

      await pumpApp(
        tester,
        WiredNavigationBar(
          destinations: testDestinations,
          onDestinationSelected: (index) => selectedIndex = index,
        ),
        asBottomNav: true,
      );

      await tester.tap(find.text('Search'));
      await tester.pump();

      expect(selectedIndex, 1);
    });

    testWidgets('calls onDestinationSelected for last item', (tester) async {
      int? selectedIndex;

      await pumpApp(
        tester,
        WiredNavigationBar(
          destinations: testDestinations,
          onDestinationSelected: (index) => selectedIndex = index,
        ),
        asBottomNav: true,
      );

      await tester.tap(find.text('Profile'));
      await tester.pump();

      expect(selectedIndex, 2);
    });

    testWidgets('does not crash when onDestinationSelected is null', (
      tester,
    ) async {
      await pumpApp(
        tester,
        WiredNavigationBar(destinations: testDestinations),
        asBottomNav: true,
      );

      await tester.tap(find.text('Home'));
      await tester.pump();

      expect(find.byType(WiredNavigationBar), findsOneWidget);
    });

    testWidgets('renders hand-drawn top line via WiredCanvas', (tester) async {
      await pumpApp(
        tester,
        WiredNavigationBar(destinations: testDestinations),
        asBottomNav: true,
      );

      expect(
        find.descendant(
          of: find.byType(WiredNavigationBar),
          matching: findWiredCanvas,
        ),
        findsWidgets,
      );
    });

    testWidgets('selected item shows rounded rect indicator', (tester) async {
      await pumpApp(
        tester,
        WiredNavigationBar(destinations: testDestinations, selectedIndex: 1),
        asBottomNav: true,
      );

      expect(
        find.descendant(
          of: find.byType(WiredNavigationBar),
          matching: findWiredCanvas,
        ),
        findsWidgets,
      );
    });

    testWidgets('uses selectedIcon when provided and item is selected', (
      tester,
    ) async {
      await pumpApp(
        tester,
        WiredNavigationBar(destinations: testDestinations, selectedIndex: 2),
        asBottomNav: true,
      );

      expect(findWiredIcon(Icons.person), findsOneWidget);
    });

    testWidgets('uses regular icon when item is not selected', (tester) async {
      await pumpApp(
        tester,
        WiredNavigationBar(destinations: testDestinations, selectedIndex: 0),
        asBottomNav: true,
      );

      expect(findWiredIcon(Icons.person_outline), findsOneWidget);
    });

    testWidgets('each destination is wrapped in GestureDetector', (
      tester,
    ) async {
      await pumpApp(
        tester,
        WiredNavigationBar(destinations: testDestinations),
        asBottomNav: true,
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
      await pumpApp(
        tester,
        WiredNavigationBar(destinations: testDestinations, selectedIndex: 0),
        asBottomNav: true,
      );

      await pumpApp(
        tester,
        WiredNavigationBar(destinations: testDestinations, selectedIndex: 2),
        asBottomNav: true,
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

      await pumpApp(
        tester,
        WiredNavigationBar(destinations: twoDestinations),
        asBottomNav: true,
      );

      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
    });

    testWidgets('shrinks a long label to fit its cell before cutting it', (
      tester,
    ) async {
      await pumpWired(
        tester,
        SizedBox(
          width: 200,
          child: WiredNavigationBar(
            destinations: const [
              WiredNavigationDestination(icon: Icons.home, label: 'Home'),
              WiredNavigationDestination(
                icon: Icons.notifications,
                label: 'Notifications',
              ),
            ],
          ),
        ),
      );

      final label = find.text('Notifications');
      final painted = tester.getRect(label);
      final bar = tester.getRect(find.byType(WiredNavigationBar));
      expect(painted.width, lessThan(tester.getSize(label).width));
      expect(painted.left, greaterThanOrEqualTo(bar.center.dx));
      expect(painted.right, lessThanOrEqualTo(bar.right));
      expect(find.byType(WiredFitText), findsNWidgets(2));
    });
  });

  group('WiredNavigationBar parity', () {
    final theme = WiredThemeData();
    const destinations = [
      WiredNavigationDestination(icon: Icons.home, label: 'Home'),
      WiredNavigationDestination(icon: Icons.search, label: 'Search'),
      WiredNavigationDestination(icon: Icons.person, label: 'Profile'),
    ];

    /// The washes drawn behind destination icons, left to right.
    List<Color> washes(WidgetTester tester) {
      final canvases = tester.widgetList<WiredCanvas>(
        find.descendant(
          of: find.byType(WiredNavigationBar),
          matching: findWiredCanvas,
        ),
      );
      return [
        for (final canvas in canvases)
          if (canvas.painter case final WiredRoundedRectangleBase wash)
            wash.fillColor,
      ];
    }

    Widget host(Widget bar) => WiredTheme(
      data: theme,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [bar],
      ),
    );

    testWidgets('onlyShowSelected hides the other labels from sight only', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      await pumpApp(
        tester,
        host(
          const WiredNavigationBar(
            destinations: destinations,
            selectedIndex: 1,
            labelBehavior:
                WiredNavigationDestinationLabelBehavior.onlyShowSelected,
          ),
        ),
      );

      expect(find.text('Search'), findsOneWidget);
      expect(find.text('Home'), findsNothing);
      expect(find.text('Profile'), findsNothing);
      // Hidden labels are still announced, with a tooltip.
      final home = tester.getSemantics(find.bySemanticsLabel('Home'));
      expect(home.tooltip, 'Home');
      expect(find.bySemanticsLabel('Profile'), findsOneWidget);
      semantics.dispose();
    });

    testWidgets('alwaysHide keeps every label for screen readers', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      await pumpApp(
        tester,
        host(
          const WiredNavigationBar(
            destinations: destinations,
            labelBehavior: WiredNavigationDestinationLabelBehavior.alwaysHide,
          ),
        ),
      );

      expect(find.byType(Text), findsNothing);
      for (final label in ['Home', 'Search', 'Profile']) {
        expect(find.bySemanticsLabel(label), findsOneWidget);
      }
      semantics.dispose();
    });

    testWidgets('colorCoded washes the selection with its accent', (
      tester,
    ) async {
      await pumpApp(
        tester,
        host(
          const WiredNavigationBar(
            destinations: destinations,
            selectedIndex: 2,
            colorCoded: true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(washes(tester), [theme.accentAt(2)]);
    });

    testWidgets('a destination colour wins over the indicator colour', (
      tester,
    ) async {
      await pumpApp(
        tester,
        host(
          WiredNavigationBar(
            indicatorColor: theme.accentAt(4),
            destinations: [
              WiredNavigationDestination(
                icon: Icons.home,
                label: 'Home',
                color: theme.accentAt(1),
              ),
              ...destinations.skip(1),
            ],
          ),
        ),
      );
      expect(washes(tester), [theme.accentAt(1)]);

      await pumpApp(
        tester,
        host(
          WiredNavigationBar(
            indicatorColor: theme.accentAt(4),
            destinations: destinations,
          ),
        ),
      );
      expect(washes(tester), [theme.accentAt(4)]);
    });

    testWidgets('a primary action stays washed with the accent', (
      tester,
    ) async {
      await pumpApp(
        tester,
        host(
          const WiredNavigationBar(
            destinations: [
              WiredNavigationDestination(icon: Icons.home, label: 'Home'),
              WiredNavigationDestination(
                icon: Icons.add,
                label: 'Create',
                isPrimaryAction: true,
              ),
            ],
          ),
        ),
      );

      expect(washes(tester), [theme.markerColor, theme.accentColor]);
      expect(
        tester.widget<WiredIcon>(findWiredIcon(Icons.add)).color,
        theme.onAccentColor,
      );
    });

    testWidgets('a disabled destination ignores taps and says so', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      final selected = <int>[];
      await pumpApp(
        tester,
        host(
          WiredNavigationBar(
            onDestinationSelected: selected.add,
            destinations: const [
              WiredNavigationDestination(icon: Icons.home, label: 'Home'),
              WiredNavigationDestination(
                icon: Icons.lock,
                label: 'Locked',
                enabled: false,
              ),
            ],
          ),
        ),
      );

      await tester.tap(find.text('Locked'));
      await tester.tap(find.text('Home'));
      expect(selected, [0]);
      expectSemantics(
        tester,
        find.bySemanticsLabel('Locked'),
        isEnabled: false,
        hasTapAction: false,
      );
      semantics.dispose();
    });

    testWidgets('draws badges as a count or a dot', (tester) async {
      await pumpApp(
        tester,
        host(
          const WiredNavigationBar(
            destinations: [
              WiredNavigationDestination(
                icon: Icons.mail,
                label: 'Inbox',
                badge: '3',
              ),
              WiredNavigationDestination(
                icon: Icons.notifications,
                label: 'Alerts',
                badge: '',
              ),
              WiredNavigationDestination(icon: Icons.home, label: 'Home'),
            ],
          ),
        ),
      );

      expect(find.text('3'), findsOneWidget);
      // The dot is a hand-drawn circle; the bar draws no other circles.
      final dots = tester
          .widgetList<WiredCanvas>(
            find.descendant(
              of: find.byType(WiredNavigationBar),
              matching: findWiredCanvas,
            ),
          )
          .where((canvas) => canvas.painter is WiredCircleBase);
      expect(dots, hasLength(1));
      // The count grows away from the glyph instead of covering it.
      expect(
        tester.getTopLeft(find.text('3')).dx,
        greaterThan(tester.getCenter(findWiredIcon(Icons.mail)).dx),
      );
    });

    testWidgets('destinations share the width and respect the min height', (
      tester,
    ) async {
      await pumpApp(
        tester,
        host(const WiredNavigationBar(destinations: destinations, height: 96)),
      );

      final widths = [
        for (final label in ['Home', 'Search', 'Profile'])
          tester
              .getSize(
                find
                    .ancestor(
                      of: find.text(label),
                      matching: find.byType(Expanded),
                    )
                    .first,
              )
              .width,
      ];
      expect(widths[0], closeTo(widths[1], 0.01));
      expect(widths[1], closeTo(widths[2], 0.01));
      expect(
        tester.getSize(find.byType(WiredNavigationBar)).height,
        greaterThanOrEqualTo(96),
      );
    });

    testWidgets('the indicator pops in and settles, or switches at once', (
      tester,
    ) async {
      Widget build(int index, {bool motion = true}) => WiredMotion(
        enabled: motion,
        child: host(
          WiredNavigationBar(destinations: destinations, selectedIndex: index),
        ),
      );

      await pumpApp(tester, build(0));
      await tester.pumpAndSettle();
      await pumpApp(tester, build(1));
      await tester.pump(const Duration(milliseconds: 16));
      expect(tester.hasRunningAnimations, isTrue);
      await tester.pumpAndSettle();
      expect(washes(tester), [theme.markerColor]);

      await pumpApp(tester, build(2, motion: false));
      expect(tester.hasRunningAnimations, isFalse);
    });
  });
}
