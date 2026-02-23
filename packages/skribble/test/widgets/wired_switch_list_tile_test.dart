import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';

void main() {
  group('WiredSwitchListTile', () {
    testWidgets('renders without error', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WiredSwitchListTile(
              value: false,
              onChanged: (_) {},
            ),
          ),
        ),
      );

      expect(find.byType(WiredSwitchListTile), findsOneWidget);
    });

    testWidgets('renders title text', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WiredSwitchListTile(
              value: false,
              onChanged: (_) {},
              title: const Text('Dark Mode'),
            ),
          ),
        ),
      );

      expect(find.text('Dark Mode'), findsOneWidget);
    });

    testWidgets('renders subtitle text', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WiredSwitchListTile(
              value: false,
              onChanged: (_) {},
              title: const Text('Title'),
              subtitle: const Text('Description text'),
            ),
          ),
        ),
      );

      expect(find.text('Description text'), findsOneWidget);
    });

    testWidgets('renders title and subtitle together', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WiredSwitchListTile(
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

    testWidgets('contains WiredSwitch as trailing widget', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WiredSwitchListTile(
              value: false,
              onChanged: (_) {},
            ),
          ),
        ),
      );

      expect(
        find.descendant(
          of: find.byType(WiredSwitchListTile),
          matching: find.byType(WiredSwitch),
        ),
        findsOneWidget,
      );
    });

    testWidgets('contains WiredListTile internally', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WiredSwitchListTile(
              value: false,
              onChanged: (_) {},
            ),
          ),
        ),
      );

      expect(
        find.descendant(
          of: find.byType(WiredSwitchListTile),
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
            body: WiredSwitchListTile(
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

    testWidgets('calls onChanged with false when value is true and tapped',
        (tester) async {
      bool? receivedValue;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WiredSwitchListTile(
              value: true,
              onChanged: (v) => receivedValue = v,
              title: const Text('Tap me'),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(InkWell));
      await tester.pump();

      expect(receivedValue, isFalse);
    });

    testWidgets('calls onChanged when switch is tapped', (tester) async {
      bool? receivedValue;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WiredSwitchListTile(
              value: false,
              onChanged: (v) => receivedValue = v,
            ),
          ),
        ),
      );

      // Tap the GestureDetector inside WiredSwitch.
      final switchGesture = find.descendant(
        of: find.byType(WiredSwitch),
        matching: find.byType(GestureDetector),
      );
      await tester.tap(switchGesture);
      await tester.pump();

      expect(receivedValue, isTrue);
    });

    testWidgets('passes value to WiredSwitch correctly when false',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WiredSwitchListTile(
              value: false,
              onChanged: (_) {},
            ),
          ),
        ),
      );

      final wiredSwitch = tester.widget<WiredSwitch>(
        find.byType(WiredSwitch),
      );
      expect(wiredSwitch.value, isFalse);
    });

    testWidgets('passes value to WiredSwitch correctly when true',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WiredSwitchListTile(
              value: true,
              onChanged: (_) {},
            ),
          ),
        ),
      );

      final wiredSwitch = tester.widget<WiredSwitch>(
        find.byType(WiredSwitch),
      );
      expect(wiredSwitch.value, isTrue);
    });

    testWidgets('showDivider defaults to true', (tester) async {
      const tile = WiredSwitchListTile(
        value: false,
      );

      expect(tile.showDivider, isTrue);
    });

    testWidgets('property defaults are correct', (tester) async {
      const tile = WiredSwitchListTile(
        value: false,
      );

      expect(tile.title, isNull);
      expect(tile.subtitle, isNull);
      expect(tile.showDivider, isTrue);
      expect(tile.onChanged, isNull);
    });

    testWidgets('renders divider when showDivider is true', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WiredSwitchListTile(
              value: false,
              onChanged: (_) {},
              showDivider: true,
            ),
          ),
        ),
      );

      // WiredSwitch also uses WiredCanvas internally, so we count all
      // WiredCanvas widgets under WiredListTile. With showDivider=true
      // there should be more than with showDivider=false.
      final canvasCount = find
          .descendant(
            of: find.byType(WiredListTile),
            matching: find.byType(WiredCanvas),
          )
          .evaluate()
          .length;

      // WiredSwitch renders 2 canvases (track + thumb), plus 1 for divider = 3.
      expect(canvasCount, greaterThanOrEqualTo(3));
    });

    testWidgets('does not render divider when showDivider is false',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WiredSwitchListTile(
              value: false,
              onChanged: (_) {},
              showDivider: false,
            ),
          ),
        ),
      );

      // WiredSwitch renders 2 WiredCanvas widgets (track + thumb).
      // With showDivider=false, no additional divider canvas is present.
      final canvasCount = find
          .descendant(
            of: find.byType(WiredListTile),
            matching: find.byType(WiredCanvas),
          )
          .evaluate()
          .length;

      expect(canvasCount, 2);
    });

    testWidgets('does not crash when onChanged is null', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WiredSwitchListTile(
              value: false,
              title: const Text('No callback'),
            ),
          ),
        ),
      );

      // Tapping should not throw even with null onChanged.
      await tester.tap(find.byType(InkWell));
      await tester.pump();

      expect(find.byType(WiredSwitchListTile), findsOneWidget);
    });

    testWidgets('renders multiple tiles in a column', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                WiredSwitchListTile(
                  value: true,
                  onChanged: (_) {},
                  title: const Text('Wi-Fi'),
                ),
                WiredSwitchListTile(
                  value: false,
                  onChanged: (_) {},
                  title: const Text('Bluetooth'),
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(WiredSwitchListTile), findsNWidgets(2));
      expect(find.text('Wi-Fi'), findsOneWidget);
      expect(find.text('Bluetooth'), findsOneWidget);
    });
  });
}
