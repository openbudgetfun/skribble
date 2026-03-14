import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';

import '../helpers/pump_app.dart';

void main() {
  Future<void> pumpSubject(
    WidgetTester tester, {
    double value = 0.5,
    ValueChanged<double>? onChanged,
    ValueChanged<double>? onChangeStart,
    ValueChanged<double>? onChangeEnd,
    double min = 0.0,
    double max = 1.0,
    int? divisions,
    Color? activeColor,
    Color? inactiveColor,
  }) {
    return pumpApp(
      tester,
      Center(
        child: SizedBox(
          width: 300,
          child: WiredCupertinoSlider(
            value: value,
            onChanged: onChanged,
            onChangeStart: onChangeStart,
            onChangeEnd: onChangeEnd,
            min: min,
            max: max,
            divisions: divisions,
            activeColor: activeColor,
            inactiveColor: inactiveColor,
          ),
        ),
      ),
    );
  }

  group('WiredCupertinoSlider', () {
    testWidgets('renders without error', (tester) async {
      await pumpSubject(tester, onChanged: (_) {});
      expect(find.byType(WiredCupertinoSlider), findsOneWidget);
    });

    testWidgets('calls onChanged when tapped', (tester) async {
      double? changed;
      await pumpSubject(tester, onChanged: (v) => changed = v);
      await tester.tap(find.byType(WiredCupertinoSlider));
      expect(changed, isNotNull);
    });

    testWidgets('does not respond when disabled', (tester) async {
      double? changed;
      await pumpSubject(tester);
      await tester.tap(find.byType(WiredCupertinoSlider));
      expect(changed, isNull);
    });

    testWidgets('calls onChangeStart on drag start', (tester) async {
      double? started;
      await pumpSubject(
        tester,
        onChanged: (_) {},
        onChangeStart: (v) => started = v,
      );
      await tester.timedDrag(
        find.byType(WiredCupertinoSlider),
        const Offset(50, 0),
        const Duration(milliseconds: 300),
      );
      expect(started, isNotNull);
    });

    testWidgets('calls onChangeEnd on drag end', (tester) async {
      double? ended;
      await pumpSubject(
        tester,
        onChanged: (_) {},
        onChangeEnd: (v) => ended = v,
      );
      await tester.timedDrag(
        find.byType(WiredCupertinoSlider),
        const Offset(50, 0),
        const Duration(milliseconds: 300),
      );
      expect(ended, isNotNull);
    });

    testWidgets('snaps to divisions when set', (tester) async {
      double? changed;
      await pumpSubject(
        tester,
        value: 0.0,
        onChanged: (v) => changed = v,
        divisions: 4,
      );
      final center = tester.getCenter(find.byType(WiredCupertinoSlider));
      await tester.tapAt(center);
      expect(changed, isNotNull);
      final remainder = (changed! * 4).round() / 4;
      expect(remainder, changed);
    });

    testWidgets('renders with custom active color', (tester) async {
      await pumpSubject(tester, onChanged: (_) {}, activeColor: Colors.red);
      expect(find.byType(WiredCupertinoSlider), findsOneWidget);
    });

    testWidgets('has reduced opacity when disabled', (tester) async {
      await pumpSubject(tester);
      final opacity = tester.widget<AnimatedOpacity>(
        find.byType(AnimatedOpacity),
      );
      expect(opacity.opacity, 0.4);
    });
  });
}
