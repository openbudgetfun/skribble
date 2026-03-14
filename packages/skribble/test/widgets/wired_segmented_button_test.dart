import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';

import '../helpers/pump_app.dart';

void main() {
  group('WiredSegmentedButton', () {
    final segments = [
      WiredButtonSegment<String>(value: 'a', label: const Text('Alpha')),
      WiredButtonSegment<String>(value: 'b', label: const Text('Beta')),
      WiredButtonSegment<String>(value: 'c', label: const Text('Gamma')),
    ];

    testWidgets('renders without error', (tester) async {
      await pumpApp(
        tester,
        WiredSegmentedButton<String>(segments: segments, selected: const {'a'}),
      );

      expect(find.byType(WiredSegmentedButton<String>), findsOneWidget);
    });

    testWidgets('renders all segment labels', (tester) async {
      await pumpApp(
        tester,
        WiredSegmentedButton<String>(segments: segments, selected: const {'a'}),
      );

      expect(find.text('Alpha'), findsOneWidget);
      expect(find.text('Beta'), findsOneWidget);
      expect(find.text('Gamma'), findsOneWidget);
    });

    testWidgets('calls onSelectionChanged with new selection on tap', (
      tester,
    ) async {
      Set<String>? receivedSelection;

      await pumpApp(
        tester,
        WiredSegmentedButton<String>(
          segments: segments,
          selected: const {'a'},
          onSelectionChanged: (s) => receivedSelection = s,
        ),
      );

      // Tap the second segment ('Beta').
      await tester.tap(find.text('Beta'));
      await tester.pump();

      expect(receivedSelection, isNotNull);
      expect(receivedSelection, contains('b'));
      // In single-selection mode, only the tapped segment should be selected.
      expect(receivedSelection!.length, 1);
    });

    testWidgets('single selection mode clears previous selection on new tap', (
      tester,
    ) async {
      Set<String>? receivedSelection;

      await pumpApp(
        tester,
        WiredSegmentedButton<String>(
          segments: segments,
          selected: const {'a'},
          multiSelectionEnabled: false,
          onSelectionChanged: (s) => receivedSelection = s,
        ),
      );

      await tester.tap(find.text('Gamma'));
      await tester.pump();

      expect(receivedSelection, equals({'c'}));
    });

    testWidgets('multi-selection mode adds to selection', (tester) async {
      Set<String>? receivedSelection;

      await pumpApp(
        tester,
        WiredSegmentedButton<String>(
          segments: segments,
          selected: const {'a'},
          multiSelectionEnabled: true,
          onSelectionChanged: (s) => receivedSelection = s,
        ),
      );

      await tester.tap(find.text('Beta'));
      await tester.pump();

      expect(receivedSelection, contains('a'));
      expect(receivedSelection, contains('b'));
      expect(receivedSelection!.length, 2);
    });

    testWidgets('multi-selection mode removes from selection on re-tap', (
      tester,
    ) async {
      Set<String>? receivedSelection;

      await pumpApp(
        tester,
        WiredSegmentedButton<String>(
          segments: segments,
          selected: const {'a', 'b'},
          multiSelectionEnabled: true,
          onSelectionChanged: (s) => receivedSelection = s,
        ),
      );

      // Tap 'Alpha' which is already selected, should remove it.
      await tester.tap(find.text('Alpha'));
      await tester.pump();

      expect(receivedSelection, equals({'b'}));
    });

    testWidgets('does not crash when onSelectionChanged is null', (
      tester,
    ) async {
      await pumpApp(
        tester,
        WiredSegmentedButton<String>(segments: segments, selected: const {'a'}),
      );

      // Tapping should not throw.
      await tester.tap(find.text('Beta'));
      await tester.pump();

      expect(find.byType(WiredSegmentedButton<String>), findsOneWidget);
    });

    testWidgets('renders segment icons when provided', (tester) async {
      final segmentsWithIcons = [
        WiredButtonSegment<String>(
          value: 'a',
          label: const Text('Home'),
          icon: Icons.home,
        ),
        WiredButtonSegment<String>(
          value: 'b',
          label: const Text('Work'),
          icon: Icons.work,
        ),
      ];

      await pumpApp(
        tester,
        WiredSegmentedButton<String>(
          segments: segmentsWithIcons,
          selected: const {'a'},
        ),
      );

      expect(find.byIcon(Icons.home), findsOneWidget);
      expect(find.byIcon(Icons.work), findsOneWidget);
    });

    testWidgets('does not render icons when not provided', (tester) async {
      await pumpApp(
        tester,
        WiredSegmentedButton<String>(segments: segments, selected: const {'a'}),
      );

      // No icons should be present since segments don't define any.
      expect(
        find.descendant(
          of: find.byType(WiredSegmentedButton<String>),
          matching: find.byType(Icon),
        ),
        findsNothing,
      );
    });

    testWidgets('has correct height of 42', (tester) async {
      await pumpApp(
        tester,
        WiredSegmentedButton<String>(segments: segments, selected: const {'a'}),
      );

      final sizedBox = tester.widget<SizedBox>(
        find
            .descendant(
              of: find.byType(WiredSegmentedButton<String>),
              matching: find.byType(SizedBox),
            )
            .first,
      );

      expect(sizedBox.height, 42.0);
    });

    testWidgets('contains WiredCanvas for the outer border', (tester) async {
      await pumpApp(
        tester,
        WiredSegmentedButton<String>(segments: segments, selected: const {'a'}),
      );

      // Should have WiredCanvas widgets for the outer border and dividers.
      expect(
        find.descendant(
          of: find.byType(WiredSegmentedButton<String>),
          matching: find.byType(WiredCanvas),
        ),
        findsAtLeast(1),
      );
    });

    testWidgets('contains RepaintBoundary wrapper', (tester) async {
      await pumpApp(
        tester,
        WiredSegmentedButton<String>(segments: segments, selected: const {'a'}),
      );

      expect(
        find.descendant(
          of: find.byType(WiredSegmentedButton<String>),
          matching: find.byType(RepaintBoundary),
        ),
        findsOneWidget,
      );
    });

    testWidgets('property defaults are correct', (tester) async {
      final button = WiredSegmentedButton<String>(
        segments: segments,
        selected: const {'a'},
      );

      expect(button.multiSelectionEnabled, isFalse);
      expect(button.onSelectionChanged, isNull);
    });

    testWidgets('works with int generic type', (tester) async {
      Set<int>? receivedSelection;

      final intSegments = [
        WiredButtonSegment<int>(value: 1, label: const Text('One')),
        WiredButtonSegment<int>(value: 2, label: const Text('Two')),
      ];

      await pumpApp(
        tester,
        WiredSegmentedButton<int>(
          segments: intSegments,
          selected: const {1},
          onSelectionChanged: (s) => receivedSelection = s,
        ),
      );

      await tester.tap(find.text('Two'));
      await tester.pump();

      expect(receivedSelection, equals({2}));
    });

    testWidgets('renders dividers between segments', (tester) async {
      await pumpApp(
        tester,
        WiredSegmentedButton<String>(segments: segments, selected: const {'a'}),
      );

      // With 3 segments, there should be 2 dividers (WiredLineBase)
      // plus the outer rectangle, totaling at least 3 WiredCanvas widgets.
      expect(
        find.descendant(
          of: find.byType(WiredSegmentedButton<String>),
          matching: find.byType(WiredCanvas),
        ),
        findsAtLeast(3),
      );
    });
  });
}
