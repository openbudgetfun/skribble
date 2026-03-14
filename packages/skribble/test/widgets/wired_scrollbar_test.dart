import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';

import '../helpers/pump_app.dart';

void main() {
  group('WiredScrollbar', () {
    testWidgets('renders child content', (tester) async {
      await pumpApp(
        tester,
        WiredScrollbar(
          child: ListView(
            children: const [Text('Item 1'), Text('Item 2'), Text('Item 3')],
          ),
        ),
      );
      expect(find.text('Item 1'), findsOneWidget);
      expect(find.byType(WiredScrollbar), findsOneWidget);
      expect(find.byType(Scrollbar), findsOneWidget);
    });

    testWidgets('wraps content in a Scrollbar', (tester) async {
      await pumpApp(
        tester,
        WiredScrollbar(
          thumbVisibility: true,
          child: ListView.builder(
            itemCount: 50,
            itemBuilder: (_, i) => Text('Row $i'),
          ),
        ),
      );

      final scrollbar = tester.widget<Scrollbar>(find.byType(Scrollbar));
      expect(scrollbar.thumbVisibility, isTrue);
    });

    testWidgets('accepts custom thickness', (tester) async {
      await pumpApp(
        tester,
        WiredScrollbar(
          thickness: 10,
          child: ListView(children: const [Text('A')]),
        ),
      );
      expect(find.byType(WiredScrollbar), findsOneWidget);
    });

    testWidgets('accepts custom scroll controller', (tester) async {
      final scrollController = ScrollController();
      addTearDown(scrollController.dispose);

      await pumpApp(
        tester,
        WiredScrollbar(
          controller: scrollController,
          child: ListView.builder(
            controller: scrollController,
            itemCount: 100,
            itemBuilder: (_, i) => Text('Row $i'),
          ),
        ),
      );

      expect(find.byType(WiredScrollbar), findsOneWidget);
      expect(find.byType(Scrollbar), findsOneWidget);
    });

    testWidgets('accepts custom radius', (tester) async {
      await pumpApp(
        tester,
        WiredScrollbar(
          radius: const Radius.circular(8),
          child: ListView(children: const [Text('Content')]),
        ),
      );
      expect(find.byType(WiredScrollbar), findsOneWidget);
    });

    testWidgets('contains RepaintBoundary', (tester) async {
      await pumpApp(
        tester,
        WiredScrollbar(child: ListView(children: const [Text('Test')])),
      );

      expect(find.byType(RepaintBoundary), findsWidgets);
    });
  });
}
