import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';

void main() {
  group('WiredReorderableListView', () {
    testWidgets('renders all children', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WiredReorderableListView(
              onReorder: (_, _) {},
              children: const [
                Text('Item A', key: ValueKey('a')),
                Text('Item B', key: ValueKey('b')),
                Text('Item C', key: ValueKey('c')),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Item A'), findsOneWidget);
      expect(find.text('Item B'), findsOneWidget);
      expect(find.text('Item C'), findsOneWidget);
      expect(find.byType(RepaintBoundary), findsWidgets);
    });

    testWidgets('shows drag handles by default', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WiredReorderableListView(
              onReorder: (_, _) {},
              children: const [
                Text('One', key: ValueKey(1)),
                Text('Two', key: ValueKey(2)),
              ],
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.drag_handle), findsNWidgets(2));
    });

    testWidgets('hides drag handles when showDragHandle is false', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WiredReorderableListView(
              onReorder: (_, _) {},
              showDragHandle: false,
              children: const [
                Text('One', key: ValueKey(1)),
                Text('Two', key: ValueKey(2)),
              ],
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.drag_handle), findsNothing);
    });

    testWidgets('calls onReorder callback', (tester) async {
      int? oldIdx;
      int? newIdx;

      final items = <String>['Alpha', 'Beta', 'Gamma'];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WiredReorderableListView(
              onReorder: (o, n) {
                oldIdx = o;
                newIdx = n;
              },
              children: [
                for (final item in items) Text(item, key: ValueKey(item)),
              ],
            ),
          ),
        ),
      );

      // Long-press the first drag handle to start reorder
      final firstHandle = find.byIcon(Icons.drag_handle).first;
      final center = tester.getCenter(firstHandle);

      // Initiate long press
      final gesture = await tester.startGesture(center);
      await tester.pump(const Duration(milliseconds: 600));

      // Drag down past the second item
      await gesture.moveBy(const Offset(0, 80));
      await tester.pump();

      // Drop
      await gesture.up();
      await tester.pumpAndSettle();

      expect(oldIdx, isNotNull);
      expect(newIdx, isNotNull);
    });

    testWidgets('renders with custom item height', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WiredReorderableListView(
              onReorder: (_, _) {},
              itemHeight: 80,
              children: const [Text('Tall item', key: ValueKey('tall'))],
            ),
          ),
        ),
      );

      final sizedBox = tester.widget<SizedBox>(
        find
            .ancestor(
              of: find.text('Tall item'),
              matching: find.byType(SizedBox),
            )
            .first,
      );

      expect(sizedBox.height, 80);
    });
  });
}
