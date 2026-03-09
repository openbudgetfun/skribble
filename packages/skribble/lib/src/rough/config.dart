import 'dart:math';

/// Describes how a particular shape is drawn.
class DrawConfig {
  final double? maxRandomnessOffset;
  final double? roughness;
  final double? bowing;
  final double? curveFitting;
  final double? curveTightness;
  final double? curveStepCount;
  final int? seed;
  final Randomizer? randomizer;

  static DrawConfig defaultValues = DrawConfig.build(
    maxRandomnessOffset: 2,
    roughness: 1,
    bowing: 1,
    curveFitting: 0.95,
    curveTightness: 0,
    curveStepCount: 9,
    seed: 1,
  );

  const DrawConfig._({
    this.maxRandomnessOffset,
    this.roughness,
    this.bowing,
    this.curveFitting,
    this.curveTightness,
    this.curveStepCount,
    this.seed,
    this.randomizer,
  });

  static DrawConfig build({
    double? maxRandomnessOffset,
    double? roughness,
    double? bowing,
    double? curveFitting,
    double? curveTightness,
    double? curveStepCount,
    int? seed,
  }) => DrawConfig._(
    maxRandomnessOffset:
        maxRandomnessOffset ?? defaultValues.maxRandomnessOffset,
    roughness: roughness ?? defaultValues.roughness,
    bowing: bowing ?? defaultValues.bowing,
    curveFitting: curveFitting ?? defaultValues.curveFitting,
    curveTightness: curveTightness ?? defaultValues.curveTightness,
    curveStepCount: curveStepCount ?? defaultValues.curveStepCount,
    seed: seed ?? defaultValues.seed,
    randomizer: Randomizer(seed: seed ?? defaultValues.seed!),
  );

  double offset(double min, double max, [double roughnessGain = 1]) {
    return roughness! *
        roughnessGain *
        ((randomizer!.next() * (max - min)) + min);
  }

  double offsetSymmetric(double x, [double roughnessGain = 1]) {
    return offset(-x, x, roughnessGain);
  }

  DrawConfig copyWith({
    double? maxRandomnessOffset,
    double? roughness,
    double? bowing,
    double? curveFitting,
    double? curveTightness,
    double? curveStepCount,
    double? fillWeight,
    int? seed,
    bool? combineNestedSvgPaths,
    Randomizer? randomizer,
  }) => DrawConfig._(
    maxRandomnessOffset: maxRandomnessOffset ?? this.maxRandomnessOffset,
    roughness: roughness ?? this.roughness,
    bowing: bowing ?? this.bowing,
    curveFitting: curveFitting ?? this.curveFitting,
    curveTightness: curveTightness ?? this.curveTightness,
    curveStepCount: curveStepCount ?? this.curveStepCount,
    seed: seed ?? this.seed,
    randomizer:
        randomizer ??
        (this.randomizer == null
            ? null
            : Randomizer(seed: this.randomizer!.seed)),
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DrawConfig &&
          runtimeType == other.runtimeType &&
          maxRandomnessOffset == other.maxRandomnessOffset &&
          roughness == other.roughness &&
          bowing == other.bowing &&
          curveFitting == other.curveFitting &&
          curveTightness == other.curveTightness &&
          curveStepCount == other.curveStepCount &&
          seed == other.seed &&
          randomizer == other.randomizer;

  @override
  int get hashCode =>
      maxRandomnessOffset.hashCode ^
      roughness.hashCode ^
      bowing.hashCode ^
      curveFitting.hashCode ^
      curveTightness.hashCode ^
      curveStepCount.hashCode ^
      seed.hashCode ^
      randomizer.hashCode;
}

class Randomizer {
  late Random _random;
  late int _seed;

  Randomizer({int seed = 0}) {
    _seed = seed;
    _random = Random(seed);
  }

  int get seed => _seed;

  double next() => _random.nextDouble();

  void reset() {
    _random = Random(_seed);
  }
}
