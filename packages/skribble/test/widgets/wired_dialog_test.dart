import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';

void main() {
  group('WiredDialog', () {
    testWidgets('renders child content', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WiredDialog(child: const Text('Dialog content')),
          ),
        ),
      );

      expect(find.text('Dialog content'), findsOneWidget);
    });

    testWidgets('applies default padding', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WiredDialog(child: const Text('Padded content')),
          ),
        ),
      );

      // The WiredDialog wraps its child in a Padding with default 20.0.
      final paddingWidgets = find.descendant(
        of: find.byType(WiredDialog),
        matching: find.byType(Padding),
      );

      // There should be at least two Padding widgets: one for the
      // WiredCanvas (5.0) and one for the child (default 20.0).
      expect(paddingWidgets, findsAtLeast(2));

      // Verify the child's padding is EdgeInsets.all(20.0).
      final childPadding = tester.widgetList<Padding>(paddingWidgets).last;
      expect(childPadding.padding, EdgeInsets.all(20.0));
    });

    testWidgets('applies custom padding', (tester) async {
      const customPadding = EdgeInsets.symmetric(
        horizontal: 40.0,
        vertical: 10.0,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WiredDialog(
              padding: customPadding,
              child: const Text('Custom padded'),
            ),
          ),
        ),
      );

      // Find the Padding widgets under the dialog.
      final paddingWidgets = find.descendant(
        of: find.byType(WiredDialog),
        matching: find.byType(Padding),
      );

      // The last Padding wraps the child with the custom padding.
      final childPadding = tester.widgetList<Padding>(paddingWidgets).last;
      expect(childPadding.padding, customPadding);
    });
  });
}
