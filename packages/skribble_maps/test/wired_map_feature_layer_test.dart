import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble_maps/skribble_maps.dart';

import 'helpers/pump_map.dart';

void main() {
  Widget subject(List<WiredMapFeature> features) {
    return WiredMap(
      initialZoom: 5,
      showZoomControls: false,
      mapViewBuilder: buildTestMapView,
      children: [WiredMapFeatureLayer(features: features)],
    );
  }

  group('WiredMapFeatureLayer', () {
    testWidgets('decorative overlays let pinch gestures reach the map', (
      tester,
    ) async {
      var zoomed = false;
      await pumpMapApp(
        tester,
        WiredMap(
          showZoomControls: false,
          mapViewBuilder: (context) => GestureDetector(
            onScaleUpdate: (details) => zoomed |= details.scale > 1.1,
            child: const ColoredBox(color: Color(0xFFF3F0E8)),
          ),
          children: const [
            WiredMapFeatureLayer(
              features: [
                WiredMapPolygon(
                  points: [LatLng(-1, -1), LatLng(-1, 1), LatLng(1, 1)],
                ),
              ],
            ),
          ],
        ),
      );
      final center = tester.getCenter(find.byType(WiredMap));
      final left = await tester.startGesture(
        center - const Offset(30, 0),
        pointer: 1,
      );
      final right = await tester.startGesture(
        center + const Offset(30, 0),
        pointer: 2,
      );
      await left.moveBy(const Offset(-60, 0));
      await right.moveBy(const Offset(60, 0));
      await left.moveBy(const Offset(-20, 0));
      await right.moveBy(const Offset(20, 0));
      await left.up();
      await right.up();
      await tester.pumpAndSettle();
      expect(zoomed, isTrue);
    });

    testWidgets('empty space beside an interactive feature reaches the map', (
      tester,
    ) async {
      var tapped = false;
      await pumpMapApp(
        tester,
        WiredMap(
          showZoomControls: false,
          mapViewBuilder: (context) => GestureDetector(
            onTap: () => tapped = true,
            child: const ColoredBox(color: Color(0xFFF3F0E8)),
          ),
          children: [
            WiredMapFeatureLayer(
              features: [
                WiredMapPolyline(
                  points: const [LatLng(0, -1), LatLng(0, 1)],
                  onTap: () {},
                ),
              ],
            ),
          ],
        ),
      );
      await tester.tapAt(
        tester.getTopLeft(find.byType(WiredMap)) + const Offset(25, 25),
      );
      await tester.pumpAndSettle();
      expect(tapped, isTrue);
    });

    testWidgets('decorative overlays let drags reach the map below', (
      tester,
    ) async {
      var moved = false;
      await pumpMapApp(
        tester,
        WiredMap(
          showZoomControls: false,
          mapViewBuilder: (context) => GestureDetector(
            onPanUpdate: (_) => moved = true,
            child: const ColoredBox(color: Color(0xFFF3F0E8)),
          ),
          children: const [
            WiredMapFeatureLayer(
              features: [
                WiredMapPolyline(points: [LatLng(0, -1), LatLng(0, 1)]),
              ],
            ),
          ],
        ),
      );
      await tester.drag(find.byType(WiredMap), const Offset(80, 0));
      await tester.pumpAndSettle();
      expect(moved, isTrue);
    });

    testWidgets('renders an empty feature list', (tester) async {
      await pumpMapApp(tester, subject(const []));

      expect(find.byType(WiredMapFeatureLayer), findsOneWidget);
    });

    testWidgets('paints a rough polyline', (tester) async {
      await pumpMapApp(
        tester,
        subject([
          const WiredMapPolyline(
            points: [LatLng(0, -1), LatLng(0, 1)],
          ),
        ]),
      );

      expect(
        find.descendant(
          of: find.byType(WiredMapFeatureLayer),
          matching: find.byType(CustomPaint),
        ),
        findsOneWidget,
      );
    });

    testWidgets('paints a hatched polygon', (tester) async {
      await pumpMapApp(
        tester,
        subject([
          const WiredMapPolygon(
            points: [
              LatLng(-1, -1),
              LatLng(-1, 1),
              LatLng(1, 1),
              LatLng(1, -1),
            ],
          ),
        ]),
      );

      expect(find.byType(WiredMapFeatureLayer), findsOneWidget);
    });

    testWidgets('calls a polyline callback near the line', (tester) async {
      var tapped = false;
      await pumpMapApp(
        tester,
        subject([
          WiredMapPolyline(
            points: const [LatLng(0, -1), LatLng(0, 1)],
            onTap: () => tapped = true,
          ),
        ]),
      );

      await tester.tapAt(tester.getCenter(find.byType(WiredMap)));
      await tester.pump(const Duration(milliseconds: 350));

      expect(tapped, isTrue);
    });

    testWidgets('calls a polygon callback inside the area', (tester) async {
      var tapped = false;
      await pumpMapApp(
        tester,
        subject([
          WiredMapPolygon(
            points: const [
              LatLng(-1, -1),
              LatLng(-1, 1),
              LatLng(1, 1),
              LatLng(1, -1),
            ],
            onTap: () => tapped = true,
          ),
        ]),
      );

      await tester.tapAt(tester.getCenter(find.byType(WiredMap)));
      await tester.pump(const Duration(milliseconds: 350));

      expect(tapped, isTrue);
    });

    testWidgets('does not activate a distant feature', (tester) async {
      var tapped = false;
      await pumpMapApp(
        tester,
        subject([
          WiredMapPolyline(
            points: const [LatLng(20, 20), LatLng(21, 21)],
            onTap: () => tapped = true,
          ),
        ]),
      );

      await tester.tapAt(tester.getCenter(find.byType(WiredMap)));
      await tester.pump(const Duration(milliseconds: 350));

      expect(tapped, isFalse);
    });

    testWidgets('exposes layer semantics', (tester) async {
      final semantics = tester.ensureSemantics();
      await pumpMapApp(
        tester,
        const WiredMap(
          showZoomControls: false,
          mapViewBuilder: buildTestMapView,
          children: [
            WiredMapFeatureLayer(
              features: [],
              semanticLabel: 'Walking route and park',
            ),
          ],
        ),
      );

      expect(find.bySemanticsLabel('Walking route and park'), findsOneWidget);
      semantics.dispose();
    });

    testWidgets('exposes each labelled feature to semantics', (tester) async {
      final semantics = tester.ensureSemantics();
      await pumpMapApp(
        tester,
        subject([
          const WiredMapPolyline(
            points: [LatLng(0, -1), LatLng(0, 1)],
            semanticLabel: 'Scenic walking route',
          ),
        ]),
      );

      expect(find.semantics.byLabel('Scenic walking route'), findsOne);
      semantics.dispose();
    });
  });
}
