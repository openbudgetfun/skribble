import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';

import '../helpers/pump_app.dart';

void main() {
  group('WiredFilterChip', () {
    testWidgets('renders without error', (tester) async {
      await pumpApp(tester, WiredFilterChip(label: const Text('Filter')));

      expect(find.byType(WiredFilterChip), findsOneWidget);
    });

    testWidgets('renders label text', (tester) async {
      await pumpApp(tester, WiredFilterChip(label: const Text('My Filter')));

      expect(find.text('My Filter'), findsOneWidget);
    });

    testWidgets('shows check icon when selected', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WiredFilterChip(label: const Text('Filter'), selected: true),
          ),
        ),
      );

      expect(find.byIcon(Icons.check), findsOneWidget);
    });

    testWidgets('does not show check icon when not selected', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WiredFilterChip(label: const Text('Filter'), selected: false),
          ),
        ),
      );

      expect(find.byIcon(Icons.check), findsNothing);
    });

    testWidgets('calls onSelected with toggled value when tapped', (
      tester,
    ) async {
      bool? receivedValue;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WiredFilterChip(
              label: const Text('Filter'),
              selected: false,
              onSelected: (v) => receivedValue = v,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(WiredFilterChip));
      await tester.pump();

      expect(receivedValue, isTrue);
    });

    testWidgets('calls onSelected with false when already selected', (
      tester,
    ) async {
      bool? receivedValue;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WiredFilterChip(
              label: const Text('Filter'),
              selected: true,
              onSelected: (v) => receivedValue = v,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(WiredFilterChip));
      await tester.pump();

      expect(receivedValue, isFalse);
    });

    testWidgets('does not crash when onSelected is null', (tester) async {
      await pumpApp(tester, WiredFilterChip(label: const Text('Filter')));

      // Tapping should not throw even with null onSelected.
      await tester.tap(find.byType(WiredFilterChip));
      await tester.pump();

      expect(find.byType(WiredFilterChip), findsOneWidget);
    });

    testWidgets('contains WiredCanvas for the rounded rectangle border', (
      tester,
    ) async {
      await pumpApp(tester, WiredFilterChip(label: const Text('Filter')));

      expect(
        find.descendant(
          of: find.byType(WiredFilterChip),
          matching: find.byType(WiredCanvas),
        ),
        findsOneWidget,
      );
    });

    testWidgets('has correct height of 32', (tester) async {
      await pumpApp(tester, WiredFilterChip(label: const Text('Filter')));

      final sizedBox = tester.widget<SizedBox>(
        find
            .descendant(
              of: find.byType(WiredFilterChip),
              matching: find.byType(SizedBox),
            )
            .first,
      );

      expect(sizedBox.height, 32);
    });

    testWidgets('contains GestureDetector for tap handling', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WiredFilterChip(
              label: const Text('Filter'),
              onSelected: (_) {},
            ),
          ),
        ),
      );

      expect(
        find.descendant(
          of: find.byType(WiredFilterChip),
          matching: find.byType(GestureDetector),
        ),
        findsOneWidget,
      );
    });

    testWidgets('contains RepaintBoundary wrapper', (tester) async {
      await pumpApp(tester, WiredFilterChip(label: const Text('Filter')));

      expect(
        find.descendant(
          of: find.byType(WiredFilterChip),
          matching: find.byType(RepaintBoundary),
        ),
        findsOneWidget,
      );
    });

    testWidgets('property defaults are correct', (tester) async {
      const chip = WiredFilterChip(label: Text('Filter'));

      expect(chip.selected, isFalse);
      expect(chip.onSelected, isNull);
    });

    testWidgets('renders correctly when selected is true', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WiredFilterChip(label: const Text('Active'), selected: true),
          ),
        ),
      );

      expect(find.byType(WiredFilterChip), findsOneWidget);
      expect(find.text('Active'), findsOneWidget);
      expect(find.byIcon(Icons.check), findsOneWidget);
    });

    testWidgets('renders correctly when selected is false', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WiredFilterChip(
              label: const Text('Inactive'),
              selected: false,
            ),
          ),
        ),
      );

      expect(find.byType(WiredFilterChip), findsOneWidget);
      expect(find.text('Inactive'), findsOneWidget);
      expect(find.byIcon(Icons.check), findsNothing);
    });
  });
}
