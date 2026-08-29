import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';

import '../helpers/pump_app.dart';

/// Matches rough shapes by their inner [WiredPainterBase] type.
bool paintsRoughShape(Widget w, Type shapeType) {
  return w is CustomPaint &&
      w.painter is WiredPainter &&
      (w.painter! as WiredPainter).painter.runtimeType == shapeType;
}

void main() {
  Future<void> pumpSubject(
    WidgetTester tester, {
    Widget? header,
    Widget? footer,
    List<Widget> children = const [],
    EdgeInsetsGeometry? margin,
    Color? backgroundColor,
  }) {
    return pumpApp(
      tester,
      SingleChildScrollView(
        child: WiredCupertinoListSection(
          header: header,
          footer: footer,
          margin: margin ?? EdgeInsets.zero,
          backgroundColor: backgroundColor,
          children: children,
        ),
      ),
    );
  }

  group('WiredCupertinoListSection', () {
    testWidgets('renders without error', (tester) async {
      await pumpSubject(tester);
      expect(find.byType(WiredCupertinoListSection), findsOneWidget);
    });

    testWidgets('renders all children', (tester) async {
      await pumpSubject(
        tester,
        children: const [
          WiredCupertinoListTile(title: Text('Row 1')),
          WiredCupertinoListTile(title: Text('Row 2')),
          WiredCupertinoListTile(title: Text('Row 3')),
        ],
      );
      expect(find.text('Row 1'), findsOneWidget);
      expect(find.text('Row 2'), findsOneWidget);
      expect(find.text('Row 3'), findsOneWidget);
    });

    testWidgets('renders header', (tester) async {
      await pumpSubject(tester, header: const Text('Documents'));
      expect(find.text('Documents'), findsOneWidget);
    });

    testWidgets('renders footer', (tester) async {
      await pumpSubject(tester, footer: const Text('Shared with your team.'));
      expect(find.text('Shared with your team.'), findsOneWidget);
    });

    testWidgets('renders nothing extra when header and footer are null', (
      tester,
    ) async {
      await pumpSubject(tester);
      final textStyles = find.descendant(
        of: find.byType(WiredCupertinoListSection),
        matching: find.byType(DefaultTextStyle),
      );
      expect(textStyles, findsNothing);
    });

    testWidgets('draws a hand-drawn separator between each child', (
      tester,
    ) async {
      await pumpSubject(
        tester,
        children: const [
          WiredCupertinoListTile(title: Text('Row 1')),
          WiredCupertinoListTile(title: Text('Row 2')),
          WiredCupertinoListTile(title: Text('Row 3')),
        ],
      );
      final separators = find.byWidgetPredicate(
        (w) => paintsRoughShape(w, WiredLineBase),
      );
      expect(separators, findsNWidgets(2));
    });

    testWidgets('does not draw separators for a single child', (tester) async {
      await pumpSubject(
        tester,
        children: const [WiredCupertinoListTile(title: Text('Row 1'))],
      );
      final lines = find.byWidgetPredicate(
        (w) => paintsRoughShape(w, WiredLineBase),
      );
      expect(lines, findsNothing);
    });

    testWidgets('applies custom margin', (tester) async {
      const margin = EdgeInsets.symmetric(horizontal: 32, vertical: 20);
      await pumpSubject(tester, margin: margin);
      final container = tester.widget<Container>(
        find
            .descendant(
              of: find.byType(WiredCupertinoListSection),
              matching: find.byType(Container),
            )
            .first,
      );
      expect(container.margin, margin);
    });

    testWidgets('applies default margin', (tester) async {
      await pumpSubject(tester);
      const defaults = WiredCupertinoListSection(children: []);
      expect(
        defaults.margin,
        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      );
    });

    testWidgets('uses the custom background color for the group card', (
      tester,
    ) async {
      await pumpSubject(tester, backgroundColor: Colors.amber);
      final card = find.byWidgetPredicate(
        (w) => paintsRoughShape(w, WiredRoundedRectangleBase),
      );
      expect(card, findsOneWidget);
      final adapter = tester.widget<CustomPaint>(card).painter! as WiredPainter;
      expect((adapter.painter as dynamic).fillColor, Colors.amber);
    });

    testWidgets('tiles inside the section remain tappable', (tester) async {
      var taps = 0;
      await pumpSubject(
        tester,
        children: [
          WiredCupertinoListTile(
            title: const Text('Tap me'),
            onTap: () => taps++,
          ),
        ],
      );
      await tester.tap(find.text('Tap me'));
      expect(taps, 1);
    });

    testWidgets('renders multiple sections without interference', (
      tester,
    ) async {
      await pumpApp(
        tester,
        SingleChildScrollView(
          child: Column(
            children: const [
              WiredCupertinoListSection(
                header: Text('First'),
                children: [WiredCupertinoListTile(title: Text('A'))],
              ),
              WiredCupertinoListSection(
                header: Text('Second'),
                children: [WiredCupertinoListTile(title: Text('B'))],
              ),
            ],
          ),
        ),
      );
      expect(find.text('First'), findsOneWidget);
      expect(find.text('Second'), findsOneWidget);
      expect(find.text('A'), findsOneWidget);
      expect(find.text('B'), findsOneWidget);
    });
  });
}
