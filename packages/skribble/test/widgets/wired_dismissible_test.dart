import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';

import '../helpers/pump_app.dart';

void main() {
  group('WiredDismissible', () {
    testWidgets('renders without error', (tester) async {
      await pumpApp(tester, ListView(
              children: const [
                WiredDismissible(
                  dismissKey: ValueKey('item1'),
                  child: ListTile(title: Text('Swipe me')),
                ),
              ],
            ));
      expect(find.byType(WiredDismissible), findsOneWidget);
      expect(find.text('Swipe me'), findsOneWidget);
    });

    testWidgets('calls onDismissed when swiped', (tester) async {
      DismissDirection? dismissed;
      await pumpApp(tester, ListView(
              children: [
                WiredDismissible(
                  dismissKey: const ValueKey('d1'),
                  onDismissed: (dir) => dismissed = dir,
                  child: const SizedBox(height: 60, child: Text('Dismiss')),
                ),
              ],
            ));
      await tester.drag(find.text('Dismiss'), const Offset(500, 0));
      await tester.pumpAndSettle();
      expect(dismissed, DismissDirection.startToEnd);
    });

    testWidgets('shows delete background on swipe', (tester) async {
      await pumpApp(tester, ListView(
              children: [
                WiredDismissible(
                  dismissKey: const ValueKey('d2'),
                  onDismissed: (_) {},
                  child: const SizedBox(height: 60, child: Text('Swipe right')),
                ),
              ],
            ));
      // Start a drag to partially reveal background
      await tester.drag(find.text('Swipe right'), const Offset(100, 0));
      await tester.pump();
      expect(find.byIcon(Icons.delete), findsOneWidget);
    });

    testWidgets('respects confirmDismiss', (tester) async {
      await pumpApp(tester, ListView(
              children: [
                WiredDismissible(
                  dismissKey: const ValueKey('d3'),
                  confirmDismiss: (_) async => false,
                  child: const SizedBox(height: 60, child: Text('No dismiss')),
                ),
              ],
            ));
      await tester.drag(find.text('No dismiss'), const Offset(500, 0));
      await tester.pumpAndSettle();
      // Should still be visible
      expect(find.text('No dismiss'), findsOneWidget);
    });

    testWidgets('renders with custom background', (tester) async {
      await pumpApp(tester, ListView(
              children: [
                WiredDismissible(
                  dismissKey: const ValueKey('d4'),
                  onDismissed: (_) {},
                  background: ColoredBox(
                    color: Colors.green,
                    child: const Text('Archive'),
                  ),
                  child: const SizedBox(height: 60, child: Text('Custom BG')),
                ),
              ],
            ));
      expect(find.byType(WiredDismissible), findsOneWidget);
    });

    testWidgets('renders with custom delete color and icon', (tester) async {
      await pumpApp(tester, ListView(
              children: [
                WiredDismissible(
                  dismissKey: const ValueKey('d5'),
                  onDismissed: (_) {},
                  deleteColor: Colors.orange,
                  deleteIcon: Icons.archive,
                  child: const SizedBox(height: 60, child: Text('Custom icon')),
                ),
              ],
            ));
      await tester.drag(find.text('Custom icon'), const Offset(100, 0));
      await tester.pump();
      expect(find.byIcon(Icons.archive), findsOneWidget);
    });
  });
}
