import 'dart:typed_data';

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';
import 'package:skribble_emoji/skribble_emoji.dart';

void main() {
  const data = WiredSvgIconData(
    width: 72,
    height: 72,
    primitives: [
      WiredSvgPrimitive.path(
        'M4 10H68',
        strokeColor: '#000000',
        strokeWidth: 4,
        strokeDashArray: [8, 8],
        strokeCap: StrokeCap.butt,
      ),
      WiredSvgPrimitive.path(
        'M12 30H24',
        strokeColor: '#000000',
        strokeWidth: 6,
        strokeCap: StrokeCap.square,
        strokeJoin: StrokeJoin.bevel,
      ),
    ],
  );
  for (final precomputed in [true, false]) {
    testWidgets(
      'dash gaps and square caps render with precomputed=$precomputed',
      (tester) async {
        final key = GlobalKey();
        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: Center(
              child: RepaintBoundary(
                key: key,
                child: precomputed
                    ? const PrecomputedEmoji(data: data, size: 72)
                    : const WiredSvgIcon(data: data, size: 72),
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
        int alpha(int x, int y) => bytes[(y * 72 + x) * 4 + 3];
        expect(alpha(6, 10), 255);
        expect(alpha(16, 10), 0);
        expect(alpha(22, 10), 255);
        expect(alpha(10, 30), 255);
        expect(alpha(8, 30), 0);
      },
    );
  }
}
