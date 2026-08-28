import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';

import '../helpers/finders.dart';
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
      await pumpApp(tester, WiredCard(fill: true, child: const Text('Filled')));

      expect(findWiredCanvas, findsOneWidget);
      expect(find.text('Filled'), findsOneWidget);
    });

    testWidgets('fill defaults to false', (tester) async {
      await pumpApp(tester, WiredCard(child: const Text('No fill')));

      expect(find.byType(WiredCard), findsOneWidget);
      expect(find.text('No fill'), findsOneWidget);
    });

    group('borderRadius', () {
      /// Returns the painter used by the card's [WiredCanvas].
      WiredPainterBase painterOf(WidgetTester tester) {
        final canvases = tester.widgetList<WiredCanvas>(
          find.descendant(
            of: find.byType(WiredCard),
            matching: find.byType(WiredCanvas),
          ),
        );

        expect(canvases, isNotEmpty);
        return canvases.first.painter;
      }

      testWidgets(
        'defaults to sharp rectangle painter when borderRadius is null',
        (tester) async {
          await pumpApp(tester, WiredCard(child: const Text('Sharp')));

          expect(painterOf(tester), isA<WiredRectangleBase>());
        },
      );

      testWidgets(
        'uses rounded rectangle painter with BorderRadius.circular(0)',
        (tester) async {
          await pumpApp(
            tester,
            WiredCard(
              borderRadius: BorderRadius.circular(0),
              child: const Text('Zero radius'),
            ),
          );

          final painter = painterOf(tester);
          expect(painter, isA<WiredRoundedRectangleBase>());
          expect(
            (painter as WiredRoundedRectangleBase).borderRadius,
            BorderRadius.circular(0),
          );
          expect(find.text('Zero radius'), findsOneWidget);
        },
      );

      testWidgets('uses rounded rectangle painter with a small radius (4)', (
        tester,
      ) async {
        await pumpApp(
          tester,
          WiredCard(
            borderRadius: BorderRadius.circular(4),
            child: const Text('Small radius'),
          ),
        );

        final painter = painterOf(tester);
        expect(painter, isA<WiredRoundedRectangleBase>());
        expect(
          (painter as WiredRoundedRectangleBase).borderRadius,
          BorderRadius.circular(4),
        );
      });

      testWidgets('uses rounded rectangle painter with a large radius (20)', (
        tester,
      ) async {
        await pumpApp(
          tester,
          WiredCard(
            borderRadius: BorderRadius.circular(20),
            child: const Text('Large radius'),
          ),
        );

        final painter = painterOf(tester);
        expect(painter, isA<WiredRoundedRectangleBase>());
        expect(
          (painter as WiredRoundedRectangleBase).borderRadius,
          BorderRadius.circular(20),
        );
      });

      testWidgets('plumbs per-corner BorderRadius.only through', (
        tester,
      ) async {
        const perCorner = BorderRadius.only(
          topLeft: Radius.circular(2),
          topRight: Radius.circular(6),
          bottomRight: Radius.circular(10),
          bottomLeft: Radius.circular(14),
        );

        await pumpApp(
          tester,
          WiredCard(borderRadius: perCorner, child: const Text('Per corner')),
        );

        final painter = painterOf(tester);
        expect(painter, isA<WiredRoundedRectangleBase>());
        expect(
          (painter as WiredRoundedRectangleBase).borderRadius,
          perCorner,
        );
      });

      testWidgets('renders child content with a border radius', (tester) async {
        await pumpApp(
          tester,
          WiredCard(
            fill: true,
            borderRadius: BorderRadius.circular(12),
            child: const Text('Filled and rounded'),
          ),
        );

        expect(find.text('Filled and rounded'), findsOneWidget);
        expect(findWiredCanvas, findsOneWidget);
      });

      testWidgets('rebuilds when the border radius changes', (tester) async {
        await pumpApp(
          tester,
          WiredCard(
            borderRadius: BorderRadius.circular(4),
            child: const Text('Rebuild'),
          ),
        );
        expect(
          (painterOf(tester) as WiredRoundedRectangleBase).borderRadius,
          BorderRadius.circular(4),
        );

        await pumpApp(
          tester,
          WiredCard(
            borderRadius: BorderRadius.circular(20),
            child: const Text('Rebuild'),
          ),
        );
        expect(
          (painterOf(tester) as WiredRoundedRectangleBase).borderRadius,
          BorderRadius.circular(20),
        );
      });
    });
  });
}
