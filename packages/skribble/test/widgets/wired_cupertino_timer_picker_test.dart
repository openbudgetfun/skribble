import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';

import '../helpers/pump_app.dart';

void main() {
  final durations = <Duration>[];

  Future<void> pumpSubject(
    WidgetTester tester, {
    Duration initialTimerDuration = Duration.zero,
    WiredCupertinoTimerPickerMode mode = WiredCupertinoTimerPickerMode.hm,
    int minuteInterval = 1,
    int secondInterval = 1,
    ValueChanged<Duration>? onTimerDurationChanged,
  }) {
    durations.clear();
    return pumpApp(
      tester,
      SizedBox(
        width: 320,
        child: WiredCupertinoTimerPicker(
          initialTimerDuration: initialTimerDuration,
          mode: mode,
          minuteInterval: minuteInterval,
          secondInterval: secondInterval,
          onTimerDurationChanged: onTimerDurationChanged ?? durations.add,
        ),
      ),
    );
  }

  group('WiredCupertinoTimerPicker', () {
    testWidgets('renders without error', (tester) async {
      await pumpSubject(tester);
      expect(find.byType(WiredCupertinoTimerPicker), findsOneWidget);
    });

    testWidgets('hour/minute mode shows both wheels', (tester) async {
      await pumpSubject(tester);
      expect(find.text('00 hours'), findsOneWidget);
      expect(find.text('00 minutes'), findsOneWidget);
      expect(find.textContaining('seconds'), findsNothing);
    });

    testWidgets('hour/minute/second mode shows all three wheels', (
      tester,
    ) async {
      await pumpSubject(tester, mode: WiredCupertinoTimerPickerMode.hms);
      expect(find.text('00 hours'), findsOneWidget);
      expect(find.text('00 minutes'), findsOneWidget);
      expect(find.text('00 seconds'), findsOneWidget);
    });

    testWidgets('minute/second mode hides the hours wheel', (tester) async {
      await pumpSubject(tester, mode: WiredCupertinoTimerPickerMode.ms);
      expect(find.textContaining('hours'), findsNothing);
      expect(find.text('00 minutes'), findsOneWidget);
      expect(find.text('00 seconds'), findsOneWidget);
    });

    testWidgets('reflects the initial duration', (tester) async {
      await pumpSubject(
        tester,
        initialTimerDuration: const Duration(hours: 1, minutes: 2),
      );
      expect(find.text('01 hours'), findsOneWidget);
      expect(find.text('02 minutes'), findsOneWidget);
    });

    testWidgets('reports hour and minute changes via callback', (tester) async {
      await pumpSubject(tester);

      // Scroll the minutes wheel up by exactly one item.
      await tester.drag(find.text('00 minutes'), const Offset(0, -32));
      await tester.pumpAndSettle();
      expect(durations.last, const Duration(minutes: 1));
    });

    testWidgets('reports hour wheel changes via callback', (tester) async {
      await pumpSubject(tester);

      await tester.drag(find.text('00 hours'), const Offset(0, -3 * 32));
      await tester.pumpAndSettle();
      expect(durations.last, const Duration(hours: 3, minutes: 0));
    });

    testWidgets('minute interval builds a sparse wheel', (tester) async {
      await pumpSubject(tester, minuteInterval: 15);
      expect(find.text('00 minutes'), findsOneWidget);
      expect(find.text('15 minutes'), findsOneWidget);
      expect(find.text('45 minutes'), findsOneWidget);
      expect(find.text('30 minutes'), findsOneWidget);
      expect(find.text('07 minutes'), findsNothing);

      // Scrolling one item moves 15 minutes.
      await tester.drag(find.text('00 minutes'), const Offset(0, -32));
      await tester.pumpAndSettle();
      expect(durations.last, const Duration(minutes: 15));
    });

    testWidgets('second wheel respects the second interval', (tester) async {
      await pumpSubject(
        tester,
        mode: WiredCupertinoTimerPickerMode.hms,
        secondInterval: 10,
      );
      expect(find.text('50 seconds'), findsOneWidget);
      expect(find.text('10 seconds'), findsOneWidget);
      expect(find.text('11 seconds'), findsNothing);
    });

    testWidgets('rejects minute intervals that do not divide 60', (
      tester,
    ) async {
      expect(
        () => WiredCupertinoTimerPicker(
          minuteInterval: 7,
          onTimerDurationChanged: (_) {},
        ),
        throwsAssertionError,
      );
    });

    testWidgets('rejects second intervals that do not divide 60', (
      tester,
    ) async {
      expect(
        () => WiredCupertinoTimerPicker(
          secondInterval: 45,
          onTimerDurationChanged: (_) {},
        ),
        throwsAssertionError,
      );
    });

    testWidgets('honors height and item extent', (tester) async {
      await pumpSubject(tester);
      final picker = tester.widget<WiredCupertinoPicker>(
        find.byType(WiredCupertinoPicker).first,
      );
      expect(picker.itemExtent, 32);
      expect(picker.height, 216);
    });

    testWidgets('composes hour + minute + second in hms mode', (tester) async {
      await pumpSubject(
        tester,
        mode: WiredCupertinoTimerPickerMode.hms,
        initialTimerDuration: const Duration(hours: 2, minutes: 5, seconds: 9),
      );
      expect(find.text('02 hours'), findsOneWidget);
      expect(find.text('05 minutes'), findsOneWidget);
      expect(find.text('09 seconds'), findsOneWidget);
    });
  });
}
