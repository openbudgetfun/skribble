import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';
import 'package:skribble_maps/skribble_maps.dart';

import 'helpers/pump_map.dart';

void main() {
  group('WiredMapPin', () {
    testWidgets('renders without error', (tester) async {
      await pumpMapApp(tester, const WiredMapPin());

      expect(find.byType(WiredMapPin), findsOneWidget);
    });

    testWidgets('renders child content', (tester) async {
      await pumpMapApp(
        tester,
        const WiredMapPin(child: Text('A')),
      );

      expect(find.text('A'), findsOneWidget);
    });

    testWidgets('renders a large hand-drawn place icon by default', (
      tester,
    ) async {
      await pumpMapApp(tester, const WiredMapPin());

      final icon = tester.widget<WiredSvgIcon>(find.byType(WiredSvgIcon));
      expect(icon.size, 28);
      expect(icon.fillStyle, WiredIconFillStyle.none);
    });

    testWidgets('renders each typed category icon', (tester) async {
      for (final icon in WiredMapPinIcon.values) {
        await pumpMapApp(tester, WiredMapPin(icon: icon));

        expect(find.byType(WiredSvgIcon), findsOneWidget);
      }
    });

    testWidgets('custom child replaces the generated icon', (tester) async {
      await pumpMapApp(
        tester,
        const WiredMapPin(child: Text('Custom')),
      );

      expect(find.text('Custom'), findsOneWidget);
      expect(find.byType(WiredSvgIcon), findsNothing);
    });

    testWidgets('uses the requested dimensions', (tester) async {
      await pumpMapApp(
        tester,
        const Center(child: WiredMapPin(height: 68)),
      );

      expect(tester.getSize(find.byType(WiredMapPin)), const Size(52, 68));
    });

    testWidgets('calls onTap when activated', (tester) async {
      var taps = 0;
      await pumpMapApp(tester, WiredMapPin(onTap: () => taps++));

      await tester.tap(find.byType(WiredMapPin));
      await tester.pump();

      expect(taps, 1);
    });

    testWidgets('handles rapid taps', (tester) async {
      var taps = 0;
      await pumpMapApp(tester, WiredMapPin(onTap: () => taps++));

      await tester.tap(find.byType(WiredMapPin));
      await tester.tap(find.byType(WiredMapPin));
      await tester.tap(find.byType(WiredMapPin));
      await tester.pump();

      expect(taps, 3);
    });

    testWidgets('exposes its semantic label', (tester) async {
      final semantics = tester.ensureSemantics();
      await pumpMapApp(
        tester,
        WiredMapPin(onTap: () {}, semanticLabel: 'Saved café'),
      );

      expect(find.bySemanticsLabel('Saved café'), findsOneWidget);
      semantics.dispose();
    });

    testWidgets('is isolated by a repaint boundary', (tester) async {
      await pumpMapApp(tester, const WiredMapPin());

      expect(
        find.descendant(
          of: find.byType(WiredMapPin),
          matching: find.byType(RepaintBoundary),
        ),
        findsWidgets,
      );
    });
  });
}
