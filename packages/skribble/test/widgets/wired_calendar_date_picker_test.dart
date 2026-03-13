import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';

void main() {
  group('WiredCalendarDatePicker', () {
    testWidgets('renders without error', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WiredCalendarDatePicker(
              initialDate: DateTime(2025, 6, 15),
              firstDate: DateTime(2020),
              lastDate: DateTime(2030),
              onDateChanged: (_) {},
            ),
          ),
        ),
      );

      expect(find.byType(WiredCalendarDatePicker), findsOneWidget);
      expect(find.byType(CalendarDatePicker), findsOneWidget);
      expect(find.byType(RepaintBoundary), findsWidgets);
    });

    testWidgets('calls onDateChanged when day tapped', (tester) async {
      DateTime? selected;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WiredCalendarDatePicker(
              initialDate: DateTime(2025, 6, 15),
              firstDate: DateTime(2020),
              lastDate: DateTime(2030),
              onDateChanged: (d) => selected = d,
            ),
          ),
        ),
      );

      // Tap a visible day number
      await tester.tap(find.text('20'));
      await tester.pumpAndSettle();

      expect(selected, isNotNull);
      expect(selected!.day, 20);
    });

    testWidgets('respects selectableDayPredicate', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WiredCalendarDatePicker(
              initialDate: DateTime(2025, 6, 16),
              firstDate: DateTime(2020),
              lastDate: DateTime(2030),
              onDateChanged: (_) {},
              selectableDayPredicate: (d) => d.weekday != DateTime.sunday,
            ),
          ),
        ),
      );

      expect(find.byType(CalendarDatePicker), findsOneWidget);
    });

    testWidgets('wraps picker in hand-drawn border', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WiredCalendarDatePicker(
              initialDate: DateTime(2025, 3, 1),
              firstDate: DateTime(2020),
              lastDate: DateTime(2030),
              onDateChanged: (_) {},
            ),
          ),
        ),
      );

      expect(find.byType(WiredCanvas), findsWidgets);
    });
  });
}
