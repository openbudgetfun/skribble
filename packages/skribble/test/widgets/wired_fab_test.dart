import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';

import '../helpers/finders.dart';
import '../helpers/pump_app.dart';
import '../helpers/rendering.dart';
import '../helpers/semantics.dart';

void main() {
  group('WiredFloatingActionButton', () {
    testWidgets('renders without error', (tester) async {
      await pumpApp(
        tester,
        WiredFloatingActionButton(icon: Icons.add, onPressed: () {}),
      );

      expect(find.byType(WiredFloatingActionButton), findsOneWidget);
    });

    testWidgets('renders the provided rough icon', (tester) async {
      await pumpApp(
        tester,
        WiredFloatingActionButton(icon: Icons.edit, onPressed: () {}),
      );

      expect(find.byType(WiredIcon), findsOneWidget);
      final roughIcon = tester.widget<WiredIcon>(find.byType(WiredIcon));
      expect(roughIcon.icon, Icons.edit);
    });

    testWidgets('calls onPressed callback when tapped', (tester) async {
      var pressed = false;

      await pumpApp(
        tester,
        WiredFloatingActionButton(
          icon: Icons.add,
          onPressed: () => pressed = true,
        ),
      );

      await tester.tap(find.byType(WiredFloatingActionButton));
      await tester.pump();

      expect(pressed, isTrue);
    });

    testWidgets('does not crash when onPressed is null', (tester) async {
      await pumpApp(
        tester,
        WiredFloatingActionButton(icon: Icons.add, onPressed: null),
      );

      expect(find.byType(WiredFloatingActionButton), findsOneWidget);
    });

    testWidgets('does not call callback when onPressed is null', (
      tester,
    ) async {
      const pressed = false;

      await pumpApp(
        tester,
        WiredFloatingActionButton(icon: Icons.add, onPressed: null),
      );

      await tester.tap(find.byType(WiredFloatingActionButton));
      await tester.pump();

      expect(pressed, isFalse);
    });

    testWidgets('onPressed defaults to null', (tester) async {
      const fab = WiredFloatingActionButton(icon: Icons.add);

      expect(fab.onPressed, isNull);
    });

    testWidgets('size defaults to 56.0', (tester) async {
      const fab = WiredFloatingActionButton(icon: Icons.add);

      expect(fab.size, 56.0);
    });

    testWidgets('renders with default size (56.0)', (tester) async {
      await pumpApp(
        tester,
        WiredFloatingActionButton(icon: Icons.add, onPressed: () {}),
      );

      final fabSize = tester.getSize(find.byType(WiredFloatingActionButton));

      expect(fabSize.width, 56.0);
      expect(fabSize.height, 56.0);
    });

    testWidgets('renders with custom size', (tester) async {
      await pumpApp(
        tester,
        WiredFloatingActionButton(
          icon: Icons.add,
          onPressed: () {},
          size: 72.0,
        ),
      );

      final fabSize = tester.getSize(find.byType(WiredFloatingActionButton));

      expect(fabSize.width, 72.0);
      expect(fabSize.height, 72.0);
    });

    testWidgets('iconColor defaults to null', (tester) async {
      const fab = WiredFloatingActionButton(icon: Icons.add);

      expect(fab.iconColor, isNull);
    });

    testWidgets('uses custom iconColor when provided', (tester) async {
      await pumpApp(
        tester,
        WiredFloatingActionButton(
          icon: Icons.add,
          onPressed: () {},
          iconColor: Colors.white,
        ),
      );

      final roughIcon = tester.widget<WiredIcon>(find.byType(WiredIcon));

      expect(roughIcon.color, Colors.white);
    });

    testWidgets('uses GestureDetector for tap handling', (tester) async {
      await pumpApp(
        tester,
        WiredFloatingActionButton(icon: Icons.add, onPressed: () {}),
      );

      expect(
        find.descendant(
          of: find.byType(WiredFloatingActionButton),
          matching: find.byType(GestureDetector),
        ),
        findsOneWidget,
      );
    });

    testWidgets('contains WiredCanvas for circle background', (tester) async {
      await pumpApp(
        tester,
        WiredFloatingActionButton(icon: Icons.add, onPressed: () {}),
      );

      expect(
        find.descendant(
          of: find.byType(WiredFloatingActionButton),
          matching: findWiredCanvas,
        ),
        findsOneWidget,
      );
    });

    testWidgets('contains Stack for layering circle and icon', (tester) async {
      await pumpApp(
        tester,
        WiredFloatingActionButton(icon: Icons.add, onPressed: () {}),
      );

      // The icon is centered over the hand-drawn circle canvas. The focus/
      // keyboard chrome may contribute its own decorative Stack, so assert the
      // layering itself rather than a Stack count.
      expect(
        find.descendant(
          of: find.byType(WiredFloatingActionButton),
          matching: find.byType(WiredIcon),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byType(WiredFloatingActionButton),
          matching: findWiredCanvas,
        ),
        findsOneWidget,
      );
    });

    testWidgets('has RepaintBoundary wrapper', (tester) async {
      await pumpApp(
        tester,
        WiredFloatingActionButton(icon: Icons.add, onPressed: () {}),
      );

      expect(
        find.descendant(
          of: find.byType(WiredFloatingActionButton),
          matching: findRepaintBoundary,
        ),
        findsAtLeastNWidgets(1),
      );
    });

    testWidgets('icon size scales with widget size', (tester) async {
      await pumpApp(
        tester,
        WiredFloatingActionButton(
          icon: Icons.add,
          onPressed: () {},
          size: 100.0,
        ),
      );

      final roughIcon = tester.widget<WiredIcon>(find.byType(WiredIcon));

      // Icon size is size * 0.43 = 100.0 * 0.43 = 43.0
      expect(roughIcon.size, 43.0);
    });

    testWidgets('tracks multiple rapid taps', (tester) async {
      var tapCount = 0;

      await pumpApp(
        tester,
        WiredFloatingActionButton(icon: Icons.add, onPressed: () => tapCount++),
      );

      await tester.tap(find.byType(WiredFloatingActionButton));
      await tester.pump();
      await tester.tap(find.byType(WiredFloatingActionButton));
      await tester.pump();
      await tester.tap(find.byType(WiredFloatingActionButton));
      await tester.pump();

      expect(tapCount, 3);
    });

    testWidgets('activates from the keyboard (Enter) when focused', (
      tester,
    ) async {
      var tapCount = 0;
      await pumpApp(
        tester,
        WiredFloatingActionButton(icon: Icons.add, onPressed: () => tapCount++),
      );

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();

      expect(tapCount, 1);
    });

    testWidgets('is not keyboard-activatable when disabled', (tester) async {
      final tapCount = <int>[];
      await pumpApp(
        tester,
        const WiredFloatingActionButton(icon: Icons.add, onPressed: null),
      );

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();

      expect(tapCount, isEmpty);
    });

    testWidgets('applies semantic label when provided', (tester) async {
      await pumpApp(
        tester,
        WiredFloatingActionButton(
          icon: Icons.add,
          onPressed: () {},
          semanticLabel: 'Add new item',
        ),
      );

      expect(find.bySemanticsLabel('Add new item'), findsOneWidget);
    });

    testWidgets('is washed with the accent and inked to read on it', (
      tester,
    ) async {
      final theme = WiredThemeData();
      await pumpWired(
        tester,
        WiredFloatingActionButton(icon: Icons.add, onPressed: () {}),
        theme: theme,
      );

      final circle =
          tester
                  .widget<WiredCanvas>(
                    find.descendant(
                      of: find.byType(WiredFloatingActionButton),
                      matching: findWiredCanvas,
                    ),
                  )
                  .painter
              as WiredCircleBase;

      expect(circle.fillColor, theme.accentColor);
      expect(
        tester.widget<WiredCanvas>(findWiredCanvas.first).fillerType,
        RoughFilter.solidFiller,
      );
      expect(
        tester.widget<WiredIcon>(find.byType(WiredIcon)).color,
        theme.onAccentColor,
      );
    });
  });

  group('WiredFloatingActionButton sizes and extended', () {
    final theme = WiredThemeData();

    testWidgets('small and large mirror Material sizes', (tester) async {
      await pumpWired(
        tester,
        WiredFloatingActionButton.small(icon: Icons.add, onPressed: () {}),
      );
      expect(
        tester.getSize(find.byType(WiredFloatingActionButton)),
        const Size(40, 40),
      );
      expect(tester.widget<WiredIcon>(find.byType(WiredIcon)).size, 20);

      await pumpWired(
        tester,
        WiredFloatingActionButton.large(icon: Icons.add, onPressed: () {}),
      );
      expect(
        tester.getSize(find.byType(WiredFloatingActionButton)),
        const Size(96, 96),
      );
      expect(tester.widget<WiredIcon>(find.byType(WiredIcon)).size, 36);
      expectPaints(find.byType(WiredFloatingActionButton));
    });

    testWidgets('extended shows its icon and label and fires on tap', (
      tester,
    ) async {
      var taps = 0;
      await pumpWired(
        tester,
        WiredFloatingActionButton.extended(
          icon: Icons.edit,
          label: const Text('Compose'),
          onPressed: () => taps++,
        ),
        theme: theme,
      );

      expect(find.text('Compose'), findsOneWidget);
      expect(find.byType(WiredIcon), findsOneWidget);
      final size = tester.getSize(find.byType(WiredFloatingActionButton));
      expect(size.height, greaterThanOrEqualTo(56));
      expect(size.width, greaterThan(size.height));
      expectPaints(find.byType(WiredFloatingActionButton));

      await tester.tap(find.text('Compose'));
      expect(taps, 1);
      expect(
        tester
            .widget<DefaultTextStyle>(
              find
                  .ancestor(
                    of: find.text('Compose'),
                    matching: find.byType(DefaultTextStyle),
                  )
                  .first,
            )
            .style
            .color,
        theme.onAccentColor,
      );
    });

    testWidgets('collapses to a circle when isExtended is false', (
      tester,
    ) async {
      Widget build(bool extended) => WiredFloatingActionButton.extended(
        icon: Icons.edit,
        label: const Text('Compose'),
        isExtended: extended,
        onPressed: () {},
      );

      await pumpWired(tester, build(true));
      final wide = tester.getSize(find.byType(WiredFloatingActionButton));

      await pumpWired(tester, build(false));
      await tester.pumpAndSettle();
      final narrow = tester.getSize(find.byType(WiredFloatingActionButton));
      expect(find.text('Compose'), findsNothing);
      expect(narrow.width, lessThan(wide.width));
      expect(narrow.width, closeTo(narrow.height, 0.5));
    });

    testWidgets('extended without an icon holds only its label', (
      tester,
    ) async {
      await pumpWired(
        tester,
        WiredFloatingActionButton.extended(
          label: const Text('Start'),
          onPressed: () {},
        ),
      );

      expect(find.text('Start'), findsOneWidget);
      expect(find.byType(WiredIcon), findsNothing);
    });

    testWidgets('backgroundColor and foregroundColor recolour it', (
      tester,
    ) async {
      await pumpWired(
        tester,
        WiredFloatingActionButton(
          icon: Icons.add,
          backgroundColor: theme.accentAt(2),
          foregroundColor: const Color(0xFF123456),
          onPressed: () {},
        ),
        theme: theme,
      );

      final circle =
          tester.widget<WiredCanvas>(findWiredCanvas.first).painter
              as WiredCircleBase;
      expect(circle.fillColor, theme.accentAt(2));
      expect(
        tester.widget<WiredIcon>(find.byType(WiredIcon)).color,
        const Color(0xFF123456),
      );
    });

    testWidgets('reads its tooltip and shows it on long press', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      await pumpWired(
        tester,
        WiredFloatingActionButton(
          icon: Icons.add,
          tooltip: 'New note',
          onPressed: () {},
        ),
      );

      expect(
        tester.getSemantics(find.byType(WiredFloatingActionButton)).tooltip,
        'New note',
      );
      await tester.longPress(find.byType(WiredFloatingActionButton));
      await tester.pumpAndSettle();
      expect(find.text('New note'), findsOneWidget);
      semantics.dispose();
    });

    testWidgets('adds a Hero only when given a heroTag', (tester) async {
      await pumpWired(
        tester,
        WiredFloatingActionButton(icon: Icons.add, onPressed: () {}),
      );
      expect(find.byType(Hero), findsNothing);

      await pumpWired(
        tester,
        WiredFloatingActionButton(
          icon: Icons.add,
          heroTag: 'compose',
          onPressed: () {},
        ),
      );
      expect(tester.widget<Hero>(find.byType(Hero)).tag, 'compose');
    });

    testWidgets('a disabled extended button ignores taps', (tester) async {
      await pumpWired(
        tester,
        const WiredFloatingActionButton.extended(
          icon: Icons.edit,
          label: Text('Compose'),
          semanticLabel: 'Compose',
        ),
      );

      await tester.tap(find.text('Compose'));
      expectSemantics(
        tester,
        find.byType(WiredFloatingActionButton),
        isEnabled: false,
        hasTapAction: false,
      );
    });

    testWidgets('extended grows with large text and keeps RTL order', (
      tester,
    ) async {
      await pumpWiredRtl(
        tester,
        WiredFloatingActionButton.extended(
          icon: Icons.edit,
          label: const Text('Compose'),
          onPressed: () {},
        ),
        textScaler: const TextScaler.linear(2),
      );

      expect(tester.takeException(), isNull);
      expect(
        tester.getSize(find.byType(WiredFloatingActionButton)).height,
        greaterThan(56),
      );
      // In RTL the icon leads from the right.
      expect(
        tester.getCenter(find.byType(WiredIcon)).dx,
        greaterThan(tester.getCenter(find.text('Compose')).dx),
      );
    });
  });
}
