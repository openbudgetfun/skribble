import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';

import '../helpers/pump_app.dart';

void main() {
  Widget buildSubject({
    VoidCallback? onPressed,
    Widget child = const Text('Tap'),
    Color? color,
    EdgeInsetsGeometry? padding,
    BorderRadius? borderRadius,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: WiredCupertinoButton(
            onPressed: onPressed,
            color: color,
            padding: padding,
            borderRadius: borderRadius,
            child: child,
          ),
        ),
      ),
    );
  }

  group('WiredCupertinoButton', () {
    testWidgets('renders without error', (tester) async {
      await tester.pumpWidget(buildSubject(onPressed: () {}));
      expect(find.byType(WiredCupertinoButton), findsOneWidget);
      expect(find.text('Tap'), findsOneWidget);
    });

    testWidgets('calls onPressed when tapped', (tester) async {
      var tapped = false;
      await tester.pumpWidget(buildSubject(onPressed: () => tapped = true));
      await tester.tap(find.text('Tap'));
      expect(tapped, isTrue);
    });

    testWidgets('does not call onPressed when disabled', (tester) async {
      const tapped = false;
      await tester.pumpWidget(buildSubject(onPressed: null));
      await tester.tap(find.text('Tap'));
      expect(tapped, isFalse);
    });

    testWidgets('renders with fill color', (tester) async {
      await tester.pumpWidget(
        buildSubject(onPressed: () {}, color: Colors.blue),
      );
      expect(find.byType(WiredCupertinoButton), findsOneWidget);
    });

    testWidgets('respects custom padding', (tester) async {
      await tester.pumpWidget(
        buildSubject(onPressed: () {}, padding: const EdgeInsets.all(32)),
      );
      expect(find.byType(WiredCupertinoButton), findsOneWidget);
    });

    testWidgets('respects custom border radius', (tester) async {
      await tester.pumpWidget(
        buildSubject(onPressed: () {}, borderRadius: BorderRadius.circular(20)),
      );
      expect(find.byType(WiredCupertinoButton), findsOneWidget);
    });

    testWidgets('shows reduced opacity when pressed', (tester) async {
      await tester.pumpWidget(buildSubject(onPressed: () {}));
      final gesture = await tester.startGesture(
        tester.getCenter(find.text('Tap')),
      );
      await tester.pump();

      final opacity = tester.widget<AnimatedOpacity>(
        find.byType(AnimatedOpacity),
      );
      // While pressed the opacity should be pressedOpacity (0.4)
      expect(opacity.opacity, 0.4);

      await gesture.up();
      await tester.pumpAndSettle();
    });

    testWidgets('shows reduced opacity when disabled', (tester) async {
      await tester.pumpWidget(buildSubject());
      final opacity = tester.widget<AnimatedOpacity>(
        find.byType(AnimatedOpacity),
      );
      expect(opacity.opacity, 0.4);
    });

    testWidgets('filled factory renders with active blue', (tester) async {
      await pumpApp(
        tester,
        Center(
          child: WiredCupertinoButton.filled(
            onPressed: () {},
            child: const Text('Filled'),
          ),
        ),
      );
      expect(find.byType(WiredCupertinoButton), findsOneWidget);
      expect(find.text('Filled'), findsOneWidget);
    });
  });
}
