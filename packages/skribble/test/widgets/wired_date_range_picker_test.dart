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

    // Run with TZ=America/New_York (or any zone with daylight saving) to
    // exercise the clock change; the expectations hold in every zone.
    testWidgets('lists every November day once across the clock change', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await pumpDialog(
        tester,
        initialDateRangeStart: DateTime(2026, 11, 3),
        first: DateTime(2026, 11, 1),
        last: DateTime(2026, 11, 30),
      );

      expect(find.text('November 2026'), findsOneWidget);
      expect(find.text('30'), findsOneWidget);
      expect(find.bySemanticsLabel('Select Nov 30, 2026'), findsOneWidget);
      // Nov 1 2026 is a Sunday: the grid shows Nov 1 and Dec 1 only.
      expect(find.text('1'), findsNWidgets(2));
      handle.dispose();
    });

    testWidgets('marks the range endpoints as selected', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpDialog(
        tester,
        initialDateRangeStart: DateTime(2026, 1, 5),
        initialDateRangeEnd: DateTime(2026, 1, 12),
      );

      expect(
        tester.getSemantics(find.bySemanticsLabel('Select Jan 5, 2026')),
        matchesSemantics(
          label: 'Select Jan 5, 2026',
          isButton: true,
          hasSelectedState: true,
          isSelected: true,
          hasTapAction: true,
        ),
      );
      handle.dispose();
    });

    testWidgets('inks the selection with the theme in dark themes', (
      tester,
    ) async {
      final dark = WiredThemeData.cuddly(brightness: Brightness.dark);
      await pumpWired(
        tester,
        WiredDateRangePickerDialog(
          initialDateRange: initialRange,
          firstDate: firstDate,
          lastDate: lastDate,
        ),
        theme: dark,
      );

      final painters = tester
          .widgetList<WiredCanvas>(find.byType(WiredCanvas))
          .map((canvas) => canvas.painter)
          .toList();
      final circles = painters.whereType<WiredCircleBase>().toList();
      final range = painters
          .whereType<WiredRectangleBase>()
          .where((r) => r.fillColor != dark.fillColor)
          .toList();
      expect(circles, hasLength(2));
      expect(circles.every((c) => c.borderColor == dark.borderColor), isTrue);
      expect(range, isNotEmpty);
      expect(range.every((r) => r.borderColor == dark.borderColor), isTrue);
    });

    testWidgets('weekday names stay on one line at 320 pixels', (
      tester,
    ) async {
      tester.view
        ..physicalSize = const Size(320, 800)
        ..devicePixelRatio = 1;
      tester.platformDispatcher.textScaleFactorTestValue = 1.3;
      addTearDown(tester.view.reset);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

      await pumpDialog(tester, initialDateRangeStart: DateTime(2026, 1, 5));

      expect(tester.takeException(), isNull);
      final number = tester.getSize(find.text('15'));
      for (final name in ['Mon', 'Wed', 'Sat']) {
        // A wrapped name is two lines tall; a fitted one is at most one.
        final size = tester.getSize(find.text(name));
        expect(size.height, lessThan(number.height * 1.5), reason: name);
      }
    });
  });
}
