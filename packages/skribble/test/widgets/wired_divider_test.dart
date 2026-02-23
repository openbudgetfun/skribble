import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';

void main() {
  group('WiredDivider', () {
    testWidgets('renders without error', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: WiredDivider())),
      );

      expect(find.byType(WiredDivider), findsOneWidget);
    });

    testWidgets('contains Divider widget', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: WiredDivider())),
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
        MaterialApp(home: Scaffold(body: WiredDivider())),
      );

      final divider = tester.widget<Divider>(
        find.descendant(
          of: find.byType(WiredDivider),
          matching: find.byType(Divider),
        ),
      );

      expect(divider.color, Colors.transparent);
    });
  });
}
