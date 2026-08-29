import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';

import '../helpers/pump_app.dart';

void main() {
  // Deterministic month: January 2026.
  final firstDate = DateTime(2026, 1, 1);
  final lastDate = DateTime(2026, 12, 31);
  final initialRange = DateTimeRange<DateTime>(
    start: DateTime(2026, 1, 5),
    end: DateTime(2026, 1, 12),
  );

  Future<void> pumpDialog(
    WidgetTester tester, {
    DateTime? initialDateRangeStart,
    DateTime? initialDateRangeEnd,
    DateTime? first,
    DateTime? last,
  }) {
    return pumpApp(
      tester,
      WiredDateRangePickerDialog(
        initialDateRange: (initialDateRangeStart != null)
            ? DateTimeRange<DateTime>(
                start: initialDateRangeStart,
                end: initialDateRangeEnd ?? initialDateRangeStart,
              )
            : null,
        firstDate: first ?? firstDate,
        lastDate: last ?? lastDate,
      ),
    );
  }

  group('WiredDateRangePickerDialog', () {
    testWidgets('renders without error', (tester) async {
      await pumpDialog(tester);

      expect(find.byType(WiredDateRangePickerDialog), findsOneWidget);
    });

    testWidgets('renders the month and weekday header', (tester) async {
      await pumpDialog(tester, initialDateRangeStart: DateTime(2026, 1, 5));

      expect(find.text('January 2026'), findsOneWidget);
      expect(find.text('Mon'), findsOneWidget);
      expect(find.text('Sun'), findsOneWidget);
      expect(find.text('Sat'), findsOneWidget);
    });

    testWidgets('hint header shows when nothing is selected', (tester) async {
      await pumpDialog(tester);

      expect(find.text('Select range'), findsOneWidget);
    });

    testWidgets('shows the initial range in the header', (tester) async {
      await pumpDialog(
        tester,
        initialDateRangeStart: DateTime(2026, 1, 5),
        initialDateRangeEnd: DateTime(2026, 1, 12),
      );

      expect(find.text('Jan 5, 2026 – Jan 12, 2026'), findsOneWidget);
    });

    testWidgets('first tap marks the start of a new range', (tester) async {
      await pumpDialog(tester);

      await tester.tap(find.text('15'));
      await tester.pump();

      expect(find.text('Jan 15, 2026 – ...'), findsOneWidget);
      expect(find.text('Select range'), findsNothing);
    });

    testWidgets('second tap completes the range and enables OK', (
      tester,
    ) async {
      await pumpDialog(tester);

      await tester.tap(find.text('15'));
      await tester.pump();
      await tester.tap(find.text('20'));
      await tester.pump();

      expect(find.text('Jan 15, 2026 – Jan 20, 2026'), findsOneWidget);
      expect(find.widgetWithText(WiredButton, 'OK'), findsOneWidget);
    });

    testWidgets('tapping an earlier day restarts the range', (tester) async {
      await pumpDialog(
        tester,
        initialDateRangeStart: DateTime(2026, 1, 5),
        initialDateRangeEnd: DateTime(2026, 1, 12),
      );

      // With a complete range on display, a tap starts a new selection.
      await tester.tap(find.text('20'));
      await tester.pump();
      await tester.tap(find.text('10'));
      await tester.pump();

      expect(find.text('Jan 10, 2026 – ...'), findsOneWidget);
    });

    testWidgets('OK pops the selected range', (tester) async {
      final result = ValueNotifier<String?>('waiting');

      await tester.pumpWidget(
        MaterialApp(
          home: ValueListenableBuilder<String?>(
            valueListenable: result,
            builder: (_, _, _) => Scaffold(
              body: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(result.value ?? 'waiting'),
                    Builder(
                      builder: (buttonContext) => WiredButton(
                        onPressed: () async {
                          final range = await showWiredDateRangePicker(
                            context: buttonContext,
                            firstDate: firstDate,
                            lastDate: lastDate,
                          );
                          result.value = range == null
                              ? 'dismissed'
                              : 'range:${range.start.day}-${range.end.day}';
                        },
                        child: const Text('Pick Range'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Pick Range'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('15'));
      await tester.pump();
      await tester.tap(find.text('20'));
      await tester.pump();

      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      expect(result.value, 'range:15-20');
    });

    testWidgets('Cancel pops with null', (tester) async {
      final result = ValueNotifier<String?>('waiting');

      await tester.pumpWidget(
        MaterialApp(
          home: ValueListenableBuilder<String?>(
            valueListenable: result,
            builder: (_, _, _) => Scaffold(
              body: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(result.value ?? 'waiting'),
                    Builder(
                      builder: (buttonContext) => WiredButton(
                        onPressed: () async {
                          final range = await showWiredDateRangePicker(
                            context: buttonContext,
                            initialDateRange: initialRange,
                            firstDate: firstDate,
                            lastDate: lastDate,
                          );
                          if (range == null) {
                            result.value = 'cancelled';
                          }
                        },
                        child: const Text('Pick Range'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Pick Range'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(result.value, 'cancelled');
    });

    testWidgets('navigates between months', (tester) async {
      await pumpDialog(tester, initialDateRangeStart: DateTime(2026, 1, 5));

      expect(find.text('January 2026'), findsOneWidget);

      await tester.tap(find.text('>>'));
      await tester.pump();
      expect(find.text('February 2026'), findsOneWidget);

      await tester.tap(find.text('<<'));
      await tester.pump();
      expect(find.text('January 2026'), findsOneWidget);
    });

    testWidgets('clamps month navigation to the allowed range', (tester) async {
      await pumpDialog(
        tester,
        initialDateRangeStart: DateTime(2026, 1, 5),
        first: DateTime(2026, 1, 1),
        last: DateTime(2026, 1, 31),
      );

      // Only January 2026 is within [first, last]; both nav buttons must be
      // disabled so the displayed month cannot leave the range.
      await tester.tap(find.text('>>'));
      await tester.pump();
      await tester.tap(find.text('<<'));
      await tester.pump();

      expect(find.text('January 2026'), findsOneWidget);
      expect(find.text('February 2026'), findsNothing);
    });

    testWidgets('days outside firstDate..lastDate are disabled', (
      tester,
    ) async {
      await pumpDialog(
        tester,
        first: DateTime(2026, 1, 10),
        last: DateTime(2026, 1, 20),
      );

      // Jan 5 is below firstDate; tapping it must not start a selection.
      await tester.tap(find.text('5'));
      await tester.pump();

      expect(find.text('Select range'), findsOneWidget);
      expect(find.text('Jan 5, 2026 – ...'), findsNothing);

      // Jan 15 is inside the range: it becomes the start.
      await tester.tap(find.text('15'));
      await tester.pump();
      expect(find.text('Jan 15, 2026 – ...'), findsOneWidget);
    });

    testWidgets('exposes semantics for the dialog and day cells', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();

      await pumpDialog(tester, initialDateRangeStart: DateTime(2026, 1, 5));

      // The container node's label gets merged with its descendants, so
      // match by prefix.
      expect(
        find.bySemanticsLabel(RegExp('^Date range picker')),
        findsOneWidget,
      );
      expect(
        find.bySemanticsLabel(RegExp('^Select Jan 20, 2026')),
        findsOneWidget,
      );

      handle.dispose();
    });
  });
}
