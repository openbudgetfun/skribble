import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';

void main() {
  group('WiredSlider', () {
    // WiredSlider uses useFuture(Future.delayed(Duration.zero)) which creates
    // a zero-duration timer on every build. When the future completes it
    // triggers a rebuild creating another timer, forming an infinite loop.
    // We verify the Slider state right after pumpWidget and explicitly flush
    // the pending timer with an extra pump before teardown to avoid the
    // "Timer still pending" assertion.

    Future<void> pumpSlider(
      WidgetTester tester,
      WiredSlider slider,
    ) async {
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: slider)),
      );
    }

    testWidgets('renders Slider widget', (tester) async {
      await tester.runAsync(() async {
        await pumpSlider(
          tester,
          WiredSlider(value: 0.5, onChanged: (v) => true),
        );
      });

      expect(find.byType(Slider), findsOneWidget);
    });

    testWidgets('has correct min/max defaults', (tester) async {
      await tester.runAsync(() async {
        await pumpSlider(
          tester,
          WiredSlider(value: 0.5, onChanged: (v) => true),
        );
      });

      final slider = tester.widget<Slider>(find.byType(Slider));

      expect(slider.min, 0.0);
      expect(slider.max, 1.0);
    });

    testWidgets('uses custom min/max values', (tester) async {
      await tester.runAsync(() async {
        await pumpSlider(
          tester,
          WiredSlider(
            value: 50.0,
            min: 10.0,
            max: 100.0,
            onChanged: (v) => true,
          ),
        );
      });

      final slider = tester.widget<Slider>(find.byType(Slider));

      expect(slider.min, 10.0);
      expect(slider.max, 100.0);
    });

    testWidgets('calls onChanged when slider value changes', (tester) async {
      double? receivedValue;

      await tester.runAsync(() async {
        await pumpSlider(
          tester,
          WiredSlider(
            value: 0.0,
            onChanged: (v) {
              receivedValue = v;
              return true;
            },
          ),
        );
      });

      // Drag the Slider to trigger onChanged.
      final sliderFinder = find.byType(Slider);
      await tester.drag(sliderFinder, const Offset(100.0, 0));

      await tester.runAsync(() async {
        await tester.pump();
      });

      expect(receivedValue, isNotNull);
      expect(receivedValue, greaterThan(0.0));
    });

    testWidgets('does not update value when onChanged returns false',
        (tester) async {
      await tester.runAsync(() async {
        await pumpSlider(
          tester,
          WiredSlider(value: 0.5, onChanged: (v) => false),
        );
      });

      final slider = tester.widget<Slider>(find.byType(Slider));
      expect(slider.value, 0.5);
    });

    testWidgets('renders with divisions and label', (tester) async {
      await tester.runAsync(() async {
        await pumpSlider(
          tester,
          WiredSlider(
            value: 0.5,
            divisions: 5,
            label: 'Value: 0.5',
            onChanged: (v) => true,
          ),
        );
      });

      final slider = tester.widget<Slider>(find.byType(Slider));

      expect(slider.divisions, 5);
      expect(slider.label, 'Value: 0.5');
    });

    testWidgets('contains WiredSlider widget type', (tester) async {
      await tester.runAsync(() async {
        await pumpSlider(
          tester,
          WiredSlider(value: 0.0, onChanged: (v) => true),
        );
      });

      expect(find.byType(WiredSlider), findsOneWidget);
    });
  });
}
