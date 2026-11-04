import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';

import '../helpers/finders.dart';
import '../helpers/pump_app.dart';

void main() {
  group('WiredCalendar', () {
    Future<void> pumpSubject(
      WidgetTester tester, {
      String? selected,
      void Function(String)? onSelected,
    }) {
      return pumpApp(
        tester,
        SizedBox(
          height: 800,
          width: 800,
          child: WiredCalendar(selected: selected, onSelected: onSelected),
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

    // Set a large viewport so hand-drawn font text doesn't overflow.
    void useLargeViewport(WidgetTester tester) {
      tester.view.physicalSize = const Size(1200, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
    }

    testWidgets('renders without error', (tester) async {
      useLargeViewport(tester);

      await pumpSubject(tester);
      await tester.pumpAndSettle();

      expect(find.byType(WiredCalendar), findsOneWidget);
    });

    testWidgets('shows current month and year', (tester) async {
      useLargeViewport(tester);

      await pumpSubject(tester);
      await tester.pumpAndSettle();

      final now = DateTime.now();
      final expectedMonthYear = '${months[now.month - 1]} ${now.year}';

      expect(find.text(expectedMonthYear), findsOneWidget);
    });

    testWidgets('shows weekday headers', (tester) async {
      useLargeViewport(tester);

      await pumpSubject(tester);
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

      await pumpSubject(tester);
      await tester.pumpAndSettle();

      final now = DateTime.now();
      final currentMonthYear = '${months[now.month - 1]} ${now.year}';
      expect(find.text(currentMonthYear), findsOneWidget);

      await tester.tap(find.text('<<'));
      await tester.pumpAndSettle();

      final prevMonth = now.month == 1 ? 12 : now.month - 1;
      final prevYear = now.month == 1 ? now.year - 1 : now.year;
      final expectedPrevMonthYear = '${months[prevMonth - 1]} $prevYear';

      expect(find.text(expectedPrevMonthYear), findsOneWidget);
    });

    testWidgets('navigate to next month with >> button', (tester) async {
      useLargeViewport(tester);

      await pumpSubject(tester);
      await tester.pumpAndSettle();

      final now = DateTime.now();
      final currentMonthYear = '${months[now.month - 1]} ${now.year}';
      expect(find.text(currentMonthYear), findsOneWidget);

      await tester.tap(find.text('>>'));
      await tester.pumpAndSettle();

      final nextMonth = now.month == 12 ? 1 : now.month + 1;
      final nextYear = now.month == 12 ? now.year + 1 : now.year;
      final expectedNextMonthYear = '${months[nextMonth - 1]} $nextYear';

      expect(find.text(expectedNextMonthYear), findsOneWidget);
    });

    testWidgets('calls onSelected when date tapped', (tester) async {
      useLargeViewport(tester);

      String? selectedDate;

      await pumpSubject(tester, onSelected: (value) => selectedDate = value);
      await tester.pumpAndSettle();

      await tester.tap(find.text('10').first);
      await tester.pumpAndSettle();

      expect(selectedDate, isNotNull);
      expect(selectedDate!.length, 8); // Format: YYYYMMDD
    });

    testWidgets('shows selected date with circle indicator', (tester) async {
      useLargeViewport(tester);

      final now = DateTime.now();
      final selectedStr =
          '${now.year}${now.month.toString().padLeft(2, '0')}15';

      await pumpSubject(tester, selected: selectedStr);
      await tester.pumpAndSettle();

      final canvasWidgets = find.descendant(
        of: find.byType(WiredCalendar),
        matching: findWiredCanvas,
      );
      expect(canvasWidgets, findsAtLeast(1));
    });

    Finder selectionCircles() => find.byWidgetPredicate(
      (widget) => widget is WiredCanvas && widget.painter is WiredCircleBase,
    );

    // Run with TZ=America/New_York (or any zone with daylight saving) to
    // exercise the clock changes; the expectations hold in every zone.
    testWidgets('lists every day once across a clock change in November', (
      tester,
    ) async {
      useLargeViewport(tester);
      await pumpSubject(tester, selected: '20261115');
      await tester.pumpAndSettle();

      expect(find.text('November 2026'), findsOneWidget);
      // November 1 2026 is a Sunday, so the grid runs Nov 1..30, Dec 1..5.
      expect(find.text('30'), findsOneWidget);
      expect(find.text('1'), findsNWidgets(2));
      expect(find.text('2'), findsNWidgets(2));
    });

    testWidgets('circles a selection after the March clock change', (
      tester,
    ) async {
      useLargeViewport(tester);
      await pumpSubject(tester, selected: '20260320');
      await tester.pumpAndSettle();

      expect(find.text('March 2026'), findsOneWidget);
      expect(selectionCircles(), findsOneWidget);
    });

    testWidgets('follows a new selected value from its parent', (
      tester,
    ) async {
      useLargeViewport(tester);
      await pumpSubject(tester, selected: '20260115');
      await tester.pumpAndSettle();
      expect(find.text('January 2026'), findsOneWidget);

      await pumpSubject(tester, selected: '20260410');
      await tester.pumpAndSettle();

      expect(find.text('April 2026'), findsOneWidget);
      expect(selectionCircles(), findsOneWidget);
    });

    testWidgets('names each day and its selection for screen readers', (
      tester,
    ) async {
      useLargeViewport(tester);
      final semantics = tester.ensureSemantics();
      await pumpSubject(tester, selected: '20260615');
      await tester.pumpAndSettle();

      expect(
        tester.getSemantics(find.bySemanticsLabel('Monday, June 15, 2026')),
        matchesSemantics(
          label: 'Monday, June 15, 2026',
          isButton: true,
          hasSelectedState: true,
          isSelected: true,
          hasTapAction: true,
        ),
      );
      expect(
        tester.getSemantics(find.bySemanticsLabel('Previous month')),
        matchesSemantics(
          label: 'Previous month',
          isButton: true,
          hasTapAction: true,
        ),
      );
      semantics.dispose();
    });

    testWidgets('inks its text and circle with the theme', (tester) async {
      useLargeViewport(tester);
      final dark = WiredThemeData.cuddly(brightness: Brightness.dark);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WiredTheme(
              data: dark,
              child: const SizedBox(
                height: 800,
                width: 800,
                child: WiredCalendar(selected: '20260615'),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        tester.widget<Text>(find.text('June 2026')).style?.color,
        dark.textColor,
      );
      expect(
        tester.widget<Text>(find.text('Mon')).style?.color,
        dark.textColor,
      );
      final circle =
          tester.widget<WiredCanvas>(selectionCircles()).painter
              as WiredCircleBase;
      expect(circle.borderColor, dark.borderColor);
    });
  });
}
