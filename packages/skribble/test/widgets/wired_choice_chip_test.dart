import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';

import '../helpers/pump_app.dart';

void main() {
  group('WiredChoiceChip', () {
    testWidgets('renders without error', (tester) async {
      await pumpApp(tester, WiredChoiceChip(label: const Text('Choice')));

      expect(find.byType(WiredChoiceChip), findsOneWidget);
    });

    testWidgets('renders label text', (tester) async {
      await pumpApp(tester, WiredChoiceChip(label: const Text('My Choice')));

      expect(find.text('My Choice'), findsOneWidget);
    });

    testWidgets('calls onSelected with toggled value when tapped', (
      tester,
    ) async {
      bool? receivedValue;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WiredChoiceChip(
              label: const Text('Choice'),
              selected: false,
              onSelected: (v) => receivedValue = v,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(WiredChoiceChip));
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
            body: WiredChoiceChip(
              label: const Text('Choice'),
              selected: true,
              onSelected: (v) => receivedValue = v,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(WiredChoiceChip));
      await tester.pump();

      expect(receivedValue, isFalse);
    });

    testWidgets('does not crash when onSelected is null', (tester) async {
      await pumpApp(tester, WiredChoiceChip(label: const Text('Choice')));

      // Tapping should not throw even with null onSelected.
      await tester.tap(find.byType(WiredChoiceChip));
      await tester.pump();

      expect(find.byType(WiredChoiceChip), findsOneWidget);
    });

    testWidgets('contains WiredCanvas for the rounded rectangle border', (
      tester,
    ) async {
      await pumpApp(tester, WiredChoiceChip(label: const Text('Choice')));

      expect(
        find.descendant(
          of: find.byType(WiredChoiceChip),
          matching: find.byType(WiredCanvas),
        ),
        findsOneWidget,
      );
    });

    testWidgets('has correct height of 32', (tester) async {
      await pumpApp(tester, WiredChoiceChip(label: const Text('Choice')));

      final sizedBox = tester.widget<SizedBox>(
        find
            .descendant(
              of: find.byType(WiredChoiceChip),
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
            body: WiredChoiceChip(
              label: const Text('Choice'),
              onSelected: (_) {},
            ),
          ),
        ),
      );

      expect(
        find.descendant(
          of: find.byType(WiredChoiceChip),
          matching: find.byType(GestureDetector),
        ),
        findsOneWidget,
      );
    });

    testWidgets('contains RepaintBoundary wrapper', (tester) async {
      await pumpApp(tester, WiredChoiceChip(label: const Text('Choice')));

      expect(
        find.descendant(
          of: find.byType(WiredChoiceChip),
          matching: find.byType(RepaintBoundary),
        ),
        findsOneWidget,
      );
    });

    testWidgets('property defaults are correct', (tester) async {
      const chip = WiredChoiceChip(label: Text('Choice'));

      expect(chip.selected, isFalse);
      expect(chip.onSelected, isNull);
    });

    testWidgets('renders correctly when selected is true', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WiredChoiceChip(
              label: const Text('Selected'),
              selected: true,
            ),
          ),
        ),
      );

      // The widget should render without error when selected.
      expect(find.byType(WiredChoiceChip), findsOneWidget);
      expect(find.text('Selected'), findsOneWidget);
    });

    testWidgets('renders correctly when selected is false', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WiredChoiceChip(
              label: const Text('Unselected'),
              selected: false,
            ),
          ),
        ),
      );

      expect(find.byType(WiredChoiceChip), findsOneWidget);
      expect(find.text('Unselected'), findsOneWidget);
    });
  });
}
