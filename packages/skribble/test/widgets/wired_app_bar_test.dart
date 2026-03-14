import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';

import '../helpers/pump_app.dart';

void main() {
  group('WiredAppBar', () {
    testWidgets('renders without error', (tester) async {
      await pumpApp(
        tester,
        WiredAppBar(title: const Text('Test')),
        asAppBar: true,
      );

      expect(find.byType(WiredAppBar), findsOneWidget);
    });

    testWidgets('renders title text', (tester) async {
      await pumpApp(
        tester,
        WiredAppBar(title: const Text('My Title')),
        asAppBar: true,
      );

      expect(find.text('My Title'), findsOneWidget);
    });

    testWidgets('renders leading widget', (tester) async {
      await pumpApp(
        tester,
        WiredAppBar(
          leading: const Icon(Icons.menu),
          title: const Text('Title'),
        ),
        asAppBar: true,
      );

      expect(find.byIcon(Icons.menu), findsOneWidget);
    });

    testWidgets('renders action widgets', (tester) async {
      await pumpApp(
        tester,
        WiredAppBar(
          title: const Text('Title'),
          actions: [
            IconButton(icon: const Icon(Icons.search), onPressed: () {}),
            IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
          ],
        ),
        asAppBar: true,
      );

      expect(find.byIcon(Icons.search), findsOneWidget);
      expect(find.byIcon(Icons.more_vert), findsOneWidget);
    });

    testWidgets('default height is 56.0', (tester) async {
      await pumpApp(
        tester,
        WiredAppBar(title: const Text('Height')),
        asAppBar: true,
      );

      final appBar = tester.widget<WiredAppBar>(find.byType(WiredAppBar));
      expect(appBar.preferredSize.height, 56.0);
    });

    testWidgets('accepts custom height', (tester) async {
      await pumpApp(
        tester,
        WiredAppBar(title: const Text('Custom'), height: 80.0),
        asAppBar: true,
      );

      final appBar = tester.widget<WiredAppBar>(find.byType(WiredAppBar));
      expect(appBar.preferredSize.height, 80.0);
    });

    testWidgets('implements PreferredSizeWidget', (tester) async {
      const appBar = WiredAppBar(title: Text('Preferred'));
      expect(appBar, isA<PreferredSizeWidget>());
      expect(appBar.preferredSize, const Size.fromHeight(56.0));
    });

    testWidgets('renders hand-drawn bottom line via WiredCanvas', (
      tester,
    ) async {
      await pumpApp(
        tester,
        WiredAppBar(title: const Text('Line')),
        asAppBar: true,
      );

      expect(
        find.descendant(
          of: find.byType(WiredAppBar),
          matching: find.byType(WiredCanvas),
        ),
        findsOneWidget,
      );
    });

    testWidgets('uses transparent background by default', (tester) async {
      await pumpApp(
        tester,
        WiredAppBar(title: const Text('Bg')),
        asAppBar: true,
      );

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(WiredAppBar),
          matching: find.byType(Container),
        ),
      );

      expect(container.color, Colors.transparent);
    });

    testWidgets('applies custom background color', (tester) async {
      await pumpApp(
        tester,
        WiredAppBar(title: const Text('Color'), backgroundColor: Colors.blue),
        asAppBar: true,
      );

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(WiredAppBar),
          matching: find.byType(Container),
        ),
      );

      expect(container.color, Colors.blue);
    });

    testWidgets('renders Spacer when no title is provided', (tester) async {
      await pumpApp(tester, WiredAppBar(), asAppBar: true);

      expect(
        find.descendant(
          of: find.byType(WiredAppBar),
          matching: find.byType(Spacer),
        ),
        findsOneWidget,
      );
    });

    testWidgets('wraps title in DefaultTextStyle', (tester) async {
      await pumpApp(
        tester,
        WiredAppBar(title: const Text('Styled')),
        asAppBar: true,
      );

      expect(
        find.descendant(
          of: find.byType(WiredAppBar),
          matching: find.byType(DefaultTextStyle),
        ),
        findsWidgets,
      );
    });

    testWidgets('action button is tappable', (tester) async {
      var tapped = false;

      await pumpApp(
        tester,
        WiredAppBar(
          title: const Text('Action'),
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => tapped = true,
            ),
          ],
        ),
        asAppBar: true,
      );

      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('contains SafeArea', (tester) async {
      await pumpApp(
        tester,
        WiredAppBar(title: const Text('Safe')),
        asAppBar: true,
      );

      expect(
        find.descendant(
          of: find.byType(WiredAppBar),
          matching: find.byType(SafeArea),
        ),
        findsOneWidget,
      );
    });
  });
}
