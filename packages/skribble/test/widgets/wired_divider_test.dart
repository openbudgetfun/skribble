import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';

import '../helpers/finders.dart';
import '../helpers/pump_app.dart';

void main() {
  group('WiredDivider', () {
    testWidgets('renders without error', (tester) async {
      await pumpApp(tester, const WiredDivider());

      expect(find.byType(WiredDivider), findsOneWidget);
    });

    testWidgets('contains Divider widget', (tester) async {
      await pumpApp(tester, const WiredDivider());

      expect(
        find.descendant(
          of: find.byType(WiredDivider),
          matching: find.byType(Divider),
        ),
        findsOneWidget,
      );
    });

    testWidgets('has transparent divider color', (tester) async {
      await pumpApp(tester, const WiredDivider());

      final divider = tester.widget<Divider>(
        find.descendant(
          of: find.byType(WiredDivider),
          matching: find.byType(Divider),
        ),
      );

      expect(divider.color, Colors.transparent);
    });

    testWidgets('contains WiredCanvas for line', (tester) async {
      await pumpApp(tester, const WiredDivider());

      expect(
        find.descendant(
          of: find.byType(WiredDivider),
          matching: findWiredCanvas,
        ),
        findsWidgets,
      );
    });

    testWidgets('renders inside a Column with other widgets', (tester) async {
      await pumpApp(
        tester,
        const Column(children: [Text('Above'), WiredDivider(), Text('Below')]),
      );

      expect(find.text('Above'), findsOneWidget);
      expect(find.byType(WiredDivider), findsOneWidget);
      expect(find.text('Below'), findsOneWidget);
    });

    testWidgets('renders multiple dividers without error', (tester) async {
      await pumpApp(
        tester,
        const Column(
          children: [
            WiredDivider(),
            SizedBox(height: 10),
            WiredDivider(),
            SizedBox(height: 10),
            WiredDivider(),
          ],
        ),
      );

      expect(find.byType(WiredDivider), findsNWidgets(3));
    });

    testWidgets('renders within WiredTheme', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: WiredTheme(
            data: WiredThemeData(borderColor: Colors.blue),
            child: Scaffold(body: Column(children: const [WiredDivider()])),
          ),
        ),
      );
      expect(find.byType(WiredDivider), findsOneWidget);
    });
  });
}
