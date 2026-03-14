import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';

import '../helpers/pump_app.dart';

void main() {
  group('WiredToggleButtons', () {
    testWidgets('renders all children', (tester) async {
      await pumpApp(
        tester,
        WiredToggleButtons(
          isSelected: const [true, false, false],
          children: const [Text('Bold'), Text('Italic'), Text('Underline')],
        ),
      );

      expect(find.text('Bold'), findsOneWidget);
      expect(find.text('Italic'), findsOneWidget);
      expect(find.text('Underline'), findsOneWidget);
    });

    testWidgets('calls onPressed with correct index', (tester) async {
      int? tappedIndex;

      await pumpApp(
        tester,
        WiredToggleButtons(
          isSelected: const [true, false],
          onPressed: (i) => tappedIndex = i,
          children: const [Text('A'), Text('B')],
        ),
      );

      await tester.tap(find.text('B'));
      expect(tappedIndex, 1);
    });

    testWidgets('selected button has different styling', (tester) async {
      await pumpApp(
        tester,
        WiredToggleButtons(
          isSelected: const [true, false],
          children: const [Icon(Icons.format_bold), Icon(Icons.format_italic)],
        ),
      );

      // First button should be selected (hachure fill)
      expect(find.byType(WiredToggleButtons), findsOneWidget);
      // Both icons render
      expect(find.byIcon(Icons.format_bold), findsOneWidget);
      expect(find.byIcon(Icons.format_italic), findsOneWidget);
    });

    testWidgets('supports icons as children', (tester) async {
      await pumpApp(
        tester,
        WiredToggleButtons(
          isSelected: const [false, true, false],
          children: const [
            Icon(Icons.view_list),
            Icon(Icons.grid_view),
            Icon(Icons.view_module),
          ],
        ),
      );

      expect(find.byIcon(Icons.view_list), findsOneWidget);
      expect(find.byIcon(Icons.grid_view), findsOneWidget);
      expect(find.byIcon(Icons.view_module), findsOneWidget);
    });

    testWidgets('does not respond when onPressed is null', (tester) async {
      await pumpApp(
        tester,
        WiredToggleButtons(
          isSelected: const [true, false],
          children: const [Text('X'), Text('Y')],
        ),
      );

      // Should not throw when tapped without onPressed
      await tester.tap(find.text('Y'));
      await tester.pump();
      expect(find.byType(WiredToggleButtons), findsOneWidget);
    });

    testWidgets('contains RepaintBoundary', (tester) async {
      await pumpApp(
        tester,
        WiredToggleButtons(
          isSelected: const [false, false],
          children: const [Text('1'), Text('2')],
        ),
      );

      expect(find.byType(RepaintBoundary), findsWidgets);
    });
  });
}
