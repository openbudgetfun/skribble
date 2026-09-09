import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble_maps/skribble_maps.dart';

import 'helpers/pump_map.dart';

void main() {
  Widget subject(List<WiredMapFeature> features) {
    return WiredMap(
      initialZoom: 5,
      showZoomControls: false,
      children: [WiredMapFeatureLayer(features: features)],
    );
  }

  group('WiredMapFeatureLayer', () {
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
