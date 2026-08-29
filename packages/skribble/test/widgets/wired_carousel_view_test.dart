import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';

import '../helpers/finders.dart';
import '../helpers/pump_app.dart';

void main() {
  group('WiredCarouselView', () {
    Widget buildItem(String label) => Center(child: Text(label));

    testWidgets('renders without error', (tester) async {
      await pumpApp(
        tester,
        WiredCarouselView(
          children: [
            buildItem('Item 1'),
            buildItem('Item 2'),
          ],
        ),
      );

      expect(find.byType(WiredCarouselView), findsOneWidget);
    });

    testWidgets('renders child content', (tester) async {
      await pumpApp(
        tester,
        WiredCarouselView(
          children: [
            buildItem('Item 1'),
            buildItem('Item 2'),
          ],
        ),
      );

      expect(find.text('Item 1'), findsOneWidget);
      expect(find.text('Item 2'), findsOneWidget);
    });

    testWidgets('draws a WiredCanvas border card per item', (tester) async {
      await pumpApp(
        tester,
        WiredCarouselView(
          children: [
            buildItem('Item 1'),
            buildItem('Item 2'),
          ],
        ),
      );

      // One canvas per item plus none extra for the container itself.
      expect(findWiredCanvas, findsNWidgets(2));
      expect(findRepaintBoundary, findsWidgets);
    });

    testWidgets('uses default item extent of 220', (tester) async {
      await pumpApp(
        tester,
        WiredCarouselView(children: [buildItem('Item 1')]),
      );

      final item = find.descendant(
        of: find.byType(WiredCarouselView),
        matching: find.byType(GestureDetector).first,
      );
      expect(tester.getSize(item).width, 220.0);
    });

    testWidgets('honors custom item extent', (tester) async {
      await pumpApp(
        tester,
        WiredCarouselView(
          itemExtent: 140,
          children: [buildItem('Item 1'), buildItem('Item 2')],
        ),
      );

      final item = find.descendant(
        of: find.byType(WiredCarouselView),
        matching: find.byType(GestureDetector).first,
      );
      expect(tester.getSize(item).width, 140.0);
    });

    testWidgets('uses default height of 200', (tester) async {
      await pumpApp(
        tester,
        WiredCarouselView(children: [buildItem('Item 1')]),
      );

      expect(tester.getSize(find.byType(WiredCarouselView)).height, 200.0);
    });

    testWidgets('honors custom height', (tester) async {
      await pumpApp(
        tester,
        WiredCarouselView(
          height: 120,
          children: [buildItem('Item 1')],
        ),
      );

      expect(tester.getSize(find.byType(WiredCarouselView)).height, 120.0);
    });

    testWidgets('applies hachure fill when fill is true', (tester) async {
      await pumpApp(
        tester,
        WiredCarouselView(
          fill: true,
          children: [buildItem('Item 1')],
        ),
      );

      final canvas = tester.widget<WiredCanvas>(findWiredCanvas.first);
      expect(canvas.fillerType, RoughFilter.hachureFiller);
    });

    testWidgets('uses no filler by default', (tester) async {
      await pumpApp(
        tester,
        WiredCarouselView(children: [buildItem('Item 1')]),
      );

      final canvas = tester.widget<WiredCanvas>(findWiredCanvas.first);
      expect(canvas.fillerType, RoughFilter.noFiller);
    });

    testWidgets('calls onTap with the tapped item index', (tester) async {
      int? tappedIndex;

      await pumpApp(
        tester,
        WiredCarouselView(
          onTap: (index) => tappedIndex = index,
          children: [
            buildItem('Item 1'),
            buildItem('Item 2'),
          ],
        ),
      );

      await tester.tap(find.text('Item 2'));
      await tester.pump();

      expect(tappedIndex, 1);
    });

    testWidgets('tapping without onTap does not throw', (tester) async {
      await pumpApp(
        tester,
        WiredCarouselView(children: [buildItem('Item 1')]),
      );

      await tester.tap(find.text('Item 1'));
      await tester.pump();

      expect(tester.takeException(), isNull);
    });

    testWidgets('supports reverse scrolling order', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Align(
              alignment: Alignment.topLeft,
              child: WiredCarouselView(
                reverse: true,
                itemExtent: 200,
                height: 100,
                children: [
                  buildItem('Item 1'),
                  buildItem('Item 2'),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      final firstDx = tester.getTopLeft(find.text('Item 1')).dx;
      final secondDx = tester.getTopLeft(find.text('Item 2')).dx;

      // In reverse mode the first child appears on the trailing (right) side,
      // so "Item 2" must be laid out to the left of "Item 1".
      expect(secondDx, lessThan(firstDx));
    });

    testWidgets('applies carousel padding', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Align(
              alignment: Alignment.topLeft,
              child: WiredCarouselView(
                padding: const EdgeInsets.all(24),
                children: [buildItem('Item 1')],
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      final itemDx = tester
          .getTopLeft(
            find.descendant(
              of: find.byType(WiredCarouselView),
              matching: find.byType(GestureDetector).first,
            ),
          )
          .dx;
      expect(itemDx, 24.0);
    });

    testWidgets('exposes a semantic label for accessibility', (tester) async {
      await pumpApp(
        tester,
        WiredCarouselView(
          semanticLabel: 'Photo carousel',
          onTap: (_) {},
          children: [buildItem('Item 1')],
        ),
      );

      expect(find.bySemanticsLabel('Photo carousel'), findsOneWidget);
    });

    testWidgets('marks items as buttons when onTap is set', (tester) async {
      final handle = tester.ensureSemantics();
      int? tappedIndex;

      await pumpApp(
        tester,
        WiredCarouselView(
          onTap: (index) => tappedIndex = index,
          itemExtent: 200,
          height: 100,
          children: [buildItem('Item 1')],
        ),
      );

      // Assistive technologies can activate the item through the semantics
      // tree (a tap handler is attached to the item's node).
      await tester.tap(find.text('Item 1'));
      await tester.pump();

      expect(tappedIndex, 0);
      handle.dispose();
    });

    testWidgets('handles rapid sequential taps', (tester) async {
      final taps = <int>[];

      await pumpApp(
        tester,
        WiredCarouselView(
          onTap: taps.add,
          children: [
            buildItem('Item 1'),
            buildItem('Item 2'),
          ],
        ),
      );

      await tester.tap(find.text('Item 1'));
      await tester.tap(find.text('Item 1'));
      await tester.tap(find.text('Item 2'));
      await tester.pump();

      expect(taps, [0, 0, 1]);
    });
  });
}
