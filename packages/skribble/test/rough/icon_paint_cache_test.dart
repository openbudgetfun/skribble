import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';

void main() {
  testWidgets('an icon painter draws the same ink on every repaint', (
    tester,
  ) async {
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Center(
          child: WiredSvgIcon(
            data: WiredBrandIcon.figma.data,
            size: 64,
            fillStyle: WiredIconFillStyle.crossHatch,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final painter = tester
        .widgetList<CustomPaint>(find.byType(CustomPaint))
        .map((widget) => widget.painter)
        .firstWhere((painter) => painter != null)!;

    Future<Uint8List> raster(CustomPainter target) async =>
        (await tester.runAsync(() async {
          final recorder = ui.PictureRecorder();
          final canvas = Canvas(recorder);
          target.paint(canvas, const Size(64, 64));
          final picture = recorder.endRecording();
          final image = await picture.toImage(64, 64);
          final bytes = (await image.toByteData())!.buffer.asUint8List();
          image.dispose();
          picture.dispose();
          return bytes;
        }))!;

    CustomPainter painterFromTree() => tester
        .widgetList<CustomPaint>(find.byType(CustomPaint))
        .map((widget) => widget.painter)
        .firstWhere((painter) => painter != null)!;

    // Cold cache: the contours are displaced during this paint.
    final cold = await raster(painter);
    // Warm cache on the same painter: reused contours must draw identically.
    expect(await raster(painter), equals(cold));

    // A rebuild with the same inputs reuses the shared painter, so an icon
    // revisited while scrolling lists paints at precomputed-path cost.
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Center(
          child: WiredSvgIcon(
            data: WiredBrandIcon.figma.data,
            size: 64,
            fillStyle: WiredIconFillStyle.crossHatch,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final rebuilt = painterFromTree();
    expect(identical(rebuilt, painter), isTrue);
    expect(await raster(rebuilt), equals(cold));

    // Different drawing inputs get their own painter and their own ink.
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Center(
          child: WiredSvgIcon(
            data: WiredBrandIcon.figma.data,
            size: 64,
            color: const ui.Color(0xff0000ff),
            fillStyle: WiredIconFillStyle.crossHatch,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final recolored = painterFromTree();
    expect(identical(recolored, painter), isFalse);
    expect(await raster(recolored), isNot(equals(cold)));
  });
}
