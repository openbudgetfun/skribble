import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
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

    // A rebuild replaces the painter, so its contours are displaced again.
    // That fresh work must also land on the same ink.
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
    expect(identical(rebuilt, painter), isFalse);
    expect(await raster(rebuilt), equals(cold));
  });
}
