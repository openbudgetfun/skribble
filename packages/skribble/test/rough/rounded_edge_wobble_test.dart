import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';

void main() {
  test('local wobble stays inside the reserved ink bleed', () {
    for (final level in WiredRoughness.values) {
      for (var seed = 1; seed <= 20; seed++) {
        final config = WiredThemeData(roughnessLevel: level).drawConfig
            .copyWith(seed: seed);
        final bleed = config.maxRandomnessOffset! * config.roughness!;
        final drawing = Generator(
          config,
          NoFiller(),
        ).roundedRectangle(0, 0, 960, 100, 12, 12, 12, 12);
        for (final point in drawing.sets!.last.ops!.expand((op) => op.data)) {
          expect(point.x, inInclusiveRange(-bleed, 960 + bleed));
          expect(point.y, inInclusiveRange(-bleed, 100 + bleed));
        }
      }
    }
  });

  test(
    'wide rounded borders wander locally and stay continuous at corners',
    () {
      for (final level in WiredRoughness.values.skip(1)) {
        final drawing = Generator(
          WiredThemeData(roughnessLevel: level).drawConfig,
          NoFiller(),
        ).roundedRectangle(0, 0, 960, 100, 12, 12, 12, 12);
        final ops = drawing.sets!.last.ops!;
        final first = ops.first.data.single;
        final top = ops
            .skip(1)
            .takeWhile((op) => op.data.last.y < first.y + 5)
            .map((op) => op.data.last.y)
            .toList();
        var turns = 0;
        for (var i = 1; i < top.length - 1; i++) {
          if ((top[i] - top[i - 1]) * (top[i + 1] - top[i]) < 0) turns++;
        }
        expect(turns, greaterThan(4));
        expect(top.last, closeTo(first.y, 0.00001));
        expect(ops.where((op) => op.op == OpType.move), hasLength(2));
        expect(
          ops
              .expand((op) => op.data)
              .every((p) => p.x.isFinite && p.y.isFinite),
          isTrue,
        );
      }
    },
  );
}
