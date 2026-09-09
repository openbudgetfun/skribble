import 'dart:typed_data';

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';

void main() {
  testWidgets('small solid icons have stable, seed-dependent contours', (
    tester,
  ) async {
    final key = GlobalKey();
    Future<Uint8List> pixels(int seed, double roughness) async {
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Center(
            child: RepaintBoundary(
              key: key,
              child: WiredSvgIcon(
                data: WiredBrandIcon.figma.data,
                size: 28,
                drawConfig: DrawConfig.build(seed: seed, roughness: roughness),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      return (await tester.runAsync(() async {
        final image =
            await (key.currentContext!.findRenderObject()!
                    as RenderRepaintBoundary)
                .toImage();
        final bytes = (await image.toByteData())!.buffer.asUint8List();
        image.dispose();
        return bytes;
      }))!;
    }

    final first = await pixels(1, 1.5);
    expect(await pixels(1, 1.5), first);
    expect(await pixels(2, 1.5), isNot(first));
    expect(await pixels(1, 0), await pixels(2, 0));
    expect(first, isNot(await pixels(1, 0)));
  });

  for (final brand in WiredBrandIcon.values) {
    testWidgets('brand ${brand.name} wraps and exposes its semantic label', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      try {
        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: Center(
              child: SizedBox(
                width: 100,
                child: Wrap(
                  children: [
                    for (final size in [16.0, 24.0, 48.0])
                      WiredSvgIcon(
                        data: brand.data,
                        size: size,
                        semanticLabel: brand.name,
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
        expect(find.bySemanticsLabel(brand.name), findsNWidgets(3));
        expect(tester.takeException(), isNull);
      } finally {
        semantics.dispose();
      }
    });
  }

  for (final rule in WiredSvgFillRule.values) {
    testWidgets('$rule keeps the counter open at small and large sizes', (
      tester,
    ) async {
      for (final size in [24.0, 48.0, 96.0]) {
        final key = GlobalKey();
        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: Center(
              child: RepaintBoundary(
                key: key,
                child: WiredSvgIcon(
                  size: size,
                  data: WiredSvgIconData(
                    width: 24,
                    height: 24,
                    primitives: [
                      WiredSvgPrimitive.path(
                        'M2 2H22V22H2Z M8 8V16H16V8Z',
                        fillRule: rule,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
        final bytes = (await tester.runAsync<Uint8List>(() async {
          final boundary =
              key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
          final image = await boundary.toImage();
          final data = (await image.toByteData())!.buffer.asUint8List();
          image.dispose();
          return data;
        }))!;
        final width = size.toInt();
        int alpha(double x, double y) =>
            bytes[((y * size).toInt() * width + (x * size).toInt()) * 4 + 3];
        expect(alpha(0.5, 0.5), 0, reason: 'the counter must stay transparent');
        expect(alpha(0.2, 0.5), 255, reason: 'the surrounding shape is filled');
      }
    });
  }
}
