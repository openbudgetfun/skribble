import { clamp } from "./math.js";

/** The values that shape a {@link RoughPen}. */
export interface RoughPenOptions {
  /** Width at the first touch, as a fraction of the full width. */
  startWidth?: number;
  /** Width as the pen lifts, as a fraction of the full width. */
  endWidth?: number;
  /** Distance over which the stroke reaches full width, in pen widths. */
  taperIn?: number;
  /** Distance over which the stroke thins before lifting, in pen widths. */
  taperOut?: number;
  /** Smooth width variation along the stroke, as a fraction of the width. */
  pressure?: number;
  /** Distance between pressure swells, in drawing units. */
  pressureWavelength?: number;
  /** Width of repeat passes, as a fraction of the first pass. */
  repeatWidth?: number;
  /**
   * Share of each repeat pass that is inked, from zero to one. Below one,
   * each repeat pass covers a seeded stretch of roughly this fraction.
   */
  repeatCoverage?: number;
  /** How far a closed loop continues past its start, in pen widths. */
  closure?: number;
  /**
   * How far the closing stretch drifts off the line, in pen widths. The
   * drift curls toward the inside of the shape and shrinks on small shapes.
   */
  closureDrift?: number;
}

/**
 * How ink leaves the pen along a rough centreline.
 *
 * The generator decides *where* a line goes. A pen decides how wide the ink
 * is at each point: a light touchdown that swells to full width, slow
 * changes in pressure, a lift that thins out, and a lighter repeat stroke
 * when the generator draws a second pass. Closed loops keep going a little
 * past where they started, the way a hand closes a circle.
 *
 * Widths are fractions of the caller's stroke width, and lengths are in pen
 * widths, so a pen keeps its character when the stroke gets thicker.
 */
export class RoughPen {
  readonly startWidth: number;
  readonly endWidth: number;
  readonly taperIn: number;
  readonly taperOut: number;
  readonly pressure: number;
  readonly pressureWavelength: number;
  readonly repeatWidth: number;
  readonly repeatCoverage: number;
  readonly closure: number;
  readonly closureDrift: number;

  constructor(options: RoughPenOptions = {}) {
    this.startWidth = options.startWidth ?? 0.45;
    this.endWidth = options.endWidth ?? 0.3;
    this.taperIn = options.taperIn ?? 4;
    this.taperOut = options.taperOut ?? 7;
    this.pressure = options.pressure ?? 0.14;
    this.pressureWavelength = options.pressureWavelength ?? 26;
    this.repeatWidth = options.repeatWidth ?? 0.5;
    this.repeatCoverage = options.repeatCoverage ?? 0.45;
    this.closure = options.closure ?? 2.5;
    this.closureDrift = options.closureDrift ?? 0.9;
  }

  /** Constant width, round caps, and no closure. Painted as a plain stroke. */
  static readonly uniform = new RoughPen({
    startWidth: 1,
    endWidth: 1,
    taperIn: 0,
    taperOut: 0,
    pressure: 0,
    repeatWidth: 1,
    repeatCoverage: 1,
    closure: 0,
    closureDrift: 0,
  });

  /** A technical pen: nearly even width with a slight touchdown. */
  static readonly fineliner = new RoughPen({
    startWidth: 0.8,
    endWidth: 0.75,
    taperIn: 2,
    taperOut: 2,
    pressure: 0.04,
    repeatWidth: 0.75,
    repeatCoverage: 0.85,
    closure: 1.5,
    closureDrift: 0.5,
  });

  /** A dip pen: tapered ends, gentle swells, and a lighter second pass. */
  static readonly ink = new RoughPen();

  /** A loaded brush: sharp entry and exit with pronounced pressure. */
  static readonly brush = new RoughPen({
    startWidth: 0.15,
    endWidth: 0.08,
    taperIn: 6,
    taperOut: 10,
    pressure: 0.28,
    pressureWavelength: 34,
    repeatWidth: 0.45,
    repeatCoverage: 0.55,
    closure: 3.5,
    closureDrift: 1.2,
  });

  /** Whether this pen lays down constant-width ink. */
  get isUniform(): boolean {
    return (
      this.startWidth === 1 &&
      this.endWidth === 1 &&
      this.pressure === 0 &&
      this.repeatWidth === 1 &&
      this.repeatCoverage >= 1 &&
      this.closure === 0
    );
  }

  /** The widest the ink can get, as a multiple of the stroke width. */
  get peakWidth(): number {
    return 1 + clamp(this.pressure, 0, 1);
  }

  /** The furthest ink reaches outward from its centreline, in stroke widths. */
  get reach(): number {
    return this.peakWidth / 2;
  }

  /** Returns a copy with the given values replaced. */
  copyWith(options: RoughPenOptions): RoughPen {
    return new RoughPen({ ...this.toJSON(), ...stripUndefined(options) });
  }

  /** Whether [other] lays down the same ink. */
  equals(other: RoughPen): boolean {
    const a = this.toJSON();
    const b = other.toJSON();
    return (Object.keys(a) as (keyof RoughPenOptions)[]).every((key) => a[key] === b[key]);
  }

  /** The pen's values as a plain object. */
  toJSON(): Required<RoughPenOptions> {
    return {
      startWidth: this.startWidth,
      endWidth: this.endWidth,
      taperIn: this.taperIn,
      taperOut: this.taperOut,
      pressure: this.pressure,
      pressureWavelength: this.pressureWavelength,
      repeatWidth: this.repeatWidth,
      repeatCoverage: this.repeatCoverage,
      closure: this.closure,
      closureDrift: this.closureDrift,
    };
  }
}

/** The pen presets by name. */
export type RoughPenName = "uniform" | "fineliner" | "ink" | "brush";

/** Resolves a preset name, a pen, or pen options to a {@link RoughPen}. */
export function resolvePen(pen: RoughPen | RoughPenName | RoughPenOptions | undefined): RoughPen | undefined {
  if (pen === undefined) return undefined;
  if (pen instanceof RoughPen) return pen;
  if (typeof pen === "string") {
    const preset = RoughPen[pen];
    if (!(preset instanceof RoughPen)) throw new RangeError(`Unknown pen preset "${pen}"`);
    return preset;
  }
  return new RoughPen(pen);
}

/** Copies [options] without keys whose value is `undefined`. */
export function stripUndefined<T extends object>(options: T): Partial<T> {
  const result: Partial<T> = {};
  for (const [key, value] of Object.entries(options)) {
    if (value !== undefined) (result as Record<string, unknown>)[key] = value;
  }
  return result;
}
