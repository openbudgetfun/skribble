import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';

Future<Uint8List> renderInk({
  double width = 2.4,
  int seed = 1,
  DrawConfig? config,
}) async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  WiredRectangleBase(strokeWidth: width).paintRough(
    canvas,
    const Size(100, 60),
    config ?? DrawConfig.build(seed: seed),
    NoFiller(),
  );
  final picture = recorder.endRecording();
  final image = await picture.toImage(100, 60);
  final bytes = (await image.toByteData())!.buffer.asUint8List();
  image.dispose();
  picture.dispose();
  return bytes;
}

void main() {
  test('a wider pen adds visible ink and leaves clipped edges clear', () async {
    final thin = await renderInk(width: 1);
    final thick = await renderInk(width: 3);
    int coverage(Uint8List bytes) =>
        [for (var i = 3; i < bytes.length; i += 4) bytes[i]]
            .fold(0, (sum, value) => sum + value);
    expect(coverage(thick), greaterThan(coverage(thin) * 1.6));
    for (var x = 0; x < 100; x++) {
      expect(thick[x * 4 + 3], 0);
      expect(thick[(59 * 100 + x) * 4 + 3], 0);
    }
  });

  test('configured decorations repaint with identical pen strokes', () async {
    final config = DrawConfig.build(seed: 23);
    final decoration = RoughBoxDecoration(
      drawConfig: config,
      borderStyle: const RoughDrawingStyle(
        width: 2.4,
        color: Color(0xff543568),
      ),
    );
    Future<Uint8List> render() async {
      final recorder = ui.PictureRecorder();
      decoration.createBoxPainter().paint(
        Canvas(recorder),
        Offset.zero,
        const ImageConfiguration(size: Size(100, 60)),
      );
      final picture = recorder.endRecording();
      final image = await picture.toImage(100, 60);
      final bytes = (await image.toByteData())!.buffer.asUint8List();
      image.dispose();
      picture.dispose();
      return bytes;
    }

    expect(await render(), await render());
    final original = DrawConfig.build(seed: 1);
    final reseeded = original.copyWith(seed: 73);
    expect(
      reseeded.randomizer!.next(),
      DrawConfig.build(seed: 73).randomizer!.next(),
    );
  });

  testWidgets('theme changes repaint colour, stroke width, and roughness', (
    tester,
  ) async {
    final boundary = GlobalKey();
    Future<Uint8List> render(
      Color color,
      double width,
      double roughness,
    ) async {
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: WiredTheme(
            data: WiredThemeData(
              borderColor: color,
              strokeWidth: width,
              roughness: roughness,
            ),
            child: Center(
              child: RepaintBoundary(
                key: boundary,
                child: SizedBox(
                  width: 180,
                  height: 90,
                  child: Builder(
                    builder: (context) => WiredCanvas(
                      painter: WiredRectangleBase(
                        borderColor: color,
                        strokeWidth: width,
                      ),
                      fillerType: RoughFilter.noFiller,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      return (await tester.runAsync(() async {
        final image =
            await (boundary.currentContext!.findRenderObject()!
                    as RenderRepaintBoundary)
                .toImage();
        final bytes = (await image.toByteData())!.buffer.asUint8List();
        image.dispose();
        return bytes;
      }))!;
    }

    // WiredCard retains Material compatibility; use the direct canvas here to
    // isolate painter invalidation from inherited Material animations.
    await tester.pumpWidget(const SizedBox());
    final theme = WiredThemeData(roughness: 2.5);
    expect(theme.drawConfig.roughness, 2.5);
    final first = await render(const Color(0xff112233), 1, 0);
    final second = await render(const Color(0xff994422), 4, 1.5);
    expect(first, isNot(second));
    expect(tester.takeException(), isNull);
  });
}
