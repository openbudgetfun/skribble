import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';

void main() {
  group('WiredListTile', () {
    testWidgets('renders without error', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WiredListTile(
              title: const Text('List item'),
            ),
          ),
        ),
      );

      expect(find.byType(WiredListTile), findsOneWidget);
    });

    testWidgets('renders title', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WiredListTile(
              title: const Text('Tile Title'),
            ),
          ),
        ),
      );

      expect(find.text('Tile Title'), findsOneWidget);
    });

    testWidgets('renders subtitle when provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WiredListTile(
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
            body: WiredListTile(
              title: const Text('Title'),
            ),
          ),
        ),
      );

      expect(find.text('Title'), findsOneWidget);
      // No extra text widgets besides the title.
      expect(
        find.descendant(
          of: find.byType(WiredListTile),
          matching: find.byType(Text),
        ),
        findsOneWidget,
      );
    });

    testWidgets('renders leading widget when provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WiredListTile(
              title: const Text('Title'),
              leading: const Icon(Icons.person),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.person), findsOneWidget);
    });

    testWidgets('does not render leading widget when null', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WiredListTile(
              title: const Text('Title'),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.person), findsNothing);
    });

    testWidgets('renders trailing widget when provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WiredListTile(
              title: const Text('Title'),
              trailing: const Icon(Icons.arrow_forward),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.arrow_forward), findsOneWidget);
    });

    testWidgets('does not render trailing widget when null', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WiredListTile(
              title: const Text('Title'),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.arrow_forward), findsNothing);
    });

    testWidgets('calls onTap callback when tapped', (tester) async {
      var tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WiredListTile(
              title: const Text('Tappable'),
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Tappable'));
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('does not crash when onTap is null', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WiredListTile(
              title: const Text('No tap'),
            ),
          ),
        ),
      );

      // Tapping should not throw when onTap is null.
      await tester.tap(find.text('No tap'));
      await tester.pump();

      expect(find.byType(WiredListTile), findsOneWidget);
    });

    testWidgets('showDivider defaults to true', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WiredListTile(
              title: const Text('Title'),
            ),
          ),
        ),
      );

      final tile = tester.widget<WiredListTile>(
        find.byType(WiredListTile),
      );
      expect(tile.showDivider, isTrue);
    });

    testWidgets('shows divider line when showDivider is true', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WiredListTile(
              title: const Text('Title'),
              showDivider: true,
            ),
          ),
        ),
      );

      // The divider is a WiredCanvas with a WiredLineBase painter.
      expect(
        find.descendant(
          of: find.byType(WiredListTile),
          matching: find.byType(WiredCanvas),
        ),
        findsOneWidget,
      );
    });

    testWidgets('hides divider line when showDivider is false', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WiredListTile(
              title: const Text('Title'),
              showDivider: false,
            ),
          ),
        ),
      );

      // No WiredCanvas should be present when the divider is hidden.
      expect(
        find.descendant(
          of: find.byType(WiredListTile),
          matching: find.byType(WiredCanvas),
        ),
        findsNothing,
      );
    });

    testWidgets('uses InkWell for tap handling', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WiredListTile(
              title: const Text('Title'),
              onTap: () {},
            ),
          ),
        ),
      );

      expect(
        find.descendant(
          of: find.byType(WiredListTile),
          matching: find.byType(InkWell),
        ),
        findsOneWidget,
      );
    });

    testWidgets('renders all optional widgets together', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WiredListTile(
              leading: const Icon(Icons.star),
              title: const Text('Full tile'),
              subtitle: const Text('With everything'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.star), findsOneWidget);
      expect(find.text('Full tile'), findsOneWidget);
      expect(find.text('With everything'), findsOneWidget);
      expect(find.byIcon(Icons.chevron_right), findsOneWidget);
    });

    testWidgets('renders with no title or subtitle', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WiredListTile(),
          ),
        ),
      );

      // Should render without error even with all optional fields null.
      expect(find.byType(WiredListTile), findsOneWidget);
    });
  });
}
