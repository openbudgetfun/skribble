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
  }) {
    return pumpApp(
      tester,
      SingleChildScrollView(
        child: WiredCupertinoFormSection(
          header: header,
          footer: footer,
          margin: margin ?? EdgeInsets.zero,
          children: children,
        ),
      ),
    );
  }

  group('WiredCupertinoFormSection', () {
    testWidgets('renders without error', (tester) async {
      await pumpSubject(tester);
      expect(find.byType(WiredCupertinoFormSection), findsOneWidget);
    });

    testWidgets('renders all children', (tester) async {
      await pumpSubject(
        tester,
        children: const [
          Text('Field 1'),
          Text('Field 2'),
          Text('Field 3'),
        ],
      );
      expect(find.text('Field 1'), findsOneWidget);
      expect(find.text('Field 2'), findsOneWidget);
      expect(find.text('Field 3'), findsOneWidget);
    });

    testWidgets('renders header', (tester) async {
      await pumpSubject(tester, header: const Text('Account'));
      expect(find.text('Account'), findsOneWidget);
    });

    testWidgets('renders footer', (tester) async {
      await pumpSubject(tester, footer: const Text('Visible to everyone.'));
      expect(find.text('Visible to everyone.'), findsOneWidget);
    });

    testWidgets('renders nothing extra when header and footer are null', (
      tester,
    ) async {
      await pumpSubject(tester);
      final textStyles = find.descendant(
        of: find.byType(WiredCupertinoFormSection),
        matching: find.byType(DefaultTextStyle),
      );
      expect(textStyles, findsNothing);
    });

    testWidgets('draws hand-drawn dividers between rows', (tester) async {
      await pumpSubject(
        tester,
        children: const [
          Text('Row 1'),
          Text('Row 2'),
          Text('Row 3'),
        ],
      );
      final dividers = find.byWidgetPredicate(
        (w) => paintsRoughShape(w, WiredLineBase),
      );
      expect(dividers, findsNWidgets(2));
    });

    testWidgets('draws a single hand-drawn group border', (tester) async {
      await pumpSubject(tester, children: const [Text('Row 1')]);
      final borders = find.byWidgetPredicate(
        (w) => paintsRoughShape(w, WiredRoundedRectangleBase),
      );
      expect(borders, findsOneWidget);
    });

    testWidgets('applies custom margin', (tester) async {
      const margin = EdgeInsets.fromLTRB(8, 4, 8, 4);
      await pumpSubject(tester, margin: margin);
      final container = tester.widget<Container>(
        find
            .descendant(
              of: find.byType(WiredCupertinoFormSection),
              matching: find.byType(Container),
            )
            .first,
      );
      expect(container.margin, margin);
    });

    testWidgets('defaults header text to the footnote style', (tester) async {
      await pumpSubject(tester, header: const Text('Account'));
      final style = DefaultTextStyle.of(
        tester.element(find.text('Account')),
      ).style;
      expect(style.fontSize, 13);
    });

    testWidgets('keeps grouped children tappable across dividers', (
      tester,
    ) async {
      var taps = 0;
      await pumpSubject(
        tester,
        children: [
          GestureDetector(
            key: const Key('child-tap'),
            onTap: () => taps++,
            child: const Text('Interactive child'),
          ),
          const Text('Static child'),
        ],
      );
      await tester.tap(find.byKey(const Key('child-tap')));
      expect(taps, 1);
    });

    testWidgets('supports text field children without overflow', (
      tester,
    ) async {
      await pumpSubject(
        tester,
        children: const [
          SizedBox(height: 48, child: Text('Input row')),
          SizedBox(height: 48, child: Text('Second row')),
        ],
      );
      expect(tester.takeException(), isNull);
      expect(find.text('Input row'), findsOneWidget);
      expect(find.text('Second row'), findsOneWidget);
    });
  });
}
