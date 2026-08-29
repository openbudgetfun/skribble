import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';

import '../helpers/finders.dart';
import '../helpers/pump_app.dart';

void main() {
  group('WiredMenuBar', () {
    testWidgets('renders menu bar with children', (tester) async {
      await pumpApp(
        tester,
        WiredMenuBar(
          children: [
            WiredSubmenuButton(
              menuChildren: [
                WiredMenuItemButton(onPressed: () {}, child: const Text('New')),
                WiredMenuItemButton(
                  onPressed: () {},
                  child: const Text('Open'),
                ),
              ],
              child: const Text('File'),
            ),
          ],
        ),
      );

      expect(find.byType(WiredMenuBar), findsOneWidget);
      expect(find.text('File'), findsOneWidget);
      expect(find.byType(RepaintBoundary), findsWidgets);
    });

    testWidgets('opens submenu on tap', (tester) async {
      await pumpApp(
        tester,
        WiredMenuBar(
          children: [
            WiredSubmenuButton(
              menuChildren: [
                WiredMenuItemButton(onPressed: () {}, child: const Text('Cut')),
                WiredMenuItemButton(
                  onPressed: () {},
                  child: const Text('Copy'),
                ),
              ],
              child: const Text('Edit'),
            ),
          ],
        ),
      );

      await tester.tap(find.text('Edit'));
      await tester.pumpAndSettle();

      expect(find.text('Cut'), findsOneWidget);
      expect(find.text('Copy'), findsOneWidget);
    });

    testWidgets('calls onPressed for menu item', (tester) async {
      var pressed = false;

      await pumpApp(
        tester,
        WiredMenuBar(
          children: [
            WiredSubmenuButton(
              menuChildren: [
                WiredMenuItemButton(
                  onPressed: () => pressed = true,
                  child: const Text('Save'),
                ),
              ],
              child: const Text('File'),
            ),
          ],
        ),
      );

      await tester.tap(find.text('File'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(pressed, isTrue);
    });
  });

  group('WiredDropdownMenu', () {
    testWidgets('renders with entries', (tester) async {
      await pumpApp(
        tester,
        SizedBox(
          width: 300,
          child: WiredDropdownMenu<String>(
            dropdownMenuEntries: const [
              DropdownMenuEntry(value: 'a', label: 'Alpha'),
              DropdownMenuEntry(value: 'b', label: 'Beta'),
            ],
            hintText: 'Select',
          ),
        ),
      );

      expect(find.byType(WiredDropdownMenu<String>), findsOneWidget);
      expect(find.byType(DropdownMenu<String>), findsOneWidget);
    });

    testWidgets('calls onSelected when item tapped', (tester) async {
      String? selected;

      await pumpApp(
        tester,
        SizedBox(
          width: 300,
          child: WiredDropdownMenu<String>(
            width: 300,
            dropdownMenuEntries: const [
              DropdownMenuEntry(value: 'x', label: 'X-ray'),
              DropdownMenuEntry(value: 'y', label: 'Yankee'),
            ],
            onSelected: (v) => selected = v,
          ),
        ),
      );

      // Tap the dropdown to open it
      await tester.tap(find.byType(DropdownMenu<String>));
      await tester.pumpAndSettle();

      // Tap an option
      await tester.tap(find.text('Yankee').last);
      await tester.pumpAndSettle();

      expect(selected, 'y');
    });

    testWidgets('renders with initial selection', (tester) async {
      await pumpApp(
        tester,
        SizedBox(
          width: 300,
          child: WiredDropdownMenu<String>(
            initialSelection: 'b',
            dropdownMenuEntries: const [
              DropdownMenuEntry(value: 'a', label: 'Alpha'),
              DropdownMenuEntry(value: 'b', label: 'Beta'),
            ],
          ),
        ),
      );

      expect(find.byType(WiredDropdownMenu<String>), findsOneWidget);
    });

    testWidgets('renders within WiredTheme', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: WiredTheme(
            data: WiredThemeData(borderColor: Colors.lime),
            child: Scaffold(
              body: WiredMenuBar(
                children: [
                  WiredSubmenuButton(
                    menuChildren: [
                      WiredMenuItemButton(
                        onPressed: () {},
                        child: const Text('Item'),
                      ),
                    ],
                    child: const Text('Menu'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      expect(find.text('Menu'), findsOneWidget);
    });
  });

  group('WiredCheckboxMenuButton', () {
    Future<void> openMenu(WidgetTester tester, Widget menuChild) async {
      await pumpApp(
        tester,
        WiredMenuBar(
          children: [
            WiredSubmenuButton(
              menuChildren: [menuChild],
              child: const Text('View'),
            ),
          ],
        ),
      );
      await tester.tap(find.text('View'));
      await tester.pumpAndSettle();
    }

    testWidgets('renders inside menu with label', (tester) async {
      await openMenu(
        tester,
        WiredCheckboxMenuButton(
          value: false,
          onChanged: (_) {},
          child: const Text('Show rulers'),
        ),
      );

      expect(find.byType(WiredCheckboxMenuButton), findsOneWidget);
      expect(find.text('Show rulers'), findsOneWidget);
    });

    testWidgets('tapping calls onChanged with true when unchecked', (
      tester,
    ) async {
      bool? reported;

      await openMenu(
        tester,
        WiredCheckboxMenuButton(
          value: false,
          onChanged: (v) => reported = v,
          child: const Text('Toggle'),
        ),
      );

      await tester.tap(find.text('Toggle'));
      await tester.pumpAndSettle();

      expect(reported, isTrue);
    });

    testWidgets('tapping calls onChanged with false when checked', (
      tester,
    ) async {
      bool? reported;

      await openMenu(
        tester,
        WiredCheckboxMenuButton(
          value: true,
          onChanged: (v) => reported = v,
          child: const Text('Toggle'),
        ),
      );

      await tester.tap(find.text('Toggle'));
      await tester.pumpAndSettle();

      expect(reported, isFalse);
    });

    testWidgets('tristate cycles null to true', (tester) async {
      bool? reported;

      await openMenu(
        tester,
        WiredCheckboxMenuButton(
          tristate: true,
          value: null,
          onChanged: (v) => reported = v,
          child: const Text('Tri'),
        ),
      );

      await tester.tap(find.text('Tri'));
      await tester.pumpAndSettle();

      expect(reported, isTrue);
    });

    testWidgets('tristate cycles true back to null', (tester) async {
      bool? reported;

      await openMenu(
        tester,
        WiredCheckboxMenuButton(
          tristate: true,
          value: true,
          onChanged: (v) => reported = v,
          child: const Text('Tri'),
        ),
      );
      await tester.tap(find.text('Tri'));
      await tester.pumpAndSettle();

      expect(reported, isNull);
    });

    testWidgets('menu stays open by default after activation', (tester) async {
      await openMenu(
        tester,
        WiredCheckboxMenuButton(
          value: false,
          onChanged: (_) {},
          child: const Text('Stay'),
        ),
      );

      await tester.tap(find.text('Stay'));
      await tester.pumpAndSettle();

      expect(find.text('Stay'), findsOneWidget);
    });

    testWidgets('closes menu when closeOnActivate is true', (tester) async {
      await openMenu(
        tester,
        WiredCheckboxMenuButton(
          value: false,
          onChanged: (_) {},
          closeOnActivate: true,
          child: const Text('Dismiss'),
        ),
      );

      await tester.tap(find.text('Dismiss'));
      await tester.pumpAndSettle();

      expect(find.text('Dismiss'), findsNothing);
    });

    testWidgets('renders leading rough checkbox icon', (tester) async {
      await openMenu(
        tester,
        WiredCheckboxMenuButton(
          value: true,
          onChanged: (_) {},
          child: const Text('Checked item'),
        ),
      );

      final checkbox = tester.widget<Checkbox>(find.byType(Checkbox));
      expect(checkbox.value, isTrue);
      // The icon is framed by a rough hand-drawn border
      // (RoughBoxDecoration), not a WiredCanvas like the radio icon.
      expect(
        find.descendant(
          of: find.byType(WiredCheckboxMenuButton),
          matching: findWiredCanvas,
        ),
        findsNothing,
      );
    });

    testWidgets('disabled without onChanged', (tester) async {
      await openMenu(
        tester,
        WiredCheckboxMenuButton(
          value: false,
          onChanged: null,
          child: const Text('Disabled'),
        ),
      );

      final item = tester.widget<MenuItemButton>(find.byType(MenuItemButton));
      expect(item.onPressed, isNull);
    });
  });

  group('WiredRadioMenuButton', () {
    Future<void> openMenu(WidgetTester tester, Widget menuChild) async {
      await pumpApp(
        tester,
        WiredMenuBar(
          children: [
            WiredSubmenuButton(
              menuChildren: [menuChild],
              child: const Text('Theme'),
            ),
          ],
        ),
      );
      await tester.tap(find.text('Theme'));
      await tester.pumpAndSettle();
    }

    testWidgets('renders inside menu with label', (tester) async {
      await openMenu(
        tester,
        WiredRadioMenuButton<String>(
          value: 'light',
          groupValue: 'light',
          onChanged: (_) {},
          child: const Text('Light'),
        ),
      );

      expect(find.text('Light'), findsOneWidget);
      expect(find.byType(WiredRadioMenuButton<String>), findsOneWidget);
    });

    testWidgets('selected item reports checked semantics', (tester) async {
      await openMenu(
        tester,
        WiredRadioMenuButton<String>(
          value: 'light',
          groupValue: 'light',
          onChanged: (_) {},
          child: const Text('Light'),
        ),
      );

      final checkedSemantics = find.descendant(
        of: find.byType(WiredRadioMenuButton<String>),
        matching: find.byWidgetPredicate(
          (widget) =>
              widget is Semantics && (widget.properties.checked ?? false),
        ),
      );
      expect(checkedSemantics, findsOneWidget);
    });

    testWidgets('unselected item is not checked', (tester) async {
      await openMenu(
        tester,
        WiredRadioMenuButton<String>(
          value: 'dark',
          groupValue: 'light',
          onChanged: (_) {},
          child: const Text('Dark'),
        ),
      );

      final checkedSemantics = find.descendant(
        of: find.byType(WiredRadioMenuButton<String>),
        matching: find.byWidgetPredicate(
          (widget) =>
              widget is Semantics && (widget.properties.checked ?? false),
        ),
      );
      expect(checkedSemantics, findsNothing);
    });

    testWidgets('tapping unselected item selects it and closes menu', (
      tester,
    ) async {
      String? reported;

      await openMenu(
        tester,
        WiredRadioMenuButton<String>(
          value: 'dark',
          groupValue: 'light',
          onChanged: (v) => reported = v,
          child: const Text('Dark'),
        ),
      );

      await tester.tap(find.text('Dark'));
      await tester.pumpAndSettle();

      expect(reported, 'dark');
      expect(find.text('Dark'), findsNothing);
    });

    testWidgets('stays open when closeOnActivate is false', (tester) async {
      await openMenu(
        tester,
        WiredRadioMenuButton<String>(
          value: 'dark',
          groupValue: 'light',
          closeOnActivate: false,
          onChanged: (_) {},
          child: const Text('Dark'),
        ),
      );

      await tester.tap(find.text('Dark'));
      await tester.pumpAndSettle();

      expect(find.text('Dark'), findsOneWidget);
    });

    testWidgets('toggleable selection toggles selected item off', (
      tester,
    ) async {
      String? reported;

      await openMenu(
        tester,
        WiredRadioMenuButton<String>(
          value: 'light',
          groupValue: 'light',
          toggleable: true,
          closeOnActivate: false,
          onChanged: (v) => reported = v,
          child: const Text('Light'),
        ),
      );

      await tester.tap(find.text('Light'));
      await tester.pumpAndSettle();

      expect(reported, isNull);
    });

    testWidgets('disabled without onChanged', (tester) async {
      await openMenu(
        tester,
        WiredRadioMenuButton<String>(
          value: 'dark',
          groupValue: 'light',
          onChanged: null,
          child: const Text('Dark'),
        ),
      );

      final item = tester.widget<MenuItemButton>(find.byType(MenuItemButton));
      expect(item.onPressed, isNull);
    });

    testWidgets('draws hand-drawn radio icon', (tester) async {
      await openMenu(
        tester,
        WiredRadioMenuButton<String>(
          value: 'dark',
          groupValue: 'dark',
          onChanged: (_) {},
          child: const Text('Dark'),
        ),
      );

      // The leading icon paints a rough circle via WiredCanvas: the outer
      // ring and the hachure-filled inner dot when selected.
      expect(
        find.descendant(
          of: find.byType(WiredRadioMenuButton<String>),
          matching: findWiredCanvas,
        ),
        findsNWidgets(2),
      );
    });
  });
}
