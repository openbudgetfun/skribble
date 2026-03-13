import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';

void main() {
  group('WiredAutocomplete', () {
    const options = ['Apple', 'Apricot', 'Banana'];

    testWidgets('renders without error', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 320,
              child: WiredAutocomplete<String>(
                options: options,
                displayStringForOption: _display,
              ),
            ),
          ),
        ),
      );

      expect(find.byType(WiredAutocomplete<String>), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
      expect(find.byType(RepaintBoundary), findsWidgets);
    });

    testWidgets('shows filtered options when typing', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 320,
              child: WiredAutocomplete<String>(
                options: options,
                displayStringForOption: _display,
              ),
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), 'ap');
      await tester.pumpAndSettle();

      expect(find.text('Apple'), findsOneWidget);
      expect(find.text('Apricot'), findsOneWidget);
      expect(find.text('Banana'), findsNothing);
    });

    testWidgets('calls onSelected and updates field text', (tester) async {
      String? selected;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 320,
              child: WiredAutocomplete<String>(
                options: options,
                displayStringForOption: _display,
                onSelected: (value) => selected = value,
              ),
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), 'ban');
      await tester.pumpAndSettle();

      await tester.tap(find.text('Banana'));
      await tester.pumpAndSettle();

      expect(selected, 'Banana');
      expect(find.text('Banana'), findsOneWidget);
    });

    testWidgets('supports label and hint text', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 320,
              child: WiredAutocomplete<String>(
                options: options,
                displayStringForOption: _display,
                labelText: 'Fruit',
                hintText: 'Search fruit',
              ),
            ),
          ),
        ),
      );

      expect(find.text('Fruit'), findsOneWidget);
      expect(find.text('Search fruit'), findsOneWidget);
    });

    testWidgets('shows no options for empty query', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 320,
              child: WiredAutocomplete<String>(
                options: options,
                displayStringForOption: _display,
              ),
            ),
          ),
        ),
      );

      // Empty text should show no suggestions
      await tester.enterText(find.byType(TextField), '');
      await tester.pumpAndSettle();

      expect(find.text('Apple'), findsNothing);
      expect(find.text('Banana'), findsNothing);
    });

    testWidgets('shows no options when query has no match', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 320,
              child: WiredAutocomplete<String>(
                options: options,
                displayStringForOption: _display,
              ),
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), 'xyz');
      await tester.pumpAndSettle();

      expect(find.text('Apple'), findsNothing);
      expect(find.text('Apricot'), findsNothing);
      expect(find.text('Banana'), findsNothing);
    });

    testWidgets('contains WiredCanvas for border', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 320,
              child: WiredAutocomplete<String>(
                options: options,
                displayStringForOption: _display,
              ),
            ),
          ),
        ),
      );

      expect(find.byType(WiredCanvas), findsWidgets);
    });
  });
}

String _display(String option) => option;
