import { formatNumber } from "./math.js";
import type { Drawable, OpSet } from "./types.js";

const number = (value: number) => formatNumber(value, 2);

/**
 * Converts the operations in [set] into SVG path data (the `d` attribute).
 *
 * Moves become `M`, straight segments `L`, and cubic segments `C`. A solid
 * fill (`fillPath`) is closed with `Z`. Coordinates keep two decimals, so the
 * same set always produces the same string and server-rendered markup stays
 * byte-stable. Returns an empty string when [set] has no operations.
 */
export function opSetToSvgPath(set: OpSet): string {
  if (set.ops.length === 0) return "";
  let data = "";
  for (const op of set.ops) {
    data += op.op === "move" ? "M" : op.op === "lineTo" ? "L" : "C";
    data += op.data.map((p) => `${number(p.x)} ${number(p.y)}`).join(" ");
  }
  if (set.type === "fillPath") data += "Z";
  return data;
}

/**
 * A drawable's path data, split the way skribble paints it: `outline`
 * (stroked with the ink colour), `sketch` (sketched fills, stroked with the
 * fill colour), and `solid` (filled with the fill colour). Each group joins
 * all of its op sets, so a shape costs at most three SVG elements.
 *
 * These are plain centrelines, independent of the drawable's pen. They suit
 * scalable output that stretches with its element. Use {@link DrawableInk}
 * when exported ink must keep the pen's tapered widths.
 */
export interface RoughSvgPaths {
  readonly outline: string;
  readonly sketch: string;
  readonly solid: string;
}

/** Splits [drawable]'s op sets into outline, sketch, and solid path data. */
export function toSvgPaths(drawable: Drawable): RoughSvgPaths {
  let outline = "";
  let sketch = "";
  let solid = "";
  for (const set of drawable.sets) {
    const data = opSetToSvgPath(set);
    if (set.type === "path") outline += data;
    else if (set.type === "fillSketch") sketch += data;
    else solid += data;
  }
  return { outline, sketch, solid };
}

/** Options for {@link toPathElements}. */
export interface PathElementOptions {
  /** Outline colour, as any SVG paint. Defaults to `currentColor`. */
  stroke?: string;
  /** Colour of both fill groups, as any SVG paint. Defaults to `currentColor`. */
  fill?: string;
  /** Outline width. Defaults to 1.5. */
  strokeWidth?: number;
  /** Width of sketched fill lines. Defaults to 1. */
  sketchWidth?: number;
  /** Keep strokes at their width when the surrounding SVG stretches. */
  nonScalingStroke?: boolean;
}

/**
 * Renders the non-empty groups of [paths] as SVG `<path>` elements in paint
 * order: solid fill, sketched fill, then outline. Colours are
 * attribute-escaped. Byte-identical to `RoughSvg.toPathElements` in Dart.
 */
export function toPathElements(paths: RoughSvgPaths, options: PathElementOptions = {}): string {
  assertSafePathData(paths.solid);
  assertSafePathData(paths.sketch);
  assertSafePathData(paths.outline);
  const effect = options.nonScalingStroke ? ' vector-effect="non-scaling-stroke"' : "";
  const ink = escapeAttribute(options.stroke ?? "currentColor");
  const paint = escapeAttribute(options.fill ?? "currentColor");
  let elements = "";
  if (paths.solid) {
    elements += `<path d="${paths.solid}" fill="${paint}" stroke="none"/>`;
  }
  if (paths.sketch) {
    elements +=
      `<path d="${paths.sketch}" fill="none" stroke="${paint}" ` +
      `stroke-width="${number(options.sketchWidth ?? 1)}" stroke-linecap="round" ` +
      `stroke-linejoin="round"${effect}/>`;
  }
  if (paths.outline) {
    elements +=
      `<path d="${paths.outline}" fill="none" stroke="${ink}" ` +
      `stroke-width="${number(options.strokeWidth ?? 1.5)}" stroke-linecap="round" ` +
      `stroke-linejoin="round"${effect}/>`;
  }
  return elements;
}

/** Escapes [value] for use inside a double-quoted XML attribute. */
export function escapeAttribute(value: string): string {
  return value.replace(/&/g, "&amp;").replace(/"/g, "&quot;").replace(/</g, "&lt;").replace(/>/g, "&gt;");
}

/**
 * The characters this engine's path data is built from: the commands it emits
 * (`M`, `L`, `C`, `Q`, `Z`) and numeric coordinates in any casing or format.
 */
const pathDataPattern = /^[MLCQZmlcqz\s0-9.,eE+-]*$/;

/**
 * Rejects path data this engine could not have generated.
 *
 * Path data is interpolated into `d` attributes unescaped, which is safe only
 * while it stays engine-built numbers. Callers that assemble
 * {@link RoughSvgPaths} or {@link SketchPath} themselves go through this
 * check, so a stray `<` or quote can never reach an SVG document as markup.
 */
export function assertSafePathData(data: string): void {
  if (!pathDataPattern.test(data)) {
    throw new Error("Path data contains characters beyond SVG commands and numbers");
  }
}
