import { DrawableInk, canvasInkSink, type CanvasPathLike } from "./ink.js";
import { RoughPen } from "./pen.js";
import type { SketchStyle } from "./sketch.js";
import type { Drawable, OpSet } from "./types.js";

/**
 * The subset of `CanvasRenderingContext2D` the canvas renderer uses. Browser
 * canvases, `OffscreenCanvas`, and Node canvas libraries all provide it.
 */
export interface CanvasContextLike extends CanvasPathLike {
  beginPath(): void;
  bezierCurveTo(cp1x: number, cp1y: number, cp2x: number, cp2y: number, x: number, y: number): void;
  stroke(): void;
  fill(): void;
  save(): void;
  restore(): void;
  strokeStyle: unknown;
  fillStyle: unknown;
  lineWidth: number;
  lineCap: string;
  lineJoin: string;
}

function tracePath(ctx: CanvasContextLike, set: OpSet): void {
  for (const op of set.ops) {
    const [a, b, c] = op.data;
    if (op.op === "move") ctx.moveTo(a!.x, a!.y);
    else if (op.op === "lineTo") ctx.lineTo(a!.x, a!.y);
    else ctx.bezierCurveTo(a!.x, a!.y, b!.x, b!.y, c!.x, c!.y);
  }
  if (set.type === "fillPath") ctx.closePath();
}

/** The colour a canvas should use for a paint value. */
function paint(ctx: CanvasContextLike, value: string): unknown {
  if (value !== "currentColor") return value;
  // Canvas has no currentColor; use the canvas element's computed colour.
  const canvas = (ctx as { canvas?: unknown }).canvas;
  const getComputedStyle = (globalThis as { getComputedStyle?: (el: unknown) => { color: string } }).getComputedStyle;
  if (canvas && typeof getComputedStyle === "function") {
    try {
      return getComputedStyle(canvas).color || "#000";
    } catch {
      return "#000";
    }
  }
  return "#000";
}

/**
 * Paints [drawable] on a 2D canvas context in paint order: solid fill,
 * sketched fill, then outline. With `style.ink` and a non-uniform pen,
 * outlines and sketched fills are filled pen shapes; otherwise they are
 * stroked centrelines.
 */
export function drawOnCanvas(ctx: CanvasContextLike, drawable: Drawable, style: SketchStyle): void {
  const pen = drawable.options?.pen ?? RoughPen.uniform;
  const inked = style.ink && !pen.isUniform;
  const ink = inked
    ? new DrawableInk(drawable, { outlineWidth: style.strokeWidth, sketchWidth: style.sketchWidth })
    : null;
  ctx.save();
  ctx.lineCap = "round";
  ctx.lineJoin = "round";
  for (const type of ["fillPath", "fillSketch", "path"] as const) {
    const color = paint(ctx, type === "path" ? style.stroke : style.fill);
    const width = type === "path" ? style.strokeWidth : style.sketchWidth;
    drawable.sets.forEach((set, index) => {
      if (set.type !== type || set.ops.length === 0) return;
      if (type === "fillPath") {
        ctx.beginPath();
        tracePath(ctx, set);
        ctx.fillStyle = color;
        ctx.fill();
        return;
      }
      const strokes = ink?.sets[index]?.strokes;
      if (strokes) {
        ctx.fillStyle = color;
        const sink = canvasInkSink(ctx);
        for (const stroke of strokes) {
          ctx.beginPath();
          stroke.writeOutline(sink);
          ctx.fill();
        }
        return;
      }
      if (width <= 0) return;
      ctx.beginPath();
      tracePath(ctx, set);
      ctx.strokeStyle = color;
      ctx.lineWidth = width;
      ctx.stroke();
    });
  }
  ctx.restore();
}
