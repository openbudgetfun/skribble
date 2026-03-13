import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';

void main() {
  group('WiredRadio', () {
    testWidgets('renders without error', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WiredRadio<String>(
              value: 'a',
              groupValue: null,
              onChanged: (_) => true,
            ),
          ),
        ),
      );

      expect(find.byType(WiredRadio<String>), findsOneWidget);
    });

    testWidgets('shows filled circle when selected (value == groupValue)', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WiredRadio<String>(
              value: 'a',
              groupValue: 'a',
              onChanged: (_) => true,
            ),
          ),
        ),
      );

      // When selected, the widget renders two WiredCanvas widgets:
      // one for the outer circle and one for the filled inner circle.
      final canvasWidgets = find.descendant(
        of: find.byType(WiredRadio<String>),
        matching: find.byType(WiredCanvas),
      );
      expect(canvasWidgets, findsAtLeast(2));
    });

    testWidgets('shows empty circle when not selected', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WiredRadio<String>(
              value: 'a',
              groupValue: 'b',
              onChanged: (_) => true,
            ),
          ),
        ),
      );

      // When not selected, there is only the outer circle WiredCanvas
      // (the inner filled one is conditionally hidden).
      final canvasWidgets = find.descendant(
        of: find.byType(WiredRadio<String>),
        matching: find.byType(WiredCanvas),
      );
      expect(canvasWidgets, findsOneWidget);
    });

    testWidgets('calls onChanged when tapped', (tester) async {
      String? changedValue;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WiredRadio<String>(
              value: 'a',
              groupValue: 'b',
              onChanged: (value) {
                changedValue = value;
                return true;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byType(Radio<String>));
      await tester.pump();

      expect(changedValue, 'a');
    });

    testWidgets('works with String generic type', (tester) async {
      String? selectedValue;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                WiredRadio<String>(
                  value: 'option1',
                  groupValue: 'option1',
                  onChanged: (v) {
                    selectedValue = v;
                    return true;
                  },
                ),
                WiredRadio<String>(
                  value: 'option2',
                  groupValue: 'option1',
                  onChanged: (v) {
                    selectedValue = v;
                    return true;
                  },
                ),
              ],
            ),
          ),
        ),
      );

      // The first radio should be selected (has 2+ canvases).
      final firstRadio = find.byType(WiredRadio<String>).first;
      final firstCanvases = find.descendant(
        of: firstRadio,
        matching: find.byType(WiredCanvas),
      );
      expect(firstCanvases, findsAtLeast(2));

      // Tap the second radio.
      final secondRadio = find.byType(Radio<String>).last;
      await tester.tap(secondRadio);
      await tester.pump();

      expect(selectedValue, 'option2');
    });

    testWidgets('works with int generic type', (tester) async {
      int? selectedValue;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                WiredRadio<int>(
                  value: 1,
                  groupValue: 1,
                  onChanged: (v) {
                    selectedValue = v;
                    return true;
                  },
                ),
                WiredRadio<int>(
                  value: 2,
                  groupValue: 1,
                  onChanged: (v) {
                    selectedValue = v;
                    return true;
                  },
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(WiredRadio<int>), findsNWidgets(2));

      // Tap the second radio.
      final secondRadio = find.byType(Radio<int>).last;
      await tester.tap(secondRadio);
      await tester.pump();

      expect(selectedValue, 2);
    });
  });
}
