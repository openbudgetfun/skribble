import 'dart:typed_data';

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';

void main() {
  const stem = WiredSvgIconData(
    width: 24,
    height: 24,
    primitives: [
      WiredSvgPrimitive.path(
        'M12 3V21',
        strokeColor: 'currentColor',
        strokeWidth: 2,
      ),
    ],
  );
  const counter = WiredSvgIconData(
    width: 24,
    height: 24,
    primitives: [
      WiredSvgPrimitive.path(
        'M4 3H20V21H4ZM9 8H15V16H9Z',
        fillRule: WiredSvgFillRule.evenOdd,
      ),
    ],
  );
  const house = WiredSvgIconData(
    width: 24,
    height: 24,
    primitives: [
      WiredSvgPrimitive.path(
        'M3 10V21H21V10L12 3Z',
        strokeColor: 'currentColor',
        strokeWidth: 2,
      ),
    ],
  );

  Future<Uint8List> render(
    WidgetTester tester,
    WiredSvgIconData data,
    WiredRoughness level, {
    DrawConfig? config,
  }) async {
    const key = ValueKey('ink');
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: WiredThemeScope(
          data: WiredThemeData(roughnessLevel: level),
          child: Center(
            child: RepaintBoundary(
              key: key,
              child: WiredSvgIcon(data: data, size: 24, drawConfig: config),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return (await tester.runAsync(() async {
      final image = await tester
          .renderObject<RenderRepaintBoundary>(find.byKey(key))
          .toImage(pixelRatio: 4);
      final bytes = (await image.toByteData())!.buffer.asUint8List();
      image.dispose();
      return bytes;
    }))!;
  }

  for (final level in WiredRoughness.values) {
    testWidgets(
      '${level.name} keeps stroke endpoints upright and counters open',
      (
        tester,
      ) async {
        final pixels = await render(tester, stem, level);
        // Compare the centers of ink at the two endpoints, not the wavering
        // middle. A sheared/italic stem would have different endpoint centers.
        double centerAt(Uint8List pixels, int y, {int from = 0, int to = 96}) {
          var weight = 0;
          var weightedX = 0;
          for (var x = from; x < to; x++) {
            final alpha = pixels[(y * 96 + x) * 4 + 3];
            weight += alpha;
            weightedX += x * alpha;
          }
          expect(weight, greaterThan(0));
          return weightedX / weight;
        }

        expect(centerAt(pixels, 12), closeTo(47.5, 0.3));
        expect(centerAt(pixels, 83), closeTo(47.5, 0.3));
        final walls = await render(tester, house, level);
        final sourceWalls = await render(
          tester,
          house,
          level,
          config: DrawConfig.build(roughness: 0),
        );
        for (final y in [40, 83]) {
          for (final from in [0, 48]) {
            expect(
              centerAt(walls, y, from: from, to: from + 48),
              closeTo(centerAt(sourceWalls, y, from: from, to: from + 48), 1.5),
              reason: 'the wall endpoints retain their source alignment',
            );
          }
        }
        final filled = await render(tester, counter, level);
        for (var y = 40; y < 56; y++) {
          for (var x = 44; x < 52; x++) {
            expect(
              filled[(y * 96 + x) * 4 + 3],
              0,
              reason: 'the central opening remains clear',
            );
          }
        }
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets(
    'an authored stroke honors explicit config across theme changes',
    (tester) async {
      final config = DrawConfig.build(roughness: 0);
      final gentle = await render(
        tester,
        stem,
        WiredRoughness.gentle,
        config: config,
      );
      final expressive = await render(
        tester,
        stem,
        WiredRoughness.expressive,
        config: config,
      );
      expect(expressive, gentle);
      expect(
        await render(tester, stem, WiredRoughness.expressive),
        isNot(gentle),
      );
    },
  );
}
