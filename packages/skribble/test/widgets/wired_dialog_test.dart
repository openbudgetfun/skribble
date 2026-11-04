import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';

import '../helpers/finders.dart';
import '../helpers/pump_app.dart';

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
      expect(childPadding.padding, const EdgeInsets.all(20.0));
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

    testWidgets('contains a Dialog widget', (tester) async {
      await pumpApp(tester, WiredDialog(child: const Text('Test')));

      expect(
        find.descendant(
          of: find.byType(WiredDialog),
          matching: find.byType(Dialog),
        ),
        findsOneWidget,
      );
    });

    testWidgets('contains WiredCanvas for border', (tester) async {
      await pumpApp(tester, WiredDialog(child: const Text('Border check')));

      expect(
        find.descendant(
          of: find.byType(WiredDialog),
          matching: findWiredCanvas,
        ),
        findsWidgets,
      );
    });

    testWidgets('renders complex child without error', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WiredDialog(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Title'),
                  const SizedBox(height: 16),
                  const Text('Body content here'),
                  const SizedBox(height: 16),
                  ElevatedButton(onPressed: () {}, child: const Text('OK')),
                ],
              ),
            ),
          ),
        ),
      );

      expect(find.text('Title'), findsOneWidget);
      expect(find.text('Body content here'), findsOneWidget);
      expect(find.text('OK'), findsOneWidget);
    });

    testWidgets('renders within WiredTheme', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: WiredTheme(
            data: WiredThemeData(borderColor: Colors.amber),
            child: Scaffold(body: WiredDialog(child: Text('themed'))),
          ),
        ),
      );
      expect(find.text('themed'), findsOneWidget);
    });

    testWidgets('hugs its content inside a dialog route', (tester) async {
      tester.view
        ..physicalSize = const Size(360, 800)
        ..devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => TextButton(
              onPressed: () => showDialog<void>(
                context: context,
                builder: (_) => const WiredDialog(child: Text('Short')),
              ),
              child: const Text('Open'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      final dialog = tester.getSize(
        find.descendant(
          of: find.byType(WiredDialog),
          matching: findWiredCanvas,
        ),
      );
      // A single line of text and the 20 pixel padding, not the full screen.
      expect(dialog.height, lessThan(150));
    });

    testWidgets('lays out inside unbounded height', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: WiredDialog(child: Text('Scrolling')),
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(find.text('Scrolling'), findsOneWidget);
    });
  });
}
