import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';

void main() {
  group('WiredChip', () {
    testWidgets('renders without error', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WiredChip(label: const Text('Chip')),
          ),
        ),
      );

      expect(find.byType(WiredChip), findsOneWidget);
    });

    testWidgets('renders label text', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WiredChip(label: const Text('My Label')),
          ),
        ),
      );

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
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WiredChip(label: const Text('Chip')),
          ),
        ),
      );

      expect(find.byIcon(Icons.person), findsNothing);
    });

    testWidgets('renders delete icon when onDeleted is provided',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WiredChip(
              label: const Text('Chip'),
              onDeleted: () {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.close), findsOneWidget);
    });

    testWidgets('does not render delete icon when onDeleted is null',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WiredChip(label: const Text('Chip')),
          ),
        ),
      );

      expect(find.byIcon(Icons.close), findsNothing);
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

      await tester.tap(find.byIcon(Icons.close));
      await tester.pump();

      expect(deleted, isTrue);
    });

    testWidgets('has correct height of 32', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WiredChip(label: const Text('Chip')),
          ),
        ),
      );

      // The SizedBox inside WiredChip has a fixed height of 32.
      final sizedBox = tester.widget<SizedBox>(
        find.descendant(
          of: find.byType(WiredChip),
          matching: find.byType(SizedBox),
        ).first,
      );

      expect(sizedBox.height, 32);
    });

    testWidgets('contains WiredCanvas for the rounded rectangle border',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WiredChip(label: const Text('Chip')),
          ),
        ),
      );

      expect(
        find.descendant(
          of: find.byType(WiredChip),
          matching: find.byType(WiredCanvas),
        ),
        findsOneWidget,
      );
    });

    testWidgets('renders avatar and label together with spacing',
        (tester) async {
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
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WiredChip(label: const Text('Chip')),
          ),
        ),
      );

      // WiredChip uses buildWiredElement which wraps with RepaintBoundary.
      expect(
        find.descendant(
          of: find.byType(WiredChip),
          matching: find.byType(RepaintBoundary),
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
