/**
 * The hand-drawn rendering engine behind skribble, for every JavaScript
 * runtime.
 *
 * A TypeScript port of the Dart package `skribble_rough`: the same seed draws
 * byte-identical SVG path data in Flutter, Jaspr, and here. Use the
 * framework-neutral {@link sketch} function, the rough.js-style
 * {@link rough} factories, or the low-level {@link Generator}.
 *
 * @packageDocumentation
 */
export { DrawConfig, type DrawConfigOptions } from "./config.js";
export { Randomizer } from "./random.js";
export { RoughPen, resolvePen, type RoughPenName, type RoughPenOptions } from "./pen.js";
export {
  Filler,
  FillerConfig,
  NoFiller,
  HachureFiller,
  ZigZagFiller,
  HatchFiller,
  DashedFiller,
  DotFiller,
  SolidFiller,
  createFiller,
  roughFillStyles,
  type FillerConfigOptions,
  type RoughFillStyle,
} from "./filler.js";
export { Generator } from "./generator.js";
export {
  OpSetBuilder,
  OpsGenerator,
  computeEllipseAllPoints,
  ellipseSet,
  generateEllipseParams,
  type EllipseParams,
} from "./renderer.js";
export { Line, Orientation, isInPolygon, orientation, point, rotatePoint, rotatePoints, rotateLines } from "./geometry.js";
export {
  curveToOp,
  lineToOp,
  moveOp,
  type Drawable,
  type Op,
  type OpSet,
  type OpSetType,
  type OpType,
  type Point,
} from "./types.js";
export {
  escapeAttribute,
  assertSafePathData,
  opSetToSvgPath,
  toPathElements,
  toSvgPaths,
  type PathElementOptions,
  type RoughSvgPaths,
} from "./svg.js";
export {
  DrawableInk,
  DrawableInkSet,
  InkStroke,
  SvgInkOutline,
  canvasInkSink,
  type CanvasPathLike,
  type DrawableInkOptions,
  type InkOutlineSink,
  type InkStrokeOptions,
  type InkSvgPath,
} from "./ink.js";
export {
  createGenerator,
  drawShape,
  drawablePaths,
  pathsToSvgElements,
  pickSketchOptions,
  resolveStyle,
  sketch,
  sketchKey,
  sketchOptionKeys,
  splitSketchOptions,
  toPoint,
  toSvgString,
  withArrowhead,
  type PointLike,
  type Shape,
  type Sketch,
  type SketchOptions,
  type SketchPath,
  type SketchStyle,
  type SvgStringOptions,
} from "./sketch.js";
export { drawOnCanvas, type CanvasContextLike } from "./canvas.js";
export { createSvgGroup, type DocumentLike } from "./dom.js";
export {
  RoughCanvas,
  RoughGenerator,
  RoughSVG,
  rough,
  type CanvasSource,
  type RoughConfig,
  type RoughDrawable,
} from "./rough.js";
export { rough as default } from "./rough.js";
