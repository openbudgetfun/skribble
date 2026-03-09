import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';

void main() {
  group('WiredCombo', () {
    testWidgets('renders without error', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WiredCombo<String>(
              value: 'a',
              items: const [
                DropdownMenuItem(value: 'a', child: Text('Option A')),
                DropdownMenuItem(value: 'b', child: Text('Option B')),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(WiredCombo<String>), findsOneWidget);
    });

    testWidgets('shows dropdown items', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WiredCombo<String>(
              value: 'a',
              items: const [
                DropdownMenuItem(value: 'a', child: Text('Option A')),
                DropdownMenuItem(value: 'b', child: Text('Option B')),
              ],
            ),
          ),
        ),
      );

      // The selected value should be visible.
      expect(find.text('Option A'), findsOneWidget);

      // Tap the dropdown to open it.
      await tester.tap(find.byType(DropdownButton<String>));
      await tester.pumpAndSettle();

      // Both items should now be visible in the dropdown overlay.
      expect(find.text('Option A'), findsAtLeast(1));
      expect(find.text('Option B'), findsAtLeast(1));
    });

    testWidgets('calls onChanged when item selected', (tester) async {
      String? changedValue;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WiredCombo<String>(
              value: 'a',
              items: const [
                DropdownMenuItem(value: 'a', child: Text('Option A')),
                DropdownMenuItem(value: 'b', child: Text('Option B')),
              ],
              onChanged: (value) {
                changedValue = value;
                return false;
              },
            ),
          ),
        ),
      );

      // Open the dropdown.
      await tester.tap(find.byType(DropdownButton<String>));
      await tester.pumpAndSettle();

      // Select the second option from the overlay.
      await tester.tap(find.text('Option B').last);
      await tester.pumpAndSettle();

      expect(changedValue, 'b');
    });
  });
}
