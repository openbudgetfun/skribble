import 'dart:math';

import 'pen.dart';

/// Describes how a particular shape is drawn: how far the hand wanders from
/// the ideal geometry, and how the pen lays down ink along the result.
///
/// Every field has a value. [DrawConfig.build] fills the ones you omit from
/// [defaultValues], so `DrawConfig.build(seed: 7)` changes only the seed.
class DrawConfig {
  /// Largest endpoint displacement, in logical pixels, before [roughness].
  final double maxRandomnessOffset;

  /// Amplitude multiplier for every random displacement.
  final double roughness;

  /// How far straight edges bow away from their chord.
  final double bowing;

  /// Local wandering along long edges; zero restores softly bowed lines.
  /// Values from zero through one span the bundled theme presets.
  final double lineWobble;

  /// How closely ellipses follow their ideal radius, from zero to one.
  final double curveFitting;

  /// Catmull-Rom tension for fitted curves; zero is the smoothest.
  final double curveTightness;

  /// Minimum number of points used to approximate a full ellipse.
  final double curveStepCount;

  /// Seed for [randomizer]. The same seed always draws the same shape.
  final int seed;

  /// How ink leaves the pen along the generated geometry.
  final RoughPen pen;

  /// The replayable random stream for [seed]. Painters reset it before
  /// generating a shape so repeated paints match.
  final Randomizer randomizer;

  /// The library defaults: playful roughness drawn with [RoughPen.ink].
  static final DrawConfig defaultValues = DrawConfig._(
    maxRandomnessOffset: 2,
    roughness: 1.8,
    bowing: 1,
    lineWobble: 1,
    curveFitting: 0.95,
    curveTightness: 0,
    curveStepCount: 9,
    seed: 1,
    pen: RoughPen.ink,
    randomizer: Randomizer(seed: 1),
  );

  DrawConfig._({
    required this.maxRandomnessOffset,
    required this.roughness,
    required this.bowing,
    required this.lineWobble,
    required this.curveFitting,
    required this.curveTightness,
    required this.curveStepCount,
    required this.seed,
    required this.pen,
    required this.randomizer,
  });

  /// Creates a configuration, taking each omitted value from [defaultValues].
  static DrawConfig build({
    double? maxRandomnessOffset,
    double? roughness,
    double? bowing,
    double? lineWobble,
    double? curveFitting,
    double? curveTightness,
    double? curveStepCount,
    int? seed,
    RoughPen? pen,
  }) {
    final resolvedSeed = seed ?? defaultValues.seed;
    return DrawConfig._(
      maxRandomnessOffset:
          maxRandomnessOffset ?? defaultValues.maxRandomnessOffset,
      roughness: roughness ?? defaultValues.roughness,
      bowing: bowing ?? defaultValues.bowing,
      lineWobble: lineWobble ?? defaultValues.lineWobble,
      curveFitting: curveFitting ?? defaultValues.curveFitting,
      curveTightness: curveTightness ?? defaultValues.curveTightness,
      curveStepCount: curveStepCount ?? defaultValues.curveStepCount,
      seed: resolvedSeed,
      pen: pen ?? defaultValues.pen,
      randomizer: Randomizer(seed: resolvedSeed),
    );
  }

  /// A random displacement between [min] and [max], scaled by [roughness].
  double offset(double min, double max, [double roughnessGain = 1]) {
    return roughness *
        roughnessGain *
        ((randomizer.next() * (max - min)) + min);
  }

  /// A random displacement between `-x` and `x`, scaled by [roughness].
  double offsetSymmetric(double x, [double roughnessGain = 1]) {
    return offset(-x, x, roughnessGain);
  }

  /// Returns a copy with the given values replaced.
  ///
  /// The copy always owns a fresh [Randomizer] for its seed, so replaying one
  /// configuration never advances another's stream.
  DrawConfig copyWith({
    double? maxRandomnessOffset,
    double? roughness,
    double? bowing,
    double? lineWobble,
    double? curveFitting,
    double? curveTightness,
    double? curveStepCount,
    int? seed,
    RoughPen? pen,
  }) {
    final resolvedSeed = seed ?? this.seed;
    return DrawConfig._(
      maxRandomnessOffset: maxRandomnessOffset ?? this.maxRandomnessOffset,
      roughness: roughness ?? this.roughness,
      bowing: bowing ?? this.bowing,
      lineWobble: lineWobble ?? this.lineWobble,
      curveFitting: curveFitting ?? this.curveFitting,
      curveTightness: curveTightness ?? this.curveTightness,
      curveStepCount: curveStepCount ?? this.curveStepCount,
      seed: resolvedSeed,
      pen: pen ?? this.pen,
      randomizer: Randomizer(seed: resolvedSeed),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DrawConfig &&
          maxRandomnessOffset == other.maxRandomnessOffset &&
          roughness == other.roughness &&
          bowing == other.bowing &&
          lineWobble == other.lineWobble &&
          curveFitting == other.curveFitting &&
          curveTightness == other.curveTightness &&
          curveStepCount == other.curveStepCount &&
          seed == other.seed &&
          pen == other.pen;

  @override
  int get hashCode => Object.hash(
    maxRandomnessOffset,
    roughness,
    bowing,
    lineWobble,
    curveFitting,
    curveTightness,
    curveStepCount,
    seed,
    pen,
  );
}

/// A seedable pseudo-random number generator for deterministic rough drawing.
///
/// Reset via [reset] to replay the same random sequence, ensuring
/// consistent sketchy output across rebuilds.
class Randomizer {
  Randomizer({int seed = 0}) : _seed = seed, _random = Random(seed);

  final int _seed;
  Random _random;

  /// The seed this stream replays from.
  int get seed => _seed;

  /// The next value in `[0, 1)`.
  double next() => _random.nextDouble();

  /// Rewinds the stream to its first value.
  void reset() {
    _random = Random(_seed);
  }
}
