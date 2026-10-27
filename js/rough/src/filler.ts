import { DrawConfig } from "./config.js";
import { Line, isInPolygon, rotateLines, rotatePoints } from "./geometry.js";
import { dartSort, roundHalfAway } from "./math.js";
import { stripUndefined } from "./pen.js";
import { OpSetBuilder, OpsGenerator } from "./renderer.js";
import { lineToOp, moveOp, type Op, type OpSet, type Point } from "./types.js";

/** The values that shape a {@link FillerConfig}. Every field is optional. */
export interface FillerConfigOptions {
  /** How fill strokes wander and how their ink is laid down. */
  drawConfig?: DrawConfig;
  /** Diameter of dots and displacement of solid fill corners. */
  fillWeight?: number;
  /** Angle of hachure lines, in degrees. */
  hachureAngle?: number;
  /** Distance between neighbouring hachure lines. */
  hachureGap?: number;
  /** Length of each dash in a dashed fill. */
  dashOffset?: number;
  /** Gap between dashes in a dashed fill. */
  dashGap?: number;
  /** Offset of zig-zag turns from the hachure line. */
  zigzagOffset?: number;
}

/** Configuration for the fill algorithms. */
export class FillerConfig {
  readonly drawConfig: DrawConfig;
  readonly fillWeight: number;
  readonly hachureAngle: number;
  readonly hachureGap: number;
  readonly dashOffset: number;
  readonly dashGap: number;
  readonly zigzagOffset: number;

  private constructor(values: Required<FillerConfigOptions>) {
    this.drawConfig = values.drawConfig;
    this.fillWeight = values.fillWeight;
    this.hachureAngle = values.hachureAngle;
    this.hachureGap = values.hachureGap;
    this.dashOffset = values.dashOffset;
    this.dashGap = values.dashGap;
    this.zigzagOffset = values.zigzagOffset;
  }

  /**
   * Creates a fill configuration. `drawConfig` defaults to a fresh
   * {@link DrawConfig.build} so its random stream is not shared.
   */
  static build(options: FillerConfigOptions = {}): FillerConfig {
    const values = stripUndefined(options);
    return new FillerConfig({
      drawConfig: values.drawConfig ?? DrawConfig.build(),
      fillWeight: values.fillWeight ?? 1,
      hachureAngle: values.hachureAngle ?? 320,
      hachureGap: values.hachureGap ?? 15,
      dashOffset: values.dashOffset ?? 15,
      dashGap: values.dashGap ?? 2,
      zigzagOffset: values.zigzagOffset ?? 5,
    });
  }

  /** Returns a copy with the given values replaced. */
  copyWith(options: FillerConfigOptions): FillerConfig {
    return new FillerConfig({
      drawConfig: this.drawConfig,
      fillWeight: this.fillWeight,
      hachureAngle: this.hachureAngle,
      hachureGap: this.hachureGap,
      dashOffset: this.dashOffset,
      dashGap: this.dashGap,
      zigzagOffset: this.zigzagOffset,
      ...stripUndefined(options),
    });
  }
}

interface Edge {
  yMin: number;
  yMax: number;
  x: number;
  slope: number;
}

interface IntersectionInfo {
  point: Point;
  distance: number;
}

/**
 * Base class for polygon fill strategies. Subclasses implement {@link fill}
 * to produce the operations that fill a polygon.
 */
export abstract class Filler {
  /** Configuration this filler draws with. */
  readonly config: FillerConfig;

  constructor(config?: FillerConfig) {
    // A fresh default, never a shared instance: two fillers built without a
    // configuration each own their random stream, so output never depends on
    // the order they are used in.
    this.config = config ?? FillerConfig.build();
  }

  /** Returns the fill operations for the polygon through [points]. */
  abstract fill(points: readonly Point[]): OpSet;

  /** Clips parallel lines at the hachure angle to the polygon. */
  buildFillLines(points: readonly Point[], config: FillerConfig): Line[] {
    const rotationCenter: Point = { x: 0, y: 0 };
    const angle = roundHalfAway(config.hachureAngle + 90);
    let vertices = points;
    if (angle !== 0) vertices = rotatePoints(vertices, rotationCenter, angle);
    let lines = this.straightenLines(vertices);
    if (angle !== 0) lines = rotateLines(lines, rotationCenter, -angle);
    return lines;
  }

  private straightenLines(points: readonly Point[]): Line[] {
    const vertices = [...points];
    const lines: Line[] = [];
    if (vertices.length === 0) return lines;
    const first = vertices[0] as Point;
    const last = vertices[vertices.length - 1] as Point;
    if (first.x !== last.x || first.y !== last.y) vertices.push(first);
    if (vertices.length <= 2) return lines;

    const gap = Math.max(this.config.hachureGap, 0.1);
    const edges = this.createSortedEdges(vertices);
    if (edges.length === 0) return lines;

    let activeEdges: Edge[] = [];
    let y = (edges[0] as Edge).yMin;
    while (activeEdges.length > 0 || edges.length > 0) {
      if (edges.length > 0) {
        let ix = -1;
        for (let i = 0; i < edges.length; i++) {
          if ((edges[i] as Edge).yMin > y) break;
          ix = i;
        }
        // An edge that starts between scanlines joins at this one, so its
        // intercept moves along the edge to y. Starting it at yMin pushed lines
        // past short, shallow edges such as rounded corners.
        for (const edge of edges.splice(0, ix + 1)) {
          activeEdges.push({ ...edge, x: edge.x + (y - edge.yMin) * edge.slope });
        }
      }
      activeEdges = activeEdges.filter((edge) => edge.yMax > y);
      dartSort(activeEdges, (a, b) => compareDoubles(a.x, b.x));

      if (activeEdges.length > 1) {
        for (let i = 0; i + 1 < activeEdges.length; i += 2) {
          const current = activeEdges[i] as Edge;
          const next = activeEdges[i + 1] as Edge;
          lines.push(new Line({ x: roundHalfAway(current.x), y }, { x: roundHalfAway(next.x), y }));
        }
      }

      y += gap;
      activeEdges = activeEdges.map((edge) => ({ ...edge, x: edge.x + gap * edge.slope }));
    }
    return lines;
  }

  /** The polygon's non-horizontal edges, ordered for the scan-line fill. */
  createSortedEdges(vertices: readonly Point[]): Edge[] {
    const edges: Edge[] = [];
    for (let i = 0; i < vertices.length - 1; i++) {
      const p1 = vertices[i] as Point;
      const p2 = vertices[i + 1] as Point;
      if (p1.y !== p2.y) {
        const yMin = Math.min(p1.y, p2.y);
        edges.push({
          yMin,
          yMax: Math.max(p1.y, p2.y),
          x: yMin === p1.y ? p1.x : p2.x,
          slope: (p2.x - p1.x) / (p2.y - p1.y),
        });
      }
    }
    dartSort(edges, (e1, e2) => {
      if (e1.yMin < e2.yMin) return -1;
      if (e1.yMin > e2.yMin) return 1;
      if (e1.x < e2.x) return -1;
      if (e1.x > e2.x) return 1;
      return compareDoubles(e1.yMax, e2.yMax);
    });
    return edges;
  }

  /** Hachure lines across the polygon, optionally joined end to end. */
  fillPolygon(points: readonly Point[], config: FillerConfig, connectEnds: boolean): OpSet {
    let lines = this.buildFillLines(points, config);
    if (connectEnds) lines = [...lines, ...this.connectLines(points, lines)];
    return { type: "fillSketch", ops: this.renderLines(lines, config) };
  }

  /** Segments that join each hachure line to the next inside the polygon. */
  connectLines(polygon: readonly Point[], lines: readonly Line[]): Line[] {
    const result: Line[] = [];
    for (let i = 1; i < lines.length; i++) {
      const prev = lines[i - 1] as Line;
      if (prev.length < 3) continue;
      const current = lines[i] as Line;
      const segment = new Line(current.source, prev.target);
      if (segment.length > 3) result.push(...this.splitOnIntersections(polygon, segment));
    }
    return result;
  }

  /** The parts of [segment] that lie inside [polygon]. */
  splitOnIntersections(polygon: readonly Point[], segment: Line): Line[] {
    const error = Math.max(5, segment.length * 0.1);
    const intersections: IntersectionInfo[] = [];
    for (let i = 0; i < polygon.length; i++) {
      const polygonSegment = new Line(polygon[i] as Point, polygon[(i + 1) % polygon.length] as Point);
      if (segment.intersects(polygonSegment)) {
        const ip = segment.intersectionWith(polygonSegment);
        if (ip !== null) {
          const d0 = new Line(ip, segment.source).length;
          const d1 = new Line(ip, segment.target).length;
          if (d0 > error && d1 > error) intersections.push({ point: ip, distance: d0 });
        }
      }
    }
    if (intersections.length > 1) {
      dartSort(intersections, (a, b) => Math.ceil(a.distance - b.distance));
      const intersectionPoints = intersections.map((info) => info.point);
      if (isInPolygon(segment.source, polygon)) intersectionPoints.shift();
      if (isInPolygon(segment.target, polygon)) intersectionPoints.pop();
      if (intersectionPoints.length <= 1) {
        return segment.isMidPointInPolygon(polygon) ? [segment] : [];
      }
      const splitPoints = [segment.source, ...intersectionPoints, segment.target];
      const splitLines: Line[] = [];
      for (let i = 0; i < splitPoints.length - 1; i += 2) {
        const subSegment = new Line(splitPoints[i] as Point, splitPoints[i + 1] as Point);
        if (subSegment.isMidPointInPolygon(polygon)) splitLines.push(subSegment);
      }
      return splitLines;
    }
    return segment.isMidPointInPolygon(polygon) ? [segment] : [];
  }

  /** Rough double strokes along every line. */
  renderLines(lines: readonly Line[], config: FillerConfig): Op[] {
    const ops: Op[] = [];
    for (const line of lines) {
      ops.push(
        ...OpSetBuilder.buildLine(line.source.x, line.source.y, line.target.x, line.target.y, config.drawConfig).ops,
      );
    }
    return ops;
  }
}

/** Dart's `double.compareTo` for ordinary values: -0.0 sorts before 0.0. */
function compareDoubles(a: number, b: number): number {
  if (a < b) return -1;
  if (a > b) return 1;
  if (a === 0 && b === 0) {
    const aNegative = Object.is(a, -0);
    const bNegative = Object.is(b, -0);
    return aNegative === bNegative ? 0 : aNegative ? -1 : 1;
  }
  return 0;
}

/** A filler that draws nothing. */
export class NoFiller extends Filler {
  fill(): OpSet {
    return { type: "fillSketch", ops: [] };
  }
}

/** Fills a polygon with parallel hachure lines at a configurable angle. */
export class HachureFiller extends Filler {
  fill(points: readonly Point[]): OpSet {
    return this.fillPolygon(points, this.config, false);
  }
}

/** Fills a polygon with connected zig-zag lines. */
export class ZigZagFiller extends Filler {
  fill(points: readonly Point[]): OpSet {
    return this.fillPolygon(points, this.config, true);
  }
}

/** Fills a polygon with cross-hatching: two hachure passes at right angles. */
export class HatchFiller extends Filler {
  fill(points: readonly Point[]): OpSet {
    const set1 = this.fillPolygon(points, this.config, false);
    const rotated = this.config.copyWith({ hachureAngle: this.config.hachureAngle + 90 });
    const set2 = this.fillPolygon(points, rotated, false);
    return { type: "fillSketch", ops: [...set1.ops, ...set2.ops] };
  }
}

/** Fills a polygon with dashed hachure lines. */
export class DashedFiller extends Filler {
  fill(points: readonly Point[]): OpSet {
    const lines = this.buildFillLines(points, this.config);
    return { type: "fillSketch", ops: this.dashedLines(lines, this.config) };
  }

  dashedLines(lines: readonly Line[], config: FillerConfig): Op[] {
    const offset = config.dashOffset;
    const gap = config.dashGap;
    const ops: Op[] = [];
    for (const line of lines) {
      const length = line.length;
      const count = Math.floor(length / (offset + gap));
      const lineOffset = (length + gap - count * (offset + gap)) / 2;
      let lineStart = line.source;
      let lineEnd = line.target;
      if (lineStart.x > lineEnd.x) {
        lineStart = line.target;
        lineEnd = line.source;
      }
      const alpha = Math.atan((lineEnd.y - lineStart.y) / (lineEnd.x - lineStart.x));
      for (let i = 0; i < count; i++) {
        const startOffset = i * (offset + gap);
        const startX = lineStart.x + startOffset * Math.cos(alpha) + lineOffset * Math.cos(alpha);
        const startY = lineStart.y + startOffset * Math.sin(alpha) + lineOffset * Math.sin(alpha);
        const endOffset = startOffset + offset;
        const endX = lineStart.x + endOffset * Math.cos(alpha) + lineOffset * Math.cos(alpha);
        const endY = lineStart.y + endOffset * Math.sin(alpha) + lineOffset * Math.sin(alpha);
        ops.push(...OpsGenerator.doubleLine(startX, startY, endX, endY, config.drawConfig));
      }
    }
    return ops;
  }
}

/** Fills a polygon with scattered rough dots. */
export class DotFiller extends Filler {
  fill(points: readonly Point[]): OpSet {
    const dotConfig = this.config.copyWith({
      drawConfig: this.config.drawConfig.copyWith({ curveStepCount: 4, roughness: 1 }),
      hachureAngle: 1,
    });
    const lines = this.buildFillLines(points, dotConfig);
    return this.dotsOnLines(lines, dotConfig);
  }

  dotsOnLines(lines: readonly Line[], config: FillerConfig): OpSet {
    const ops: Op[] = [];
    const gap = Math.max(config.hachureGap, 0.1);
    const weight = Math.max(config.fillWeight, 0.1);
    const ro = gap / 4;
    for (const line of lines) {
      const length = line.length;
      const count = Math.ceil(length / gap) - 1;
      const off = length - count * gap;
      const x = (line.source.x + line.target.x) / 2 - gap / 4;
      const minY = Math.min(line.source.y, line.target.y);
      for (let i = 0; i < count; i++) {
        const y = minY + off + i * gap;
        const cx = config.drawConfig.offset(x - ro, x + ro);
        const cy = config.drawConfig.offset(y - ro, y + ro);
        ops.push(...OpSetBuilder.ellipse(cx, cy, weight, weight, config.drawConfig).ops);
      }
    }
    return { type: "fillSketch", ops };
  }
}

/** Fills a polygon with a solid path whose corners wander slightly. */
export class SolidFiller extends Filler {
  fill(points: readonly Point[]): OpSet {
    if (points.length <= 2) return { type: "fillPath", ops: [] };
    const { drawConfig, fillWeight } = this.config;
    const result = points.map((p) => ({
      x: p.x + drawConfig.offsetSymmetric(fillWeight),
      y: p.y + drawConfig.offsetSymmetric(fillWeight),
    }));
    // Smoothing a polygon as a spline rounds its corners and overshoots long
    // edges. Keep the perturbed polygon so solid ink stays in its shape.
    const first = result[0] as Point;
    return {
      type: "fillPath",
      ops: [moveOp(first), ...result.slice(1).map((p) => lineToOp(p)), lineToOp(first)],
    };
  }
}

/**
 * How a closed rough shape is filled. The names match rough.js, so designs
 * and docs written for either read the same.
 */
export type RoughFillStyle = "none" | "hachure" | "cross-hatch" | "zigzag" | "dashed" | "dots" | "solid";

/** Every {@link RoughFillStyle}, in declaration order. */
export const roughFillStyles: readonly RoughFillStyle[] = [
  "none",
  "hachure",
  "cross-hatch",
  "zigzag",
  "dashed",
  "dots",
  "solid",
];

/**
 * Creates the filler for [style], drawing with [config].
 *
 * Pass a configuration built from a seed when output must be reproducible;
 * a filler built without one draws from the default seed, from a stream only
 * it owns.
 */
export function createFiller(style: RoughFillStyle, config: FillerConfig): Filler {
  switch (style) {
    case "none":
      return new NoFiller(config);
    case "hachure":
      return new HachureFiller(config);
    case "cross-hatch":
      return new HatchFiller(config);
    case "zigzag":
      return new ZigZagFiller(config);
    case "dashed":
      return new DashedFiller(config);
    case "dots":
      return new DotFiller(config);
    case "solid":
      return new SolidFiller(config);
    default:
      throw new RangeError(`Unknown fill style "${String(style)}"`);
  }
}
