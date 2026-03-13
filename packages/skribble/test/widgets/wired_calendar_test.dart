import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';

void main() {
  group('WiredCalendar', () {
    Widget buildCalendar({
      String? selected,
      void Function(String)? onSelected,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: SizedBox(
            height: 800,
            width: 800,
            child: WiredCalendar(selected: selected, onSelected: onSelected),
          ),
        ),
      );
    }

    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    // Set a large viewport so GoogleFonts text doesn't overflow.
    void useLargeViewport(WidgetTester tester) {
      tester.view.physicalSize = const Size(1200, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
    }

    testWidgets('renders without error', (tester) async {
      useLargeViewport(tester);

      await tester.pumpWidget(buildCalendar());
      await tester.pumpAndSettle();

      expect(find.byType(WiredCalendar), findsOneWidget);
    });

    testWidgets('shows current month and year', (tester) async {
      useLargeViewport(tester);

      await tester.pumpWidget(buildCalendar());
      await tester.pumpAndSettle();

      final now = DateTime.now();
      final expectedMonthYear = '${months[now.month - 1]} ${now.year}';

      expect(find.text(expectedMonthYear), findsOneWidget);
    });

    testWidgets('shows weekday headers', (tester) async {
      useLargeViewport(tester);

      await tester.pumpWidget(buildCalendar());
      await tester.pumpAndSettle();

      expect(find.text('Sun'), findsOneWidget);
      expect(find.text('Mon'), findsOneWidget);
      expect(find.text('Tue'), findsOneWidget);
      expect(find.text('Wed'), findsOneWidget);
      expect(find.text('Thu'), findsOneWidget);
      expect(find.text('Fri'), findsOneWidget);
      expect(find.text('Sat'), findsOneWidget);
    });

    testWidgets('navigate to previous month with << button', (tester) async {
      useLargeViewport(tester);

      await tester.pumpWidget(buildCalendar());
      await tester.pumpAndSettle();

      final now = DateTime.now();
      final currentMonthYear = '${months[now.month - 1]} ${now.year}';
      expect(find.text(currentMonthYear), findsOneWidget);

      // Tap the << button to navigate to the previous month.
      await tester.tap(find.text('<<'));
      await tester.pumpAndSettle();

      // Compute the expected previous month.
      final prevMonth = now.month == 1 ? 12 : now.month - 1;
      final prevYear = now.month == 1 ? now.year - 1 : now.year;
      final expectedPrevMonthYear = '${months[prevMonth - 1]} $prevYear';

      expect(find.text(expectedPrevMonthYear), findsOneWidget);
    });

    testWidgets('navigate to next month with >> button', (tester) async {
      useLargeViewport(tester);

      await tester.pumpWidget(buildCalendar());
      await tester.pumpAndSettle();

      final now = DateTime.now();
      final currentMonthYear = '${months[now.month - 1]} ${now.year}';
      expect(find.text(currentMonthYear), findsOneWidget);

      // Tap the >> button to navigate to the next month.
      await tester.tap(find.text('>>'));
      await tester.pumpAndSettle();

      // Compute the expected next month.
      final nextMonth = now.month == 12 ? 1 : now.month + 1;
      final nextYear = now.month == 12 ? now.year + 1 : now.year;
      final expectedNextMonthYear = '${months[nextMonth - 1]} $nextYear';

      expect(find.text(expectedNextMonthYear), findsOneWidget);
    });

    testWidgets('calls onSelected when date tapped', (tester) async {
      useLargeViewport(tester);

      String? selectedDate;

      await tester.pumpWidget(
        buildCalendar(onSelected: (value) => selectedDate = value),
      );
      await tester.pumpAndSettle();

      // Tap on a day number that is guaranteed to exist in any month.
      // Day "10" is safe since every month has at least 10 days.
      await tester.tap(find.text('10').first);
      await tester.pumpAndSettle();

      expect(selectedDate, isNotNull);
      expect(selectedDate!.length, 8); // Format: YYYYMMDD
    });

    testWidgets('shows selected date with circle indicator', (tester) async {
      useLargeViewport(tester);

      // Select a date to trigger the circle indicator.
      final now = DateTime.now();
      final selectedStr =
          '${now.year}${now.month.toString().padLeft(2, '0')}15';

      await tester.pumpWidget(buildCalendar(selected: selectedStr));
      await tester.pumpAndSettle();

      // When a date is selected, the calendar renders a WiredCanvas with a
      // WiredCircleBase around the selected cell. There should be at least
      // one WiredCanvas in the calendar widget tree.
      final canvasWidgets = find.descendant(
        of: find.byType(WiredCalendar),
        matching: find.byType(WiredCanvas),
      );
      expect(canvasWidgets, findsAtLeast(1));
    });
  });
}
