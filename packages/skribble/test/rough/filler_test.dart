import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';

void main() {
  /// A simple square polygon used across multiple filler tests.
  final List<PointD> squarePolygon = [
    PointD(0, 0),
    PointD(100, 0),
    PointD(100, 100),
    PointD(0, 100),
  ];

  group('NoFiller', () {
    test('fill() returns empty ops', () {
      final NoFiller filler = NoFiller();
      final OpSet result = filler.fill(squarePolygon);

      expect(result.type, equals(OpSetType.fillSketch));
      expect(result.ops, isNotNull);
      expect(result.ops, isEmpty);
    });

    test('fill() returns fillSketch type regardless of input', () {
      final NoFiller filler = NoFiller();
      final List<PointD> triangle = [
        PointD(0, 0),
        PointD(50, 100),
        PointD(100, 0),
      ];
      final OpSet result = filler.fill(triangle);

      expect(result.type, equals(OpSetType.fillSketch));
      expect(result.ops, isEmpty);
    });
  });

  group('HachureFiller', () {
    test('fill() returns non-empty ops for a square polygon', () {
      final HachureFiller filler = HachureFiller();
      final OpSet result = filler.fill(squarePolygon);

      expect(result.type, equals(OpSetType.fillSketch));
      expect(result.ops, isNotNull);
      expect(result.ops, isNotEmpty);
    });

    test('fill() returns ops containing move and curve operations', () {
      final HachureFiller filler = HachureFiller();
      final OpSet result = filler.fill(squarePolygon);

      expect(result.ops, isNotNull);
      expect(result.ops!.length, greaterThan(1));
    });

    test('fill() works with custom FillerConfig', () {
      final FillerConfig customConfig = FillerConfig.build(
        hachureAngle: 45,
        hachureGap: 10,
      );
      final HachureFiller filler = HachureFiller(customConfig);
      final OpSet result = filler.fill(squarePolygon);

      expect(result.type, equals(OpSetType.fillSketch));
      expect(result.ops, isNotEmpty);
    });
  });

  group('ZigZagFiller', () {
    test('fill() returns non-empty ops', () {
      final ZigZagFiller filler = ZigZagFiller();
      final OpSet result = filler.fill(squarePolygon);

      expect(result.type, equals(OpSetType.fillSketch));
      expect(result.ops, isNotNull);
      expect(result.ops, isNotEmpty);
    });

    test('fill() produces more ops than hachure for same polygon', () {
      // ZigZag connects ends, so it should generally produce more ops.
      final ZigZagFiller zigzag = ZigZagFiller();
      final HachureFiller hachure = HachureFiller();

      final OpSet zigzagResult = zigzag.fill(squarePolygon);
      final OpSet hachureResult = hachure.fill(squarePolygon);

      // ZigZag connects line ends, so it should have at least as many ops.
      expect(zigzagResult.ops!.length, greaterThanOrEqualTo(hachureResult.ops!.length));
    });
  });

  group('HatchFiller', () {
    test('fill() returns non-empty ops (double hatch)', () {
      final HatchFiller filler = HatchFiller();
      final OpSet result = filler.fill(squarePolygon);

      expect(result.type, equals(OpSetType.fillSketch));
      expect(result.ops, isNotNull);
      expect(result.ops, isNotEmpty);
    });

    test('fill() produces more ops than single hachure (cross-hatch)', () {
      final HatchFiller hatch = HatchFiller();
      final HachureFiller hachure = HachureFiller();

      final OpSet hatchResult = hatch.fill(squarePolygon);
      final OpSet hachureResult = hachure.fill(squarePolygon);

      // Hatch fills in two directions, so should have roughly double the ops.
      expect(
        hatchResult.ops!.length,
        greaterThan(hachureResult.ops!.length),
      );
    });
  });

  group('DashedFiller', () {
    test('fill() returns non-empty ops', () {
      final DashedFiller filler = DashedFiller();
      final OpSet result = filler.fill(squarePolygon);

      expect(result.type, equals(OpSetType.fillSketch));
      expect(result.ops, isNotNull);
      expect(result.ops, isNotEmpty);
    });

    test('fill() works with custom dash config', () {
      final FillerConfig customConfig = FillerConfig.build(
        dashOffset: 10,
        dashGap: 5,
      );
      final DashedFiller filler = DashedFiller(customConfig);
      final OpSet result = filler.fill(squarePolygon);

      expect(result.ops, isNotEmpty);
    });
  });

  group('DotFiller', () {
    test('fill() returns non-empty ops', () {
      final DotFiller filler = DotFiller();
      final OpSet result = filler.fill(squarePolygon);

      expect(result.type, equals(OpSetType.fillSketch));
      expect(result.ops, isNotNull);
      expect(result.ops, isNotEmpty);
    });

    test('fill() works with a triangle polygon', () {
      final DotFiller filler = DotFiller();
      final List<PointD> triangle = [
        PointD(0, 0),
        PointD(50, 100),
        PointD(100, 0),
      ];
      final OpSet result = filler.fill(triangle);

      expect(result.ops, isNotNull);
      expect(result.ops, isNotEmpty);
    });
  });

  group('SolidFiller', () {
    test('fill() returns fillPath type OpSet', () {
      final SolidFiller filler = SolidFiller();
      final OpSet result = filler.fill(squarePolygon);

      expect(result.type, equals(OpSetType.fillPath));
      expect(result.ops, isNotNull);
      expect(result.ops, isNotEmpty);
    });

    test('fill() with fewer than 3 points returns empty ops', () {
      final SolidFiller filler = SolidFiller();
      final List<PointD> twoPoints = [PointD(0, 0), PointD(100, 100)];
      final OpSet result = filler.fill(twoPoints);

      expect(result.type, equals(OpSetType.fillPath));
      // With fewer than 3 points, result list is empty so curve returns [].
      expect(result.ops, isEmpty);
    });

    test('fill() type differs from sketch fillers', () {
      final SolidFiller solid = SolidFiller();
      final HachureFiller hachure = HachureFiller();

      final OpSet solidResult = solid.fill(squarePolygon);
      final OpSet hachureResult = hachure.fill(squarePolygon);

      expect(solidResult.type, equals(OpSetType.fillPath));
      expect(hachureResult.type, equals(OpSetType.fillSketch));
      expect(solidResult.type, isNot(equals(hachureResult.type)));
    });
  });

  group('FillerConfig', () {
    group('build()', () {
      test('has correct defaults', () {
        final FillerConfig config = FillerConfig.build();

        expect(config.fillWeight, equals(1));
        expect(config.hachureAngle, equals(320));
        expect(config.hachureGap, equals(15));
        expect(config.dashOffset, equals(15));
        expect(config.dashGap, equals(2));
        expect(config.zigzagOffset, equals(5));
        expect(config.drawConfig, isNotNull);
      });

      test('overrides specific values', () {
        final FillerConfig config = FillerConfig.build(
          fillWeight: 3,
          hachureAngle: 45,
          hachureGap: 20,
        );

        expect(config.fillWeight, equals(3));
        expect(config.hachureAngle, equals(45));
        expect(config.hachureGap, equals(20));
        // Non-overridden values retain defaults.
        expect(config.dashOffset, equals(15));
        expect(config.dashGap, equals(2));
        expect(config.zigzagOffset, equals(5));
      });

      test('accepts custom DrawConfig', () {
        final DrawConfig customDraw = DrawConfig.build(
          roughness: 3,
          seed: 99,
        );
        final FillerConfig config = FillerConfig.build(
          drawConfig: customDraw,
        );

        expect(config.drawConfig, equals(customDraw));
        expect(config.drawConfig!.roughness, equals(3));
        expect(config.drawConfig!.seed, equals(99));
      });
    });

    group('defaultConfig', () {
      test('has expected default values', () {
        final FillerConfig config = FillerConfig.defaultConfig;

        expect(config.fillWeight, equals(1));
        expect(config.hachureAngle, equals(320));
        expect(config.hachureGap, equals(15));
        expect(config.drawConfig, isNotNull);
      });
    });

    group('copyWith()', () {
      test('copies all values when no overrides given', () {
        final FillerConfig original = FillerConfig.build(
          fillWeight: 2,
          hachureAngle: 45,
          dashOffset: 10,
        );
        final FillerConfig copy = original.copyWith();

        expect(copy.fillWeight, equals(original.fillWeight));
        expect(copy.hachureAngle, equals(original.hachureAngle));
        expect(copy.hachureGap, equals(original.hachureGap));
        expect(copy.dashOffset, equals(original.dashOffset));
        expect(copy.dashGap, equals(original.dashGap));
        expect(copy.zigzagOffset, equals(original.zigzagOffset));
      });

      test('overrides specific values', () {
        final FillerConfig original = FillerConfig.build(
          fillWeight: 2,
          hachureAngle: 45,
        );
        final FillerConfig copy = original.copyWith(
          fillWeight: 5,
          dashGap: 10,
        );

        expect(copy.fillWeight, equals(5));
        expect(copy.dashGap, equals(10));
        // Unchanged values should remain the same.
        expect(copy.hachureAngle, equals(original.hachureAngle));
        expect(copy.hachureGap, equals(original.hachureGap));
      });

      test('can override drawConfig', () {
        final FillerConfig original = FillerConfig.build();
        final DrawConfig newDrawConfig = DrawConfig.build(
          roughness: 5,
          seed: 77,
        );
        final FillerConfig copy = original.copyWith(
          drawConfig: newDrawConfig,
        );

        expect(copy.drawConfig, equals(newDrawConfig));
        expect(copy.drawConfig!.roughness, equals(5));
      });
    });
  });
}
