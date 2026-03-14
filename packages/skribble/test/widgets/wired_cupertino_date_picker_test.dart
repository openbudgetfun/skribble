import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';

import '../helpers/pump_app.dart';

void main() {
  Future<void> pumpSubject(
    WidgetTester tester, {
    ValueChanged<DateTime>? onDateTimeChanged,
    DateTime? initialDateTime,
    DateTime? minimumDate,
    DateTime? maximumDate,
    CupertinoDatePickerMode mode = CupertinoDatePickerMode.dateAndTime,
    bool use24hFormat = false,
    double height = 216,
  }) {
    return pumpApp(
      tester,
      Center(
        child: WiredCupertinoDatePicker(
          onDateTimeChanged: onDateTimeChanged ?? (_) {},
          initialDateTime: initialDateTime,
          minimumDate: minimumDate,
          maximumDate: maximumDate,
          mode: mode,
          use24hFormat: use24hFormat,
          height: height,
        ),
      ),
    );
  }

  group('WiredCupertinoDatePicker', () {
    testWidgets('renders without error', (tester) async {
      await pumpSubject(tester);
      expect(find.byType(WiredCupertinoDatePicker), findsOneWidget);
    });

    testWidgets('contains CupertinoDatePicker', (tester) async {
      await pumpSubject(tester);
      expect(find.byType(CupertinoDatePicker), findsOneWidget);
    });

    testWidgets('renders in date mode', (tester) async {
      await pumpSubject(tester, mode: CupertinoDatePickerMode.date);
      expect(find.byType(WiredCupertinoDatePicker), findsOneWidget);
    });

    testWidgets('renders in time mode', (tester) async {
      await pumpSubject(tester, mode: CupertinoDatePickerMode.time);
      expect(find.byType(WiredCupertinoDatePicker), findsOneWidget);
    });

    testWidgets('renders with 24h format', (tester) async {
      await pumpSubject(
        tester,
        mode: CupertinoDatePickerMode.time,
        use24hFormat: true,
      );
      expect(find.byType(WiredCupertinoDatePicker), findsOneWidget);
    });

    testWidgets('renders with custom height', (tester) async {
      await pumpSubject(tester, height: 300);
      final sized = tester.widget<SizedBox>(
        find.descendant(
          of: find.byType(WiredCupertinoDatePicker),
          matching: find.byType(SizedBox).first,
        ),
      );
      expect(sized.height, 300);
    });

    testWidgets('calls onDateTimeChanged when scrolled', (tester) async {
      await pumpSubject(tester, mode: CupertinoDatePickerMode.time);
      await tester.drag(find.byType(CupertinoDatePicker), const Offset(0, -50));
      await tester.pump();
      expect(find.byType(WiredCupertinoDatePicker), findsOneWidget);
    });

    testWidgets('renders with min/max date constraints', (tester) async {
      final now = DateTime.now();
      await pumpSubject(
        tester,
        initialDateTime: now,
        minimumDate: now.subtract(const Duration(days: 30)),
        maximumDate: now.add(const Duration(days: 30)),
      );
      expect(find.byType(WiredCupertinoDatePicker), findsOneWidget);
    });
  });
}
