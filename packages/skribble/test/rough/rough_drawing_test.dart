import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';

Future<Uint8List> pixels(void Function(Canvas) paint) async {
  final recorder = PictureRecorder();
  paint(Canvas(recorder));
  final picture = recorder.endRecording();
  final image = await picture.toImage(160, 120);
  final data = (await image.toByteData())!.buffer.asUint8List();
  image.dispose();
  picture.dispose();
  return data;
}

Paint pen(Color color) => Paint()
  ..color = color
  ..strokeWidth = 3
  ..style = PaintingStyle.stroke
  ..strokeCap = StrokeCap.round;

int alphaAt(Uint8List image, int x, int y) => image[(y * 160 + x) * 4 + 3];
int inkCount(Uint8List image) {
  var count = 0;
  for (var i = 3; i < image.length; i += 4) {
    if (image[i] > 0) count++;
  }
  return count;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final border = pen(const Color(0xff48336a));
  final fill = pen(const Color(0xffe6a132));

  for (final filler in <Filler>[
    NoFiller(),
    HachureFiller(),
    HatchFiller(),
    ZigZagFiller(),
    DotFiller(),
    DashedFiller(),
    SolidFiller(),
  ]) {
    for (final shape in ['rectangle', 'rounded', 'circle', 'line']) {
      test(
        'completed $shape ${filler.runtimeType} matches static ink',
        () async {
          final generator = Generator(DrawConfig.build(seed: 17), filler);
          final drawable = switch (shape) {
            'rectangle' => generator.rectangle(12, 12, 130, 92),
            'rounded' => generator.roundedRectangle(
              12,
              12,
              130,
              92,
              12,
              12,
              12,
              12,
            ),
            'circle' => generator.circle(80, 60, 92),
            _ => generator.line(12, 30, 130, 92),
          };
          final drawing = RoughDrawing(drawable, border, fill);
          final before = await pixels(
            (canvas) => drawing.paint(canvas, progress: .41),
          );
          final complete = await pixels(drawing.paint);
          final original = await pixels(
            (canvas) => canvas.drawRough(
              drawable,
              Paint.from(border),
              Paint.from(fill),
            ),
          );
          expect(complete, original);
          expect(
            await pixels((canvas) => drawing.paint(canvas, progress: .41)),
            before,
          );
        },
      );
    }
  }

  final twoLines = Drawable(
    sets: [
      OpSet(
        type: OpSetType.path,
        ops: [
          Op.move(PointD(10, 20)),
          Op.lineTo(PointD(110, 20)),
          Op.move(PointD(10, 50)),
          Op.lineTo(PointD(110, 50)),
        ],
      ),
    ],
  );

  test(
    'pen distance advances across contours instead of revealing each at once',
    () async {
      final drawing = RoughDrawing(twoLines, border, fill);
      final image = await pixels(
        (canvas) => drawing.paint(canvas, progress: .1625),
      );
      expect(alphaAt(image, 30, 20), greaterThan(0));
      expect(alphaAt(image, 80, 20), 0);
      expect(alphaAt(image, 30, 50), 0);
    },
  );

  test(
    'hatching starts after the outline and scribbles sequentially',
    () async {
      final drawable = Drawable(
        sets: [
          OpSet(
            type: OpSetType.fillSketch,
            ops: [
              Op.move(PointD(10, 80)),
              Op.lineTo(PointD(110, 80)),
              Op.move(PointD(10, 100)),
              Op.lineTo(PointD(110, 100)),
            ],
          ),
          twoLines.sets!.single,
        ],
      );
      final drawing = RoughDrawing(drawable, border, fill);
      final early = await pixels(
        (canvas) => drawing.paint(canvas, progress: .2),
      );
      final middle = await pixels(
        (canvas) => drawing.paint(canvas, progress: .475),
      );
      expect(alphaAt(early, 30, 80), 0);
      expect(alphaAt(middle, 30, 80), greaterThan(0));
      expect(alphaAt(middle, 30, 100), 0);
    },
  );

  test(
    'zero hides ink, overshoot clamps, non-finite input settles safely',
    () async {
      final drawing = RoughDrawing(twoLines, border, fill);
      final full = await pixels(drawing.paint);
      expect(inkCount(await pixels((c) => drawing.paint(c, progress: 0))), 0);
      expect(inkCount(await pixels((c) => drawing.paint(c, progress: -2))), 0);
      for (final value in [1.4, double.nan, double.infinity]) {
        expect(await pixels((c) => drawing.paint(c, progress: value)), full);
      }
    },
  );

  test('solid background preserves contrast even at zero progress', () async {
    final drawable = Generator(
      DrawConfig.build(),
      SolidFiller(),
    ).rectangle(10, 10, 130, 90);
    final drawing = RoughDrawing(drawable, border, fill);
    expect(
      alphaAt(await pixels((c) => drawing.paint(c, progress: 0)), 60, 50),
      255,
    );
    expect(fill.style, PaintingStyle.stroke);
  });

  test('snapshot isolates later operation and paint mutations', () async {
    final drawable = Generator(
      DrawConfig.build(),
      NoFiller(),
    ).line(10, 20, 120, 20);
    final paint = pen(const Color(0xff112233));
    final drawing = RoughDrawing(drawable, paint, paint);
    final original = await pixels(drawing.paint);
    drawable.sets!.clear();
    paint.color = const Color(0xffff0000);
    expect(await pixels(drawing.paint), original);
  });

  test(
    'pressure reinforces the fixed path and returns exactly to rest',
    () async {
      final drawing = RoughDrawing(twoLines, border, fill);
      final rest = await pixels(drawing.paint);
      final pressed = await pixels((c) => drawing.paint(c, pressure: 1));
      expect(inkCount(pressed), greaterThan(inkCount(rest)));
      expect(await pixels(drawing.paint), rest);
    },
  );

  test('empty operations are paintable at every phase', () async {
    final drawing = RoughDrawing(Drawable(sets: []), border, fill);
    for (final value in [0.0, .5, 1.0]) {
      expect(
        inkCount(await pixels((c) => drawing.paint(c, progress: value))),
        0,
      );
    }
  });
}
