import 'dart:math' as math;
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

  testWidgets('route geometry is exact and ignores roughness', (
    tester,
  ) async {
    const key = Key('route');
    const size = Size(360, 240);
    const route = Color(0xFF376D7B);
    const points = [
      LatLng(-2, -3),
      LatLng(-2, -1),
      LatLng(2, -1),
      LatLng(2, -1),
      LatLng(0, 1),
      LatLng(0, 3),
    ];

    Future<ByteData> render(double roughness) async {
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
                    points: points,
                    color: route,
                    strokeWidth: 5,
                    seed: roughness.toInt() + 1,
                  ),
                ],
              ),
            ],
          ),
        ),
        size: size,
        theme: WiredThemeData(
          drawConfig: DrawConfig.build(
            roughness: roughness,
            lineWobble: roughness,
          ),
        ),
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

    final smooth = await render(0);
    final rough = await render(8);

    // Roughness and seed never move a route: both renders match exactly.
    expect(rough.buffer.asUint8List(), smooth.buffer.asUint8List());

    const camera = WiredMapCamera(
      center: LatLng(0, 0),
      zoom: 5,
      viewportSize: size,
      minimumZoom: 0,
      maximumZoom: 20,
    );
    final projected = [for (final point in points) camera.project(point)];
    double distanceToRoute(Offset pixel) {
      var nearest = double.infinity;
      for (var index = 1; index < projected.length; index++) {
        final start = projected[index - 1];
        final span = projected[index] - start;
        final length = span.distanceSquared;
        final along = length == 0
            ? 0.0
            : (((pixel - start).dx * span.dx + (pixel - start).dy * span.dy) /
                      length)
                  .clamp(0.0, 1.0);
        nearest = math.min(nearest, (pixel - (start + span * along)).distance);
      }
      return nearest;
    }

    int pixelAt(Offset point) =>
        smooth.getUint32((point.dy.floor() * 360 + point.dx.floor()) * 4);
    final ink = (route.toARGB32() << 8 | 0xff) & 0xffffffff;
    final paper = (const Color(0xFFF3F0E8).toARGB32() << 8 | 0xff) & 0xffffffff;

    // Every segment, including the turns, is solid route ink at its centre.
    for (var index = 1; index < projected.length; index++) {
      if (projected[index] == projected[index - 1]) continue;
      expect(
        pixelAt((projected[index - 1] + projected[index]) / 2),
        ink,
        reason: 'segment $index',
      );
    }

    var inked = 0;
    for (var y = 0; y < size.height; y++) {
      for (var x = 0; x < size.width; x++) {
        final pixel = smooth.getUint32((y * 360 + x) * 4);
        if (pixel == paper) continue;
        // Only the stroke, half its width plus antialiasing, leaves paper.
        expect(
          distanceToRoute(Offset(x + 0.5, y + 0.5)),
          lessThanOrEqualTo(2.5 + 1.5),
          reason: 'ink at ($x, $y)',
        );
        if (pixel == ink) inked++;
      }
    }

    // The round-capped stroke covers about its width times its length.
    var length = 0.0;
    for (var index = 1; index < projected.length; index++) {
      length += (projected[index] - projected[index - 1]).distance;
    }
    expect(inked, inInclusiveRange(length * 3, length * 6));
  });

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
