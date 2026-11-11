import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';
import 'package:skribble/testing.dart';

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
    testWidgets('spans a bounded width and wraps an unbounded one', (
      tester,
    ) async {
      await pumpApp(
        tester,
        Column(
          children: [
            SizedBox(width: 300, child: WiredCard(child: const Text('Wide'))),
            SizedBox(
              height: 140,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: const [WiredCard(child: Text('Narrow'))],
              ),
            ),
            SizedBox(
              width: 300,
              child: Align(
                alignment: Alignment.centerLeft,
                child: WiredCard(height: null, child: const Text('Hugged')),
              ),
            ),
          ],
        ),
      );

      expect(tester.takeException(), isNull);
      expect(tester.getSize(find.byType(WiredCard).at(0)).width, 300);
      expect(tester.getSize(find.byType(WiredCard).at(1)).width, lessThan(300));
      expect(tester.getSize(find.byType(WiredCard).at(2)).width, lessThan(300));
    });

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

    testWidgets('keeps its text the ink padding from the outline', (
      tester,
    ) async {
      await pumpApp(
        tester,
        const Padding(
          padding: EdgeInsets.all(16),
          child: WiredCard(child: Text('Hello from a card')),
        ),
      );

      final card = tester.getRect(find.byType(WiredCard));
      final text = tester.getRect(find.text('Hello from a card'));
      expect(text.left - card.left, 12);
      expect(text.top - card.top, 8);
      expect(crampedText(tester.binding.renderViews.first), isEmpty);
    });

    testWidgets('grows past its height for taller content', (tester) async {
      await pumpApp(
        tester,
        const WiredCard(child: SizedBox(height: 200, width: 100)),
      );

      // 200 of content and 8 of ink padding above and below.
      expect(tester.getSize(find.byType(WiredCard)).height, 216);
      expect(tester.takeException(), isNull);
    });

    testWidgets('padding can be removed for a child with its own', (
      tester,
    ) async {
      await pumpApp(
        tester,
        const Padding(
          padding: EdgeInsets.all(16),
          child: WiredCard(padding: EdgeInsets.zero, child: Text('Flush')),
        ),
      );

      final card = tester.getRect(find.byType(WiredCard));
      expect(tester.getRect(find.text('Flush')).topLeft, card.topLeft);
    });
    testWidgets('a colour washes the card with a solid fill', (tester) async {
      await pumpWired(
        tester,
        const SizedBox(
          width: 200,
          child: WiredCard(color: WiredPalette.sky, child: Text('Wash')),
        ),
      );
      final canvas = tester.widget<WiredCanvas>(
        find.descendant(
          of: find.byType(WiredCard),
          matching: find.byType(WiredCanvas),
        ),
      );
      expect(canvas.fillerType, RoughFilter.solidFiller);
      expect(
        (canvas.painter as WiredRoundedRectangleBase).fillColor,
        WiredPalette.sky,
      );
    });

    testWidgets('a colour with fill hatches the card in that colour', (
      tester,
    ) async {
      await pumpWired(
        tester,
        const SizedBox(
          width: 200,
          child: WiredCard(color: WiredPalette.mint, fill: true),
        ),
      );
      final canvas = tester.widget<WiredCanvas>(
        find.descendant(
          of: find.byType(WiredCard),
          matching: find.byType(WiredCanvas),
        ),
      );
      expect(canvas.fillerType, RoughFilter.hachureFiller);
      expect(
        (canvas.painter as WiredRoundedRectangleBase).fillColor,
        WiredPalette.mint,
      );
    });

    testWidgets('content on a vivid wash turns dark at night', (tester) async {
      await pumpWired(
        tester,
        const SizedBox(
          width: 200,
          child: WiredCard(color: WiredPalette.sunshine, child: Text('Glow')),
        ),
        theme: WiredThemeData.cuddly(brightness: Brightness.dark),
      );
      final style = DefaultTextStyle.of(tester.element(find.text('Glow')));
      expect(style.style.color, WiredPalette.night);
    });
  });
}
