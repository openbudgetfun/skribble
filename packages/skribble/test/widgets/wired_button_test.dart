import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';

import '../helpers/pump_app.dart';

void main() {
  group('WiredButton', () {
    testWidgets('renders child text widget', (tester) async {
      await pumpApp(
        tester,
        WiredButton(onPressed: () {}, child: const Text('Press me')),
      );

      expect(find.text('Press me'), findsOneWidget);
    });

    testWidgets('calls onPressed callback when tapped', (tester) async {
      var pressed = false;

      await pumpApp(
        tester,
        WiredButton(onPressed: () => pressed = true, child: const Text('Tap')),
      );

      await tester.tap(find.text('Tap'));
      await tester.pump();

      expect(pressed, isTrue);
    });

    testWidgets('renders with correct height (42.0)', (tester) async {
      await pumpApp(
        tester,
        WiredButton(onPressed: () {}, child: const Text('Height test')),
      );

      // The WiredButton's buildWiredElement wraps content in a Container
      // with height 42.0. We verify the rendered size of the button.
      final buttonSize = tester.getSize(find.byType(WiredButton));

      expect(buttonSize.height, 42.0);
    });

    testWidgets('contains TextButton internally', (tester) async {
      await pumpApp(
        tester,
        WiredButton(onPressed: () {}, child: const Text('Button')),
      );

      expect(
        find.descendant(
          of: find.byType(WiredButton),
          matching: find.byType(TextButton),
        ),
        findsOneWidget,
      );
    });

    testWidgets('has RepaintBoundary wrapper', (tester) async {
      await pumpApp(
        tester,
        WiredButton(onPressed: () {}, child: const Text('Repaint')),
      );

      // WiredBaseWidget.build wraps buildWiredElement in RepaintBoundary.
      expect(
        find.descendant(
          of: find.byType(WiredButton),
          matching: find.byType(RepaintBoundary),
        ),
        findsOneWidget,
      );
    });

    testWidgets('renders with icon child', (tester) async {
      await pumpApp(
        tester,
        WiredButton(onPressed: () {}, child: const Icon(Icons.add)),
      );

      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('uses theme border color from WiredTheme', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: WiredTheme(
            data: WiredThemeData(borderColor: Colors.red),
            child: Scaffold(
              body: WiredButton(onPressed: () {}, child: const Text('Themed')),
            ),
          ),
        ),
      );

      expect(find.byType(WiredButton), findsOneWidget);
    });

    testWidgets('applies semantic label when provided', (tester) async {
      await pumpApp(
        tester,
        WiredButton(
          onPressed: () {},
          semanticLabel: 'Submit form',
          child: const Text('Submit'),
        ),
      );

      expect(find.bySemanticsLabel('Submit form'), findsOneWidget);
    });

    group('borderRadius', () {
      /// Returns the [RoughBoxDecoration] painted by the [WiredButton].
      RoughBoxDecoration decorationOf(WidgetTester tester) {
        final decorations = tester
            .widgetList<Container>(
              find.descendant(
                of: find.byType(WiredButton),
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
          WiredButton(onPressed: () {}, child: const Text('Sharp')),
        );

        final decoration = decorationOf(tester);
        expect(decoration.shape, RoughBoxShape.rectangle);
        expect(decoration.borderRadius, isNull);
      });

      testWidgets('renders with BorderRadius.circular(0)', (tester) async {
        await pumpApp(
          tester,
          WiredButton(
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
          WiredButton(
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
          WiredButton(
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
          WiredButton(
            onPressed: () {},
            borderRadius: perCorner,
            child: const Text('Per corner'),
          ),
        );

        final decoration = decorationOf(tester);
        expect(decoration.shape, RoughBoxShape.roundedRectangle);
        expect(decoration.borderRadius, perCorner);
      });

      testWidgets('child remains tappable with a border radius', (
        tester,
      ) async {
        var pressed = false;

        await pumpApp(
          tester,
          WiredButton(
            onPressed: () => pressed = true,
            borderRadius: BorderRadius.circular(12),
            child: const Text('Rounded tap'),
          ),
        );

        await tester.tap(find.text('Rounded tap'));
        await tester.pump();

        expect(pressed, isTrue);
      });

      testWidgets('rebuilds when the border radius changes', (tester) async {
        await pumpApp(
          tester,
          WiredButton(
            onPressed: () {},
            borderRadius: BorderRadius.circular(4),
            child: const Text('Rebuild'),
          ),
        );
        expect(decorationOf(tester).borderRadius, BorderRadius.circular(4));

        await pumpApp(
          tester,
          WiredButton(
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
