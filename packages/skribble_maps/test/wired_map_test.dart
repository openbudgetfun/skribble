import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble_maps/skribble_maps.dart';

import 'helpers/pump_map.dart';

void main() {
  group('WiredMap', () {
    testWidgets('renders without a basemap', (tester) async {
      await pumpMapApp(tester, const WiredMap());

      expect(find.byType(WiredMap), findsOneWidget);
    });

    testWidgets('renders overlay children', (tester) async {
      await pumpMapApp(
        tester,
        const WiredMap(
          children: [Center(child: Text('Overlay'))],
        ),
      );

      expect(find.text('Overlay'), findsOneWidget);
    });

    testWidgets('fills the requested dimensions', (tester) async {
      await pumpMapApp(
        tester,
        const WiredMap(),
        size: const Size(320, 240),
      );

      expect(tester.getSize(find.byType(WiredMap)), const Size(320, 240));
    });

    testWidgets('exposes a custom semantic label', (tester) async {
      final semantics = tester.ensureSemantics();
      await pumpMapApp(
        tester,
        const WiredMap(
          semanticLabel: 'Check-in map',
        ),
      );

      expect(find.bySemanticsLabel('Check-in map'), findsOneWidget);
      semantics.dispose();
    });

    testWidgets('shows both zoom controls by default', (tester) async {
      final semantics = tester.ensureSemantics();
      await pumpMapApp(
        tester,
        const WiredMap(),
      );

      expect(find.bySemanticsLabel('Zoom in'), findsOneWidget);
      expect(find.bySemanticsLabel('Zoom out'), findsOneWidget);
      semantics.dispose();
    });

    testWidgets('can hide zoom controls', (tester) async {
      await pumpMapApp(
        tester,
        const WiredMap(
          showZoomControls: false,
        ),
      );

      expect(find.byType(WiredMapZoomControls), findsNothing);
    });

    testWidgets('zoom controls move an external controller', (tester) async {
      final controller = WiredMapController(initialZoom: 5);
      await pumpMapApp(
        tester,
        WiredMap(
          controller: controller,
        ),
      );

      await tester.tap(find.text('+'));
      await tester.pump(const Duration(milliseconds: 350));

      expect(controller.camera.zoom, 6);
      controller.dispose();
    });

    testWidgets('pans the camera with a drag gesture', (tester) async {
      final controller = WiredMapController();
      await pumpMapApp(
        tester,
        WiredMap(controller: controller, showZoomControls: false),
      );
      final original = controller.camera.center;

      await tester.drag(find.byType(WiredMap), const Offset(60, 0));
      await tester.pump();

      expect(controller.camera.center.longitude, lessThan(original.longitude));
      controller.dispose();
    });

    testWidgets('zooms once on a map double tap', (tester) async {
      final controller = WiredMapController(initialZoom: 5);
      await pumpMapApp(
        tester,
        WiredMap(controller: controller, showZoomControls: false),
      );
      final center = tester.getCenter(find.byType(WiredMap));

      await tester.tapAt(center);
      await tester.tapAt(center);
      await tester.pump();

      expect(controller.camera.zoom, 6);
      controller.dispose();
    });

    testWidgets('handles rapid zoom-control taps without map double zoom', (
      tester,
    ) async {
      final controller = WiredMapController(initialZoom: 5);
      await pumpMapApp(tester, WiredMap(controller: controller));

      await tester.tap(find.text('+'));
      await tester.tap(find.text('+'));
      await tester.tap(find.text('+'));
      await tester.pump();

      expect(controller.camera.zoom, 8);
      controller.dispose();
    });
  });
}
