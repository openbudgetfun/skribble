import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
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

      expect(find.bySemanticsLabel('OpenStreetMap attribution'), findsOneWidget);
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
        find.descendant(
          of: find.byType(WiredMapAttribution),
          matching: find.byType(Padding),
        ).first,
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
  });
}
