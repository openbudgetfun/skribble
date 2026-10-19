import { RoughPen, stripUndefined } from "./pen.js";
import { Randomizer } from "./random.js";

/** The values that shape a {@link DrawConfig}. Every field is optional. */
export interface DrawConfigOptions {
  /** Largest endpoint displacement, in drawing units, before roughness. */
  maxRandomnessOffset?: number;
  /** Amplitude multiplier for every random displacement. */
  roughness?: number;
  /** How far straight edges bow away from their chord. */
  bowing?: number;
  /** Local wandering along long edges; zero restores softly bowed lines. */
  lineWobble?: number;
  /** How closely ellipses follow their ideal radius, from zero to one. */
  curveFitting?: number;
  /** Catmull-Rom tension for fitted curves; zero is the smoothest. */
  curveTightness?: number;
  /** Minimum number of points used to approximate a full ellipse. */
  curveStepCount?: number;
  /** Seed for the random stream. The same seed always draws the same shape. */
  seed?: number | bigint;
  /** How ink leaves the pen along the generated geometry. */
  pen?: RoughPen;
}

type ResolvedDrawConfig = Required<DrawConfigOptions>;

const defaults: ResolvedDrawConfig = {
  maxRandomnessOffset: 2,
  roughness: 1.8,
  bowing: 1,
  lineWobble: 1,
  curveFitting: 0.95,
  curveTightness: 0,
  curveStepCount: 9,
  seed: 1,
  pen: RoughPen.ink,
};

/**
 * Describes how a shape is drawn: how far the hand wanders from the ideal
 * geometry, and how the pen lays down ink along the result.
 *
 * Every configuration owns a fresh {@link Randomizer} for its seed, so build
 * a new one for every shape (and for its filler) instead of sharing one.
 */
export class DrawConfig {
  readonly maxRandomnessOffset: number;
  readonly roughness: number;
  readonly bowing: number;
  readonly lineWobble: number;
  readonly curveFitting: number;
  readonly curveTightness: number;
  readonly curveStepCount: number;
  readonly seed: number | bigint;
  readonly pen: RoughPen;
  /** The replayable random stream for {@link seed}. */
  readonly randomizer: Randomizer;

  private constructor(values: ResolvedDrawConfig) {
    this.maxRandomnessOffset = values.maxRandomnessOffset;
    this.roughness = values.roughness;
    this.bowing = values.bowing;
    this.lineWobble = values.lineWobble;
    this.curveFitting = values.curveFitting;
    this.curveTightness = values.curveTightness;
    this.curveStepCount = values.curveStepCount;
    this.seed = values.seed;
    this.pen = values.pen;
    this.randomizer = new Randomizer(values.seed);
  }

  /** The library defaults: playful roughness drawn with {@link RoughPen.ink}. */
  static readonly defaultValues: DrawConfig = new DrawConfig(defaults);

  /** Creates a configuration, taking each omitted value from the defaults. */
  static build(options: DrawConfigOptions = {}): DrawConfig {
    return new DrawConfig({ ...defaults, ...stripUndefined(options) });
  }

  /** A random displacement between [min] and [max], scaled by roughness. */
  offset(min: number, max: number, roughnessGain = 1): number {
    return this.roughness * roughnessGain * (this.randomizer.next() * (max - min) + min);
  }

  /** A random displacement between `-x` and `x`, scaled by roughness. */
  offsetSymmetric(x: number, roughnessGain = 1): number {
    return this.offset(-x, x, roughnessGain);
  }

  /**
   * Returns a copy with the given values replaced. The copy owns a fresh
   * random stream, so replaying one configuration never advances another's.
   */
  copyWith(options: DrawConfigOptions): DrawConfig {
    return new DrawConfig({ ...this.toOptions(), ...stripUndefined(options) });
  }

  /** The configuration's values as a plain object. */
  toOptions(): ResolvedDrawConfig {
    return {
      maxRandomnessOffset: this.maxRandomnessOffset,
      roughness: this.roughness,
      bowing: this.bowing,
      lineWobble: this.lineWobble,
      curveFitting: this.curveFitting,
      curveTightness: this.curveTightness,
      curveStepCount: this.curveStepCount,
      seed: this.seed,
      pen: this.pen,
    };
  }
}
