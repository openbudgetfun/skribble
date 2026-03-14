import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';

import '../helpers/finders.dart';
import '../helpers/pump_app.dart';

void main() {
  group('WiredCalendarDatePicker', () {
    testWidgets('renders without error', (tester) async {
      await pumpApp(
        tester,
        WiredCalendarDatePicker(
          initialDate: DateTime(2025, 6, 15),
          firstDate: DateTime(2020),
          lastDate: DateTime(2030),
          onDateChanged: (_) {},
        ),
      );

      expect(find.byType(WiredCalendarDatePicker), findsOneWidget);
      expect(find.byType(CalendarDatePicker), findsOneWidget);
      expect(findRepaintBoundary, findsWidgets);
    });

    testWidgets('calls onDateChanged when day tapped', (tester) async {
      DateTime? selected;

      await pumpApp(
        tester,
        WiredCalendarDatePicker(
          initialDate: DateTime(2025, 6, 15),
          firstDate: DateTime(2020),
          lastDate: DateTime(2030),
          onDateChanged: (d) => selected = d,
        ),
      );

      // Tap a visible day number
      await tester.tap(find.text('20'));
      await tester.pumpAndSettle();

      expect(selected, isNotNull);
      expect(selected!.day, 20);
    });

    testWidgets('respects selectableDayPredicate', (tester) async {
      await pumpApp(
        tester,
        WiredCalendarDatePicker(
          initialDate: DateTime(2025, 6, 16),
          firstDate: DateTime(2020),
          lastDate: DateTime(2030),
          onDateChanged: (_) {},
          selectableDayPredicate: (d) => d.weekday != DateTime.sunday,
        ),
      );

      expect(find.byType(CalendarDatePicker), findsOneWidget);
    });

    testWidgets('wraps picker in hand-drawn border', (tester) async {
      await pumpApp(
        tester,
        WiredCalendarDatePicker(
          initialDate: DateTime(2025, 3, 1),
          firstDate: DateTime(2020),
          lastDate: DateTime(2030),
          onDateChanged: (_) {},
        ),
      );

      expect(findWiredCanvas, findsWidgets);
    });

    testWidgets('accepts onDisplayedMonthChanged callback', (tester) async {
      await pumpApp(
        tester,
        WiredCalendarDatePicker(
          initialDate: DateTime(2025, 6, 15),
          firstDate: DateTime(2020),
          lastDate: DateTime(2030),
          onDateChanged: (_) {},
          onDisplayedMonthChanged: (_) {},
        ),
      );

      // Tap the forward chevron to go to next month
      final chevrons = find.byIcon(Icons.chevron_right);
      expect(chevrons, findsWidgets);
      await tester.tap(chevrons.first);
      await tester.pumpAndSettle();

      // Should have navigated without error
      expect(find.byType(WiredCalendarDatePicker), findsOneWidget);
    });

    testWidgets('renders in year mode', (tester) async {
      await pumpApp(
        tester,
        WiredCalendarDatePicker(
          initialDate: DateTime(2025, 6, 15),
          firstDate: DateTime(2020),
          lastDate: DateTime(2030),
          onDateChanged: (_) {},
          initialCalendarMode: DatePickerMode.year,
        ),
      );

      expect(find.byType(WiredCalendarDatePicker), findsOneWidget);
      // In year mode, year numbers should be visible
      expect(find.text('2025'), findsOneWidget);
    });
  });
}
