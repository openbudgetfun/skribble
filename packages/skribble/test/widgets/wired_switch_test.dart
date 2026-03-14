import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';

import '../helpers/finders.dart';
import '../helpers/pump_app.dart';

void main() {
  group('WiredSwitch', () {
    testWidgets('renders without error', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(child: WiredSwitch(value: false, onChanged: (_) {})),
          ),
        ),
      );

      expect(find.byType(WiredSwitch), findsOneWidget);
    });

    testWidgets('contains GestureDetector for tap handling', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(child: WiredSwitch(value: false, onChanged: (_) {})),
          ),
        ),
      );

      expect(
        find.descendant(
          of: find.byType(WiredSwitch),
          matching: find.byType(GestureDetector),
        ),
        findsOneWidget,
      );
    });

    testWidgets('calls onChanged with negated value on tap', (tester) async {
      bool? receivedValue;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: WiredSwitch(
                value: false,
                onChanged: (v) => receivedValue = v,
              ),
            ),
          ),
        ),
      );

      // Invoke onTap directly on the GestureDetector since the CustomPaint
      // children in the Stack may intercept hit-testing in the test
      // environment.
      final gestureDetector = tester.widget<GestureDetector>(
        find.descendant(
          of: find.byType(WiredSwitch),
          matching: find.byType(GestureDetector),
        ),
      );
      gestureDetector.onTap!();
      await tester.pumpAndSettle();

      // The switch starts with value=false, so tapping should pass true.
      expect(receivedValue, isTrue);
    });

    testWidgets('calls onChanged with false when value is true', (
      tester,
    ) async {
      bool? receivedValue;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: WiredSwitch(
                value: true,
                onChanged: (v) => receivedValue = v,
              ),
            ),
          ),
        ),
      );

      final gestureDetector = tester.widget<GestureDetector>(
        find.descendant(
          of: find.byType(WiredSwitch),
          matching: find.byType(GestureDetector),
        ),
      );
      gestureDetector.onTap!();
      await tester.pumpAndSettle();

      // The switch starts with value=true, so tapping should pass false.
      expect(receivedValue, isFalse);
    });

    testWidgets('does not throw when onChanged is null', (tester) async {
      await pumpApp(tester, Center(child: WiredSwitch(value: false)));

      // Invoke onTap directly; it should not throw even when onChanged is null.
      final gestureDetector = tester.widget<GestureDetector>(
        find.descendant(
          of: find.byType(WiredSwitch),
          matching: find.byType(GestureDetector),
        ),
      );

      expect(() => gestureDetector.onTap!(), returnsNormally);
    });

    testWidgets('has correct default size (60x24)', (tester) async {
      await pumpApp(tester, Center(child: WiredSwitch(value: false)));

      final size = tester.getSize(find.byType(WiredSwitch));

      // The widget uses _trackWidth = 60 and _thumbSize = 24.
      expect(size.width, 60.0);
      expect(size.height, 24.0);
    });

    testWidgets('renders with custom activeColor', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: WiredSwitch(value: true, activeColor: Colors.green),
            ),
          ),
        ),
      );

      final widget = tester.widget<WiredSwitch>(find.byType(WiredSwitch));
      expect(widget.activeColor, Colors.green);
    });

    testWidgets('renders with custom inactiveColor', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: WiredSwitch(value: false, inactiveColor: Colors.red),
            ),
          ),
        ),
      );

      final widget = tester.widget<WiredSwitch>(find.byType(WiredSwitch));
      expect(widget.inactiveColor, Colors.red);
    });

    testWidgets('property defaults are null for colors', (tester) async {
      await pumpApp(tester, Center(child: WiredSwitch(value: false)));

      final widget = tester.widget<WiredSwitch>(find.byType(WiredSwitch));
      expect(widget.activeColor, isNull);
      expect(widget.inactiveColor, isNull);
      expect(widget.onChanged, isNull);
    });

    testWidgets('contains WiredCanvas widgets for track and thumb', (
      tester,
    ) async {
      await pumpApp(tester, Center(child: WiredSwitch(value: false)));

      // The switch renders two WiredCanvas: one for the track, one for the
      // thumb.
      expect(
        find.descendant(
          of: find.byType(WiredSwitch),
          matching: findWiredCanvas,
        ),
        findsNWidgets(2),
      );
    });

    testWidgets('renders in both value states without error', (tester) async {
      // Render with value=true
      await pumpApp(tester, Center(child: WiredSwitch(value: true)));

      expect(find.byType(WiredSwitch), findsOneWidget);

      // Render with value=false
      await pumpApp(tester, Center(child: WiredSwitch(value: false)));
      await tester.pumpAndSettle();

      expect(find.byType(WiredSwitch), findsOneWidget);
    });

    testWidgets('animation completes when value changes', (tester) async {
      await pumpApp(tester, Center(child: WiredSwitch(value: false)));

      // Rebuild with value=true to trigger the forward animation.
      await pumpApp(tester, Center(child: WiredSwitch(value: true)));
      await tester.pumpAndSettle();

      // No assertions on exact position, but pumpAndSettle should complete
      // without error indicating the animation finished.
      expect(find.byType(WiredSwitch), findsOneWidget);
    });

    testWidgets('applies semantic label when provided', (tester) async {
      await pumpApp(
        tester,
        Center(
          child: WiredSwitch(
            value: false,
            onChanged: (_) {},
            semanticLabel: 'Enable notifications',
          ),
        ),
      );

      expect(find.bySemanticsLabel('Enable notifications'), findsOneWidget);
    });
  });
}
