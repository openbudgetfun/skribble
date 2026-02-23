import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';

void main() {
  group('WiredSearchBar', () {
    testWidgets('renders without error', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: WiredSearchBar()),
        ),
      );

      expect(find.byType(WiredSearchBar), findsOneWidget);
    });

    testWidgets('renders default search icon', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: WiredSearchBar()),
        ),
      );

      expect(find.byIcon(Icons.search), findsOneWidget);
    });

    testWidgets('renders custom leading widget', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WiredSearchBar(
              leading: const Icon(Icons.filter_list),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.filter_list), findsOneWidget);
      // The default search icon should not be present when a custom leading
      // widget is provided.
      expect(find.byIcon(Icons.search), findsNothing);
    });

    testWidgets('renders trailing widget when provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WiredSearchBar(
              trailing: const Icon(Icons.close),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.close), findsOneWidget);
    });

    testWidgets('does not render trailing when null', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: WiredSearchBar()),
        ),
      );

      // Only the search icon should be present, no trailing.
      expect(find.byIcon(Icons.close), findsNothing);
    });

    testWidgets('displays default hint text', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: WiredSearchBar()),
        ),
      );

      expect(find.text('Search...'), findsOneWidget);
    });

    testWidgets('displays custom hint text', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WiredSearchBar(hintText: 'Find items...'),
          ),
        ),
      );

      expect(find.text('Find items...'), findsOneWidget);
      expect(find.text('Search...'), findsNothing);
    });

    testWidgets('contains TextField internally', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: WiredSearchBar()),
        ),
      );

      expect(
        find.descendant(
          of: find.byType(WiredSearchBar),
          matching: find.byType(TextField),
        ),
        findsOneWidget,
      );
    });

    testWidgets('accepts text input', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: WiredSearchBar()),
        ),
      );

      await tester.enterText(find.byType(TextField), 'search query');
      await tester.pump();

      expect(find.text('search query'), findsOneWidget);
    });

    testWidgets('calls onChanged callback', (tester) async {
      String? changedValue;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WiredSearchBar(
              onChanged: (value) {
                changedValue = value;
              },
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), 'typed text');
      await tester.pump();

      expect(changedValue, 'typed text');
    });

    testWidgets('calls onSubmitted callback', (tester) async {
      String? submittedValue;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WiredSearchBar(
              onSubmitted: (value) {
                submittedValue = value;
              },
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), 'submitted query');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();

      expect(submittedValue, 'submitted query');
    });

    testWidgets('uses provided TextEditingController', (tester) async {
      final controller = TextEditingController(text: 'preset');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WiredSearchBar(controller: controller),
          ),
        ),
      );

      expect(find.text('preset'), findsOneWidget);

      controller.dispose();
    });

    testWidgets('has fixed height of 48', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: WiredSearchBar()),
        ),
      );

      final size = tester.getSize(find.byType(WiredSearchBar));
      expect(size.height, 48.0);
    });

    testWidgets('contains WiredCanvas background', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: WiredSearchBar()),
        ),
      );

      expect(
        find.descendant(
          of: find.byType(WiredSearchBar),
          matching: find.byType(WiredCanvas),
        ),
        findsOneWidget,
      );
    });

    testWidgets('contains Stack for layered layout', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: WiredSearchBar()),
        ),
      );

      expect(
        find.descendant(
          of: find.byType(WiredSearchBar),
          matching: find.byType(Stack),
        ),
        findsOneWidget,
      );
    });

    testWidgets('contains Row for horizontal layout', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: WiredSearchBar()),
        ),
      );

      expect(
        find.descendant(
          of: find.byType(WiredSearchBar),
          matching: find.byType(Row),
        ),
        findsOneWidget,
      );
    });
  });
}
