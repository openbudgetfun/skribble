import { DrawConfig, type DrawConfigOptions } from "./config.js";
import { FillerConfig, createFiller, type RoughFillStyle } from "./filler.js";
import { Generator } from "./generator.js";
import { DrawableInk } from "./ink.js";
import { formatNumber } from "./math.js";
import { RoughPen, resolvePen, type RoughPenName, type RoughPenOptions } from "./pen.js";
import { escapeAttribute, opSetToSvgPath, toSvgPaths } from "./svg.js";
import type { Drawable, Point } from "./types.js";

/** A point as `[x, y]` or `{ x, y }`. */
export type PointLike = readonly [number, number] | Point;

/** A shape to sketch, described as data so every framework can share it. */
export type Shape =
  | { readonly type: "rectangle"; readonly x: number; readonly y: number; readonly width: number; readonly height: number }
  | {
      readonly type: "roundedRectangle";
      readonly x: number;
      readonly y: number;
      readonly width: number;
      readonly height: number;
      /** One radius for every corner, or `[topLeft, topRight, bottomRight, bottomLeft]`. */
      readonly radius: number | readonly [number, number, number, number];
    }
  | {
      readonly type: "ellipse";
      /** Centre. */
      readonly x: number;
      readonly y: number;
      readonly width: number;
      readonly height: number;
    }
  | { readonly type: "circle"; readonly x: number; readonly y: number; readonly diameter: number }
  | {
      readonly type: "line";
      readonly x1: number;
      readonly y1: number;
      readonly x2: number;
      readonly y2: number;
      /** Ends the line in two short barbs. */
      readonly arrowhead?: boolean;
    }
  | {
      readonly type: "linearPath";
      readonly points: readonly PointLike[];
      /** Joins the last point back to the first. Defaults to `false`. */
      readonly closed?: boolean;
    }
  | { readonly type: "polygon"; readonly points: readonly PointLike[] }
  | {
      readonly type: "arc";
      /** Centre. */
      readonly x: number;
      readonly y: number;
      readonly width: number;
      readonly height: number;
      /** Start angle in radians. */
      readonly start: number;
      /** Stop angle in radians. */
      readonly stop: number;
      /** Draws a pie slice back to the centre. */
      readonly closed?: boolean;
    }
  | {
      readonly type: "curve";
      /** At least two points. */
      readonly points: readonly PointLike[];
      /** Ends the curve in two short barbs that follow its last segment. */
      readonly arrowhead?: boolean;
    };

/** How a sketch is drawn and painted. Every field is optional. */
export interface SketchOptions extends Omit<DrawConfigOptions, "pen"> {
  /**
   * How ink leaves the pen: a preset name, a {@link RoughPen}, or pen
   * options. Defaults to `"ink"`. Use `"uniform"` for constant-width
   * strokes like rough.js.
   */
  pen?: RoughPen | RoughPenName | RoughPenOptions;
  /**
   * The fill pattern for closed shapes. Defaults to `"hachure"` when `fill`
   * is set, like rough.js, and to `"none"` otherwise.
   */
  fillStyle?: RoughFillStyle;
  /** Fill colour for closed shapes. Defaults to `currentColor`. */
  fill?: string;
  /** Ink colour. Defaults to `currentColor`. */
  stroke?: string;
  /** Outline width. Defaults to 1.5. */
  strokeWidth?: number;
  /** Width of sketched fill lines. Defaults to 1. */
  sketchWidth?: number;
  /** Diameter of dots and wander of solid fill corners. Defaults to 1. */
  fillWeight?: number;
  /** Angle of hachure lines, in degrees. Defaults to 320. */
  hachureAngle?: number;
  /** Distance between hachure lines. Defaults to 8. */
  hachureGap?: number;
  /** Length of each dash in a dashed fill. Defaults to 15. */
  dashOffset?: number;
  /** Gap between dashes in a dashed fill. Defaults to 2. */
  dashGap?: number;
  /** Offset of zig-zag turns. Defaults to 5. */
  zigzagOffset?: number;
  /**
   * Paint outlines and sketched fills as pen-shaped ink (filled outlines
   * with tapered ends) instead of constant-width strokes. Defaults to
   * `true`; uniform pens always use plain strokes. Turn it off for drawings
   * that stretch with their container.
   */
  ink?: boolean;
}

/** The paint for one element of a sketch. */
export interface SketchPath {
  /** A key that is stable for the same drawable, for framework lists. */
  readonly key: string;
  /** Which part of the drawing this path belongs to. */
  readonly part: "outline" | "sketch" | "solid";
  /** SVG path data. */
  readonly d: string;
  /** Fill paint, or `"none"`. */
  readonly fill: string;
  /** Stroke paint, or `"none"`. */
  readonly stroke: string;
  /** Stroke width; zero when the path is filled. */
  readonly strokeWidth: number;
}

/** The resolved paint settings of a sketch. */
export interface SketchStyle {
  readonly stroke: string;
  readonly fill: string;
  readonly strokeWidth: number;
  readonly sketchWidth: number;
  readonly ink: boolean;
}

/** A drawn sketch: the rough geometry and the paths that paint it. */
export interface Sketch {
  readonly drawable: Drawable;
  readonly style: SketchStyle;
  readonly paths: readonly SketchPath[];
}

/** Converts a {@link PointLike} to a {@link Point}. */
export function toPoint(p: PointLike): Point {
  return Array.isArray(p) ? { x: p[0] as number, y: p[1] as number } : (p as Point);
}

/** The {@link DrawConfig} values in [options]. */
export function drawConfigOptions(options: SketchOptions): DrawConfigOptions {
  return {
    maxRandomnessOffset: options.maxRandomnessOffset,
    roughness: options.roughness,
    bowing: options.bowing,
    lineWobble: options.lineWobble,
    curveFitting: options.curveFitting,
    curveTightness: options.curveTightness,
    curveStepCount: options.curveStepCount,
    seed: options.seed,
    pen: resolvePen(options.pen),
  };
}

/**
 * Creates a generator whose outline and fill both replay from the seed.
 * The fill gets its own configuration so the two never share a stream.
 */
export function createGenerator(options: SketchOptions = {}): Generator {
  const draw = drawConfigOptions(options);
  return new Generator(
    DrawConfig.build(draw),
    createFiller(
      options.fillStyle ?? (options.fill === undefined ? "none" : "hachure"),
      FillerConfig.build({
        drawConfig: DrawConfig.build(draw),
        fillWeight: options.fillWeight,
        hachureAngle: options.hachureAngle,
        hachureGap: options.hachureGap ?? 8,
        dashOffset: options.dashOffset,
        dashGap: options.dashGap,
        zigzagOffset: options.zigzagOffset,
      }),
    ),
  );
}

/** Draws [shape] with [generator]. */
export function drawShape(generator: Generator, shape: Shape): Drawable {
  switch (shape.type) {
    case "rectangle":
      return generator.rectangle(shape.x, shape.y, shape.width, shape.height);
    case "roundedRectangle": {
      const [tl, tr, br, bl] =
        typeof shape.radius === "number" ? [shape.radius, shape.radius, shape.radius, shape.radius] : shape.radius;
      return generator.roundedRectangle(shape.x, shape.y, shape.width, shape.height, tl, tr, br, bl);
    }
    case "ellipse":
      return generator.ellipse(shape.x, shape.y, shape.width, shape.height);
    case "circle":
      return generator.circle(shape.x, shape.y, shape.diameter);
    case "line": {
      const line = generator.line(shape.x1, shape.y1, shape.x2, shape.y2);
      return shape.arrowhead
        ? withArrowhead(generator, line, { x: shape.x1, y: shape.y1 }, { x: shape.x2, y: shape.y2 })
        : line;
    }
    case "linearPath":
      return generator.linearPath(shape.points.map(toPoint), shape.closed ?? false);
    case "polygon":
      return generator.polygon(shape.points.map(toPoint));
    case "arc":
      return generator.arc(shape.x, shape.y, shape.width, shape.height, shape.start, shape.stop, shape.closed ?? false);
    case "curve": {
      if (shape.points.length < 2) throw new RangeError("A curve needs at least two points");
      const points = shape.points.map(toPoint);
      const curve = generator.curvePath(points);
      return shape.arrowhead
        ? withArrowhead(generator, curve, points[points.length - 2] as Point, points[points.length - 1] as Point)
        : curve;
    }
    default:
      throw new RangeError(`Unknown shape type "${(shape as { type: string }).type}"`);
  }
}

/** Adds two short barbs at [tip], angled back along the [from] direction. */
export function withArrowhead(generator: Generator, shaft: Drawable, from: Point, tip: Point): Drawable {
  const spread = Math.PI / 7;
  const angle = Math.atan2(tip.y - from.y, tip.x - from.x);
  const dx = tip.x - from.x;
  const dy = tip.y - from.y;
  const length = Math.min(14, Math.sqrt(dx * dx + dy * dy) * 0.6);
  const barbs = [-spread, spread].map((side) =>
    generator.line(tip.x, tip.y, tip.x - length * Math.cos(angle + side), tip.y - length * Math.sin(angle + side)),
  );
  return { ...shaft, sets: [...shaft.sets, ...barbs.flatMap((barb) => barb.sets)] };
}

/** Resolves the paint settings in [options]. */
export function resolveStyle(options: SketchOptions = {}): SketchStyle {
  return {
    stroke: options.stroke ?? "currentColor",
    fill: options.fill ?? "currentColor",
    strokeWidth: options.strokeWidth ?? 1.5,
    sketchWidth: options.sketchWidth ?? 1,
    ink: options.ink ?? true,
  };
}

/**
 * The paths that paint [drawable], in paint order: solid fill, sketched fill,
 * then outline.
 */
export function drawablePaths(drawable: Drawable, style: SketchStyle): SketchPath[] {
  const pen = drawable.options?.pen ?? RoughPen.uniform;
  const paths: SketchPath[] = [];
  if (!style.ink || pen.isUniform) {
    const groups = toSvgPaths(drawable);
    if (groups.solid) {
      paths.push({ key: "solid", part: "solid", d: groups.solid, fill: style.fill, stroke: "none", strokeWidth: 0 });
    }
    if (groups.sketch) {
      paths.push({
        key: "sketch",
        part: "sketch",
        d: groups.sketch,
        fill: "none",
        stroke: style.fill,
        strokeWidth: style.sketchWidth,
      });
    }
    if (groups.outline) {
      paths.push({
        key: "outline",
        part: "outline",
        d: groups.outline,
        fill: "none",
        stroke: style.stroke,
        strokeWidth: style.strokeWidth,
      });
    }
    return paths;
  }

  const solid = drawable.sets
    .filter((set) => set.type === "fillPath")
    .map(opSetToSvgPath)
    .join("");
  if (solid) paths.push({ key: "solid", part: "solid", d: solid, fill: style.fill, stroke: "none", strokeWidth: 0 });
  const ink = new DrawableInk(drawable, { outlineWidth: style.strokeWidth, sketchWidth: style.sketchWidth });
  let index = 0;
  for (const path of ink.svgPaths()) {
    if (path.type === "fillPath" || !path.data) continue;
    const part = path.type === "path" ? "outline" : "sketch";
    const color = part === "outline" ? style.stroke : style.fill;
    paths.push(
      path.filled
        ? { key: `${part}-${index++}`, part, d: path.data, fill: color, stroke: "none", strokeWidth: 0 }
        : { key: `${part}-${index++}`, part, d: path.data, fill: "none", stroke: color, strokeWidth: path.strokeWidth },
    );
  }
  return paths;
}

/**
 * Sketches one shape, or several drawn in order from one random stream.
 *
 * ```ts
 * const { paths } = sketch({ type: "rectangle", x: 4, y: 4, width: 192, height: 92 }, { seed: 7 });
 * ```
 */
export function sketch(shapes: Shape | readonly Shape[], options: SketchOptions = {}): Sketch {
  const generator = createGenerator(options);
  const list: readonly Shape[] = Array.isArray(shapes) ? shapes : [shapes as Shape];
  const drawables = list.map((shape) => drawShape(generator, shape));
  const drawable: Drawable =
    drawables.length === 1
      ? (drawables[0] as Drawable)
      : { shape: "group", options: generator.drawConfig, sets: drawables.flatMap((d) => d.sets) };
  const style = resolveStyle(options);
  return { drawable, style, paths: drawablePaths(drawable, style) };
}

/** Options for {@link toSvgString}. */
export interface SvgStringOptions {
  /** Intrinsic width and `viewBox` width. */
  width: number;
  /** Intrinsic height and `viewBox` height. */
  height: number;
  /** An accessible description; without one the SVG is decorative. */
  label?: string;
  /** A `class` attribute for the `<svg>`. */
  className?: string;
}

/** Renders [paths] as `<path>` elements. */
export function pathsToSvgElements(paths: readonly SketchPath[]): string {
  return paths
    .map((path) => {
      const stroke =
        path.stroke === "none"
          ? ' stroke="none"'
          : ` stroke="${escapeAttribute(path.stroke)}" stroke-width="${formatNumber(path.strokeWidth, 2)}" stroke-linecap="round" stroke-linejoin="round"`;
      return `<path d="${path.d}" fill="${escapeAttribute(path.fill)}"${stroke}/>`;
    })
    .join("");
}

/** Renders a sketch as a standalone `<svg>` document fragment. */
export function toSvgString(value: Sketch, options: SvgStringOptions): string {
  const width = formatNumber(options.width, 2);
  const height = formatNumber(options.height, 2);
  const a11y =
    options.label === undefined
      ? ' aria-hidden="true" focusable="false"'
      : ` role="img" aria-label="${escapeAttribute(options.label)}"`;
  const className = options.className === undefined ? "" : ` class="${escapeAttribute(options.className)}"`;
  return (
    `<svg xmlns="http://www.w3.org/2000/svg" width="${width}" height="${height}" viewBox="0 0 ${width} ${height}"${className}${a11y}>` +
    pathsToSvgElements(value.paths) +
    "</svg>"
  );
}

/** Every key of {@link SketchOptions}, for frameworks that take them as props. */
export const sketchOptionKeys = [
  "maxRandomnessOffset",
  "roughness",
  "bowing",
  "lineWobble",
  "curveFitting",
  "curveTightness",
  "curveStepCount",
  "seed",
  "pen",
  "fillStyle",
  "fill",
  "stroke",
  "strokeWidth",
  "sketchWidth",
  "fillWeight",
  "hachureAngle",
  "hachureGap",
  "dashOffset",
  "dashGap",
  "zigzagOffset",
  "ink",
] as const satisfies readonly (keyof SketchOptions)[];

/**
 * Splits [props] into sketch options and everything else, so components can
 * pass the rest through to their root element.
 */
export function splitSketchOptions<T extends object>(
  props: T,
): [SketchOptions, Omit<T, (typeof sketchOptionKeys)[number]>] {
  const options: Record<string, unknown> = {};
  const rest: Record<string, unknown> = {};
  const keys = new Set<string>(sketchOptionKeys);
  for (const [key, value] of Object.entries(props)) {
    if (keys.has(key)) {
      if (value !== undefined) options[key] = value;
    } else {
      rest[key] = value;
    }
  }
  return [options as SketchOptions, rest as Omit<T, (typeof sketchOptionKeys)[number]>];
}

/**
 * A string that changes whenever [shape] or [options] would draw something
 * different. Frameworks use it to memoise {@link sketch}.
 */
export function sketchKey(shape: Shape | readonly Shape[], options: SketchOptions = {}): string {
  return JSON.stringify([shape, options], (_key, value: unknown) =>
    typeof value === "bigint" ? `${value}n` : value instanceof RoughPen ? value.toJSON() : value,
  );
}
