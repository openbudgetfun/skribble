import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/testing.dart';
import 'package:skribble_maps/skribble_maps.dart';

import 'helpers/pump_map.dart';

void main() {
  group('WiredMapAttribution', () {
    testWidgets('renders attribution text', (tester) async {
      await pumpMapApp(
        tester,
        const WiredMapAttribution(text: 'Map data'),
      );

      expect(find.text('Map data'), findsOneWidget);
    });

    testWidgets('calls onTap when activated', (tester) async {
      var tapped = false;
      await pumpMapApp(
        tester,
        WiredMapAttribution(text: 'Map data', onTap: () => tapped = true),
      );

      await tester.tap(find.text('Map data'));

      expect(tapped, isTrue);
    });

    testWidgets('exposes the visible text to semantics', (tester) async {
      final semantics = tester.ensureSemantics();
      await pumpMapApp(
        tester,
        const WiredMapAttribution(text: 'Open map data'),
      );

      expect(find.bySemanticsLabel('Open map data'), findsOneWidget);
      semantics.dispose();
    });

    testWidgets('supports a custom semantic label', (tester) async {
      final semantics = tester.ensureSemantics();
      await pumpMapApp(
        tester,
        const WiredMapAttribution(
          text: '© OSM',
          semanticLabel: 'OpenStreetMap attribution',
        ),
      );

      expect(
        find.bySemanticsLabel('OpenStreetMap attribution'),
        findsOneWidget,
      );
      semantics.dispose();
    });

    testWidgets('applies custom padding', (tester) async {
      await pumpMapApp(
        tester,
        const WiredMapAttribution(
          text: 'Map data',
          padding: EdgeInsets.all(20),
        ),
      );

      final padding = tester.widget<Padding>(
        find
            .descendant(
              of: find.byType(WiredMapAttribution),
              matching: find.byType(Padding),
            )
            .first,
      );
      expect(padding.padding, const EdgeInsets.all(20));
    });

    testWidgets('has a repaint boundary', (tester) async {
      await pumpMapApp(
        tester,
        const WiredMapAttribution(text: 'Map data'),
      );

      expect(
        find.descendant(
          of: find.byType(WiredMapAttribution),
          matching: find.byType(RepaintBoundary),
        ),
        findsWidgets,
      );
    });

    testWidgets('keeps the ink padding around its text by default', (
      tester,
    ) async {
      await pumpMapApp(
        tester,
        const Center(
          child: SizedBox(
            width: 200,
            child: WiredMapAttribution(
              text: '© OpenStreetMap contributors · OpenFreeMap · MapLibre',
            ),
          ),
        ),
      );

      // Two lines are too tall to count as a micro badge, so the badge's
      // own ink is held to the full padding.
      final text = tester.renderObject<RenderParagraph>(
        find.textContaining('OpenStreetMap'),
      );
      expect(text.size.height, greaterThan(20));
      expect(text.didExceedMaxLines, isFalse);
      expect(crampedText(tester.binding.renderViews.first), isEmpty);
    });

    testWidgets('screen readers and keyboards can open a linked source', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      var opened = 0;
      await tester.pumpWidget(
        WidgetsApp(
          color: const Color(0xFFFFFFFF),
          pageRouteBuilder: <T>(settings, builder) => PageRouteBuilder<T>(
            settings: settings,
            pageBuilder: (context, _, _) => builder(context),
          ),
          home: Center(
            child: WiredMapAttribution(
              text: '© OpenStreetMap',
              onTap: () => opened++,
            ),
          ),
        ),
      );

      final node = tester.getSemantics(
        find.bySemanticsLabel('© OpenStreetMap'),
      );
      expect(node.getSemanticsData().hasAction(SemanticsAction.tap), isTrue);
      expect(node.flagsCollection.isLink, isTrue);
      tester.semantics.tap(find.semantics.byLabel('© OpenStreetMap'));
      expect(opened, 1);

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      expect(opened, 2);
      semantics.dispose();
    });
  });
}
