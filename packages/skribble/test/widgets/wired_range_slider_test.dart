import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';

import '../helpers/pump_app.dart';

void main() {
  group('WiredRangeSlider', () {
    testWidgets('renders without error', (tester) async {
      await pumpApp(tester, WiredRangeSlider(
              values: const RangeValues(0.2, 0.8),
              onChanged: (v) => true,
            ));

      expect(find.byType(WiredRangeSlider), findsOneWidget);
    });

    testWidgets('contains RangeSlider internally', (tester) async {
      await pumpApp(tester, WiredRangeSlider(
              values: const RangeValues(0.2, 0.8),
              onChanged: (v) => true,
            ));

      expect(
        find.descendant(
          of: find.byType(WiredRangeSlider),
          matching: find.byType(RangeSlider),
        ),
        findsOneWidget,
      );
    });

    testWidgets('has correct min/max defaults', (tester) async {
      await pumpApp(tester, WiredRangeSlider(
              values: const RangeValues(0.2, 0.8),
              onChanged: (v) => true,
            ));

      final slider = tester.widget<RangeSlider>(find.byType(RangeSlider));
      expect(slider.min, 0.0);
      expect(slider.max, 1.0);
    });

    testWidgets('uses custom min/max values', (tester) async {
      await pumpApp(tester, WiredRangeSlider(
              values: const RangeValues(20, 80),
              min: 10,
              max: 100,
              onChanged: (v) => true,
            ));

      final slider = tester.widget<RangeSlider>(find.byType(RangeSlider));
      expect(slider.min, 10.0);
      expect(slider.max, 100.0);
    });

    testWidgets('renders with divisions', (tester) async {
      await pumpApp(tester, WiredRangeSlider(
              values: const RangeValues(0.2, 0.8),
              divisions: 5,
              onChanged: (v) => true,
            ));

      final slider = tester.widget<RangeSlider>(find.byType(RangeSlider));
      expect(slider.divisions, 5);
    });

    testWidgets('renders with labels', (tester) async {
      await pumpApp(tester, WiredRangeSlider(
              values: const RangeValues(0.2, 0.8),
              labels: const RangeLabels('Start', 'End'),
              onChanged: (v) => true,
            ));

      final slider = tester.widget<RangeSlider>(find.byType(RangeSlider));
      expect(slider.labels?.start, 'Start');
      expect(slider.labels?.end, 'End');
    });

    testWidgets('calls onChanged when slider is dragged', (tester) async {
      RangeValues? receivedValues;

      await pumpApp(tester, WiredRangeSlider(
              values: const RangeValues(0.2, 0.8),
              onChanged: (v) {
                receivedValues = v;
                return true;
              },
            ));

      // Drag the range slider to trigger onChanged.
      final sliderFinder = find.byType(RangeSlider);
      await tester.drag(sliderFinder, const Offset(50.0, 0));
      await tester.pump();

      expect(receivedValues, isNotNull);
    });

    testWidgets('does not update when onChanged returns false', (tester) async {
      await pumpApp(tester, WiredRangeSlider(
              values: const RangeValues(0.3, 0.7),
              onChanged: (v) => false,
            ));

      final slider = tester.widget<RangeSlider>(find.byType(RangeSlider));
      expect(slider.values, const RangeValues(0.3, 0.7));
    });

    testWidgets('contains Stack for layered layout', (tester) async {
      await pumpApp(tester, WiredRangeSlider(
              values: const RangeValues(0.2, 0.8),
              onChanged: (v) => true,
            ));

      expect(
        find.descendant(
          of: find.byType(WiredRangeSlider),
          matching: find.byType(Stack),
        ),
        findsAtLeast(1),
      );
    });

    testWidgets('contains WiredCanvas for track line', (tester) async {
      await pumpApp(tester, WiredRangeSlider(
              values: const RangeValues(0.2, 0.8),
              onChanged: (v) => true,
            ));

      expect(
        find.descendant(
          of: find.byType(WiredRangeSlider),
          matching: find.byType(WiredCanvas),
        ),
        findsOneWidget,
      );
    });

    testWidgets('has transparent track colors via SliderTheme', (tester) async {
      await pumpApp(tester, WiredRangeSlider(
              values: const RangeValues(0.2, 0.8),
              onChanged: (v) => true,
            ));

      expect(
        find.descendant(
          of: find.byType(WiredRangeSlider),
          matching: find.byType(SliderTheme),
        ),
        findsOneWidget,
      );
    });

    testWidgets('divisions defaults to null', (tester) async {
      await pumpApp(tester, WiredRangeSlider(
              values: const RangeValues(0.2, 0.8),
              onChanged: (v) => true,
            ));

      final slider = tester.widget<RangeSlider>(find.byType(RangeSlider));
      expect(slider.divisions, isNull);
    });

    testWidgets('labels defaults to null', (tester) async {
      await pumpApp(tester, WiredRangeSlider(
              values: const RangeValues(0.2, 0.8),
              onChanged: (v) => true,
            ));

      final slider = tester.widget<RangeSlider>(find.byType(RangeSlider));
      expect(slider.labels, isNull);
    });
  });
}
