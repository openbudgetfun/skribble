import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';
import 'package:skribble/src/rough/renderer.dart';

void main() {
  test('long edges change direction locally instead of bowing once', () {
    final ops = OpsGenerator.doubleLine(0, 0, 960, 0, DrawConfig.build());
    final firstPass = ops.skip(1).takeWhile((op) => op.op != OpType.move);
    final heights = firstPass.map((op) => op.data.last.y).toList();
    var turns = 0;

    for (var i = 1; i < heights.length - 1; i++) {
      if ((heights[i] - heights[i - 1]) * (heights[i + 1] - heights[i]) < 0) {
        turns++;
      }
    }

    expect(turns, greaterThan(5));
    expect(heights.reduce(math.max) - heights.reduce(math.min), greaterThan(2));
    expect(ops.where((op) => op.op == OpType.move), hasLength(2));
  });

  test('jitter stays in the reserved band at every size and orientation', () {
    for (final length in [60.0, 96.0, 390.0, 1440.0]) {
      for (final angle in [0.0, math.pi / 4, math.pi / 2, math.pi]) {
        for (var seed = 1; seed <= 30; seed++) {
          final config = DrawConfig.build(seed: seed);
          final dx = math.cos(angle);
          final dy = math.sin(angle);
          final ops = OpsGenerator.doubleLine(
            0,
            0,
            length * dx,
            length * dy,
            config,
          );

          for (final point in ops.expand((op) => op.data)) {
            final along = point.x * dx + point.y * dy;
            final across = point.y * dx - point.x * dy;
            expect(along, inInclusiveRange(-0.000001, length + 0.000001));
            expect(across.abs(), lessThanOrEqualTo(3.600001));
          }
        }
      }
    }
  });

  test(
    'the seed is stable, reseeding changes ink, and zero remains straight',
    () {
      List<List<double>> coordinates(int seed, double roughness) =>
          OpsGenerator.doubleLine(
            0,
            0,
            960,
            0,
            DrawConfig.build(seed: seed, roughness: roughness),
          ).expand((op) => op.data).map((p) => [p.x, p.y]).toList();

      expect(coordinates(5, 1.8), coordinates(5, 1.8));
      expect(coordinates(5, 1.8), isNot(coordinates(6, 1.8)));
      expect(coordinates(5, 0).every((p) => p[1] == 0), isTrue);
      final tiny = OpsGenerator.doubleLine(2, 2, 2, 2, DrawConfig.build());
      expect(
        tiny.expand((op) => op.data).every((p) => p.x.isFinite && p.y.isFinite),
        isTrue,
      );
    },
  );
}
