import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';

import 'helpers/pump_app.dart';

void main() {
  group('WiredButton', () {
    testWidgets('renders child text', (tester) async {
      await pumpApp(
        tester,
        WiredButton(onPressed: () {}, child: const Text('Press me')),
      );

      expect(find.text('Press me'), findsOneWidget);
    });

    testWidgets('calls onPressed when tapped', (tester) async {
      var pressed = false;
      await pumpApp(
        tester,
        WiredButton(
          onPressed: () => pressed = true,
          child: const Text('Tap'),
        ),
      );

      await tester.tap(find.text('Tap'));
      expect(pressed, isTrue);
    });
  });

  group('WiredInput', () {
    testWidgets('accepts text input', (tester) async {
      final controller = TextEditingController();
      addTearDown(controller.dispose);
      await pumpApp(
        tester,
        WiredInput(controller: controller, hintText: 'Enter text'),
      );

      await tester.enterText(find.byType(TextField), 'hello');
      expect(controller.text, 'hello');
    });
  });

  group('WiredCard', () {
    testWidgets('renders child widget', (tester) async {
      await pumpApp(
        tester,
        WiredCard(child: const Text('Card content')),
      );

      expect(find.text('Card content'), findsOneWidget);
    });
  });

  group('WiredCheckbox', () {
    testWidgets('toggles when tapped', (tester) async {
      bool? lastValue;
      await pumpApp(
        tester,
        WiredCheckbox(value: false, onChanged: (v) => lastValue = v),
      );

      await tester.tap(find.byType(Checkbox));
      await tester.pump();
      expect(lastValue, isTrue);
    });
  });

  group('WiredToggle', () {
    testWidgets('renders without error', (tester) async {
      await pumpApp(
        tester,
        Center(
          child: SizedBox(
            width: 100,
            height: 100,
            child: WiredToggle(value: false, onChange: (v) => true),
          ),
        ),
      );

      expect(find.byType(WiredToggle), findsOneWidget);
      expect(find.byType(GestureDetector), findsOneWidget);
    });
  });
}
