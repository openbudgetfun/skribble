import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';

void main() {
  group('WiredDivider', () {
    testWidgets('renders without error', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: WiredDivider())),
      );

      expect(find.byType(WiredDivider), findsOneWidget);
    });

    testWidgets('contains Divider widget', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: WiredDivider())),
      );

      expect(
        find.descendant(
          of: find.byType(WiredDivider),
          matching: find.byType(Divider),
        ),
        findsOneWidget,
      );
    });

    testWidgets('has transparent divider color', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: WiredDivider())),
      );

      final divider = tester.widget<Divider>(
        find.descendant(
          of: find.byType(WiredDivider),
          matching: find.byType(Divider),
        ),
      );

      expect(divider.color, Colors.transparent);
    });

    testWidgets('contains WiredCanvas for line', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: WiredDivider())),
      );

      expect(
        find.descendant(
          of: find.byType(WiredDivider),
          matching: find.byType(WiredCanvas),
        ),
        findsWidgets,
      );
    });

    testWidgets('renders inside a Column with other widgets', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                Text('Above'),
                WiredDivider(),
                Text('Below'),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Above'), findsOneWidget);
      expect(find.byType(WiredDivider), findsOneWidget);
      expect(find.text('Below'), findsOneWidget);
    });

    testWidgets('renders multiple dividers without error', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                WiredDivider(),
                SizedBox(height: 10),
                WiredDivider(),
                SizedBox(height: 10),
                WiredDivider(),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(WiredDivider), findsNWidgets(3));
    });
  });
}
