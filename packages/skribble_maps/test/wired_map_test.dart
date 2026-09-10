import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble_maps/skribble_maps.dart';

import 'helpers/pump_map.dart';

void main() {
  group('WiredMap', () {
    testWidgets('renders with a replacement map view', (tester) async {
      await pumpMapApp(
        tester,
        const WiredMap(mapViewBuilder: buildTestMapView),
      );

      expect(find.byType(WiredMap), findsOneWidget);
      expect(find.byType(ColoredBox), findsWidgets);
    });

    testWidgets('renders overlay children', (tester) async {
      await pumpMapApp(
        tester,
        const WiredMap(
          mapViewBuilder: buildTestMapView,
          children: [Center(child: Text('Overlay'))],
        ),
      );

      expect(find.text('Overlay'), findsOneWidget);
    });

    testWidgets('fills the requested dimensions', (tester) async {
      await pumpMapApp(
        tester,
        const WiredMap(mapViewBuilder: buildTestMapView),
        size: const Size(320, 240),
      );

      expect(tester.getSize(find.byType(WiredMap)), const Size(320, 240));
    });

    testWidgets('exposes a custom semantic label', (tester) async {
      final semantics = tester.ensureSemantics();
      await pumpMapApp(
        tester,
        const WiredMap(
          mapViewBuilder: buildTestMapView,
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
        const WiredMap(mapViewBuilder: buildTestMapView),
      );

      expect(find.bySemanticsLabel('Zoom in'), findsOneWidget);
      expect(find.bySemanticsLabel('Zoom out'), findsOneWidget);
      semantics.dispose();
    });

    testWidgets('can hide zoom controls', (tester) async {
      await pumpMapApp(
        tester,
        const WiredMap(
          mapViewBuilder: buildTestMapView,
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
          mapViewBuilder: buildTestMapView,
        ),
      );

      await tester.tap(find.bySemanticsLabel('Zoom in'));
      await tester.pump(const Duration(milliseconds: 350));

      expect(controller.camera.zoom, 6);
      controller.dispose();
    });

    testWidgets('handles rapid zoom-control taps', (
      tester,
    ) async {
      final controller = WiredMapController(initialZoom: 5);
      await pumpMapApp(
        tester,
        WiredMap(
          controller: controller,
          mapViewBuilder: buildTestMapView,
        ),
      );

      final zoomIn = find.bySemanticsLabel('Zoom in');
      await tester.tap(zoomIn);
      await tester.tap(zoomIn);
      await tester.tap(zoomIn);
      await tester.pump();

      expect(controller.camera.zoom, 8);
      controller.dispose();
    });
  });
}
