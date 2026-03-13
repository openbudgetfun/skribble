import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';

void main() {
  Widget buildSubject({
    Widget? title,
    Widget? content,
    List<Widget> actions = const [],
  }) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: WiredCupertinoAlertDialog(
            title: title,
            content: content,
            actions: actions,
          ),
        ),
      ),
    );
  }

  group('WiredCupertinoAlertDialog', () {
    testWidgets('renders without error', (tester) async {
      await tester.pumpWidget(buildSubject());
      expect(find.byType(WiredCupertinoAlertDialog), findsOneWidget);
    });

    testWidgets('renders title', (tester) async {
      await tester.pumpWidget(buildSubject(title: const Text('Alert')));
      expect(find.text('Alert'), findsOneWidget);
    });

    testWidgets('renders content', (tester) async {
      await tester.pumpWidget(
        buildSubject(content: const Text('Are you sure?')),
      );
      expect(find.text('Are you sure?'), findsOneWidget);
    });

    testWidgets('renders title and content together', (tester) async {
      await tester.pumpWidget(
        buildSubject(
          title: const Text('Delete'),
          content: const Text('This action cannot be undone.'),
        ),
      );
      expect(find.text('Delete'), findsOneWidget);
      expect(find.text('This action cannot be undone.'), findsOneWidget);
    });

    testWidgets('renders action buttons', (tester) async {
      await tester.pumpWidget(
        buildSubject(
          title: const Text('Confirm'),
          actions: [
            WiredCupertinoDialogAction(
              onPressed: () {},
              child: const Text('Cancel'),
            ),
            WiredCupertinoDialogAction(
              onPressed: () {},
              isDefaultAction: true,
              child: const Text('OK'),
            ),
          ],
        ),
      );
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('OK'), findsOneWidget);
    });

    testWidgets('action button calls onPressed', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        buildSubject(
          actions: [
            WiredCupertinoDialogAction(
              onPressed: () => tapped = true,
              child: const Text('OK'),
            ),
          ],
        ),
      );
      await tester.tap(find.text('OK'));
      expect(tapped, isTrue);
    });

    testWidgets('destructive action renders', (tester) async {
      await tester.pumpWidget(
        buildSubject(
          actions: [
            WiredCupertinoDialogAction(
              onPressed: () {},
              isDestructiveAction: true,
              child: const Text('Delete'),
            ),
          ],
        ),
      );
      expect(find.text('Delete'), findsOneWidget);
    });

    testWidgets('showWiredCupertinoDialog shows dialog', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showWiredCupertinoDialog<void>(
                  context: context,
                  title: const Text('Test'),
                  actions: [
                    WiredCupertinoDialogAction(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Close'),
                    ),
                  ],
                ),
                child: const Text('Show'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Show'));
      await tester.pumpAndSettle();
      expect(find.text('Test'), findsOneWidget);
      expect(find.text('Close'), findsOneWidget);
    });
  });
}
