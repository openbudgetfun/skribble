import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';

void main() {
  group('WiredMenuBar', () {
    testWidgets('renders menu bar with children', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WiredMenuBar(
              children: [
                WiredSubmenuButton(
                  child: const Text('File'),
                  menuChildren: [
                    WiredMenuItemButton(
                      onPressed: () {},
                      child: const Text('New'),
                    ),
                    WiredMenuItemButton(
                      onPressed: () {},
                      child: const Text('Open'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(WiredMenuBar), findsOneWidget);
      expect(find.text('File'), findsOneWidget);
      expect(find.byType(RepaintBoundary), findsWidgets);
    });

    testWidgets('opens submenu on tap', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WiredMenuBar(
              children: [
                WiredSubmenuButton(
                  child: const Text('Edit'),
                  menuChildren: [
                    WiredMenuItemButton(
                      onPressed: () {},
                      child: const Text('Cut'),
                    ),
                    WiredMenuItemButton(
                      onPressed: () {},
                      child: const Text('Copy'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );

      await tester.tap(find.text('Edit'));
      await tester.pumpAndSettle();

      expect(find.text('Cut'), findsOneWidget);
      expect(find.text('Copy'), findsOneWidget);
    });

    testWidgets('calls onPressed for menu item', (tester) async {
      var pressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WiredMenuBar(
              children: [
                WiredSubmenuButton(
                  child: const Text('File'),
                  menuChildren: [
                    WiredMenuItemButton(
                      onPressed: () => pressed = true,
                      child: const Text('Save'),
                    ),
                  ],
                ),
              ],
            ),
          ),
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
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 300,
              child: WiredDropdownMenu<String>(
                dropdownMenuEntries: const [
                  DropdownMenuEntry(value: 'a', label: 'Alpha'),
                  DropdownMenuEntry(value: 'b', label: 'Beta'),
                ],
                hintText: 'Select',
              ),
            ),
          ),
        ),
      );

      expect(find.byType(WiredDropdownMenu<String>), findsOneWidget);
      expect(find.byType(DropdownMenu<String>), findsOneWidget);
    });

    testWidgets('calls onSelected when item tapped', (tester) async {
      String? selected;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
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
  });
}
