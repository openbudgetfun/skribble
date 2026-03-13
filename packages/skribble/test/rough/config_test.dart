import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';

void main() {
  group('DrawConfig', () {
    group('defaultValues', () {
      test('has expected properties', () {
        final DrawConfig defaults = DrawConfig.defaultValues;

        expect(defaults.maxRandomnessOffset, equals(2));
        expect(defaults.roughness, equals(1));
        expect(defaults.bowing, equals(1));
        expect(defaults.curveFitting, equals(0.95));
        expect(defaults.curveTightness, equals(0));
        expect(defaults.curveStepCount, equals(9));
        expect(defaults.seed, equals(1));
        expect(defaults.randomizer, isNotNull);
      });
    });

    group('build()', () {
      test('overrides individual values', () {
        final DrawConfig config = DrawConfig.build(
          maxRandomnessOffset: 5,
          roughness: 2,
          bowing: 3,
        );

        expect(config.maxRandomnessOffset, equals(5));
        expect(config.roughness, equals(2));
        expect(config.bowing, equals(3));
        // Non-overridden values should be defaults.
        expect(config.curveFitting, equals(0.95));
        expect(config.curveTightness, equals(0));
        expect(config.curveStepCount, equals(9));
      });

      test('overrides seed and creates matching Randomizer', () {
        final DrawConfig config = DrawConfig.build(seed: 42);

        expect(config.seed, equals(42));
        expect(config.randomizer, isNotNull);
        expect(config.randomizer!.seed, equals(42));
      });

      test('overrides all values', () {
        final DrawConfig config = DrawConfig.build(
          maxRandomnessOffset: 10,
          roughness: 3,
          bowing: 5,
          curveFitting: 0.5,
          curveTightness: 0.3,
          curveStepCount: 20,
          seed: 99,
        );

        expect(config.maxRandomnessOffset, equals(10));
        expect(config.roughness, equals(3));
        expect(config.bowing, equals(5));
        expect(config.curveFitting, equals(0.5));
        expect(config.curveTightness, equals(0.3));
        expect(config.curveStepCount, equals(20));
        expect(config.seed, equals(99));
      });
    });

    group('copyWith()', () {
      test('copies all values when no overrides given', () {
        final DrawConfig original = DrawConfig.build(
          maxRandomnessOffset: 3,
          roughness: 2,
          seed: 42,
        );
        final DrawConfig copy = original.copyWith();

        expect(copy.maxRandomnessOffset, equals(original.maxRandomnessOffset));
        expect(copy.roughness, equals(original.roughness));
        expect(copy.bowing, equals(original.bowing));
        expect(copy.curveFitting, equals(original.curveFitting));
        expect(copy.curveTightness, equals(original.curveTightness));
        expect(copy.curveStepCount, equals(original.curveStepCount));
        expect(copy.seed, equals(original.seed));
      });

      test('overrides specific values', () {
        final DrawConfig original = DrawConfig.build(
          maxRandomnessOffset: 3,
          roughness: 2,
          seed: 42,
        );
        final DrawConfig copy = original.copyWith(roughness: 5, bowing: 10);

        expect(copy.roughness, equals(5));
        expect(copy.bowing, equals(10));
        // Unchanged values should remain the same.
        expect(copy.maxRandomnessOffset, equals(original.maxRandomnessOffset));
        expect(copy.seed, equals(original.seed));
      });

      test('preserves randomizer seed when not overridden', () {
        final DrawConfig original = DrawConfig.build(seed: 77);
        final DrawConfig copy = original.copyWith(roughness: 3);

        expect(copy.randomizer, isNotNull);
        expect(copy.randomizer!.seed, equals(original.randomizer!.seed));
      });
    });

    group('offset()', () {
      test('returns value within expected range', () {
        final DrawConfig config = DrawConfig.build(roughness: 1, seed: 42);

        // offset returns roughness * roughnessGain * (random * (max - min) + min)
        // With roughness=1 and roughnessGain=1, the result should be
        // between min and max (approximately).
        final double result = config.offset(0, 10);

        // The randomizer produces a value in [0, 1), so result is in [0, 10).
        expect(result, greaterThanOrEqualTo(0));
        expect(result, lessThan(10));
      });

      test('respects roughnessGain parameter', () {
        final DrawConfig config1 = DrawConfig.build(roughness: 1, seed: 42);
        final DrawConfig config2 = DrawConfig.build(roughness: 1, seed: 42);

        final double resultGain1 = config1.offset(0, 10, 1);
        final double resultGain2 = config2.offset(0, 10, 2);

        // With gain=2, the result should be double the gain=1 result.
        expect(resultGain2, closeTo(resultGain1 * 2, 0.0001));
      });
    });

    group('offsetSymmetric()', () {
      test('returns value within symmetric range', () {
        final DrawConfig config = DrawConfig.build(roughness: 1, seed: 42);

        final double result = config.offsetSymmetric(5);

        // offsetSymmetric(x) calls offset(-x, x) which returns
        // roughness * roughnessGain * (random * 2x + (-x))
        // so the value should be in [-5, 5).
        expect(result, greaterThanOrEqualTo(-5));
        expect(result, lessThan(5));
      });

      test('returns value within range for different inputs', () {
        final DrawConfig config = DrawConfig.build(roughness: 1, seed: 10);

        for (int i = 0; i < 20; i++) {
          final double x = (i + 1) * 2.0;
          final double result = config.offsetSymmetric(x);
          expect(result, greaterThanOrEqualTo(-x));
          expect(result, lessThan(x));
        }
      });
    });

    group('equality and hashCode', () {
      test('config is equal to itself (identity)', () {
        final DrawConfig config = DrawConfig.build(seed: 42);

        expect(config, equals(config));
      });

      test(
        'two configs from build() with same values share same scalar fields',
        () {
          final DrawConfig a = DrawConfig.build(
            maxRandomnessOffset: 2,
            roughness: 1,
            bowing: 1,
            curveFitting: 0.95,
            curveTightness: 0,
            curveStepCount: 9,
            seed: 1,
          );
          final DrawConfig b = DrawConfig.build(
            maxRandomnessOffset: 2,
            roughness: 1,
            bowing: 1,
            curveFitting: 0.95,
            curveTightness: 0,
            curveStepCount: 9,
            seed: 1,
          );

          // Scalar fields match.
          expect(a.maxRandomnessOffset, equals(b.maxRandomnessOffset));
          expect(a.roughness, equals(b.roughness));
          expect(a.bowing, equals(b.bowing));
          expect(a.curveFitting, equals(b.curveFitting));
          expect(a.curveTightness, equals(b.curveTightness));
          expect(a.curveStepCount, equals(b.curveStepCount));
          expect(a.seed, equals(b.seed));
        },
      );

      test('copyWith produces config that shares randomizer seed', () {
        final DrawConfig original = DrawConfig.build(seed: 42);
        final DrawConfig copy = original.copyWith();

        // copyWith creates a new Randomizer with the same seed.
        expect(copy.randomizer!.seed, equals(original.randomizer!.seed));
        expect(copy.seed, equals(original.seed));
      });

      test('configs with different values are not equal', () {
        final DrawConfig a = DrawConfig.build(roughness: 1, seed: 1);
        final DrawConfig b = DrawConfig.build(roughness: 2, seed: 1);

        expect(a.roughness, isNot(equals(b.roughness)));
      });

      test('hashCode is consistent for same instance', () {
        final DrawConfig config = DrawConfig.build(seed: 42);

        expect(config.hashCode, equals(config.hashCode));
      });
    });
  });

  group('Randomizer', () {
    test('produces deterministic values with same seed', () {
      final Randomizer r1 = Randomizer(seed: 42);
      final Randomizer r2 = Randomizer(seed: 42);

      final List<double> values1 = List.generate(10, (_) => r1.next());
      final List<double> values2 = List.generate(10, (_) => r2.next());

      expect(values1, equals(values2));
    });

    test('produces different values with different seeds', () {
      final Randomizer r1 = Randomizer(seed: 42);
      final Randomizer r2 = Randomizer(seed: 99);

      final List<double> values1 = List.generate(10, (_) => r1.next());
      final List<double> values2 = List.generate(10, (_) => r2.next());

      expect(values1, isNot(equals(values2)));
    });

    test('reset() restarts the sequence', () {
      final Randomizer r = Randomizer(seed: 42);

      final List<double> firstRun = List.generate(5, (_) => r.next());

      r.reset();

      final List<double> secondRun = List.generate(5, (_) => r.next());

      expect(firstRun, equals(secondRun));
    });

    test('seed getter returns the configured seed', () {
      final Randomizer r = Randomizer(seed: 123);

      expect(r.seed, equals(123));
    });

    test('next() returns values between 0 and 1', () {
      final Randomizer r = Randomizer(seed: 42);

      for (int i = 0; i < 100; i++) {
        final double value = r.next();
        expect(value, greaterThanOrEqualTo(0));
        expect(value, lessThan(1));
      }
    });

    test('default seed is 0', () {
      final Randomizer r = Randomizer();

      expect(r.seed, equals(0));
    });
  });
}
