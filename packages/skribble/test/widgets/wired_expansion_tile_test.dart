import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';

void main() {
  group('WiredExpansionTile', () {
    testWidgets('renders without error', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WiredExpansionTile(
              title: const Text('Tile title'),
            ),
          ),
        ),
      );

      expect(find.byType(WiredExpansionTile), findsOneWidget);
    });

    testWidgets('renders title', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WiredExpansionTile(
              title: const Text('Expansion Title'),
            ),
          ),
        ),
      );

      expect(find.text('Expansion Title'), findsOneWidget);
    });

    testWidgets('renders subtitle when provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WiredExpansionTile(
              title: const Text('Title'),
              subtitle: const Text('Subtitle text'),
            ),
          ),
        ),
      );

      expect(find.text('Subtitle text'), findsOneWidget);
    });

    testWidgets('does not render subtitle when null', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WiredExpansionTile(
              title: const Text('Title'),
            ),
          ),
        ),
      );

      // Only title text should be present, no subtitle.
      expect(find.text('Title'), findsOneWidget);
    });

    testWidgets('renders leading widget when provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WiredExpansionTile(
              title: const Text('Title'),
              leading: const Icon(Icons.folder),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.folder), findsOneWidget);
    });

    testWidgets('does not render leading widget when null', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WiredExpansionTile(
              title: const Text('Title'),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.folder), findsNothing);
    });

    testWidgets('children are hidden when collapsed', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WiredExpansionTile(
              title: const Text('Title'),
              children: const [
                Text('Child 1'),
                Text('Child 2'),
              ],
            ),
          ),
        ),
      );

      // initiallyExpanded defaults to false, so children should not be visible.
      expect(find.text('Child 1'), findsNothing);
      expect(find.text('Child 2'), findsNothing);
    });

    testWidgets('children are visible when initiallyExpanded is true',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WiredExpansionTile(
              title: const Text('Title'),
              initiallyExpanded: true,
              children: const [
                Text('Child 1'),
                Text('Child 2'),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Child 1'), findsOneWidget);
      expect(find.text('Child 2'), findsOneWidget);
    });

    testWidgets('initiallyExpanded defaults to false', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WiredExpansionTile(
              title: const Text('Title'),
            ),
          ),
        ),
      );

      final tile = tester.widget<WiredExpansionTile>(
        find.byType(WiredExpansionTile),
      );
      expect(tile.initiallyExpanded, isFalse);
    });

    testWidgets('children default to empty list', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WiredExpansionTile(
              title: const Text('Title'),
            ),
          ),
        ),
      );

      final tile = tester.widget<WiredExpansionTile>(
        find.byType(WiredExpansionTile),
      );
      expect(tile.children, isEmpty);
    });

    testWidgets('tapping expands to show children', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WiredExpansionTile(
              title: const Text('Title'),
              children: const [
                Text('Expanded content'),
              ],
            ),
          ),
        ),
      );

      // Initially collapsed.
      expect(find.text('Expanded content'), findsNothing);

      // Tap the tile to expand.
      await tester.tap(find.text('Title'));
      await tester.pumpAndSettle();

      expect(find.text('Expanded content'), findsOneWidget);
    });

    testWidgets('tapping again collapses children', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WiredExpansionTile(
              title: const Text('Title'),
              children: const [
                Text('Content'),
              ],
            ),
          ),
        ),
      );

      // Expand.
      await tester.tap(find.text('Title'));
      await tester.pumpAndSettle();
      expect(find.text('Content'), findsOneWidget);

      // Collapse.
      await tester.tap(find.text('Title'));
      await tester.pumpAndSettle();
      expect(find.text('Content'), findsNothing);
    });

    testWidgets('contains expand_more icon', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WiredExpansionTile(
              title: const Text('Title'),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.expand_more), findsOneWidget);
    });

    testWidgets('icon rotates when expanded', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WiredExpansionTile(
              title: const Text('Title'),
              children: const [Text('Content')],
            ),
          ),
        ),
      );

      // When collapsed, AnimatedRotation turns = 0.
      var rotation = tester.widget<AnimatedRotation>(
        find.byType(AnimatedRotation),
      );
      expect(rotation.turns, 0);

      // Expand the tile.
      await tester.tap(find.text('Title'));
      await tester.pumpAndSettle();

      // When expanded, AnimatedRotation turns = 0.5.
      rotation = tester.widget<AnimatedRotation>(
        find.byType(AnimatedRotation),
      );
      expect(rotation.turns, 0.5);
    });

    testWidgets('contains WiredCanvas separator line', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WiredExpansionTile(
              title: const Text('Title'),
            ),
          ),
        ),
      );

      expect(
        find.descendant(
          of: find.byType(WiredExpansionTile),
          matching: find.byType(WiredCanvas),
        ),
        findsOneWidget,
      );
    });

    testWidgets('uses InkWell for tap handling', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WiredExpansionTile(
              title: const Text('Title'),
            ),
          ),
        ),
      );

      expect(
        find.descendant(
          of: find.byType(WiredExpansionTile),
          matching: find.byType(InkWell),
        ),
        findsOneWidget,
      );
    });
  });
}
