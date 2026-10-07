import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';
import 'package:skribble/src/wired_button_base.dart';

import '../helpers/pump_app.dart';

/// Every rectangular button built on `WiredButtonBase`.
final Map<String, Widget Function(Widget label)> _buttons = {
  'WiredButton': (label) => WiredButton(onPressed: () {}, child: label),
  'WiredElevatedButton': (label) =>
      WiredElevatedButton(onPressed: () {}, child: label),
  'WiredFilledButton': (label) =>
      WiredFilledButton(onPressed: () {}, child: label),
  'WiredOutlinedButton': (label) =>
      WiredOutlinedButton(onPressed: () {}, child: label),
};

void main() {
  for (final MapEntry(key: name, value: build) in _buttons.entries) {
    group(name, () {
      testWidgets('is kWiredButtonHeight tall with a default label', (
        tester,
      ) async {
        await pumpApp(tester, Center(child: build(const Text('Save'))));
        expect(
          tester.getSize(find.byWidgetPredicate(_isButton)).height,
          kWiredButtonHeight,
        );
      });

      testWidgets('grows with a larger label instead of clipping it', (
        tester,
      ) async {
        await pumpApp(
          tester,
          Center(
            child: build(const Text('Save', style: TextStyle(fontSize: 32))),
          ),
        );
        final button = tester.getRect(find.byWidgetPredicate(_isButton));
        final label = tester.getRect(find.text('Save'));
        expect(button.height, greaterThan(kWiredButtonHeight));
        expect(label.top - button.top, greaterThanOrEqualTo(8));
        expect(button.bottom - label.bottom, greaterThanOrEqualTo(8));
        expect(tester.takeException(), isNull);
      });

      testWidgets('pads the label from the side ink', (tester) async {
        await pumpApp(tester, Center(child: build(const Text('Save'))));
        final button = tester.getRect(find.byWidgetPredicate(_isButton));
        final label = tester.getRect(find.text('Save'));
        expect(
          label.left - button.left,
          greaterThanOrEqualTo(kWiredButtonPadding.left),
        );
        expect(
          button.right - label.right,
          greaterThanOrEqualTo(kWiredButtonPadding.right),
        );
      });
    });
  }
}

bool _isButton(Widget widget) => widget is WiredButtonBase;
