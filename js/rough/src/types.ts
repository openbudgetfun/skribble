import type { DrawConfig } from "./config.js";

/** A point in drawing coordinates. */
export interface Point {
  readonly x: number;
  readonly y: number;
}

/** The kind of a single drawing operation. */
export type OpType = "move" | "lineTo" | "curveTo";

/**
 * A single drawing operation.
 *
 * `move` and `lineTo` carry one point; `curveTo` carries two cubic Bézier
 * control points followed by its end point.
 */
export interface Op {
  readonly op: OpType;
  readonly data: readonly Point[];
  /**
   * Which pen pass a contour belongs to, set on the move that starts it.
   *
   * Zero is the first stroke. The generator draws most shapes twice and a
   * {@link RoughPen} lays later passes down lighter. Always zero for `lineTo`
   * and `curveTo`.
   */
  readonly pass: number;
}

/**
 * What an {@link OpSet} draws: an outline (`path`), a solid fill polygon
 * (`fillPath`), or a sketched fill pattern (`fillSketch`).
 */
export type OpSetType = "path" | "fillPath" | "fillSketch";

/** Operations that are painted together. */
export interface OpSet {
  readonly type: OpSetType;
  readonly ops: Op[];
}

/** A generated rough shape: its op sets and the configuration that drew it. */
export interface Drawable {
  readonly shape?: string;
  readonly options: DrawConfig;
  readonly sets: OpSet[];
}

/** Starts a new contour at [p], drawn as pen pass [pass]. */
export function moveOp(p: Point, pass = 0): Op {
  return { op: "move", data: [p], pass };
}

/** A straight segment to [p]. */
export function lineToOp(p: Point): Op {
  return { op: "lineTo", data: [p], pass: 0 };
}

/** A cubic Bézier segment to [end]. */
export function curveToOp(control1: Point, control2: Point, end: Point): Op {
  return { op: "curveTo", data: [control1, control2, end], pass: 0 };
}
