import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';

import '../helpers/pump_app.dart';

void main() {
  group('WiredBadge', () {
    testWidgets('renders without error when badge is hidden', (tester) async {
      await pumpApp(
        tester,
        WiredBadge(isVisible: false, child: const Icon(Icons.mail)),
      );

      expect(find.byType(WiredBadge), findsOneWidget);
    });

    testWidgets('renders child content', (tester) async {
      await pumpApp(
        tester,
        WiredBadge(isVisible: false, child: const Icon(Icons.mail)),
      );

      expect(find.byIcon(Icons.mail), findsOneWidget);
    });

    testWidgets('renders dot badge when visible without label', (
      tester,
    ) async {
      await pumpApp(
        tester,
        Center(
          child: WiredBadge(child: const SizedBox(width: 48, height: 48)),
        ),
      );

      expect(find.byType(WiredBadge), findsOneWidget);
      expect(find.byType(WiredCanvas), findsOneWidget);
    });

    testWidgets('hides badge indicator when isVisible is false', (
      tester,
    ) async {
      await pumpApp(
        tester,
        WiredBadge(
          isVisible: false,
          label: '3',
          child: const Icon(Icons.mail),
        ),
      );

      expect(find.byIcon(Icons.mail), findsOneWidget);
      expect(find.text('3'), findsNothing);
      expect(
        find.descendant(
          of: find.byType(WiredBadge),
          matching: find.byType(WiredCanvas),
        ),
        findsNothing,
      );
    });

    testWidgets('no Positioned widget when isVisible is false', (
      tester,
    ) async {
      await pumpApp(
        tester,
        WiredBadge(isVisible: false, child: const Icon(Icons.mail)),
      );

      expect(
        find.descendant(
          of: find.byType(WiredBadge),
          matching: find.byType(Positioned),
        ),
        findsNothing,
      );
    });

    testWidgets('isVisible defaults to true', (tester) async {
      final badge = WiredBadge(child: const SizedBox());
      expect(badge.isVisible, isTrue);
    });

    testWidgets('label defaults to null', (tester) async {
      final badge = WiredBadge(child: const SizedBox());
      expect(badge.label, isNull);
    });

    testWidgets('backgroundColor defaults to null', (tester) async {
      final badge = WiredBadge(child: const SizedBox());
      expect(badge.backgroundColor, isNull);
    });

    testWidgets('accepts custom backgroundColor', (tester) async {
      final badge = WiredBadge(
        backgroundColor: Colors.red,
        child: const SizedBox(),
      );
      expect(badge.backgroundColor, Colors.red);
    });

    testWidgets('accepts label parameter', (tester) async {
      final badge = WiredBadge(label: '5', child: const SizedBox());
      expect(badge.label, '5');
    });

    testWidgets('uses Stack with Clip.none', (tester) async {
      await pumpApp(
        tester,
        WiredBadge(isVisible: false, child: const Icon(Icons.mail)),
      );

      final stack = tester.widget<Stack>(
        find.descendant(
          of: find.byType(WiredBadge),
          matching: find.byType(Stack),
        ),
      );
      expect(stack.clipBehavior, Clip.none);
    });

    testWidgets('shows Positioned indicator when visible', (tester) async {
      await pumpApp(
        tester,
        Center(
          child: WiredBadge(child: const SizedBox(width: 48, height: 48)),
        ),
      );

      expect(
        find.descendant(
          of: find.byType(WiredBadge),
          matching: find.byType(Positioned),
        ),
        findsOneWidget,
      );
    });

    testWidgets('Positioned has right:-6 and top:-6 offsets', (tester) async {
      await pumpApp(
        tester,
        Center(
          child: WiredBadge(child: const SizedBox(width: 48, height: 48)),
        ),
      );

      final positioned = tester.widget<Positioned>(
        find.descendant(
          of: find.byType(WiredBadge),
          matching: find.byType(Positioned),
        ),
      );
      expect(positioned.right, -6);
      expect(positioned.top, -6);
    });

    testWidgets('dot badge uses SizedBox with 16x16 dimensions', (
      tester,
    ) async {
      await pumpApp(
        tester,
        Center(
          child: WiredBadge(child: const SizedBox(width: 48, height: 48)),
        ),
      );

      final sizedBox = tester.widget<SizedBox>(
        find.descendant(
          of: find.byType(Positioned),
          matching: find.byType(SizedBox),
        ),
      );
      expect(sizedBox.width, 16);
      expect(sizedBox.height, 16);
    });

    testWidgets('dot badge contains WiredCanvas', (tester) async {
      await pumpApp(
        tester,
        Center(
          child: WiredBadge(child: const SizedBox(width: 48, height: 48)),
        ),
      );

      expect(
        find.descendant(
          of: find.byType(WiredBadge),
          matching: find.byType(WiredCanvas),
        ),
        findsOneWidget,
      );
    });
  });
}
