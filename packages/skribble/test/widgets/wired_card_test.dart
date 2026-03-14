import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';

import '../helpers/pump_app.dart';

void main() {
  group('WiredCard', () {
    testWidgets('renders child widget', (tester) async {
      await pumpApp(tester, WiredCard(child: const Text('Card content')));

      expect(find.text('Card content'), findsOneWidget);
    });

    testWidgets('renders with default height (130.0)', (tester) async {
      await pumpApp(tester, WiredCard(child: const Text('Default height')));

      final cardSize = tester.getSize(find.byType(WiredCard));
      expect(cardSize.height, 130.0);
    });

    testWidgets('renders with custom height', (tester) async {
      await pumpApp(
        tester,
        WiredCard(height: 200.0, child: const Text('Custom height')),
      );

      final cardSize = tester.getSize(find.byType(WiredCard));
      expect(cardSize.height, 200.0);
    });

    testWidgets('renders with null height (uses IntrinsicHeight)', (
      tester,
    ) async {
      await pumpApp(
        tester,
        WiredCard(height: null, child: const Text('Intrinsic')),
      );

      expect(
        find.descendant(
          of: find.byType(WiredCard),
          matching: find.byType(IntrinsicHeight),
        ),
        findsOneWidget,
      );
    });

    testWidgets('does not use IntrinsicHeight when height is provided', (
      tester,
    ) async {
      await pumpApp(
        tester,
        WiredCard(height: 130.0, child: const Text('No intrinsic')),
      );

      expect(
        find.descendant(
          of: find.byType(WiredCard),
          matching: find.byType(IntrinsicHeight),
        ),
        findsNothing,
      );
    });

    testWidgets('fill parameter adds filler', (tester) async {
      await pumpApp(
        tester,
        WiredCard(fill: true, child: const Text('Filled')),
      );

      expect(find.byType(WiredCanvas), findsOneWidget);
      expect(find.text('Filled'), findsOneWidget);
    });

    testWidgets('fill defaults to false', (tester) async {
      await pumpApp(tester, WiredCard(child: const Text('No fill')));

      expect(find.byType(WiredCard), findsOneWidget);
      expect(find.text('No fill'), findsOneWidget);
    });
  });
}
