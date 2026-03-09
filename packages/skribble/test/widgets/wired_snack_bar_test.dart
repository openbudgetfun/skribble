import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';

void main() {
  group('WiredSnackBarContent', () {
    testWidgets('renders without error', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WiredSnackBarContent(
              child: const Text('Snack bar message'),
            ),
          ),
        ),
      );

      expect(find.byType(WiredSnackBarContent), findsOneWidget);
    });

    testWidgets('renders child content', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WiredSnackBarContent(
              child: const Text('Hello snack bar'),
            ),
          ),
        ),
      );

      expect(find.text('Hello snack bar'), findsOneWidget);
    });

    testWidgets('renders action widget when provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WiredSnackBarContent(
              action: TextButton(
                onPressed: () {},
                child: const Text('UNDO'),
              ),
              child: const Text('Message'),
            ),
          ),
        ),
      );

      expect(find.text('Message'), findsOneWidget);
      expect(find.text('UNDO'), findsOneWidget);
    });

    testWidgets('does not render action when null', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WiredSnackBarContent(
              child: const Text('No action'),
            ),
          ),
        ),
      );

      expect(find.byType(TextButton), findsNothing);
    });

    testWidgets('contains Row for layout', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WiredSnackBarContent(
              child: const Text('Row test'),
            ),
          ),
        ),
      );

      expect(
        find.descendant(
          of: find.byType(WiredSnackBarContent),
          matching: find.byType(Row),
        ),
        findsOneWidget,
      );
    });

    testWidgets('wraps child with DefaultTextStyle', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WiredSnackBarContent(
              child: const Text('Styled text'),
            ),
          ),
        ),
      );

      expect(
        find.descendant(
          of: find.byType(WiredSnackBarContent),
          matching: find.byType(DefaultTextStyle),
        ),
        findsAtLeast(1),
      );
    });

    testWidgets('child is wrapped in Expanded', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WiredSnackBarContent(
              child: const Text('Expanded test'),
            ),
          ),
        ),
      );

      expect(
        find.descendant(
          of: find.byType(WiredSnackBarContent),
          matching: find.byType(Expanded),
        ),
        findsOneWidget,
      );
    });
  });

  group('showWiredSnackBar', () {
    testWidgets('shows a SnackBar', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    showWiredSnackBar(
                      context,
                      content: const Text('Snack message'),
                    );
                  },
                  child: const Text('Show'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show'));
      await tester.pumpAndSettle();

      expect(find.text('Snack message'), findsOneWidget);
      expect(find.byType(SnackBar), findsOneWidget);
    });

    testWidgets('SnackBar has floating behavior', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    showWiredSnackBar(
                      context,
                      content: const Text('Floating'),
                    );
                  },
                  child: const Text('Show'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show'));
      await tester.pumpAndSettle();

      final snackBar = tester.widget<SnackBar>(find.byType(SnackBar));
      expect(snackBar.behavior, SnackBarBehavior.floating);
    });

    testWidgets('SnackBar has transparent background', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    showWiredSnackBar(
                      context,
                      content: const Text('Transparent'),
                    );
                  },
                  child: const Text('Show'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show'));
      await tester.pumpAndSettle();

      final snackBar = tester.widget<SnackBar>(find.byType(SnackBar));
      expect(snackBar.backgroundColor, Colors.transparent);
      expect(snackBar.elevation, 0);
    });

    testWidgets('SnackBar uses zero padding', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    showWiredSnackBar(
                      context,
                      content: const Text('Zero padding'),
                    );
                  },
                  child: const Text('Show'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show'));
      await tester.pumpAndSettle();

      final snackBar = tester.widget<SnackBar>(find.byType(SnackBar));
      expect(snackBar.padding, EdgeInsets.zero);
    });
  });
}
