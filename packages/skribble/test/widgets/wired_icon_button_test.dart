import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';

import '../helpers/pump_app.dart';

void main() {
  group('WiredIconButton', () {
    testWidgets('renders without error', (tester) async {
      await pumpApp(tester, WiredIconButton(icon: Icons.add, onPressed: () {}));

      expect(find.byType(WiredIconButton), findsOneWidget);
    });

    testWidgets('renders the provided icon', (tester) async {
      await pumpApp(
        tester,
        WiredIconButton(icon: Icons.favorite, onPressed: () {}),
      );

      expect(find.byIcon(Icons.favorite), findsOneWidget);
    });

    testWidgets('calls onPressed callback when tapped', (tester) async {
      var pressed = false;

      await pumpApp(
        tester,
        WiredIconButton(icon: Icons.add, onPressed: () => pressed = true),
      );

      await tester.tap(find.byType(IconButton));
      await tester.pump();

      expect(pressed, isTrue);
    });

    testWidgets('does not crash when onPressed is null', (tester) async {
      await pumpApp(tester, WiredIconButton(icon: Icons.add, onPressed: null));

      expect(find.byType(WiredIconButton), findsOneWidget);
    });

    testWidgets('does not call callback when onPressed is null', (
      tester,
    ) async {
      const pressed = false;

      await pumpApp(tester, WiredIconButton(icon: Icons.add, onPressed: null));

      await tester.tap(find.byType(WiredIconButton));
      await tester.pump();

      expect(pressed, isFalse);
    });

    testWidgets('onPressed defaults to null', (tester) async {
      const button = WiredIconButton(icon: Icons.add);

      expect(button.onPressed, isNull);
    });

    testWidgets('size defaults to 48.0', (tester) async {
      const button = WiredIconButton(icon: Icons.add);

      expect(button.size, 48.0);
    });

    testWidgets('renders with default size (48.0)', (tester) async {
      await pumpApp(tester, WiredIconButton(icon: Icons.add, onPressed: () {}));

      final buttonSize = tester.getSize(find.byType(WiredIconButton));

      expect(buttonSize.width, 48.0);
      expect(buttonSize.height, 48.0);
    });

    testWidgets('renders with custom size', (tester) async {
      await pumpApp(
        tester,
        WiredIconButton(icon: Icons.add, onPressed: () {}, size: 64.0),
      );

      final buttonSize = tester.getSize(find.byType(WiredIconButton));

      expect(buttonSize.width, 64.0);
      expect(buttonSize.height, 64.0);
    });

    testWidgets('iconColor defaults to null', (tester) async {
      const button = WiredIconButton(icon: Icons.add);

      expect(button.iconColor, isNull);
    });

    testWidgets('uses custom iconColor when provided', (tester) async {
      await pumpApp(
        tester,
        WiredIconButton(
          icon: Icons.add,
          onPressed: () {},
          iconColor: Colors.red,
        ),
      );

      final icon = tester.widget<Icon>(find.byIcon(Icons.add));

      expect(icon.color, Colors.red);
    });

    testWidgets('contains IconButton internally', (tester) async {
      await pumpApp(tester, WiredIconButton(icon: Icons.add, onPressed: () {}));

      expect(
        find.descendant(
          of: find.byType(WiredIconButton),
          matching: find.byType(IconButton),
        ),
        findsOneWidget,
      );
    });

    testWidgets('contains WiredCanvas for circle border', (tester) async {
      await pumpApp(tester, WiredIconButton(icon: Icons.add, onPressed: () {}));

      expect(
        find.descendant(
          of: find.byType(WiredIconButton),
          matching: find.byType(WiredCanvas),
        ),
        findsOneWidget,
      );
    });

    testWidgets('contains Stack for layering circle and icon', (tester) async {
      await pumpApp(tester, WiredIconButton(icon: Icons.add, onPressed: () {}));

      expect(
        find.descendant(
          of: find.byType(WiredIconButton),
          matching: find.byType(Stack),
        ),
        findsOneWidget,
      );
    });

    testWidgets('has RepaintBoundary wrapper', (tester) async {
      await pumpApp(tester, WiredIconButton(icon: Icons.add, onPressed: () {}));

      expect(
        find.descendant(
          of: find.byType(WiredIconButton),
          matching: find.byType(RepaintBoundary),
        ),
        findsOneWidget,
      );
    });

    testWidgets('tracks multiple rapid taps', (tester) async {
      var tapCount = 0;

      await pumpApp(
        tester,
        WiredIconButton(icon: Icons.add, onPressed: () => tapCount++),
      );

      await tester.tap(find.byType(IconButton));
      await tester.pump();
      await tester.tap(find.byType(IconButton));
      await tester.pump();
      await tester.tap(find.byType(IconButton));
      await tester.pump();

      expect(tapCount, 3);
    });

    testWidgets('applies semantic label when provided', (tester) async {
      await pumpApp(
        tester,
        WiredIconButton(
          icon: Icons.settings,
          onPressed: () {},
          semanticLabel: 'Open settings',
        ),
      );

      expect(find.bySemanticsLabel('Open settings'), findsOneWidget);
    });
  });
}
