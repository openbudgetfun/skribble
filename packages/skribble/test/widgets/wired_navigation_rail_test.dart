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
      await pumpApp(
        tester,
        Row(
          children: const [
            WiredNavigationRail(destinations: testDestinations),
            Expanded(child: SizedBox()),
          ],
        ),
      );

      expect(find.byType(WiredNavigationRail), findsOneWidget);
    });

    testWidgets('renders all destination labels', (tester) async {
      await pumpApp(
        tester,
        Row(
          children: const [
            WiredNavigationRail(destinations: testDestinations),
            Expanded(child: SizedBox()),
          ],
        ),
      );

      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Search'), findsOneWidget);
      expect(find.text('Profile'), findsOneWidget);
    });

    testWidgets('renders all destination icons', (tester) async {
      await pumpApp(
        tester,
        Row(
          children: const [
            WiredNavigationRail(destinations: testDestinations),
            Expanded(child: SizedBox()),
          ],
        ),
      );

      expect(find.byType(WiredIcon), findsNWidgets(3));
      expect(findWiredIcon(Icons.home), findsOneWidget);
      expect(findWiredIcon(Icons.search), findsOneWidget);
    });

    testWidgets('default selectedIndex is 0', (tester) async {
      await pumpApp(
        tester,
        Row(
          children: const [
            WiredNavigationRail(destinations: testDestinations),
            Expanded(child: SizedBox()),
          ],
        ),
      );

      final widget = tester.widget<WiredNavigationRail>(
        find.byType(WiredNavigationRail),
      );

      expect(widget.selectedIndex, 0);
    });

    testWidgets('calls onDestinationSelected with correct index', (
      tester,
    ) async {
      int? selectedIndex;

      await pumpApp(
        tester,
        Row(
          children: [
            WiredNavigationRail(
              destinations: testDestinations,
              onDestinationSelected: (index) => selectedIndex = index,
            ),
            const Expanded(child: SizedBox()),
          ],
        ),
      );

      await tester.tap(find.text('Search'));
      await tester.pump();

      expect(selectedIndex, 1);
    });

    testWidgets('calls onDestinationSelected for last item', (tester) async {
      int? selectedIndex;

      await pumpApp(
        tester,
        Row(
          children: [
            WiredNavigationRail(
              destinations: testDestinations,
              onDestinationSelected: (index) => selectedIndex = index,
            ),
            const Expanded(child: SizedBox()),
          ],
        ),
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
        Row(
          children: const [
            WiredNavigationRail(destinations: testDestinations),
            Expanded(child: SizedBox()),
          ],
        ),
      );

      await tester.tap(find.text('Home'));
      await tester.pump();

      expect(find.byType(WiredNavigationRail), findsOneWidget);
    });

    testWidgets('renders hand-drawn right border via WiredCanvas', (
      tester,
    ) async {
      await pumpApp(
        tester,
        Row(
          children: const [
            WiredNavigationRail(destinations: testDestinations),
            Expanded(child: SizedBox()),
          ],
        ),
      );

      expect(
        find.descendant(
          of: find.byType(WiredNavigationRail),
          matching: findWiredCanvas,
        ),
        findsWidgets,
      );
    });

    testWidgets('selected item shows rounded rect indicator', (tester) async {
      await pumpApp(
        tester,
        Row(
          children: const [
            WiredNavigationRail(
              destinations: testDestinations,
              selectedIndex: 1,
            ),
            Expanded(child: SizedBox()),
          ],
        ),
      );

      // The selected item should have a WiredCanvas for the rounded rectangle
      // indicator plus the vertical border line WiredCanvas.
      expect(
        find.descendant(
          of: find.byType(WiredNavigationRail),
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
        Row(
          children: const [
            WiredNavigationRail(
              destinations: testDestinations,
              selectedIndex: 2,
            ),
            Expanded(child: SizedBox()),
          ],
        ),
      );

      // Profile destination has selectedIcon: Icons.person.
      expect(findWiredIcon(Icons.person), findsOneWidget);
    });

    testWidgets('uses regular icon when item is not selected', (tester) async {
      await pumpApp(
        tester,
        Row(
          children: const [
            WiredNavigationRail(
              destinations: testDestinations,
              selectedIndex: 0,
            ),
            Expanded(child: SizedBox()),
          ],
        ),
      );

      // Profile (index 2) is not selected, so it uses person_outline.
      expect(findWiredIcon(Icons.person_outline), findsOneWidget);
    });

    testWidgets('renders leading widget', (tester) async {
      await pumpApp(
        tester,
        Row(
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
      );

      expect(find.byIcon(Icons.add), findsOneWidget);
      expect(find.byType(FloatingActionButton), findsOneWidget);
    });

    testWidgets('renders trailing widget', (tester) async {
      await pumpApp(
        tester,
        Row(
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
      );

      expect(find.byIcon(Icons.settings), findsOneWidget);
    });

    testWidgets('each destination is wrapped in GestureDetector', (
      tester,
    ) async {
      await pumpApp(
        tester,
        Row(
          children: const [
            WiredNavigationRail(destinations: testDestinations),
            Expanded(child: SizedBox()),
          ],
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
      await pumpApp(
        tester,
        Row(
          children: const [
            WiredNavigationRail(
              destinations: testDestinations,
              selectedIndex: 0,
            ),
            Expanded(child: SizedBox()),
          ],
        ),
      );

      await pumpApp(
        tester,
        Row(
          children: const [
            WiredNavigationRail(
              destinations: testDestinations,
              selectedIndex: 2,
            ),
            Expanded(child: SizedBox()),
          ],
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
        WiredNavigationRailDestination(icon: Icons.settings, label: 'Settings'),
      ];

      await pumpApp(
        tester,
        Row(
          children: const [
            WiredNavigationRail(destinations: twoDestinations),
            Expanded(child: SizedBox()),
          ],
        ),
      );

      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
    });

    testWidgets('rail has 72px width for destination area', (tester) async {
      await pumpApp(
        tester,
        Row(
          children: const [
            WiredNavigationRail(destinations: testDestinations),
            Expanded(child: SizedBox()),
          ],
        ),
      );

      // The rail main column is 72px wide, plus space for the themed pen.
      final railSize = tester.getSize(find.byType(WiredNavigationRail));
      expect(railSize.width, 72 + WiredThemeData.defaultTheme.inkExtent);
    });
  });

  group('WiredNavigationRail parity', () {
    final theme = WiredThemeData();
    const destinations = [
      WiredNavigationRailDestination(icon: Icons.inbox, label: 'Inbox'),
      WiredNavigationRailDestination(icon: Icons.send, label: 'Sent'),
      WiredNavigationRailDestination(icon: Icons.drafts, label: 'Drafts'),
    ];

    List<Color> washes(WidgetTester tester) => [
      for (final canvas in tester.widgetList<WiredCanvas>(
        find.descendant(
          of: find.byType(WiredNavigationRail),
          matching: findWiredCanvas,
        ),
      ))
        if (canvas.painter case final WiredRoundedRectangleBase wash)
          wash.fillColor,
    ];

    Widget host(Widget rail, {double height = 400}) => WiredTheme(
      data: theme,
      child: Align(
        alignment: Alignment.topLeft,
        child: SizedBox(
          height: height,
          child: Row(
            children: [
              rail,
              const Expanded(child: SizedBox()),
            ],
          ),
        ),
      ),
    );

    testWidgets('extended springs wider and puts labels beside icons', (
      tester,
    ) async {
      Widget build(bool extended) => host(
        WiredNavigationRail(destinations: destinations, extended: extended),
      );

      await pumpApp(tester, build(false));
      expect(
        tester.getSize(find.byType(WiredNavigationRail)).width,
        72 + theme.inkExtent,
      );

      await pumpApp(tester, build(true));
      await tester.pump(const Duration(milliseconds: 50));
      expect(tester.hasRunningAnimations, isTrue);
      await tester.pumpAndSettle();

      expect(
        tester.getSize(find.byType(WiredNavigationRail)).width,
        256 + theme.inkExtent,
      );
      final icon = tester.getCenter(find.byType(WiredIcon).first);
      final label = tester.getCenter(find.text('Inbox'));
      expect(label.dx, greaterThan(icon.dx));
      expect(label.dy, closeTo(icon.dy, 4));
      expect(tester.takeException(), isNull);
    });

    testWidgets('labelType none and selected hide labels but announce them', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      await pumpApp(
        tester,
        host(
          const WiredNavigationRail(
            destinations: destinations,
            labelType: WiredNavigationRailLabelType.none,
          ),
        ),
      );
      expect(find.byType(Text), findsNothing);
      expect(
        tester.getSemantics(find.bySemanticsLabel('Sent')).tooltip,
        'Sent',
      );

      await pumpApp(
        tester,
        host(
          const WiredNavigationRail(
            destinations: destinations,
            selectedIndex: 1,
            labelType: WiredNavigationRailLabelType.selected,
          ),
        ),
      );
      expect(find.text('Sent'), findsOneWidget);
      expect(find.text('Inbox'), findsNothing);
      semantics.dispose();
    });

    testWidgets('a null selectedIndex selects nothing', (tester) async {
      await pumpApp(
        tester,
        host(
          const WiredNavigationRail(
            destinations: destinations,
            selectedIndex: null,
          ),
        ),
      );

      expect(washes(tester), isEmpty);
    });

    testWidgets('useIndicator false drops the wash; colorCoded recolours it', (
      tester,
    ) async {
      await pumpApp(
        tester,
        host(
          const WiredNavigationRail(
            destinations: destinations,
            useIndicator: false,
          ),
        ),
      );
      expect(washes(tester), isEmpty);

      await pumpApp(
        tester,
        host(
          const WiredNavigationRail(
            destinations: destinations,
            selectedIndex: 2,
            colorCoded: true,
          ),
        ),
      );
      expect(washes(tester), [theme.accentAt(2)]);
    });

    testWidgets('a disabled destination ignores taps', (tester) async {
      final semantics = tester.ensureSemantics();
      final selected = <int>[];
      await pumpApp(
        tester,
        host(
          WiredNavigationRail(
            onDestinationSelected: selected.add,
            destinations: const [
              WiredNavigationRailDestination(icon: Icons.inbox, label: 'Inbox'),
              WiredNavigationRailDestination(
                icon: Icons.lock,
                label: 'Locked',
                disabled: true,
              ),
            ],
          ),
        ),
      );

      await tester.tap(find.text('Locked'));
      await tester.tap(find.text('Inbox'));
      expect(selected, [0]);
      expectSemantics(
        tester,
        find.bySemanticsLabel('Locked'),
        isEnabled: false,
        hasTapAction: false,
      );
      semantics.dispose();
    });

    testWidgets('groupAlignment centres or sinks the destinations', (
      tester,
    ) async {
      Future<double> topOfInbox(double alignment) async {
        await pumpApp(
          tester,
          host(
            WiredNavigationRail(
              destinations: destinations,
              groupAlignment: alignment,
            ),
          ),
        );
        return tester.getTopLeft(find.text('Inbox')).dy;
      }

      final top = await topOfInbox(-1);
      final centre = await topOfInbox(0);
      final bottom = await topOfInbox(1);
      expect(centre, greaterThan(top));
      expect(bottom, greaterThan(centre));
    });

    testWidgets('scrollable rails fit many destinations in a short space', (
      tester,
    ) async {
      await pumpApp(
        tester,
        host(
          WiredNavigationRail(
            scrollable: true,
            destinations: [
              for (var i = 0; i < 12; i++)
                WiredNavigationRailDestination(
                  icon: Icons.label,
                  label: 'Label $i',
                ),
            ],
          ),
          height: 300,
        ),
      );

      expect(tester.takeException(), isNull);
      await tester.drag(find.text('Label 2'), const Offset(0, -1200));
      await tester.pumpAndSettle();
      expect(find.text('Label 11').hitTestable(), findsOneWidget);
    });

    testWidgets('extended rail mirrors in RTL and survives large text', (
      tester,
    ) async {
      await pumpWiredRtl(
        tester,
        const SizedBox(
          height: 400,
          child: Row(
            children: [
              WiredNavigationRail(destinations: destinations, extended: true),
              Expanded(child: SizedBox()),
            ],
          ),
        ),
        textScaler: const TextScaler.linear(1.6),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      final icon = tester.getCenter(find.byType(WiredIcon).first);
      final label = tester.getCenter(find.text('Inbox'));
      expect(label.dx, lessThan(icon.dx));
    });

    testWidgets('an extended label on the wash takes the wash ink in dark', (
      tester,
    ) async {
      final dark = WiredThemeData.colorway(
        WiredColorway.sunny,
        brightness: Brightness.dark,
      );
      await pumpWired(
        tester,
        const SizedBox(
          height: 400,
          child: WiredNavigationRail(
            destinations: destinations,
            extended: true,
          ),
        ),
        theme: dark,
      );
      await tester.pumpAndSettle();

      expect(
        tester.widget<Text>(find.text('Inbox')).style!.color,
        dark.onColor(dark.markerColor),
      );
      expect(
        tester.widget<Text>(find.text('Sent')).style!.color,
        dark.disabledTextColor,
      );
    });

    testWidgets('a custom minWidth sizes the compact rail', (tester) async {
      await pumpApp(
        tester,
        host(
          const WiredNavigationRail(destinations: destinations, minWidth: 88),
        ),
      );

      expect(
        tester.getSize(find.byType(WiredNavigationRail)).width,
        88 + theme.inkExtent,
      );
    });
  });
}
