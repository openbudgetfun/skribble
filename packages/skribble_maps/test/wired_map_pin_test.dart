import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';
import 'package:skribble_maps/skribble_maps.dart';

import 'helpers/pump_map.dart';

void main() {
  group('WiredMapPin', () {
    testWidgets('holding selects once without also tapping', (tester) async {
      var taps = 0;
      var holds = 0;
      final semantics = tester.ensureSemantics();
      await pumpMapApp(
        tester,
        Center(
          child: WiredMapPin(
            semanticLabel: 'Saved cafe',
            onTap: () => taps++,
            onLongPress: () => holds++,
          ),
        ),
      );

      await tester.longPress(find.byType(WiredMapPin));
      await tester.pumpAndSettle();

      expect(holds, 1);
      expect(taps, 0);
      expect(tester.widget<AnimatedScale>(find.byType(AnimatedScale)).scale, 1);
      expect(
        tester.getSemantics(find.bySemanticsLabel('Saved cafe')),
        matchesSemantics(
          label: 'Saved cafe',
          isButton: true,
          hasTapAction: true,
          hasLongPressAction: true,
        ),
      );
      semantics.dispose();
    });

    testWidgets('a long-press-only pin ignores taps and cancelled drags', (
      tester,
    ) async {
      var holds = 0;
      await pumpMapApp(
        tester,
        Center(child: WiredMapPin(onLongPress: () => holds++)),
      );
      await tester.tap(find.byType(WiredMapPin));
      await tester.drag(find.byType(WiredMapPin), const Offset(80, 0));
      await tester.pumpAndSettle();
      expect(holds, 0);

      await tester.longPress(find.byType(WiredMapPin));
      await tester.pumpAndSettle();
      expect(holds, 1);
    });

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

    testWidgets('press cancels back to its geographic anchor', (tester) async {
      await pumpMapApp(tester, Center(child: WiredMapPin(onTap: () {})));
      final gesture = await tester.startGesture(
        tester.getCenter(find.byType(WiredMapPin)),
      );
      await tester.pumpAndSettle();
      final scale = tester.widget<AnimatedScale>(find.byType(AnimatedScale));
      expect(scale.scale, 0.92);
      expect(scale.alignment, Alignment.bottomCenter);

      await gesture.cancel();
      await tester.pumpAndSettle();
      expect(tester.widget<AnimatedScale>(find.byType(AnimatedScale)).scale, 1);
    });

    testWidgets('small pins constrain their icon without overflow', (
      tester,
    ) async {
      await pumpMapApp(
        tester,
        const Center(child: WiredMapPin(width: 32, height: 40)),
      );

      expect(tester.getSize(find.byType(WiredMapPin)), const Size(32, 40));
      expect(tester.takeException(), isNull);
    });

    testWidgets('null icon paints an empty pin', (tester) async {
      await pumpMapApp(tester, const WiredMapPin(icon: null));

      expect(find.byType(WiredSvgIcon), findsNothing);
      expect(tester.takeException(), isNull);
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
