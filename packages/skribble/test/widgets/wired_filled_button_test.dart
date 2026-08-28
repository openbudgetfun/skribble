import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';

import '../helpers/pump_app.dart';

void main() {
  group('WiredFilledButton', () {
    testWidgets('renders with child text', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WiredFilledButton(
              onPressed: () {},
              child: const Text('Filled'),
            ),
          ),
        ),
      );

      expect(find.byType(WiredFilledButton), findsOneWidget);
      expect(find.text('Filled'), findsOneWidget);
      expect(find.byType(RepaintBoundary), findsWidgets);
    });

    testWidgets('calls onPressed when tapped', (tester) async {
      var tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WiredFilledButton(
              onPressed: () => tapped = true,
              child: const Text('Tap me'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Tap me'));
      expect(tapped, isTrue);
    });

    testWidgets('renders with custom fill color', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WiredFilledButton(
              onPressed: () {},
              fillColor: Colors.blue,
              child: const Text('Blue'),
            ),
          ),
        ),
      );

      expect(find.byType(WiredFilledButton), findsOneWidget);
    });

    testWidgets('disabled when onPressed is null', (tester) async {
      await pumpApp(tester, WiredFilledButton(child: Text('Disabled')));

      final button = tester.widget<TextButton>(find.byType(TextButton));
      expect(button.onPressed, isNull);
    });

    testWidgets('renders with custom foreground color', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WiredFilledButton(
              onPressed: () {},
              foregroundColor: Colors.yellow,
              child: const Text('Yellow text'),
            ),
          ),
        ),
      );

      expect(find.byType(WiredFilledButton), findsOneWidget);
      expect(find.text('Yellow text'), findsOneWidget);
    });

    testWidgets('has fixed height of 42', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WiredFilledButton(
              onPressed: () {},
              child: const Text('Check height'),
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(
        find
            .descendant(
              of: find.byType(WiredFilledButton),
              matching: find.byType(Container),
            )
            .first,
      );
      expect(container.constraints?.maxHeight, 42.0);
    });

    testWidgets('does not respond to tap when disabled', (tester) async {
      const tapped = false;

      await pumpApp(tester, WiredFilledButton(child: Text('No tap')));

      await tester.tap(find.text('No tap'));
      expect(tapped, isFalse);
    });

    testWidgets('applies semantic label when provided', (tester) async {
      await pumpApp(
        tester,
        WiredFilledButton(
          onPressed: () {},
          semanticLabel: 'Confirm order',
          child: const Text('Confirm'),
        ),
      );

      expect(find.bySemanticsLabel('Confirm order'), findsOneWidget);
    });

    group('borderRadius', () {
      /// Returns the [RoughBoxDecoration] painted by the [WiredFilledButton].
      RoughBoxDecoration decorationOf(WidgetTester tester) {
        final decorations = tester
            .widgetList<Container>(
              find.descendant(
                of: find.byType(WiredFilledButton),
                matching: find.byType(Container),
              ),
            )
            .map((container) => container.decoration)
            .whereType<RoughBoxDecoration>()
            .toList();

        expect(decorations, isNotEmpty);
        return decorations.first;
      }

      testWidgets('defaults to sharp corners when borderRadius is null', (
        tester,
      ) async {
        await pumpApp(
          tester,
          WiredFilledButton(child: const Text('Sharp')),
        );

        final decoration = decorationOf(tester);
        expect(decoration.shape, RoughBoxShape.rectangle);
        expect(decoration.borderRadius, isNull);
      });

      testWidgets('renders with BorderRadius.circular(0)', (tester) async {
        await pumpApp(
          tester,
          WiredFilledButton(
            onPressed: () {},
            borderRadius: BorderRadius.circular(0),
            child: const Text('Zero radius'),
          ),
        );

        final decoration = decorationOf(tester);
        expect(decoration.shape, RoughBoxShape.roundedRectangle);
        expect(decoration.borderRadius, BorderRadius.circular(0));
        expect(find.text('Zero radius'), findsOneWidget);
      });

      testWidgets('renders with a small radius (4)', (tester) async {
        await pumpApp(
          tester,
          WiredFilledButton(
            onPressed: () {},
            borderRadius: BorderRadius.circular(4),
            child: const Text('Small radius'),
          ),
        );

        final decoration = decorationOf(tester);
        expect(decoration.shape, RoughBoxShape.roundedRectangle);
        expect(decoration.borderRadius, BorderRadius.circular(4));
      });

      testWidgets('renders with a large radius (20)', (tester) async {
        await pumpApp(
          tester,
          WiredFilledButton(
            onPressed: () {},
            borderRadius: BorderRadius.circular(20),
            child: const Text('Large radius'),
          ),
        );

        final decoration = decorationOf(tester);
        expect(decoration.shape, RoughBoxShape.roundedRectangle);
        expect(decoration.borderRadius, BorderRadius.circular(20));
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
          WiredFilledButton(
            onPressed: () {},
            borderRadius: perCorner,
            child: const Text('Per corner'),
          ),
        );

        final decoration = decorationOf(tester);
        expect(decoration.shape, RoughBoxShape.roundedRectangle);
        expect(decoration.borderRadius, perCorner);
      });

      testWidgets('rebuilds when the border radius changes', (tester) async {
        await pumpApp(
          tester,
          WiredFilledButton(
            onPressed: () {},
            borderRadius: BorderRadius.circular(4),
            child: const Text('Rebuild'),
          ),
        );
        expect(decorationOf(tester).borderRadius, BorderRadius.circular(4));

        await pumpApp(
          tester,
          WiredFilledButton(
            onPressed: () {},
            borderRadius: BorderRadius.circular(20),
            child: const Text('Rebuild'),
          ),
        );
        expect(decorationOf(tester).borderRadius, BorderRadius.circular(20));
      });
    });
  });
}
