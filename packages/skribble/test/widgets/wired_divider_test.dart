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

    testWidgets('takes 16 pixels like a Material divider', (tester) async {
      await pumpApp(tester, const WiredDivider());

      expect(tester.getSize(find.byType(WiredDivider)).height, 16);
    });

    testWidgets('draws its line in the middle of its height', (tester) async {
      await pumpApp(tester, const Center(child: WiredDivider()));

      final divider = tester.getRect(find.byType(WiredDivider));
      final line = tester.getRect(
        find.descendant(
          of: find.byType(WiredDivider),
          matching: findWiredCanvas,
        ),
      );
      expect(line.center.dy, moreOrLessEquals(divider.center.dy));
    });

    testWidgets('inks the line with the theme border colour', (tester) async {
      await pumpWired(
        tester,
        const SizedBox(width: 200, child: WiredDivider()),
        theme: WiredThemeData(borderColor: const Color(0xFF00AA00)),
      );

      final canvas = tester.widget<WiredCanvas>(
        find.descendant(
          of: find.byType(WiredDivider),
          matching: findWiredCanvas,
        ),
      );
      expect(
        (canvas.painter as WiredLineBase).borderColor,
        const Color(0xFF00AA00),
      );
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
