import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';

void main() {
  late DrawConfig config;
  late Generator generator;

  setUp(() {
    config = DrawConfig.defaultValues;
    generator = Generator(config, NoFiller());
  });

  group('Generator', () {
    group('line()', () {
      test('produces non-empty Drawable with OpSets', () {
        final Drawable drawable = generator.line(0, 0, 100, 100);

        expect(drawable.sets, isNotNull);
        expect(drawable.sets, isNotEmpty);
        expect(drawable.options, equals(config));

        final OpSet opSet = drawable.sets!.first;
        expect(opSet.type, equals(OpSetType.path));
        expect(opSet.ops, isNotNull);
        expect(opSet.ops, isNotEmpty);
      });

      test('produces ops for a horizontal line', () {
        final Drawable drawable = generator.line(0, 0, 200, 0);

        expect(drawable.sets, isNotNull);
        expect(drawable.sets!.length, equals(1));
        expect(drawable.sets!.first.ops, isNotEmpty);
      });

      test('produces ops for a vertical line', () {
        final Drawable drawable = generator.line(0, 0, 0, 200);

        expect(drawable.sets, isNotNull);
        expect(drawable.sets!.length, equals(1));
        expect(drawable.sets!.first.ops, isNotEmpty);
      });

      test('produces ops for a zero-length line', () {
        final Drawable drawable = generator.line(50, 50, 50, 50);

        expect(drawable.sets, isNotNull);
        expect(drawable.sets, isNotEmpty);
      });
    });

    group('rectangle()', () {
      test('produces Drawable with fill and path OpSets', () {
        final Drawable drawable = generator.rectangle(10, 10, 100, 50);

        expect(drawable.sets, isNotNull);
        expect(drawable.sets!.length, equals(2));

        // First set is the fill (from NoFiller, so fillSketch with empty ops).
        final OpSet fillSet = drawable.sets![0];
        expect(fillSet.type, equals(OpSetType.fillSketch));

        // Second set is the outline path.
        final OpSet pathSet = drawable.sets![1];
        expect(pathSet.type, equals(OpSetType.path));
        expect(pathSet.ops, isNotEmpty);
      });

      test('produces non-empty path ops for the outline', () {
        final Drawable drawable = generator.rectangle(0, 0, 200, 100);

        final OpSet pathSet = drawable.sets!.last;
        expect(pathSet.type, equals(OpSetType.path));
        expect(pathSet.ops!.length, greaterThan(0));
      });

      test('with HachureFiller produces non-empty fill ops', () {
        final Generator filledGenerator = Generator(
          config,
          HachureFiller(),
        );
        final Drawable drawable = filledGenerator.rectangle(0, 0, 100, 100);

        expect(drawable.sets!.length, equals(2));

        final OpSet fillSet = drawable.sets![0];
        expect(fillSet.type, equals(OpSetType.fillSketch));
        expect(fillSet.ops, isNotEmpty);
      });
    });

    group('ellipse()', () {
      test('produces non-empty Drawable', () {
        final Drawable drawable = generator.ellipse(50, 50, 100, 60);

        expect(drawable.sets, isNotNull);
        expect(drawable.sets, isNotEmpty);

        // Should have fill + outline.
        expect(drawable.sets!.length, equals(2));
      });

      test('outline ops are non-empty', () {
        final Drawable drawable = generator.ellipse(100, 100, 80, 40);

        final OpSet pathSet = drawable.sets!.last;
        expect(pathSet.type, equals(OpSetType.path));
        expect(pathSet.ops, isNotEmpty);
      });

      test('works with equal width and height (circle-like)', () {
        final Drawable drawable = generator.ellipse(50, 50, 100, 100);

        expect(drawable.sets, isNotNull);
        expect(drawable.sets, isNotEmpty);
        expect(drawable.sets!.last.ops, isNotEmpty);
      });
    });

    group('circle()', () {
      test('produces non-empty Drawable', () {
        final Drawable drawable = generator.circle(50, 50, 100);

        expect(drawable.sets, isNotNull);
        expect(drawable.sets, isNotEmpty);
        expect(drawable.sets!.length, equals(2));
      });

      test('produces same number of OpSets as equivalent ellipse', () {
        // Reset seeds to ensure deterministic comparison.
        final DrawConfig config1 = DrawConfig.build(seed: 42);
        final DrawConfig config2 = DrawConfig.build(seed: 42);

        final Generator gen1 = Generator(config1, NoFiller());
        final Generator gen2 = Generator(config2, NoFiller());

        final Drawable circleDrawable = gen1.circle(50, 50, 100);
        final Drawable ellipseDrawable = gen2.ellipse(50, 50, 100, 100);

        expect(
          circleDrawable.sets!.length,
          equals(ellipseDrawable.sets!.length),
        );
      });
    });

    group('polygon()', () {
      test('produces Drawable with fill', () {
        final List<PointD> points = [
          PointD(0, 0),
          PointD(100, 0),
          PointD(100, 100),
          PointD(0, 100),
        ];
        final Drawable drawable = generator.polygon(points);

        expect(drawable.sets, isNotNull);
        // polygon uses _buildDrawable with fillPoints, so 2 sets.
        expect(drawable.sets!.length, equals(2));

        // First set is fill.
        expect(drawable.sets![0].type, equals(OpSetType.fillSketch));

        // Second set is path outline.
        expect(drawable.sets![1].type, equals(OpSetType.path));
        expect(drawable.sets![1].ops, isNotEmpty);
      });

      test('triangle polygon produces non-empty outline', () {
        final List<PointD> triangle = [
          PointD(50, 0),
          PointD(100, 100),
          PointD(0, 100),
        ];
        final Drawable drawable = generator.polygon(triangle);

        expect(drawable.sets!.last.ops, isNotEmpty);
      });
    });

    group('arc()', () {
      test('produces Drawable for a quarter arc', () {
        final Drawable drawable = generator.arc(50, 50, 100, 100, 0, pi / 2);

        expect(drawable.sets, isNotNull);
        expect(drawable.sets, isNotEmpty);
        expect(drawable.sets!.length, equals(2));
      });

      test('produces Drawable for a half arc', () {
        final Drawable drawable = generator.arc(50, 50, 100, 100, 0, pi);

        expect(drawable.sets, isNotNull);
        expect(drawable.sets, isNotEmpty);
      });

      test('produces Drawable for a full arc (2*pi)', () {
        final Drawable drawable = generator.arc(50, 50, 100, 100, 0, 2 * pi);

        expect(drawable.sets, isNotNull);
        expect(drawable.sets, isNotEmpty);
      });

      test('produces Drawable for negative start angle', () {
        final Drawable drawable = generator.arc(50, 50, 80, 60, -pi, pi / 2);

        expect(drawable.sets, isNotNull);
        expect(drawable.sets, isNotEmpty);
      });

      test('outline ops are non-empty for various angle ranges', () {
        final List<List<double>> ranges = [
          [0, pi / 4],
          [0, pi / 2],
          [0, pi],
          [pi / 4, 3 * pi / 4],
          [0, 2 * pi],
        ];

        for (final range in ranges) {
          final Drawable drawable = generator.arc(
            50,
            50,
            100,
            100,
            range[0],
            range[1],
          );
          expect(drawable.sets!.last.ops, isNotEmpty);
        }
      });
    });

    group('roundedRectangle()', () {
      test('produces non-empty Drawable', () {
        final Drawable drawable = generator.roundedRectangle(
          10,
          10,
          200,
          100,
          10,
          10,
          10,
          10,
        );

        expect(drawable.sets, isNotNull);
        expect(drawable.sets, isNotEmpty);
        expect(drawable.sets!.length, equals(2));
      });

      test('with zero radii matches rectangle behavior (same number of OpSets)', () {
        final DrawConfig config1 = DrawConfig.build(seed: 7);
        final DrawConfig config2 = DrawConfig.build(seed: 7);

        final Generator gen1 = Generator(config1, NoFiller());
        final Generator gen2 = Generator(config2, NoFiller());

        final Drawable roundedRect = gen1.roundedRectangle(
          10,
          10,
          200,
          100,
          0,
          0,
          0,
          0,
        );
        final Drawable rect = gen2.rectangle(10, 10, 200, 100);

        expect(roundedRect.sets!.length, equals(rect.sets!.length));
      });

      test('clamps radii to half-side-length', () {
        // Width=100, Height=50 => max radius = min(50, 25) = 25.
        // Passing 999 should be clamped.
        final Drawable drawable = generator.roundedRectangle(
          0,
          0,
          100,
          50,
          999,
          999,
          999,
          999,
        );

        expect(drawable.sets, isNotNull);
        expect(drawable.sets, isNotEmpty);
        // Should not throw and should produce a valid drawable.
        expect(drawable.sets!.last.type, equals(OpSetType.path));
        expect(drawable.sets!.last.ops, isNotEmpty);
      });

      test('outline is path type', () {
        final Drawable drawable = generator.roundedRectangle(
          0,
          0,
          150,
          80,
          15,
          15,
          15,
          15,
        );

        final OpSet outline = drawable.sets!.last;
        expect(outline.type, equals(OpSetType.path));
      });

      test('asymmetric radii produce non-empty Drawable', () {
        final Drawable drawable = generator.roundedRectangle(
          0,
          0,
          200,
          100,
          5,
          10,
          20,
          15,
        );

        expect(drawable.sets, isNotNull);
        expect(drawable.sets!.length, equals(2));
        expect(drawable.sets!.last.ops, isNotEmpty);
      });
    });

    group('linearPath()', () {
      test('works with two points', () {
        final List<PointD> points = [PointD(0, 0), PointD(100, 100)];
        final Drawable drawable = generator.linearPath(points);

        expect(drawable.sets, isNotNull);
        expect(drawable.sets!.length, equals(1));
        expect(drawable.sets!.first.ops, isNotEmpty);
      });

      test('works with three points', () {
        final List<PointD> points = [
          PointD(0, 0),
          PointD(50, 50),
          PointD(100, 0),
        ];
        final Drawable drawable = generator.linearPath(points);

        expect(drawable.sets, isNotNull);
        expect(drawable.sets!.first.ops, isNotEmpty);
      });

      test('works with many points', () {
        final List<PointD> points = List.generate(
          10,
          (i) => PointD(i * 10.0, (i % 2) * 20.0),
        );
        final Drawable drawable = generator.linearPath(points);

        expect(drawable.sets, isNotNull);
        expect(drawable.sets!.first.ops, isNotEmpty);
      });

      test('single point returns empty ops', () {
        final List<PointD> points = [PointD(50, 50)];
        final Drawable drawable = generator.linearPath(points);

        expect(drawable.sets, isNotNull);
        expect(drawable.sets!.first.ops, isEmpty);
      });
    });

    group('curvePath()', () {
      test('works with multiple points', () {
        final List<PointD> points = [
          PointD(0, 0),
          PointD(25, 50),
          PointD(50, 25),
          PointD(75, 75),
          PointD(100, 0),
        ];
        final Drawable drawable = generator.curvePath(points);

        expect(drawable.sets, isNotNull);
        expect(drawable.sets!.length, equals(1));
        expect(drawable.sets!.first.type, equals(OpSetType.path));
        expect(drawable.sets!.first.ops, isNotEmpty);
      });

      test('works with four points', () {
        final List<PointD> points = [
          PointD(0, 0),
          PointD(30, 60),
          PointD(60, 30),
          PointD(100, 100),
        ];
        final Drawable drawable = generator.curvePath(points);

        expect(drawable.sets, isNotNull);
        expect(drawable.sets!.first.ops, isNotEmpty);
      });
    });
  });
}
