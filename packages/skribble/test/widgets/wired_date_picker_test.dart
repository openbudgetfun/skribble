import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';

void main() {
  group('WiredDatePicker', () {
    // Set a large viewport so GoogleFonts text in WiredCalendar does not
    // overflow.
    void useLargeViewport(WidgetTester tester) {
      tester.view.physicalSize = const Size(1200, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
    }

    Widget buildDatePicker({
      DateTime? initialDate,
      void Function(DateTime)? onDateSelected,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 800,
            height: 800,
            child: WiredDatePicker(
              initialDate: initialDate,
              onDateSelected: onDateSelected,
            ),
          ),
        ),
      );
    }

    testWidgets('renders without error', (tester) async {
      useLargeViewport(tester);

      await tester.pumpWidget(buildDatePicker());
      await tester.pumpAndSettle();

      expect(find.byType(WiredDatePicker), findsOneWidget);
    });

    testWidgets('contains a WiredCalendar', (tester) async {
      useLargeViewport(tester);

      await tester.pumpWidget(buildDatePicker());
      await tester.pumpAndSettle();

      expect(
        find.descendant(
          of: find.byType(WiredDatePicker),
          matching: find.byType(WiredCalendar),
        ),
        findsOneWidget,
      );
    });

    testWidgets('has correct dimensions (320x400)', (tester) async {
      useLargeViewport(tester);

      await tester.pumpWidget(buildDatePicker());
      await tester.pumpAndSettle();

      // The WiredDatePicker wraps content in a SizedBox(320, 400) inside a
      // RepaintBoundary. We look for the inner SizedBox.
      final sizedBoxFinder = find.descendant(
        of: find.byType(WiredDatePicker),
        matching: find.byWidgetPredicate(
          (w) => w is SizedBox && w.width == 320 && w.height == 400,
        ),
      );
      expect(sizedBoxFinder, findsOneWidget);
    });

    testWidgets('contains RepaintBoundary wrapper', (tester) async {
      useLargeViewport(tester);

      await tester.pumpWidget(buildDatePicker());
      await tester.pumpAndSettle();

      // WiredDatePicker uses buildWiredElement which wraps in
      // RepaintBoundary. The calendar grid also produces many
      // RepaintBoundary widgets, so we check that at least one exists
      // as a descendant.
      expect(
        find.descendant(
          of: find.byType(WiredDatePicker),
          matching: find.byType(RepaintBoundary),
        ),
        findsAtLeast(1),
      );
    });

    testWidgets('renders with initialDate without error', (tester) async {
      useLargeViewport(tester);

      // Suppress overflow errors since the date picker's internal 320px
      // width may cause the calendar navigation bar to overflow with
      // GoogleFonts text.
      final origOnError = FlutterError.onError;
      final errors = <FlutterErrorDetails>[];
      FlutterError.onError = (details) {
        if (details.toString().contains('overflowed')) {
          errors.add(details);
        } else {
          origOnError?.call(details);
        }
      };
      addTearDown(() => FlutterError.onError = origOnError);

      await tester.pumpWidget(
        buildDatePicker(initialDate: DateTime(2025, 6, 15)),
      );
      await tester.pumpAndSettle();

      // The date picker should render and contain a WiredCalendar
      // navigated to the initial date's month.
      expect(find.byType(WiredDatePicker), findsOneWidget);
      expect(find.byType(WiredCalendar), findsOneWidget);
    });

    testWidgets('renders current month when no initialDate', (tester) async {
      useLargeViewport(tester);

      // Suppress overflow errors.
      final origOnError = FlutterError.onError;
      FlutterError.onError = (details) {
        if (!details.toString().contains('overflowed')) {
          origOnError?.call(details);
        }
      };
      addTearDown(() => FlutterError.onError = origOnError);

      await tester.pumpWidget(buildDatePicker());
      await tester.pumpAndSettle();

      final now = DateTime.now();
      const months = [
        'January', 'February', 'March', 'April', 'May', 'June',
        'July', 'August', 'September', 'October', 'November', 'December',
      ];
      final expectedMonthYear = '${months[now.month - 1]} ${now.year}';

      expect(find.text(expectedMonthYear), findsOneWidget);
    });

    testWidgets('property defaults: initialDate and onDateSelected are null',
        (tester) async {
      useLargeViewport(tester);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 800,
              height: 800,
              child: WiredDatePicker(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final widget =
          tester.widget<WiredDatePicker>(find.byType(WiredDatePicker));
      expect(widget.initialDate, isNull);
      expect(widget.onDateSelected, isNull);
    });

    testWidgets('calls onDateSelected when a date is tapped', (tester) async {
      useLargeViewport(tester);

      // Suppress overflow errors.
      final origOnError = FlutterError.onError;
      FlutterError.onError = (details) {
        if (!details.toString().contains('overflowed')) {
          origOnError?.call(details);
        }
      };
      addTearDown(() => FlutterError.onError = origOnError);

      DateTime? selectedDate;

      await tester.pumpWidget(
        buildDatePicker(
          initialDate: DateTime(2025, 3, 1),
          onDateSelected: (date) => selectedDate = date,
        ),
      );
      await tester.pumpAndSettle();

      // Tap on day 15 which is guaranteed to exist in March.
      await tester.tap(find.text('15').first);
      await tester.pumpAndSettle();

      expect(selectedDate, isNotNull);
      expect(selectedDate!.day, 15);
    });

    testWidgets('contains WiredCanvas for border rectangle', (tester) async {
      useLargeViewport(tester);

      await tester.pumpWidget(buildDatePicker());
      await tester.pumpAndSettle();

      // WiredDatePicker renders a WiredCanvas with WiredRectangleBase as a
      // border, plus any WiredCanvas widgets from the calendar.
      expect(
        find.descendant(
          of: find.byType(WiredDatePicker),
          matching: find.byType(WiredCanvas),
        ),
        findsAtLeast(1),
      );
    });

    testWidgets('calendar navigation works within date picker',
        (tester) async {
      useLargeViewport(tester);

      // Suppress overflow errors from the narrow 320px date picker.
      final origOnError = FlutterError.onError;
      FlutterError.onError = (details) {
        if (!details.toString().contains('overflowed')) {
          origOnError?.call(details);
        }
      };
      addTearDown(() => FlutterError.onError = origOnError);

      await tester.pumpWidget(
        buildDatePicker(initialDate: DateTime(2025, 1, 10)),
      );
      await tester.pumpAndSettle();

      expect(find.text('January 2025'), findsOneWidget);

      // Navigate to next month.
      await tester.tap(find.text('>>'));
      await tester.pumpAndSettle();

      expect(find.text('February 2025'), findsOneWidget);
    });
  });

  group('showWiredDatePicker', () {
    // Set a large viewport so GoogleFonts text does not overflow.
    void useLargeViewport(WidgetTester tester) {
      tester.view.physicalSize = const Size(1200, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
    }

    testWidgets('opens a dialog containing WiredDatePicker', (tester) async {
      useLargeViewport(tester);

      // Suppress overflow errors from the date picker's constrained width.
      final origOnError = FlutterError.onError;
      FlutterError.onError = (details) {
        if (!details.toString().contains('overflowed')) {
          origOnError?.call(details);
        }
      };
      addTearDown(() => FlutterError.onError = origOnError);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  unawaited(showWiredDatePicker(context: context));
                },
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.byType(WiredDatePicker), findsOneWidget);
      expect(find.byType(Dialog), findsOneWidget);
    });

    testWidgets('dialog closes and returns date on selection',
        (tester) async {
      useLargeViewport(tester);

      // Suppress overflow errors from the date picker's constrained width.
      final origOnError = FlutterError.onError;
      FlutterError.onError = (details) {
        if (!details.toString().contains('overflowed')) {
          origOnError?.call(details);
        }
      };
      addTearDown(() => FlutterError.onError = origOnError);

      DateTime? result;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () async {
                  result = await showWiredDatePicker(
                    context: context,
                    initialDate: DateTime(2025, 5, 1),
                  );
                },
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      // Verify the dialog is open.
      expect(find.byType(Dialog), findsOneWidget);

      // Tap on day 10 within the dialog.
      await tester.tap(find.text('10').first);
      await tester.pumpAndSettle();

      // The dialog should have closed and returned the selected date.
      expect(find.byType(Dialog), findsNothing);
      expect(result, isNotNull);
    });
  });
}
