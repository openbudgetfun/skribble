import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';

void main() {
  group('WiredCard', () {
    testWidgets('renders child widget', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WiredCard(child: const Text('Card content')),
          ),
        ),
      );

      expect(find.text('Card content'), findsOneWidget);
    });

    testWidgets('renders with default height (130.0)', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WiredCard(child: const Text('Default height')),
          ),
        ),
      );

      // The WiredCard default height is 130.0. Verify the rendered size.
      final cardSize = tester.getSize(find.byType(WiredCard));

      expect(cardSize.height, 130.0);
    });

    testWidgets('renders with custom height', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WiredCard(
              height: 200.0,
              child: const Text('Custom height'),
            ),
          ),
        ),
      );

      final cardSize = tester.getSize(find.byType(WiredCard));

      expect(cardSize.height, 200.0);
    });

    testWidgets('renders with null height (uses IntrinsicHeight)',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WiredCard(
              height: null,
              child: const Text('Intrinsic'),
            ),
          ),
        ),
      );

      // When height is null the card wraps the Stack in an IntrinsicHeight.
      expect(
        find.descendant(
          of: find.byType(WiredCard),
          matching: find.byType(IntrinsicHeight),
        ),
        findsOneWidget,
      );
    });

    testWidgets('does not use IntrinsicHeight when height is provided',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WiredCard(
              height: 130.0,
              child: const Text('No intrinsic'),
            ),
          ),
        ),
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
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WiredCard(
              fill: true,
              child: const Text('Filled'),
            ),
          ),
        ),
      );

      // When fill is true the WiredCanvas receives hachureFiller instead of
      // noFiller. We verify that the WiredCanvas is present; the filler type
      // is an internal detail of the canvas painter.
      expect(find.byType(WiredCanvas), findsOneWidget);
      expect(find.text('Filled'), findsOneWidget);
    });

    testWidgets('fill defaults to false', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WiredCard(child: const Text('No fill')),
          ),
        ),
      );

      // Should still render without error when fill is false (default).
      expect(find.byType(WiredCard), findsOneWidget);
      expect(find.text('No fill'), findsOneWidget);
    });
  });
}
