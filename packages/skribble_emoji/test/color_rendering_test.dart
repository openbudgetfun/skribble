import 'dart:typed_data';

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble_emoji/skribble_emoji.dart';

void main() {
  testWidgets(
    'source colors, transparency, unfilled strokes and clips survive',
    (tester) async {
      final key = GlobalKey();
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Center(
            child: RepaintBoundary(
              key: key,
              child: const PrecomputedEmoji(
                size: 72,
                color: Color(0xff00ff00),
                data: WiredSvgIconData(
                  width: 72,
                  height: 72,
                  primitives: [
                    WiredSvgPrimitive.path(
                      'M2 2H22V22H2Z',
                      fillColor: '#ffcc00',
                    ),
                    WiredSvgPrimitive.path(
                      'M26 2H46V22H26Z',
                      strokeColor: '#000000',
                      strokeWidth: 2,
                    ),
                    WiredSvgPrimitive.path(
                      'M50 2H70V22H50Z',
                      fillColor: '#ff000080',
                    ),
                    WiredSvgPrimitive.path(
                      'M2 26H70V70H2Z',
                      fillColor: '#0000ff',
                      clipPaths: ['M2 26H22V70H2Z'],
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
        final bytes = (await image.toByteData())!.buffer.asUint8List();
        image.dispose();
        return bytes;
      }))!;
      List<int> pixel(int x, int y) =>
          bytes.sublist((y * 72 + x) * 4, (y * 72 + x) * 4 + 4);
      expect(pixel(12, 12), [255, 204, 0, 255]);
      expect(pixel(36, 12)[3], 0);
      expect(pixel(60, 12)[3], 128);
      expect(pixel(12, 40), [0, 0, 255, 255]);
      expect(pixel(40, 40)[3], 0);
    },
  );
}
