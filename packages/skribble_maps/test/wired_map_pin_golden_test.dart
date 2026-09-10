import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';
import 'package:skribble_maps/skribble_maps.dart';

import 'helpers/pump_map.dart';

void main() {
  for (final roughness in [0.0, 8.0]) {
    testWidgets('route geometry is exact at roughness $roughness', (
      tester,
    ) async {
      const key = Key('route');
      await pumpMapApp(
        tester,
        RepaintBoundary(
          key: key,
          child: WiredMap(
            initialZoom: 5,
            showZoomControls: false,
            mapViewBuilder: buildTestMapView,
            children: [
              WiredMapFeatureLayer(
                features: [
                  WiredMapPolyline(
                    points: const [
                      LatLng(-2, -3),
                      LatLng(-2, -1),
                      LatLng(2, -1),
                      LatLng(2, -1),
                      LatLng(0, 1),
                      LatLng(0, 3),
                    ],
                    color: const Color(0xFF376D7B),
                    strokeWidth: 5,
                    seed: roughness.toInt() + 1,
                  ),
                ],
              ),
            ],
          ),
        ),
        size: const Size(360, 240),
        theme: WiredThemeData(
          drawConfig: DrawConfig.build(
            roughness: roughness,
            lineWobble: roughness,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await expectLater(
        find.byKey(key),
        matchesGoldenFile('goldens/map-route.png'),
      );
    });
  }

  testWidgets('category pins stay legible on paper and dark maps', (
    tester,
  ) async {
    const key = Key('pin-sheet');
    await pumpMapApp(
      tester,
      RepaintBoundary(
        key: key,
        child: Column(
          children: [
            for (final background in [
              const Color(0xFFF6F2E9),
              const Color(0xFF272E32),
            ])
              Expanded(
                child: ColoredBox(
                  color: background,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      for (final icon in WiredMapPinIcon.values)
                        WiredMapPin(icon: icon, seed: 37 + icon.index),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
      size: const Size(560, 220),
    );
    await tester.pumpAndSettle();

    await expectLater(
      find.byKey(key),
      matchesGoldenFile('goldens/map-pins.png'),
    );
  });
}
