import 'dart:typed_data';

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';
import 'package:skribble_icons_material/skribble_icons_material.dart';
import 'package:skribble_maps/skribble_maps.dart';

import 'helpers/pump_map.dart';

void main() {
  setUpAll(registerSkribbleMaterialIcons);

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
    Future<ByteData> render(
      WiredMapPinIcon icon,
      Color background, {
      bool showGlyph = true,
    }) async {
      await pumpMapApp(
        tester,
        RepaintBoundary(
          key: key,
          child: ColoredBox(
            color: background,
            child: Center(
              child: WiredMapPin(
                key: UniqueKey(),
                icon: icon,
                seed: 37 + icon.index,
                child: showGlyph ? null : const SizedBox(),
              ),
            ),
          ),
        ),
        size: const Size(96, 96),
      );
      await tester.pumpAndSettle();
      return (await tester.runAsync(() async {
        final image = await tester
            .renderObject<RenderRepaintBoundary>(find.byKey(key))
            .toImage();
        final bytes = (await image.toByteData())!;
        image.dispose();
        return bytes;
      }))!;
    }

    for (final background in [
      const Color(0xFFF6F2E9),
      const Color(0xFF272E32),
    ]) {
      final signatures = <String>{};
      for (final icon in WiredMapPinIcon.values) {
        final pixels = await render(icon, background);
        final repeated = await render(icon, background);
        expect(pixels.buffer.asUint8List(), repeated.buffer.asUint8List());
        final bounds = tester
            .getRect(find.byType(WiredSvgIcon))
            .shift(
              -tester.getTopLeft(find.byKey(key)),
            );
        final blank = await render(icon, background, showGlyph: false);
        final darkInk = <int>[];
        var halo = 0;
        for (var y = 0; y < 96; y++) {
          for (var x = 0; x < 96; x++) {
            final offset = (y * 96 + x) * 4;
            final pixel = pixels.getUint32(offset);
            final under = blank.getUint32(offset);
            if (x < 2 || x > 93 || y < 2 || y > 93) {
              expect(pixel, (background.toARGB32() << 8 | 0xff) & 0xffffffff);
            }
            if (pixel == 0xfffcf3ff) halo++;
            if (pixel == under) continue;
            expect(
              bounds.inflate(1).contains(Offset(x.toDouble(), y.toDouble())),
              isTrue,
            );
            final ink = Color(0xff000000 | pixel >> 8).computeLuminance();
            final fill = Color(0xff000000 | under >> 8).computeLuminance();
            if ((fill + 0.05) / (ink + 0.05) >= 4.5) darkInk.add(y * 96 + x);
          }
        }
        expect(halo, greaterThan(30), reason: '${icon.name} sticker edge');
        expect(darkInk.length, inInclusiveRange(20, 500), reason: icon.name);
        signatures.add(darkInk.join(','));
      }
      expect(signatures, hasLength(WiredMapPinIcon.values.length));
    }
  });
}
