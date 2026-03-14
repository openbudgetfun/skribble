import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';

import '../helpers/pump_app.dart';

void main() {
  Widget buildSubject({
    Widget? title,
    Widget? message,
    List<Widget> actions = const [],
    Widget? cancelButton,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: WiredCupertinoActionSheet(
            title: title,
            message: message,
            actions: actions,
            cancelButton: cancelButton,
          ),
        ),
      ),
    );
  }

  group('WiredCupertinoActionSheet', () {
    testWidgets('renders without error', (tester) async {
      await tester.pumpWidget(buildSubject());
      expect(find.byType(WiredCupertinoActionSheet), findsOneWidget);
    });

    testWidgets('renders title', (tester) async {
      await tester.pumpWidget(buildSubject(title: const Text('Choose')));
      expect(find.text('Choose'), findsOneWidget);
    });

    testWidgets('renders message', (tester) async {
      await tester.pumpWidget(
        buildSubject(message: const Text('Pick an option')),
      );
      expect(find.text('Pick an option'), findsOneWidget);
    });

    testWidgets('renders title and message together', (tester) async {
      await tester.pumpWidget(
        buildSubject(
          title: const Text('Share'),
          message: const Text('Choose how to share this item.'),
        ),
      );
      expect(find.text('Share'), findsOneWidget);
      expect(find.text('Choose how to share this item.'), findsOneWidget);
    });

    testWidgets('renders action buttons', (tester) async {
      await tester.pumpWidget(
        buildSubject(
          actions: [
            WiredCupertinoActionSheetAction(
              onPressed: () {},
              child: const Text('Copy'),
            ),
            WiredCupertinoActionSheetAction(
              onPressed: () {},
              child: const Text('Move'),
            ),
          ],
        ),
      );
      expect(find.text('Copy'), findsOneWidget);
      expect(find.text('Move'), findsOneWidget);
    });

    testWidgets('action calls onPressed', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        buildSubject(
          actions: [
            WiredCupertinoActionSheetAction(
              onPressed: () => tapped = true,
              child: const Text('Tap Me'),
            ),
          ],
        ),
      );
      await tester.tap(find.text('Tap Me'));
      expect(tapped, isTrue);
    });

    testWidgets('renders cancel button', (tester) async {
      await tester.pumpWidget(
        buildSubject(
          actions: [
            WiredCupertinoActionSheetAction(
              onPressed: () {},
              child: const Text('Share'),
            ),
          ],
          cancelButton: WiredCupertinoActionSheetAction(
            onPressed: () {},
            child: const Text('Cancel'),
          ),
        ),
      );
      expect(find.text('Cancel'), findsOneWidget);
    });

    testWidgets('destructive action renders', (tester) async {
      await tester.pumpWidget(
        buildSubject(
          actions: [
            WiredCupertinoActionSheetAction(
              onPressed: () {},
              isDestructiveAction: true,
              child: const Text('Delete'),
            ),
          ],
        ),
      );
      expect(find.text('Delete'), findsOneWidget);
    });

    testWidgets('showWiredCupertinoActionSheet shows sheet', (tester) async {
      await pumpApp(tester, Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showWiredCupertinoActionSheet<void>(
                  context: context,
                  title: const Text('Options'),
                  actions: [
                    WiredCupertinoActionSheetAction(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Option 1'),
                    ),
                  ],
                  cancelButton: WiredCupertinoActionSheetAction(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                ),
                child: const Text('Show'),
              ),
            ));
      await tester.tap(find.text('Show'));
      await tester.pumpAndSettle();
      expect(find.text('Options'), findsOneWidget);
      expect(find.text('Option 1'), findsOneWidget);
    });
  });
}
