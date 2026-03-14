import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';

import '../helpers/pump_app.dart';

void main() {
  group('WiredCheckbox', () {
    testWidgets('renders without error', (tester) async {
      await pumpApp(tester, WiredCheckbox(value: false, onChanged: (_) {}));

      expect(find.byType(WiredCheckbox), findsOneWidget);
    });

    testWidgets('calls onChanged when tapped', (tester) async {
      bool? receivedValue;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WiredCheckbox(
              value: false,
              onChanged: (v) => receivedValue = v,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(Checkbox));
      await tester.pump();

      expect(receivedValue, isNotNull);
      expect(receivedValue, isTrue);
    });

    testWidgets('displays checked state when value is true', (tester) async {
      await pumpApp(tester, WiredCheckbox(value: true, onChanged: (_) {}));

      // The internal Checkbox should reflect the initial checked state.
      final checkbox = tester.widget<Checkbox>(find.byType(Checkbox));

      expect(checkbox.value, isTrue);
    });

    testWidgets('toggles internal state', (tester) async {
      bool? lastValue;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WiredCheckbox(value: false, onChanged: (v) => lastValue = v),
          ),
        ),
      );

      // Initially unchecked.
      var checkbox = tester.widget<Checkbox>(find.byType(Checkbox));
      expect(checkbox.value, isFalse);

      // Tap to check.
      await tester.tap(find.byType(Checkbox));
      await tester.pump();

      expect(lastValue, isTrue);

      // After tapping, the internal state via useState should now be true.
      checkbox = tester.widget<Checkbox>(find.byType(Checkbox));
      expect(checkbox.value, isTrue);
    });

    testWidgets('displays unchecked state when value is false', (tester) async {
      await pumpApp(tester, WiredCheckbox(value: false, onChanged: (_) {}));

      final checkbox = tester.widget<Checkbox>(find.byType(Checkbox));
      expect(checkbox.value, isFalse);
    });

    testWidgets('contains RepaintBoundary wrapper', (tester) async {
      await pumpApp(tester, WiredCheckbox(value: false, onChanged: (_) {}));

      // WiredCheckbox uses buildWiredElement which wraps with RepaintBoundary.
      expect(
        find.descendant(
          of: find.byType(WiredCheckbox),
          matching: find.byType(RepaintBoundary),
        ),
        findsOneWidget,
      );
    });

    testWidgets('renders within WiredTheme', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: WiredTheme(
            data: WiredThemeData(borderColor: Colors.red),
            child: Scaffold(
              body: WiredCheckbox(value: true, onChanged: (_) {}),
            ),
          ),
        ),
      );
      expect(find.byType(WiredCheckbox), findsOneWidget);
    });
  });
}
