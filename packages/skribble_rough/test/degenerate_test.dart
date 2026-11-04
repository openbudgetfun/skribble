import 'dart:math';

import 'package:skribble_rough/skribble_rough.dart';
import 'package:test/test.dart';

/// Degenerate input must finish, the way the JavaScript and Rust engines
/// do: each case once hung, threw, or ran out of memory. The timeouts turn
/// a regression into a failure instead of a stuck test run.
void main() {
  const deadline = Timeout(Duration(seconds: 10));
  final config = DrawConfig.build(seed: 7);

  Iterable<Op> opsOf(Drawable drawable) =>
      drawable.sets.expand((set) => set.ops);

  group('arcs', () {
    test('a tiny positive sweep finishes', () {
      final drawable = Generator(
        config,
        HachureFiller(),
      ).arc(50, 50, 80, 80, 0, 1e-12, true);
      expect(opsOf(drawable).length, lessThan(100000));
    }, timeout: deadline);

    for (final steps in [0.0, -1.0]) {
      test('a curveStepCount of $steps finishes', () {
        final stepConfig = DrawConfig.build(seed: 7, curveStepCount: steps);
        Generator(stepConfig, NoFiller()).arc(50, 50, 80, 80, 0, pi);
      }, timeout: deadline);
    }
  });

  test('an ellipse of infinite size finishes', () {
    Generator(config, NoFiller()).ellipse(0, 0, double.infinity, 10);
  }, timeout: deadline);

  group('dashed fills', () {
    for (final (offset, gap) in [
      (0.0, 0.0),
      (0.04, 0.05),
      (-3.0, 1.0),
      (double.nan, 2.0),
      (double.infinity, 2.0),
    ]) {
      test('a dash pattern of $offset + $gap draws plain lines', () {
        final filler = DashedFiller(
          FillerConfig.build(
            drawConfig: config,
            dashOffset: offset,
            dashGap: gap,
          ),
        );
        final drawable = Generator(config, filler).rectangle(0, 0, 100, 100);
        // The hachure lines are still drawn, just not split into dashes.
        expect(drawable.sets.first.ops, isNotEmpty);
      }, timeout: deadline);
    }

    test('an ordinary pattern is still dashed', () {
      final dashed = Generator(
        config,
        DashedFiller(FillerConfig.build(drawConfig: config)),
      ).rectangle(0, 0, 100, 100);
      final plain = Generator(
        config,
        DashedFiller(
          FillerConfig.build(drawConfig: config, dashOffset: 0, dashGap: 0),
        ),
      ).rectangle(0, 0, 100, 100);
      expect(
        dashed.sets.first.ops.length,
        greaterThan(plain.sets.first.ops.length),
      );
    }, timeout: deadline);
  });

  group('infinite coordinates', () {
    test('a line to infinity finishes', () {
      Generator(config, NoFiller()).line(0, 0, double.infinity, 0);
    }, timeout: deadline);

    test('a filled shape with an infinite side finishes unfilled', () {
      final drawable = Generator(
        config,
        HachureFiller(),
      ).rectangle(0, 0, double.infinity, 50);
      expect(drawable.sets.first.ops, isEmpty);
    }, timeout: deadline);
  });

  test('a curve through no points is empty', () {
    final drawable = Generator(config, NoFiller()).curvePath(const []);
    expect(opsOf(drawable), isEmpty);
  }, timeout: deadline);
}
