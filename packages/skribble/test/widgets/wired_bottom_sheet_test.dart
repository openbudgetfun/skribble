import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';

import '../helpers/pump_app.dart';

void main() {
  group('WiredBottomSheet', () {
    testWidgets('renders without error', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WiredBottomSheet(child: const Text('Sheet content')),
          ),
        ),
      );

      expect(find.byType(WiredBottomSheet), findsOneWidget);
    });

    testWidgets('renders child content', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WiredBottomSheet(child: const Text('Sheet content')),
          ),
        ),
      );

      expect(find.text('Sheet content'), findsOneWidget);
    });

    testWidgets('renders drag handle', (tester) async {
      await pumpApp(tester, WiredBottomSheet(child: const Text('Content')));

      // The drag handle is a 40x4 SizedBox containing a WiredCanvas.
      // There should be at least two WiredCanvas widgets: the top line and
      // the drag handle.
      expect(
        find.descendant(
          of: find.byType(WiredBottomSheet),
          matching: find.byType(WiredCanvas),
        ),
        findsNWidgets(2),
      );
    });

    testWidgets('renders top border line', (tester) async {
      await pumpApp(tester, WiredBottomSheet(child: const Text('Content')));

      // The top border is a 2px-tall SizedBox containing a WiredCanvas.
      final sizedBoxes = tester.widgetList<SizedBox>(
        find.descendant(
          of: find.byType(WiredBottomSheet),
          matching: find.byType(SizedBox),
        ),
      );

      // One SizedBox should have height 2 (top line) and another width 40,
      // height 4 (drag handle).
      final topLine = sizedBoxes.where((s) => s.height == 2);
      expect(topLine, isNotEmpty);
    });

    testWidgets('uses Column with MainAxisSize.min', (tester) async {
      await pumpApp(tester, WiredBottomSheet(child: const Text('Content')));

      final column = tester.widget<Column>(
        find.descendant(
          of: find.byType(WiredBottomSheet),
          matching: find.byType(Column),
        ),
      );
      expect(column.mainAxisSize, MainAxisSize.min);
    });

    testWidgets('renders multiple children correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WiredBottomSheet(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Text('Item 1'),
                  Text('Item 2'),
                  Text('Item 3'),
                ],
              ),
            ),
          ),
        ),
      );

      expect(find.text('Item 1'), findsOneWidget);
      expect(find.text('Item 2'), findsOneWidget);
      expect(find.text('Item 3'), findsOneWidget);
    });
  });

  group('showWiredBottomSheet', () {
    testWidgets('opens a modal bottom sheet', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  unawaited(
                    showWiredBottomSheet<void>(
                      context: context,
                      builder: (context) => const Text('Bottom sheet content'),
                    ),
                  );
                },
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );

      // Tap the button to open the bottom sheet.
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('Bottom sheet content'), findsOneWidget);
      expect(find.byType(WiredBottomSheet), findsOneWidget);
    });

    testWidgets('wraps builder content in WiredBottomSheet', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  unawaited(
                    showWiredBottomSheet<void>(
                      context: context,
                      builder: (context) => const Padding(
                        padding: EdgeInsets.all(16),
                        child: Text('Wrapped content'),
                      ),
                    ),
                  );
                },
                child: const Text('Show'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show'));
      await tester.pumpAndSettle();

      // The content should be inside a WiredBottomSheet.
      expect(
        find.descendant(
          of: find.byType(WiredBottomSheet),
          matching: find.text('Wrapped content'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('can be dismissed', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  unawaited(
                    showWiredBottomSheet<void>(
                      context: context,
                      builder: (context) => const Text('Dismissible'),
                    ),
                  );
                },
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('Dismissible'), findsOneWidget);

      // Tap the barrier/scrim to dismiss.
      await tester.tapAt(const Offset(20, 20));
      await tester.pumpAndSettle();

      expect(find.text('Dismissible'), findsNothing);
    });
  });
}
