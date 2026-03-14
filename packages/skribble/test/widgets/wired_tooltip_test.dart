import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';

import '../helpers/pump_app.dart';

void main() {
  group('WiredTooltip', () {
    testWidgets('renders without error', (tester) async {
      await pumpApp(tester, WiredTooltip(
              message: 'Tooltip text',
              child: const Text('Hover me'),
            ));

      expect(find.byType(WiredTooltip), findsOneWidget);
    });

    testWidgets('renders child content', (tester) async {
      await pumpApp(tester, WiredTooltip(
              message: 'Tooltip',
              child: const Icon(Icons.info),
            ));

      expect(find.byIcon(Icons.info), findsOneWidget);
    });

    testWidgets('contains Tooltip widget internally', (tester) async {
      await pumpApp(tester, WiredTooltip(
              message: 'Internal tooltip',
              child: const Text('Child'),
            ));

      expect(
        find.descendant(
          of: find.byType(WiredTooltip),
          matching: find.byType(Tooltip),
        ),
        findsOneWidget,
      );
    });

    testWidgets('tooltip message is set correctly', (tester) async {
      await pumpApp(tester, WiredTooltip(
              message: 'My tooltip message',
              child: const Text('Target'),
            ));

      final tooltip = tester.widget<Tooltip>(find.byType(Tooltip));
      expect(tooltip.message, 'My tooltip message');
    });

    testWidgets('shows tooltip on long press', (tester) async {
      await pumpApp(tester, WiredTooltip(
              message: 'Long press tooltip',
              child: const Text('Press me'),
            ));

      // Long press to trigger the tooltip.
      await tester.longPress(find.text('Press me'));
      await tester.pumpAndSettle();

      expect(find.text('Long press tooltip'), findsOneWidget);
    });

    testWidgets('accepts waitDuration parameter', (tester) async {
      await pumpApp(tester, WiredTooltip(
              message: 'Wait tooltip',
              waitDuration: const Duration(seconds: 2),
              child: const Text('Wait'),
            ));

      final tooltip = tester.widget<Tooltip>(find.byType(Tooltip));
      expect(tooltip.waitDuration, const Duration(seconds: 2));
    });

    testWidgets('accepts showDuration parameter', (tester) async {
      await pumpApp(tester, WiredTooltip(
              message: 'Show tooltip',
              showDuration: const Duration(seconds: 5),
              child: const Text('Show'),
            ));

      final tooltip = tester.widget<Tooltip>(find.byType(Tooltip));
      expect(tooltip.showDuration, const Duration(seconds: 5));
    });

    testWidgets('waitDuration defaults to null', (tester) async {
      await pumpApp(tester, WiredTooltip(
              message: 'Default',
              child: const Text('Default durations'),
            ));

      final tooltip = tester.widget<Tooltip>(find.byType(Tooltip));
      expect(tooltip.waitDuration, isNull);
      expect(tooltip.showDuration, isNull);
    });

    testWidgets('has RoughBoxDecoration on tooltip', (tester) async {
      await pumpApp(tester, WiredTooltip(
              message: 'Decorated',
              child: const Text('Styled'),
            ));

      final tooltip = tester.widget<Tooltip>(find.byType(Tooltip));
      expect(tooltip.decoration, isA<RoughBoxDecoration>());
    });
  });
}
