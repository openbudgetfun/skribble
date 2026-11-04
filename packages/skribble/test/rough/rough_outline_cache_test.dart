import 'dart:ui' as ui;

import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';
import 'package:skribble/testing.dart';

/// The shared outline cache behind `RoughOutlinedBorder` and the rough
/// input border: geometry is cached, color is applied per paint.
void main() {
  const rect = Rect.fromLTWH(0, 0, 120, 48);
  const radius = BorderRadius.all(Radius.circular(12));

  void paintWith(Canvas canvas, BorderSide side, {int seed = 3}) =>
      RoughOutlinedBorder(
        side: side,
        borderRadius: radius,
        seed: seed,
      ).paint(canvas, rect);

  Future<ui.Image> render(BorderSide side) {
    final recorder = ui.PictureRecorder();
    paintWith(Canvas(recorder), side);
    return recorder.endRecording().toImage(120, 48);
  }

  /// Every opaque pixel of [image], as colors.
  Future<List<Color>> inkOf(ui.Image image) async {
    final bytes = (await image.toByteData())!;
    return [
      for (var i = 0; i < bytes.lengthInBytes; i += 4)
        if (bytes.getUint8(i + 3) > 200)
          Color.fromARGB(
            255,
            bytes.getUint8(i),
            bytes.getUint8(i + 1),
            bytes.getUint8(i + 2),
          ),
    ];
  }

  test('a color fade reuses one prepared outline', () {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    // A size no other test uses, so the shared cache starts cold.
    const unique = Rect.fromLTWH(0, 0, 123.25, 47.5);
    RoughGenerationCounter.reset();
    for (var step = 0; step <= 20; step++) {
      final color = Color.lerp(
        const Color(0xFF4A3470),
        const Color(0xFFE87960),
        step / 20,
      )!;
      RoughOutlinedBorder(
        side: BorderSide(color: color, width: 2),
        borderRadius: radius,
        seed: 11,
      ).paint(canvas, unique);
    }
    recorder.endRecording().dispose();
    expect(RoughGenerationCounter.generations, 1);
  });

  test('a new width or seed prepares a new outline', () {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    const side = BorderSide(color: Color(0xFF4A3470), width: 2.25);
    RoughGenerationCounter.reset();
    paintWith(canvas, side, seed: 101);
    paintWith(canvas, side.copyWith(width: 3.25), seed: 101);
    paintWith(canvas, side, seed: 102);
    recorder.endRecording().dispose();
    expect(RoughGenerationCounter.generations, 3);
  });

  test('each paint inks the outline in its own color', () async {
    const red = Color(0xFFFF0000);
    const blue = Color(0xFF0000FF);
    final first = await inkOf(await render(const BorderSide(color: red)));
    final second = await inkOf(await render(const BorderSide(color: blue)));
    final third = await inkOf(await render(const BorderSide(color: red)));

    expect(first, isNotEmpty);
    // Anti-aliased ink blends at its edges, so compare the dominant channel.
    expect(first.every((color) => color.r > color.b), isTrue);
    expect(second, isNotEmpty);
    expect(second.every((color) => color.b > color.r), isTrue);
    // The shared drawing went back to its own color after the blue paint.
    expect(third, first);
  });
}
