import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';

import '../helpers/finders.dart';
import '../helpers/pump_app.dart';

void main() {
  testWidgets(
    'natural height accepts responsive content without intrinsic layout',
    (tester) async {
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Center(
            child: SizedBox(
              width: 240,
              child: WiredCard(
                height: null,
                child: LayoutBuilder(
                  builder: (context, constraints) => SizedBox(
                    height: constraints.maxWidth / 2,
                    child: const Text('Responsive paper'),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      expect(tester.takeException(), isNull);
      expect(
        tester.getSize(find.byType(WiredCard)).height,
        greaterThanOrEqualTo(100),
      );
    },
  );

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

    testWidgets('null height follows the child height', (tester) async {
      await pumpApp(
        tester,
        const WiredCard(
          height: null,
          child: SizedBox(height: 80, child: Text('Natural paper')),
        ),
      );
      final initial = tester.getSize(find.byType(WiredCard)).height;
      await pumpApp(
        tester,
        const WiredCard(
          height: null,
          child: SizedBox(height: 180, child: Text('Natural paper')),
        ),
      );
      expect(tester.getSize(find.byType(WiredCard)).height - initial, 100);
      expect(find.text('Natural paper'), findsOneWidget);
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
      await pumpApp(tester, WiredCard(fill: true, child: const Text('Filled')));

      expect(findWiredCanvas, findsOneWidget);
      expect(find.text('Filled'), findsOneWidget);
    });

    testWidgets('fill defaults to false', (tester) async {
      await pumpApp(tester, WiredCard(child: const Text('No fill')));

      expect(find.byType(WiredCard), findsOneWidget);
      expect(find.text('No fill'), findsOneWidget);
    });
  });
}
