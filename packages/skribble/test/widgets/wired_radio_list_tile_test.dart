import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';

void main() {
  group('WiredRadioListTile', () {
    testWidgets('renders without error', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WiredRadioListTile<String>(
              value: 'a',
              groupValue: null,
              onChanged: (_) => true,
            ),
          ),
        ),
      );

      expect(find.byType(WiredRadioListTile<String>), findsOneWidget);
    });

    testWidgets('renders title text', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WiredRadioListTile<String>(
              value: 'a',
              groupValue: null,
              onChanged: (_) => true,
              title: const Text('Option A'),
            ),
          ),
        ),
      );

      expect(find.text('Option A'), findsOneWidget);
    });

    testWidgets('renders subtitle text', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WiredRadioListTile<String>(
              value: 'a',
              groupValue: null,
              onChanged: (_) => true,
              title: const Text('Title'),
              subtitle: const Text('Subtitle text'),
            ),
          ),
        ),
      );

      expect(find.text('Subtitle text'), findsOneWidget);
    });

    testWidgets('renders title and subtitle together', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WiredRadioListTile<String>(
              value: 'a',
              groupValue: null,
              onChanged: (_) => true,
              title: const Text('Main title'),
              subtitle: const Text('Supporting text'),
            ),
          ),
        ),
      );

      expect(find.text('Main title'), findsOneWidget);
      expect(find.text('Supporting text'), findsOneWidget);
    });

    testWidgets('contains WiredRadio as leading widget', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WiredRadioListTile<String>(
              value: 'a',
              groupValue: null,
              onChanged: (_) => true,
            ),
          ),
        ),
      );

      expect(
        find.descendant(
          of: find.byType(WiredRadioListTile<String>),
          matching: find.byType(WiredRadio<String>),
        ),
        findsOneWidget,
      );
    });

    testWidgets('contains WiredListTile internally', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WiredRadioListTile<String>(
              value: 'a',
              groupValue: null,
              onChanged: (_) => true,
            ),
          ),
        ),
      );

      expect(
        find.descendant(
          of: find.byType(WiredRadioListTile<String>),
          matching: find.byType(WiredListTile),
        ),
        findsOneWidget,
      );
    });

    testWidgets('calls onChanged when list tile is tapped', (tester) async {
      String? receivedValue;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WiredRadioListTile<String>(
              value: 'a',
              groupValue: null,
              onChanged: (v) {
                receivedValue = v;
                return true;
              },
              title: const Text('Tap me'),
            ),
          ),
        ),
      );

      // Tap the InkWell area (the list tile).
      await tester.tap(find.byType(InkWell));
      await tester.pump();

      expect(receivedValue, 'a');
    });

    testWidgets('calls onChanged when radio button is tapped', (tester) async {
      String? receivedValue;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WiredRadioListTile<String>(
              value: 'a',
              groupValue: 'b',
              onChanged: (v) {
                receivedValue = v;
                return true;
              },
            ),
          ),
        ),
      );

      // Tap the internal Radio widget.
      await tester.tap(find.byType(Radio<String>));
      await tester.pump();

      expect(receivedValue, 'a');
    });

    testWidgets('shows selected state when value equals groupValue', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WiredRadioListTile<String>(
              value: 'a',
              groupValue: 'a',
              onChanged: (_) => true,
            ),
          ),
        ),
      );

      // When selected, WiredRadio renders an additional filled inner circle.
      final canvasWidgets = find.descendant(
        of: find.byType(WiredRadio<String>),
        matching: find.byType(WiredCanvas),
      );
      expect(canvasWidgets, findsAtLeast(2));
    });

    testWidgets('shows unselected state when value differs from groupValue', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WiredRadioListTile<String>(
              value: 'a',
              groupValue: 'b',
              onChanged: (_) => true,
            ),
          ),
        ),
      );

      // When not selected, WiredRadio renders only the outer circle.
      final canvasWidgets = find.descendant(
        of: find.byType(WiredRadio<String>),
        matching: find.byType(WiredCanvas),
      );
      expect(canvasWidgets, findsOneWidget);
    });

    testWidgets('showDivider defaults to true', (tester) async {
      final tile = WiredRadioListTile<String>(
        value: 'a',
        groupValue: null,
        onChanged: (_) => true,
      );

      expect(tile.showDivider, isTrue);
    });

    testWidgets('property defaults are correct', (tester) async {
      final tile = WiredRadioListTile<String>(
        value: 'a',
        groupValue: null,
        onChanged: (_) => true,
      );

      expect(tile.title, isNull);
      expect(tile.subtitle, isNull);
      expect(tile.showDivider, isTrue);
    });

    testWidgets('renders divider when showDivider is true', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WiredRadioListTile<String>(
              value: 'a',
              groupValue: null,
              onChanged: (_) => true,
              showDivider: true,
            ),
          ),
        ),
      );

      // WiredRadio also uses WiredCanvas internally, so we count all
      // WiredCanvas widgets under WiredListTile. With showDivider=true
      // there should be more than with showDivider=false.
      final canvasCount = find
          .descendant(
            of: find.byType(WiredListTile),
            matching: find.byType(WiredCanvas),
          )
          .evaluate()
          .length;

      // WiredRadio renders 1 canvas (outer circle, not selected), plus
      // 1 for the divider = 2.
      expect(canvasCount, greaterThanOrEqualTo(2));
    });

    testWidgets('does not render divider when showDivider is false', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WiredRadioListTile<String>(
              value: 'a',
              groupValue: null,
              onChanged: (_) => true,
              showDivider: false,
            ),
          ),
        ),
      );

      // WiredRadio renders 1 WiredCanvas (outer circle, not selected).
      // With showDivider=false, no additional divider canvas is present.
      final canvasCount = find
          .descendant(
            of: find.byType(WiredListTile),
            matching: find.byType(WiredCanvas),
          )
          .evaluate()
          .length;

      expect(canvasCount, 1);
    });

    testWidgets('does not crash when onChanged is null', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WiredRadioListTile<String>(
              value: 'a',
              groupValue: null,
              onChanged: null,
              title: const Text('No callback'),
            ),
          ),
        ),
      );

      // Tapping should not throw.
      await tester.tap(find.byType(InkWell));
      await tester.pump();

      expect(find.byType(WiredRadioListTile<String>), findsOneWidget);
    });

    testWidgets('works with int generic type', (tester) async {
      int? receivedValue;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WiredRadioListTile<int>(
              value: 42,
              groupValue: 1,
              onChanged: (v) {
                receivedValue = v;
                return true;
              },
              title: const Text('Answer'),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(InkWell));
      await tester.pump();

      expect(receivedValue, 42);
    });

    testWidgets('renders multiple tiles in a column', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                WiredRadioListTile<String>(
                  value: 'a',
                  groupValue: 'a',
                  onChanged: (_) => true,
                  title: const Text('Option A'),
                ),
                WiredRadioListTile<String>(
                  value: 'b',
                  groupValue: 'a',
                  onChanged: (_) => true,
                  title: const Text('Option B'),
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(WiredRadioListTile<String>), findsNWidgets(2));
      expect(find.text('Option A'), findsOneWidget);
      expect(find.text('Option B'), findsOneWidget);
    });
  });
}
