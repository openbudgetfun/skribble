import { drawOnCanvas, type CanvasContextLike } from "./canvas.js";
import { createSvgGroup, type DocumentLike } from "./dom.js";
import { stripUndefined } from "./pen.js";
import {
  drawablePaths,
  sketch,
  type PointLike,
  type Shape,
  type SketchOptions,
  type SketchPath,
  type SketchStyle,
} from "./sketch.js";
import type { Drawable } from "./types.js";

/** A drawable that remembers how to paint itself. */
export interface RoughDrawable extends Drawable {
  readonly style: SketchStyle;
}

/** Configuration for the rough.js-style entry points. */
export interface RoughConfig {
  /** Defaults applied to every shape. */
  options?: SketchOptions;
}

/**
 * Generates drawables without painting them, like rough.js's generator.
 *
 * Shapes without a `seed` take consecutive seeds starting at 1, so every
 * shape wobbles differently and a page still draws the same way on every
 * load (and on the server).
 */
export class RoughGenerator {
  readonly defaults: SketchOptions;
  private nextSeed = 1;

  constructor(config: RoughConfig = {}) {
    this.defaults = config.options ?? {};
  }

  /** Draws [shape] with the defaults and [options]. */
  draw(shape: Shape, options: SketchOptions = {}): RoughDrawable {
    const merged: SketchOptions = { ...this.defaults, ...stripUndefined(options) };
    if (merged.seed === undefined) merged.seed = this.nextSeed++;
    const result = sketch(shape, merged);
    return { ...result.drawable, style: result.style };
  }

  line(x1: number, y1: number, x2: number, y2: number, options?: SketchOptions): RoughDrawable {
    return this.draw({ type: "line", x1, y1, x2, y2 }, options);
  }

  rectangle(x: number, y: number, width: number, height: number, options?: SketchOptions): RoughDrawable {
    return this.draw({ type: "rectangle", x, y, width, height }, options);
  }

  roundedRectangle(
    x: number,
    y: number,
    width: number,
    height: number,
    radius: number | readonly [number, number, number, number],
    options?: SketchOptions,
  ): RoughDrawable {
    return this.draw({ type: "roundedRectangle", x, y, width, height, radius }, options);
  }

  /** An ellipse centred on ([x], [y]). */
  ellipse(x: number, y: number, width: number, height: number, options?: SketchOptions): RoughDrawable {
    return this.draw({ type: "ellipse", x, y, width, height }, options);
  }

  /** A circle centred on ([x], [y]). */
  circle(x: number, y: number, diameter: number, options?: SketchOptions): RoughDrawable {
    return this.draw({ type: "circle", x, y, diameter }, options);
  }

  /** An open polyline through [points]. */
  linearPath(points: readonly PointLike[], options?: SketchOptions): RoughDrawable {
    return this.draw({ type: "linearPath", points }, options);
  }

  polygon(points: readonly PointLike[], options?: SketchOptions): RoughDrawable {
    return this.draw({ type: "polygon", points }, options);
  }

  /** An arc centred on ([x], [y]) between two angles in radians. */
  arc(
    x: number,
    y: number,
    width: number,
    height: number,
    start: number,
    stop: number,
    closed = false,
    options?: SketchOptions,
  ): RoughDrawable {
    return this.draw({ type: "arc", x, y, width, height, start, stop, closed }, options);
  }

  /** A smooth curve through [points]. */
  curve(points: readonly PointLike[], options?: SketchOptions): RoughDrawable {
    return this.draw({ type: "curve", points }, options);
  }

  /** The paths that paint [drawable], like rough.js's `toPaths`. */
  toPaths(drawable: RoughDrawable): SketchPath[] {
    return drawablePaths(drawable, drawable.style);
  }
}

type ShapeMethods = "line" | "rectangle" | "roundedRectangle" | "ellipse" | "circle" | "linearPath" | "polygon" | "arc" | "curve";

/** Something that can hand out a 2D context, such as a canvas element. */
export interface CanvasSource {
  getContext(type: "2d"): unknown;
}

/** Draws rough shapes straight onto a canvas, like rough.js's `RoughCanvas`. */
export class RoughCanvas {
  readonly generator: RoughGenerator;
  readonly ctx: CanvasContextLike;

  constructor(canvas: CanvasSource | CanvasContextLike, config?: RoughConfig) {
    this.generator = new RoughGenerator(config);
    const ctx = "getContext" in canvas ? canvas.getContext("2d") : canvas;
    if (!ctx) throw new Error("RoughCanvas could not get a 2D context");
    this.ctx = ctx as CanvasContextLike;
  }

  /** Paints [drawable] and returns it. */
  draw(drawable: RoughDrawable): RoughDrawable {
    drawOnCanvas(this.ctx, drawable, drawable.style);
    return drawable;
  }

  private paint<M extends ShapeMethods>(method: M, args: Parameters<RoughGenerator[M]>): RoughDrawable {
    const fn = this.generator[method] as (...a: Parameters<RoughGenerator[M]>) => RoughDrawable;
    return this.draw(fn.apply(this.generator, args));
  }

  line(...args: Parameters<RoughGenerator["line"]>) {
    return this.paint("line", args);
  }
  rectangle(...args: Parameters<RoughGenerator["rectangle"]>) {
    return this.paint("rectangle", args);
  }
  roundedRectangle(...args: Parameters<RoughGenerator["roundedRectangle"]>) {
    return this.paint("roundedRectangle", args);
  }
  ellipse(...args: Parameters<RoughGenerator["ellipse"]>) {
    return this.paint("ellipse", args);
  }
  circle(...args: Parameters<RoughGenerator["circle"]>) {
    return this.paint("circle", args);
  }
  linearPath(...args: Parameters<RoughGenerator["linearPath"]>) {
    return this.paint("linearPath", args);
  }
  polygon(...args: Parameters<RoughGenerator["polygon"]>) {
    return this.paint("polygon", args);
  }
  arc(...args: Parameters<RoughGenerator["arc"]>) {
    return this.paint("arc", args);
  }
  curve(...args: Parameters<RoughGenerator["curve"]>) {
    return this.paint("curve", args);
  }
}

/**
 * Creates rough SVG groups for an `<svg>` element, like rough.js's
 * `RoughSVG`. Each method returns a `<g>` for you to append.
 */
export class RoughSVG {
  readonly generator: RoughGenerator;
  private readonly doc: DocumentLike;

  constructor(svg: SVGSVGElement | { ownerDocument: DocumentLike | null }, config?: RoughConfig) {
    this.generator = new RoughGenerator(config);
    const doc = svg.ownerDocument ?? (globalThis as { document?: DocumentLike }).document;
    if (!doc) throw new Error("RoughSVG needs an element that belongs to a document");
    this.doc = doc;
  }

  /** Creates the `<g>` that paints [drawable]. */
  draw(drawable: RoughDrawable): SVGGElement {
    return createSvgGroup(drawablePaths(drawable, drawable.style), this.doc);
  }

  private paint<M extends ShapeMethods>(method: M, args: Parameters<RoughGenerator[M]>): SVGGElement {
    const fn = this.generator[method] as (...a: Parameters<RoughGenerator[M]>) => RoughDrawable;
    return this.draw(fn.apply(this.generator, args));
  }

  line(...args: Parameters<RoughGenerator["line"]>) {
    return this.paint("line", args);
  }
  rectangle(...args: Parameters<RoughGenerator["rectangle"]>) {
    return this.paint("rectangle", args);
  }
  roundedRectangle(...args: Parameters<RoughGenerator["roundedRectangle"]>) {
    return this.paint("roundedRectangle", args);
  }
  ellipse(...args: Parameters<RoughGenerator["ellipse"]>) {
    return this.paint("ellipse", args);
  }
  circle(...args: Parameters<RoughGenerator["circle"]>) {
    return this.paint("circle", args);
  }
  linearPath(...args: Parameters<RoughGenerator["linearPath"]>) {
    return this.paint("linearPath", args);
  }
  polygon(...args: Parameters<RoughGenerator["polygon"]>) {
    return this.paint("polygon", args);
  }
  arc(...args: Parameters<RoughGenerator["arc"]>) {
    return this.paint("arc", args);
  }
  curve(...args: Parameters<RoughGenerator["curve"]>) {
    return this.paint("curve", args);
  }
}

/** rough.js-style factories: `rough.canvas(el)`, `rough.svg(el)`, `rough.generator()`. */
export const rough = {
  canvas: (canvas: CanvasSource | CanvasContextLike, config?: RoughConfig) => new RoughCanvas(canvas, config),
  svg: (svg: SVGSVGElement | { ownerDocument: DocumentLike | null }, config?: RoughConfig) => new RoughSVG(svg, config),
  generator: (config?: RoughConfig) => new RoughGenerator(config),
};
