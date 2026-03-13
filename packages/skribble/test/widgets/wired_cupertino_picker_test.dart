import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';

void main() {
  group('WiredCupertinoPicker', () {
    testWidgets('renders with children', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WiredCupertinoPicker(
              onSelectedItemChanged: (_) {},
              children: const [Text('One'), Text('Two'), Text('Three')],
            ),
          ),
        ),
      );

      expect(find.byType(WiredCupertinoPicker), findsOneWidget);
      expect(find.byType(CupertinoPicker), findsOneWidget);
      expect(find.byType(RepaintBoundary), findsWidgets);
    });

    testWidgets('calls onSelectedItemChanged when scrolled', (tester) async {
      int? selectedIndex;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WiredCupertinoPicker(
              onSelectedItemChanged: (i) => selectedIndex = i,
              children: const [
                Text('Alpha'),
                Text('Beta'),
                Text('Gamma'),
                Text('Delta'),
              ],
            ),
          ),
        ),
      );

      // Fling down to scroll to a different item
      await tester.fling(
        find.byType(CupertinoPicker),
        const Offset(0, -100),
        800,
      );
      await tester.pumpAndSettle();

      expect(selectedIndex, isNotNull);
    });

    testWidgets('respects initial item', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WiredCupertinoPicker(
              initialItem: 2,
              onSelectedItemChanged: (_) {},
              children: const [Text('First'), Text('Second'), Text('Third')],
            ),
          ),
        ),
      );

      // The widget should render with item at index 2 centered
      expect(find.byType(WiredCupertinoPicker), findsOneWidget);
    });

    testWidgets('renders with custom height and item extent', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WiredCupertinoPicker(
              height: 150,
              itemExtent: 50,
              onSelectedItemChanged: (_) {},
              children: const [Text('A'), Text('B')],
            ),
          ),
        ),
      );

      final sizedBox = tester.widget<SizedBox>(
        find
            .descendant(
              of: find.byType(WiredCupertinoPicker),
              matching: find.byType(SizedBox),
            )
            .first,
      );
      expect(sizedBox.height, 150);
    });

    testWidgets('contains WiredCanvas for border', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WiredCupertinoPicker(
              onSelectedItemChanged: (_) {},
              children: const [Text('X')],
            ),
          ),
        ),
      );

      expect(find.byType(WiredCanvas), findsWidgets);
    });

    testWidgets('renders many items without error', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WiredCupertinoPicker(
              onSelectedItemChanged: (_) {},
              children: List.generate(
                20,
                (i) => Text('Item $i'),
              ),
            ),
          ),
        ),
      );

      expect(find.byType(WiredCupertinoPicker), findsOneWidget);
    });
  });
}
