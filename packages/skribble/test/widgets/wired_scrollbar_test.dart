import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';

void main() {
  group('WiredScrollbar', () {
    testWidgets('renders child content', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WiredScrollbar(
              child: ListView(
                children: const [
                  Text('Item 1'),
                  Text('Item 2'),
                  Text('Item 3'),
                ],
              ),
            ),
          ),
        ),
      );
      expect(find.text('Item 1'), findsOneWidget);
      expect(find.byType(WiredScrollbar), findsOneWidget);
      expect(find.byType(Scrollbar), findsOneWidget);
    });

    testWidgets('wraps content in a Scrollbar', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WiredScrollbar(
              thumbVisibility: true,
              child: ListView.builder(
                itemCount: 50,
                itemBuilder: (_, i) => Text('Row $i'),
              ),
            ),
          ),
        ),
      );

      final scrollbar = tester.widget<Scrollbar>(find.byType(Scrollbar));
      expect(scrollbar.thumbVisibility, isTrue);
    });

    testWidgets('accepts custom thickness', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WiredScrollbar(
              thickness: 10,
              child: ListView(children: const [Text('A')]),
            ),
          ),
        ),
      );
      expect(find.byType(WiredScrollbar), findsOneWidget);
    });
  });
}
