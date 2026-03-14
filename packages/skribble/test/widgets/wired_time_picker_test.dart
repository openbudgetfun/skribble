import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';

import '../helpers/finders.dart';
import '../helpers/pump_app.dart';

void main() {
  group('WiredTimePicker', () {
    Widget buildTimePicker({
      TimeOfDay? initialTime,
      ValueChanged<TimeOfDay>? onTimeSelected,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 400,
              height: 400,
              child: WiredTimePicker(
                initialTime: initialTime,
                onTimeSelected: onTimeSelected,
              ),
            ),
          ),
        ),
      );
    }

    testWidgets('renders without error', (tester) async {
      await tester.pumpWidget(buildTimePicker());
      await tester.pumpAndSettle();

      expect(find.byType(WiredTimePicker), findsOneWidget);
    });

    testWidgets('contains RepaintBoundary wrapper', (tester) async {
      await tester.pumpWidget(buildTimePicker());
      await tester.pumpAndSettle();

      // WiredTimePicker uses buildWiredElement which wraps in
      // RepaintBoundary.
      expect(
        find.descendant(
          of: find.byType(WiredTimePicker),
          matching: findRepaintBoundary,
        ),
        findsOneWidget,
      );
    });

    testWidgets('displays initial time', (tester) async {
      await tester.pumpWidget(
        buildTimePicker(initialTime: const TimeOfDay(hour: 14, minute: 30)),
      );
      await tester.pumpAndSettle();

      // The hour and minute are displayed as zero-padded two-digit strings.
      expect(find.text('14'), findsOneWidget);
      expect(find.text('30'), findsOneWidget);
    });

    testWidgets('displays colon separator between hour and minute', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTimePicker(initialTime: const TimeOfDay(hour: 9, minute: 5)),
      );
      await tester.pumpAndSettle();

      expect(find.text(' : '), findsOneWidget);
    });

    testWidgets('displays zero-padded hours and minutes', (tester) async {
      await tester.pumpWidget(
        buildTimePicker(initialTime: const TimeOfDay(hour: 3, minute: 7)),
      );
      await tester.pumpAndSettle();

      // Single digit values should be zero-padded.
      expect(find.text('03'), findsOneWidget);
      expect(find.text('07'), findsOneWidget);
    });

    testWidgets('property defaults: initialTime and onTimeSelected are null', (
      tester,
    ) async {
      await pumpApp(
        tester,
        Center(
          child: SizedBox(width: 400, height: 400, child: WiredTimePicker()),
        ),
      );
      await tester.pumpAndSettle();

      final widget = tester.widget<WiredTimePicker>(
        find.byType(WiredTimePicker),
      );
      expect(widget.initialTime, isNull);
      expect(widget.onTimeSelected, isNull);
    });

    testWidgets('has correct inner dimensions (280x340)', (tester) async {
      await tester.pumpWidget(buildTimePicker());
      await tester.pumpAndSettle();

      // The WiredTimePicker wraps content in a SizedBox(280, 340) inside
      // RepaintBoundary.
      final sizedBoxFinder = find.descendant(
        of: find.byType(WiredTimePicker),
        matching: find.byWidgetPredicate(
          (w) => w is SizedBox && w.width == 280 && w.height == 340,
        ),
      );
      expect(sizedBoxFinder, findsOneWidget);
    });

    testWidgets('contains WiredCanvas widgets for clock face and time fields', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTimePicker(initialTime: const TimeOfDay(hour: 10, minute: 30)),
      );
      await tester.pumpAndSettle();

      // There should be WiredCanvas widgets: 2 for time fields (hour/minute
      // rectangles), 1 for clock face circle, and 1 for center dot = 4
      // minimum.
      expect(
        find.descendant(
          of: find.byType(WiredTimePicker),
          matching: findWiredCanvas,
        ),
        findsAtLeast(4),
      );
    });

    testWidgets('contains CustomPaint for clock hands', (tester) async {
      await tester.pumpWidget(
        buildTimePicker(initialTime: const TimeOfDay(hour: 10, minute: 30)),
      );
      await tester.pumpAndSettle();

      // The clock face renders two CustomPaint widgets for the hour and
      // minute hands.
      expect(
        find.descendant(
          of: find.byType(WiredTimePicker),
          matching: findCustomPaint,
        ),
        findsAtLeast(2),
      );
    });

    testWidgets('contains GestureDetector for time field interaction', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTimePicker(initialTime: const TimeOfDay(hour: 10, minute: 30)),
      );
      await tester.pumpAndSettle();

      // There should be at least 2 GestureDetectors for the hour and minute
      // fields.
      expect(
        find.descendant(
          of: find.byType(WiredTimePicker),
          matching: find.byType(GestureDetector),
        ),
        findsAtLeast(2),
      );
    });

    testWidgets('renders with midnight time (00:00)', (tester) async {
      await tester.pumpWidget(
        buildTimePicker(initialTime: const TimeOfDay(hour: 0, minute: 0)),
      );
      await tester.pumpAndSettle();

      expect(find.text('00'), findsNWidgets(2));
    });

    testWidgets('renders with max time (23:59)', (tester) async {
      await tester.pumpWidget(
        buildTimePicker(initialTime: const TimeOfDay(hour: 23, minute: 59)),
      );
      await tester.pumpAndSettle();

      expect(find.text('23'), findsOneWidget);
      expect(find.text('59'), findsOneWidget);
    });
  });
}
