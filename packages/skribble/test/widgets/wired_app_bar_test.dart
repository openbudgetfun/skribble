import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';

void main() {
  group('WiredAppBar', () {
    testWidgets('renders without error', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: WiredAppBar(title: const Text('Test')),
            body: const SizedBox(),
          ),
        ),
      );

      expect(find.byType(WiredAppBar), findsOneWidget);
    });

    testWidgets('renders title text', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: WiredAppBar(title: const Text('My Title')),
            body: const SizedBox(),
          ),
        ),
      );

      expect(find.text('My Title'), findsOneWidget);
    });

    testWidgets('renders leading widget', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: WiredAppBar(
              leading: const Icon(Icons.menu),
              title: const Text('Title'),
            ),
            body: const SizedBox(),
          ),
        ),
      );

      expect(find.byIcon(Icons.menu), findsOneWidget);
    });

    testWidgets('renders action widgets', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: WiredAppBar(
              title: const Text('Title'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.more_vert),
                  onPressed: () {},
                ),
              ],
            ),
            body: const SizedBox(),
          ),
        ),
      );

      expect(find.byIcon(Icons.search), findsOneWidget);
      expect(find.byIcon(Icons.more_vert), findsOneWidget);
    });

    testWidgets('default height is 56.0', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: WiredAppBar(title: const Text('Height')),
            body: const SizedBox(),
          ),
        ),
      );

      final appBar = tester.widget<WiredAppBar>(find.byType(WiredAppBar));
      expect(appBar.preferredSize.height, 56.0);
    });

    testWidgets('accepts custom height', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: WiredAppBar(
              title: const Text('Custom'),
              height: 80.0,
            ),
            body: const SizedBox(),
          ),
        ),
      );

      final appBar = tester.widget<WiredAppBar>(find.byType(WiredAppBar));
      expect(appBar.preferredSize.height, 80.0);
    });

    testWidgets('implements PreferredSizeWidget', (tester) async {
      const appBar = WiredAppBar(title: Text('Preferred'));
      expect(appBar, isA<PreferredSizeWidget>());
      expect(appBar.preferredSize, const Size.fromHeight(56.0));
    });

    testWidgets('renders hand-drawn bottom line via WiredCanvas',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: WiredAppBar(title: const Text('Line')),
            body: const SizedBox(),
          ),
        ),
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
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: WiredAppBar(title: const Text('Bg')),
            body: const SizedBox(),
          ),
        ),
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
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: WiredAppBar(
              title: const Text('Color'),
              backgroundColor: Colors.blue,
            ),
            body: const SizedBox(),
          ),
        ),
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
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: WiredAppBar(),
            body: const SizedBox(),
          ),
        ),
      );

      expect(
        find.descendant(
          of: find.byType(WiredAppBar),
          matching: find.byType(Spacer),
        ),
        findsOneWidget,
      );
    });

    testWidgets('wraps title in DefaultTextStyle', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: WiredAppBar(title: const Text('Styled')),
            body: const SizedBox(),
          ),
        ),
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

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: WiredAppBar(
              title: const Text('Action'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => tapped = true,
                ),
              ],
            ),
            body: const SizedBox(),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('contains SafeArea', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: WiredAppBar(title: const Text('Safe')),
            body: const SizedBox(),
          ),
        ),
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
