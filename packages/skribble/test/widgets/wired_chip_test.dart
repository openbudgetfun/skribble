import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';

import '../helpers/finders.dart';
import '../helpers/pump_app.dart';

Finder findWiredIcon(IconData icon) {
  return find.byWidgetPredicate(
    (widget) => widget is WiredIcon && widget.icon == icon,
    description: 'WiredIcon($icon)',
  );
}

void main() {
  group('WiredChip', () {
    testWidgets('renders without error', (tester) async {
      await pumpApp(tester, WiredChip(label: const Text('Chip')));

      expect(find.byType(WiredChip), findsOneWidget);
    });

    testWidgets('renders label text', (tester) async {
      await pumpApp(tester, WiredChip(label: const Text('My Label')));

      expect(find.text('My Label'), findsOneWidget);
    });

    testWidgets('renders avatar when provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WiredChip(
              label: const Text('Chip'),
              avatar: const Icon(Icons.person),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.person), findsOneWidget);
    });

    testWidgets('does not render avatar when not provided', (tester) async {
      await pumpApp(tester, WiredChip(label: const Text('Chip')));

      expect(find.byIcon(Icons.person), findsNothing);
    });

    testWidgets('renders rough delete icon when onDeleted is provided', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WiredChip(label: const Text('Chip'), onDeleted: () {}),
          ),
        ),
      );

      expect(findWiredIcon(Icons.close), findsOneWidget);
    });

    testWidgets('does not render delete icon when onDeleted is null', (
      tester,
    ) async {
      await pumpApp(tester, WiredChip(label: const Text('Chip')));

      expect(findWiredIcon(Icons.close), findsNothing);
    });

    testWidgets('calls onDeleted when delete icon is tapped', (tester) async {
      var deleted = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WiredChip(
              label: const Text('Chip'),
              onDeleted: () => deleted = true,
            ),
          ),
        ),
      );

      await tester.tap(findWiredIcon(Icons.close));
      await tester.pump();

      expect(deleted, isTrue);
    });

    testWidgets('has correct height of 32', (tester) async {
      await pumpApp(tester, WiredChip(label: const Text('Chip')));

      // The SizedBox inside WiredChip has a fixed height of 32.
      final sizedBox = tester.widget<SizedBox>(
        find
            .descendant(
              of: find.byType(WiredChip),
              matching: find.byType(SizedBox),
            )
            .first,
      );

      expect(sizedBox.height, 32);
    });

    testWidgets('contains WiredCanvas for the rounded rectangle border', (
      tester,
    ) async {
      await pumpApp(tester, WiredChip(label: const Text('Chip')));

      expect(
        find.descendant(of: find.byType(WiredChip), matching: findWiredCanvas),
        findsOneWidget,
      );
    });

    testWidgets('renders avatar and label together with spacing', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WiredChip(
              label: const Text('Tagged'),
              avatar: const CircleAvatar(child: Text('A')),
            ),
          ),
        ),
      );

      expect(find.text('Tagged'), findsOneWidget);
      expect(find.text('A'), findsOneWidget);
    });

    testWidgets('contains RepaintBoundary wrapper', (tester) async {
      await pumpApp(tester, WiredChip(label: const Text('Chip')));

      // WiredChip uses buildWiredElement which wraps with RepaintBoundary.
      expect(
        find.descendant(
          of: find.byType(WiredChip),
          matching: findRepaintBoundary,
        ),
        findsOneWidget,
      );
    });

    testWidgets('property defaults are correct', (tester) async {
      const chip = WiredChip(label: Text('Chip'));

      expect(chip.avatar, isNull);
      expect(chip.onDeleted, isNull);
    });
  });
}
