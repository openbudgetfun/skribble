import { clamp, dartDoubleToString, formatNumber } from "./math.js";
import { RoughPen } from "./pen.js";
import { Randomizer } from "./random.js";
import type { Drawable, Op, OpSetType } from "./types.js";

/**
 * Receives the outline of an {@link InkStroke}: a canvas context, SVG path
 * data, or anything else that speaks moves, lines, and quadratic curves.
 * A `CanvasRenderingContext2D` or `Path2D` already satisfies it apart from
 * naming, see {@link canvasInkSink}.
 */
export interface InkOutlineSink {
  moveTo(x: number, y: number): void;
  lineTo(x: number, y: number): void;
  quadraticTo(cx: number, cy: number, x: number, y: number): void;
  close(): void;
}

/** Writes an {@link InkStroke} outline as SVG path data. */
export class SvgInkOutline implements InkOutlineSink {
  private data = "";

  moveTo(x: number, y: number): void {
    this.data += `M${n3(x)} ${n3(y)}`;
  }

  lineTo(x: number, y: number): void {
    this.data += `L${n3(x)} ${n3(y)}`;
  }

  quadraticTo(cx: number, cy: number, x: number, y: number): void {
    this.data += `Q${n3(cx)} ${n3(cy)} ${n3(x)} ${n3(y)}`;
  }

  close(): void {
    this.data += "Z";
  }

  /** The accumulated path data. */
  toString(): string {
    return this.data;
  }
}

const n3 = (value: number) => formatNumber(value, 3);

/** The subset of the canvas path API that {@link canvasInkSink} drives. */
export interface CanvasPathLike {
  moveTo(x: number, y: number): void;
  lineTo(x: number, y: number): void;
  quadraticCurveTo(cx: number, cy: number, x: number, y: number): void;
  closePath(): void;
}

/** Adapts a canvas context or `Path2D` to an {@link InkOutlineSink}. */
export function canvasInkSink(path: CanvasPathLike): InkOutlineSink {
  return {
    moveTo: (x, y) => path.moveTo(x, y),
    lineTo: (x, y) => path.lineTo(x, y),
    quadraticTo: (cx, cy, x, y) => path.quadraticCurveTo(cx, cy, x, y),
    close: () => path.closePath(),
  };
}

/** Options for {@link InkStroke}. */
export interface InkStrokeOptions {
  /** Full ink width. */
  width: number;
  /** How ink leaves the pen. */
  pen: RoughPen;
  /** Chooses loop starts and pressure phase. Defaults to 1. */
  seed?: number | bigint;
  /** Scales this stroke relative to `width`. Defaults to 1. */
  weight?: number;
  /** Share of each contour to ink, from 0.05 to 1. Defaults to 1. */
  coverage?: number;
}

/**
 * One pen stroke along rough centreline geometry, sampled once.
 *
 * The operations are flattened and resampled at a spacing tied to the pen
 * width, then each sample gets a width from the {@link RoughPen}.
 * {@link writeOutline} turns the samples into a filled shape, completely or
 * up to a distance for draw-on animation, without sampling again.
 */
export class InkStroke {
  private readonly contours: InkContour[];
  /** Total distance the pen travels, including loop closures. */
  readonly length: number;
  private cachedSvgPathData: string | undefined;

  constructor(ops: readonly Op[], options: InkStrokeOptions) {
    const random = new Randomizer(options.seed ?? 1);
    const width = options.width * (options.weight ?? 1);
    const coverage = clamp(options.coverage ?? 1, 0.05, 1);
    this.contours = [];
    for (const polyline of flatten(ops)) {
      const contour = InkContour.sample(polyline, width, options.pen, random, coverage);
      if (contour !== null) this.contours.push(contour);
    }
    this.length = this.contours.reduce((sum, contour) => sum + contour.length, 0);
  }

  /** The outline of the whole stroke as SVG path data, to be filled. */
  get svgPathData(): string {
    if (this.cachedSvgPathData === undefined) {
      const sink = new SvgInkOutline();
      this.writeOutline(sink);
      this.cachedSvgPathData = sink.toString();
    }
    return this.cachedSvgPathData;
  }

  /**
   * Writes the filled outline of the first [distance] the pen travels.
   * Omit [distance] for the whole stroke. A cut end is round and keeps the
   * width it had at that point, like a pen still on the paper.
   */
  writeOutline(sink: InkOutlineSink, distance = Number.POSITIVE_INFINITY): void {
    let remaining = distance;
    for (const contour of this.contours) {
      if (remaining <= 0) break;
      contour.write(sink, remaining);
      remaining -= contour.length;
    }
  }
}

class Polyline {
  constructor(
    readonly xs: number[],
    readonly ys: number[],
    readonly distances: number[],
  ) {}

  get length(): number {
    return this.distances[this.distances.length - 1] as number;
  }

  get isEmpty(): boolean {
    return this.xs.length < 2 || this.length === 0;
  }

  at(distance: number): [number, number] {
    const { xs, ys, distances } = this;
    const d = clamp(distance, 0, this.length);
    let low = 0;
    let high = distances.length - 1;
    while (high - low > 1) {
      const mid = (low + high) >> 1;
      if ((distances[mid] as number) <= d) low = mid;
      else high = mid;
    }
    const span = (distances[high] as number) - (distances[low] as number);
    const t = span === 0 ? 0 : (d - (distances[low] as number)) / span;
    return [
      (xs[low] as number) + ((xs[high] as number) - (xs[low] as number)) * t,
      (ys[low] as number) + ((ys[high] as number) - (ys[low] as number)) * t,
    ];
  }
}

class PolylineWalker {
  private segment = 0;
  x = 0;
  y = 0;

  constructor(readonly polyline: Polyline) {}

  moveTo(distance: number): void {
    const { distances, xs, ys } = this.polyline;
    const last = distances.length - 1;
    const d = clamp(distance, 0, this.polyline.length);
    if (d < (distances[this.segment] as number)) this.segment = 0;
    while (this.segment < last - 1 && (distances[this.segment + 1] as number) < d) {
      this.segment++;
    }
    const s = this.segment;
    const from = distances[s] as number;
    const span = (distances[s + 1] as number) - from;
    const t = span === 0 ? 0 : (d - from) / span;
    this.x = (xs[s] as number) + ((xs[s + 1] as number) - (xs[s] as number)) * t;
    this.y = (ys[s] as number) + ((ys[s + 1] as number) - (ys[s] as number)) * t;
  }
}

function distanceBetween(x0: number, y0: number, x1: number, y1: number): number {
  const dx = x1 - x0;
  const dy = y1 - y0;
  return Math.sqrt(dx * dx + dy * dy);
}

/** Splits [ops] into contours and flattens their curves into polylines. */
function flatten(ops: readonly Op[]): Polyline[] {
  const result: Polyline[] = [];
  let xs: number[] | null = null;
  let ys: number[] = [];
  let distances: number[] = [];

  const finish = () => {
    if (xs !== null && xs.length > 1 && (distances[distances.length - 1] as number) > 0) {
      result.push(new Polyline(xs, ys, distances));
    }
  };
  const start = (x: number, y: number) => {
    xs = [x];
    ys = [y];
    distances = [0];
  };
  const add = (px: number[], x: number, y: number) => {
    const step = distanceBetween(px[px.length - 1] as number, ys[ys.length - 1] as number, x, y);
    if (step < 1e-6) return;
    px.push(x);
    ys.push(y);
    distances.push((distances[distances.length - 1] as number) + step);
  };

  for (const op of ops) {
    const data = op.data;
    if (op.op === "move") {
      finish();
      start(data[0]!.x, data[0]!.y);
    } else if (op.op === "lineTo") {
      if (xs === null) start(data[0]!.x, data[0]!.y);
      else add(xs, data[0]!.x, data[0]!.y);
    } else {
      if (xs === null) {
        start(data[2]!.x, data[2]!.y);
        continue;
      }
      const px: number[] = xs;
      const x0 = px[px.length - 1] as number;
      const y0 = ys[ys.length - 1] as number;
      const c1 = data[0]!;
      const c2 = data[1]!;
      const end = data[2]!;
      // The control polygon bounds the curve's length. A segment every two
      // units stays within a hair of the gentle bends rough geometry makes,
      // and resampling smooths the tangents.
      const hull =
        distanceBetween(x0, y0, c1.x, c1.y) +
        distanceBetween(c1.x, c1.y, c2.x, c2.y) +
        distanceBetween(c2.x, c2.y, end.x, end.y);
      const segments = clamp(Math.ceil(hull / 2), 2, 64);
      for (let i = 1; i <= segments; i++) {
        const t = i / segments;
        const u = 1 - t;
        const a = u * u * u;
        const b = 3 * u * u * t;
        const c = 3 * u * t * t;
        const d = t * t * t;
        add(px, a * x0 + b * c1.x + c * c2.x + d * end.x, a * y0 + b * c1.y + c * c2.y + d * end.y);
      }
    }
  }
  finish();
  return result;
}

const easeOut = (t: number) => 1 - (1 - t) * (1 - t);

class InkContour {
  constructor(
    readonly xs: Float64Array,
    readonly ys: Float64Array,
    readonly nxs: Float64Array,
    readonly nys: Float64Array,
    readonly radii: Float64Array,
    readonly distances: Float64Array,
  ) {}

  get length(): number {
    return this.distances[this.distances.length - 1] as number;
  }

  static sample(
    polyline: Polyline,
    width: number,
    pen: RoughPen,
    random: Randomizer,
    coverage: number,
  ): InkContour | null {
    if (polyline.isEmpty || width <= 0) return null;
    const contourLength = polyline.length;
    const startToEnd = distanceBetween(
      polyline.xs[0] as number,
      polyline.ys[0] as number,
      polyline.xs[polyline.xs.length - 1] as number,
      polyline.ys[polyline.ys.length - 1] as number,
    );

    // A loop whose ends meet keeps going a little past its start. Its start
    // moves to a seeded point so the seam is not always at the same corner.
    const closed = contourLength > width * 4 && startToEnd < width;
    const partial = coverage < 1;
    const drawn = partial ? contourLength * coverage * (0.75 + 0.25 * random.next()) : contourLength;
    const from = closed
      ? random.next() * contourLength
      : partial
        ? random.next() * (contourLength - drawn)
        : 0;
    const closing = closed && !partial ? Math.max(0, pen.closure) * width : 0;
    const total = drawn + closing;
    // The closing tail curls inward, and less on small loops, so it never
    // reaches past the outline painters reserve room for.
    const drift =
      closing > 0
        ? Math.abs(pen.closureDrift) *
          width *
          Math.min(1, contourLength / (60 * width)) *
          inwardSign(polyline, from)
        : 0;

    const step = clamp(width * 0.8, 0.4, 3);
    const count = Math.max(1, Math.ceil(total / step));
    const taperIn = Math.min(total * 0.3, Math.max(0, pen.taperIn) * width);
    const taperOut = Math.min(total * 0.4, Math.max(0, pen.taperOut) * width);
    const startWidth = clamp(pen.startWidth, 0.05, 1);
    const endWidth = clamp(pen.endWidth, 0.05, 1);
    const pressure = clamp(pen.pressure, 0, 1);
    const wavelength = Math.max(1, pen.pressureWavelength);
    const phase1 = random.next() * Math.PI * 2;
    const phase2 = random.next() * Math.PI * 2;

    // Positions first, in one forward walk along the polyline.
    const xs = new Float64Array(count + 1);
    const ys = new Float64Array(count + 1);
    const distances = new Float64Array(count + 1);
    const walker = new PolylineWalker(polyline);
    for (let i = 0; i <= count; i++) {
      const travelled = (total * i) / count;
      let at = from + travelled;
      if (closed) at = dartModulo(at, contourLength);
      walker.moveTo(at);
      xs[i] = walker.x;
      ys[i] = walker.y;
      distances[i] = travelled;
    }

    // Tangents from neighbouring samples smooth the flattening without
    // rounding off real corners. Widths come from the pen.
    const nxs = new Float64Array(count + 1);
    const nys = new Float64Array(count + 1);
    const radii = new Float64Array(count + 1);
    let tx = 1;
    let ty = 0;
    for (let i = 0; i <= count; i++) {
      const before = i === 0 ? 0 : i - 1;
      const after = i === count ? count : i + 1;
      const dx = (xs[after] as number) - (xs[before] as number);
      const dy = (ys[after] as number) - (ys[before] as number);
      const tangentLength = Math.sqrt(dx * dx + dy * dy);
      if (tangentLength > 1e-9) {
        tx = dx / tangentLength;
        ty = dy / tangentLength;
      }
      nxs[i] = -ty;
      nys[i] = tx;

      const travelled = distances[i] as number;
      let factor = 1;
      if (taperIn > 0 && travelled < taperIn) {
        factor *= startWidth + (1 - startWidth) * easeOut(travelled / taperIn);
      }
      const toEnd = total - travelled;
      if (taperOut > 0 && toEnd < taperOut) {
        factor *= endWidth + (1 - endWidth) * easeOut(toEnd / taperOut);
      }
      if (pressure > 0) {
        const cycle = (travelled / wavelength) * Math.PI * 2;
        factor *= 1 + pressure * (0.65 * Math.sin(cycle + phase1) + 0.35 * Math.sin(cycle * 2.7 + phase2));
      }
      radii[i] = Math.max(0.1, factor * width) / 2;
    }

    // The closing stretch eases off the line it is retracing.
    if (closing > 0) {
      for (let i = 0; i <= count; i++) {
        const travelled = distances[i] as number;
        if (travelled <= drawn) continue;
        const off = drift * easeOut((travelled - drawn) / closing);
        xs[i] = (xs[i] as number) + (nxs[i] as number) * off;
        ys[i] = (ys[i] as number) + (nys[i] as number) * off;
      }
    }
    return new InkContour(xs, ys, nxs, nys, radii, distances);
  }

  /** Writes the outline of this contour, cut at [distance] when shorter. */
  write(sink: InkOutlineSink, distance: number): void {
    const { xs, ys, nxs, nys, radii, distances } = this;
    let last = xs.length - 1;
    let cut = 1;
    if (distance < this.length) {
      last = 1;
      while (last < distances.length - 1 && (distances[last] as number) < distance) last++;
      const span = (distances[last] as number) - (distances[last - 1] as number);
      cut = span === 0 ? 1 : (distance - (distances[last - 1] as number)) / span;
    }

    const value = (values: Float64Array, i: number) =>
      i === last
        ? (values[i - 1] as number) + ((values[i] as number) - (values[i - 1] as number)) * cut
        : (values[i] as number);

    const leftX: number[] = [];
    const leftY: number[] = [];
    const rightX: number[] = [];
    const rightY: number[] = [];
    let previousNx = nxs[0] as number;
    let previousNy = nys[0] as number;
    for (let i = 0; i <= last; i++) {
      const x = value(xs, i);
      const y = value(ys, i);
      const nx = value(nxs, i);
      const ny = value(nys, i);
      const r = value(radii, i);
      // A sharp turn between samples leaves a notch on its outer side. Sweep
      // that side around the corner so the joint stays round.
      const dot = previousNx * nx + previousNy * ny;
      if (i > 0 && dot < 0.82) {
        const angle = Math.atan2(previousNx * ny - previousNy * nx, dot);
        const steps = Math.ceil(Math.abs(angle) / 0.35);
        const outerX = angle > 0 ? rightX : leftX;
        const outerY = angle > 0 ? rightY : leftY;
        const sign = angle > 0 ? -1 : 1;
        const base = Math.atan2(previousNy, previousNx);
        for (let s = 1; s < steps; s++) {
          const a = base + (angle * s) / steps;
          outerX.push(x + sign * Math.cos(a) * r);
          outerY.push(y + sign * Math.sin(a) * r);
        }
      }
      leftX.push(x + nx * r);
      leftY.push(y + ny * r);
      rightX.push(x - nx * r);
      rightY.push(y - ny * r);
      previousNx = nx;
      previousNy = ny;
    }

    sink.moveTo(leftX[0] as number, leftY[0] as number);
    smooth(sink, leftX, leftY, false);
    cap(sink, value(xs, last), value(ys, last), value(nxs, last), value(nys, last), value(radii, last), true);
    smooth(sink, rightX, rightY, true);
    cap(sink, xs[0] as number, ys[0] as number, nxs[0] as number, nys[0] as number, radii[0] as number, false);
    sink.close();
  }
}

/** Dart's `%` on doubles: the result takes the divisor's sign. */
function dartModulo(a: number, b: number): number {
  const r = a % b;
  return r < 0 ? r + Math.abs(b) : r;
}

/** +1 when the normal at [distance] points into the loop, otherwise -1. */
function inwardSign(polyline: Polyline, distance: number): number {
  let cx = 0;
  let cy = 0;
  for (let i = 0; i < polyline.xs.length; i++) {
    cx += polyline.xs[i] as number;
    cy += polyline.ys[i] as number;
  }
  cx /= polyline.xs.length;
  cy /= polyline.xs.length;
  const [x, y] = polyline.at(distance);
  const [ax, ay] = polyline.at(Math.min(distance + 1, polyline.length));
  const [bx, by] = polyline.at(Math.max(distance - 1, 0));
  const nx = -(ay - by);
  const ny = ax - bx;
  return nx * (cx - x) + ny * (cy - y) >= 0 ? 1 : -1;
}

/**
 * Draws through the midpoints of [xs]/[ys] with each point as a control,
 * which keeps the edge smooth between samples.
 */
function smooth(sink: InkOutlineSink, xs: number[], ys: number[], reversed: boolean): void {
  const n = xs.length;
  const at = (i: number) => (reversed ? n - 1 - i : i);
  sink.lineTo(xs[at(0)] as number, ys[at(0)] as number);
  for (let i = 1; i < n - 1; i++) {
    const here = at(i);
    const next = at(i + 1);
    sink.quadraticTo(
      xs[here] as number,
      ys[here] as number,
      ((xs[here] as number) + (xs[next] as number)) / 2,
      ((ys[here] as number) + (ys[next] as number)) / 2,
    );
  }
  sink.lineTo(xs[at(n - 1)] as number, ys[at(n - 1)] as number);
}

/**
 * A half circle from one side of the stroke to the other, bulging along the
 * direction of travel at the end and against it at the start.
 */
function cap(
  sink: InkOutlineSink,
  x: number,
  y: number,
  nx: number,
  ny: number,
  radius: number,
  forward: boolean,
): void {
  const fx = forward ? nx : -nx;
  const fy = forward ? ny : -ny;
  const ax = forward ? ny : -ny;
  const ay = forward ? -nx : nx;
  const steps = 6;
  for (let i = 1; i <= steps; i++) {
    const angle = (Math.PI * i) / steps;
    const c = Math.cos(angle);
    const s = Math.sin(angle);
    sink.lineTo(x + (fx * c + ax * s) * radius, y + (fy * c + ay * s) * radius);
  }
}

/** One SVG `<path>` of exported ink. */
export interface InkSvgPath {
  /** Which part of the drawing this path came from. */
  readonly type: OpSetType;
  /** The SVG `d` attribute. */
  readonly data: string;
  /** Whether {@link data} is filled; otherwise it is stroked. */
  readonly filled: boolean;
  /** The stroke width when not filled; zero for fills. */
  readonly strokeWidth: number;
}

/** The prepared ink for one op set. */
export class DrawableInkSet {
  constructor(
    /** Which part of the drawing this set is. */
    readonly type: OpSetType,
    /** The rough centreline or fill polygon. */
    readonly ops: readonly Op[],
    /** The pen width for this set. */
    readonly width: number,
    /**
     * Pen strokes, one per contour, or null when the set keeps a plain
     * centreline (uniform pens, solid fills, or ink turned off).
     */
    readonly strokes: readonly InkStroke[] | null,
  ) {}

  /** This set as SVG paths. */
  svgPaths(): InkSvgPath[] {
    if (this.strokes !== null) {
      return this.strokes.map((stroke) => ({
        type: this.type,
        data: stroke.svgPathData,
        filled: true,
        strokeWidth: 0,
      }));
    }
    if (this.ops.length === 0) return [];
    let data = "";
    for (const op of this.ops) {
      data += op.op === "move" ? "M" : op.op === "lineTo" ? "L" : "C";
      data += op.data.map((p) => `${dartDoubleToString(p.x)} ${dartDoubleToString(p.y)}`).join(" ");
      data += " ";
    }
    const fill = this.type === "fillPath";
    return [
      {
        type: this.type,
        data: `${data.trimEnd()}${fill ? " Z" : ""}`,
        filled: fill,
        strokeWidth: fill ? 0 : this.width,
      },
    ];
  }
}

/** Options for {@link DrawableInk}. */
export interface DrawableInkOptions {
  /** Pen width for outlines. */
  outlineWidth: number;
  /** Pen width for sketched fills. */
  sketchWidth: number;
  /** Ink outlines with the pen. Defaults to true. */
  inkOutline?: boolean;
  /** Ink sketched fills with the pen. Defaults to true. */
  inkSketch?: boolean;
  /**
   * Ink every part as a filled outline even when the pen is uniform, which
   * would otherwise keep a cheaper plain centreline.
   */
  inkUniform?: boolean;
}

/**
 * The ink a {@link Drawable} lays down, prepared once.
 *
 * Splits each op set into contours and gives every contour an
 * {@link InkStroke} from the drawable's {@link RoughPen}, with repeat passes
 * lighter and partial. Matches `DrawableInk` in Dart, so exported ink is the
 * ink skribble paints.
 */
export class DrawableInk {
  /** One entry per op set, in the drawable's order. */
  readonly sets: readonly DrawableInkSet[];

  constructor(drawable: Drawable, options: DrawableInkOptions) {
    const { outlineWidth, sketchWidth, inkOutline = true, inkSketch = true, inkUniform = false } = options;
    const pen = drawable.options?.pen ?? RoughPen.uniform;
    const seed = drawable.options?.seed ?? 1;
    let index = 0;
    const strokeSeed = () =>
      typeof seed === "bigint" ? seed * 7919n + BigInt(index++) : seed * 7919 + index++;
    this.sets = drawable.sets.map((set) => {
      const width = set.type === "path" ? outlineWidth : sketchWidth;
      const wanted = set.type === "path" ? inkOutline : set.type === "fillSketch" ? inkSketch : false;
      const inked = (inkUniform || !pen.isUniform) && width > 0 && wanted;
      return new DrawableInkSet(
        set.type,
        set.ops,
        width,
        inked
          ? splitContours(set.ops).map(
              ([contour, pass]) =>
                new InkStroke(contour, {
                  width,
                  pen,
                  seed: strokeSeed(),
                  weight: pass === 0 ? 1 : pen.repeatWidth,
                  coverage: pass === 0 ? 1 : pen.repeatCoverage,
                }),
            )
          : null,
      );
    });
  }

  /** The ink as SVG paths, in paint order: solid fills, sketched fills, outlines. */
  svgPaths(): InkSvgPath[] {
    const order: OpSetType[] = ["fillPath", "fillSketch", "path"];
    return order.flatMap((type) => this.sets.filter((set) => set.type === type).flatMap((set) => set.svgPaths()));
  }
}

/** Splits operations into contours, with the pass that drew each. */
function splitContours(ops: readonly Op[]): [Op[], number][] {
  const result: [Op[], number][] = [];
  let current: Op[] | null = null;
  let pass = 0;
  for (const op of ops) {
    if (op.op === "move") {
      if (current !== null) result.push([current, pass]);
      current = [];
      pass = op.pass;
    }
    (current ??= []).push(op);
  }
  if (current !== null) result.push([current, pass]);
  return result;
}
