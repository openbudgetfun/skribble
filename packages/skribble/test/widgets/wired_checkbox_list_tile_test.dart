import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';

void main() {
  group('WiredCheckboxListTile', () {
    testWidgets('renders without error', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WiredCheckboxListTile(value: false, onChanged: (_) {}),
          ),
        ),
      );

      expect(find.byType(WiredCheckboxListTile), findsOneWidget);
    });

    testWidgets('renders title text', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WiredCheckboxListTile(
              value: false,
              onChanged: (_) {},
              title: const Text('Enable notifications'),
            ),
          ),
        ),
      );

      expect(find.text('Enable notifications'), findsOneWidget);
    });

    testWidgets('renders subtitle text', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WiredCheckboxListTile(
              value: false,
              onChanged: (_) {},
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
            body: WiredCheckboxListTile(
              value: false,
              onChanged: (_) {},
              title: const Text('Main title'),
              subtitle: const Text('Supporting text'),
            ),
          ),
        ),
      );

      expect(find.text('Main title'), findsOneWidget);
      expect(find.text('Supporting text'), findsOneWidget);
    });

    testWidgets('contains WiredCheckbox as trailing widget', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WiredCheckboxListTile(value: false, onChanged: (_) {}),
          ),
        ),
      );

      expect(
        find.descendant(
          of: find.byType(WiredCheckboxListTile),
          matching: find.byType(WiredCheckbox),
        ),
        findsOneWidget,
      );
    });

    testWidgets('contains WiredListTile internally', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WiredCheckboxListTile(value: false, onChanged: (_) {}),
          ),
        ),
      );

      expect(
        find.descendant(
          of: find.byType(WiredCheckboxListTile),
          matching: find.byType(WiredListTile),
        ),
        findsOneWidget,
      );
    });

    testWidgets('calls onChanged when list tile is tapped', (tester) async {
      bool? receivedValue;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WiredCheckboxListTile(
              value: false,
              onChanged: (v) => receivedValue = v,
              title: const Text('Tap me'),
            ),
          ),
        ),
      );

      // Tap the InkWell area (the list tile).
      await tester.tap(find.byType(InkWell));
      await tester.pump();

      // When value is false, tapping the tile calls onChanged(true).
      expect(receivedValue, isTrue);
    });

    testWidgets('calls onChanged when checkbox is tapped', (tester) async {
      bool? receivedValue;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WiredCheckboxListTile(
              value: false,
              onChanged: (v) => receivedValue = v,
            ),
          ),
        ),
      );

      // Tap the internal Checkbox widget.
      await tester.tap(find.byType(Checkbox));
      await tester.pump();

      expect(receivedValue, isNotNull);
    });

    testWidgets('passes value to WiredCheckbox correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WiredCheckboxListTile(value: true, onChanged: (_) {}),
          ),
        ),
      );

      final checkbox = tester.widget<Checkbox>(find.byType(Checkbox));
      expect(checkbox.value, isTrue);
    });

    testWidgets('passes false value to WiredCheckbox correctly', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WiredCheckboxListTile(value: false, onChanged: (_) {}),
          ),
        ),
      );

      final checkbox = tester.widget<Checkbox>(find.byType(Checkbox));
      expect(checkbox.value, isFalse);
    });

    testWidgets('showDivider defaults to true', (tester) async {
      const tile = WiredCheckboxListTile(value: false, onChanged: _noOp);

      expect(tile.showDivider, isTrue);
    });

    testWidgets('property defaults are correct', (tester) async {
      const tile = WiredCheckboxListTile(value: false, onChanged: _noOp);

      expect(tile.title, isNull);
      expect(tile.subtitle, isNull);
      expect(tile.showDivider, isTrue);
    });

    testWidgets('renders divider when showDivider is true', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WiredCheckboxListTile(
              value: false,
              onChanged: (_) {},
              showDivider: true,
            ),
          ),
        ),
      );

      // When showDivider is true, WiredListTile renders a WiredCanvas
      // for the divider line.
      expect(
        find.descendant(
          of: find.byType(WiredListTile),
          matching: find.byType(WiredCanvas),
        ),
        findsOneWidget,
      );
    });

    testWidgets('does not render divider when showDivider is false', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WiredCheckboxListTile(
              value: false,
              onChanged: (_) {},
              showDivider: false,
            ),
          ),
        ),
      );

      // When showDivider is false, no WiredCanvas for the divider should
      // appear within the WiredListTile.
      expect(
        find.descendant(
          of: find.byType(WiredListTile),
          matching: find.byType(WiredCanvas),
        ),
        findsNothing,
      );
    });

    testWidgets('handles null value for tristate checkbox', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WiredCheckboxListTile(value: null, onChanged: (_) {}),
          ),
        ),
      );

      expect(find.byType(WiredCheckboxListTile), findsOneWidget);
    });
  });
}

void _noOp(bool? value) {}
