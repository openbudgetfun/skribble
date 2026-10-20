import type { DrawConfig } from "./config.js";
import { clamp } from "./math.js";
import type { Filler } from "./filler.js";
import {
  OpSetBuilder,
  computeEllipseAllPoints,
  ellipseSet,
  generateEllipseParams,
} from "./renderer.js";
import { curveToOp, moveOp, type Drawable, type Op, type OpSet, type Point } from "./types.js";

const KAPPA = 0.5522847498307936;

/**
 * The low-level entry point for rough shapes.
 *
 * Combines a {@link DrawConfig} and a {@link Filler} to produce rectangles,
 * ellipses, arcs, lines, polygons, and curves with hand-drawn imperfections.
 * Every method mirrors `Generator` in the Dart package `skribble_rough`, and
 * the same seed draws the same shape in both.
 */
export class Generator {
  constructor(
    readonly drawConfig: DrawConfig,
    readonly filler: Filler,
  ) {}

  private build(outline: OpSet, fillPoints?: readonly Point[], shape?: string): Drawable {
    const sets: OpSet[] = [];
    if (fillPoints !== undefined) sets.push(this.filler.fill(fillPoints));
    sets.push(outline);
    return { shape, options: this.drawConfig, sets };
  }

  line(x1: number, y1: number, x2: number, y2: number): Drawable {
    return this.build(OpSetBuilder.buildLine(x1, y1, x2, y2, this.drawConfig), undefined, "line");
  }

  rectangle(x: number, y: number, width: number, height: number): Drawable {
    const points: Point[] = [
      { x, y },
      { x: x + width, y },
      { x: x + width, y: y + height },
      { x, y: y + height },
    ];
    return this.build(OpSetBuilder.buildPolygon(points, this.drawConfig), points, "rectangle");
  }

  /** An ellipse centred on ([x], [y]). */
  ellipse(x: number, y: number, width: number, height: number): Drawable {
    const params = generateEllipseParams(width, height, this.drawConfig);
    const outline = ellipseSet(x, y, this.drawConfig, params);
    const estimatedPoints = computeEllipseAllPoints({
      increment: params.increment,
      cx: x,
      cy: y,
      rx: params.rx,
      ry: params.ry,
      offset: 0,
      overlap: 0,
      config: this.drawConfig,
    });
    return this.build(outline, estimatedPoints, "ellipse");
  }

  /** A circle centred on ([x], [y]). */
  circle(x: number, y: number, diameter: number): Drawable {
    return { ...this.ellipse(x, y, diameter, diameter), shape: "circle" };
  }

  /**
   * An unfilled path through [points]. Closed by default, like the Dart
   * engine; pass `false` for an open polyline as rough.js draws it.
   */
  linearPath(points: readonly Point[], closed = true): Drawable {
    return this.build(OpSetBuilder.linearPath(points, closed, this.drawConfig), undefined, "linearPath");
  }

  polygon(points: readonly Point[]): Drawable {
    return this.build(OpSetBuilder.linearPath(points, true, this.drawConfig), points, "polygon");
  }

  /**
   * An elliptical arc centred on ([x], [y]) from [start] to [stop] radians.
   * A [closed] arc is drawn as a pie slice.
   */
  arc(x: number, y: number, width: number, height: number, start: number, stop: number, closed = false): Drawable {
    const center = { x, y };
    const outline = OpSetBuilder.arc(center, width, height, start, stop, closed, true, this.drawConfig);
    const fillPoints = OpSetBuilder.arcPolygon(center, width, height, start, stop, this.drawConfig);
    return this.build(outline, fillPoints, "arc");
  }

  /** A smooth curve through [points]. */
  curvePath(points: readonly Point[]): Drawable {
    return this.build(OpSetBuilder.curve(points, this.drawConfig), undefined, "curve");
  }

  /**
   * A rectangle with rounded corners. Each pen pass follows one closed
   * contour, so small radii do not leave knots where corners meet edges.
   */
  roundedRectangle(
    x: number,
    y: number,
    width: number,
    height: number,
    topLeft: number,
    topRight = topLeft,
    bottomRight = topLeft,
    bottomLeft = topLeft,
  ): Drawable {
    const maxRadius = Math.min(width / 2, height / 2);
    const tl = clamp(topLeft, 0, maxRadius);
    const tr = clamp(topRight, 0, maxRadius);
    const br = clamp(bottomRight, 0, maxRadius);
    const bl = clamp(bottomLeft, 0, maxRadius);

    const ops: Op[] = [];
    const config = this.drawConfig;
    const offset = Math.min(config.maxRandomnessOffset, Math.min(width, height) / 16);

    for (let pass = 0; pass < 2; pass++) {
      const gain = pass === 0 ? 0.45 : 0.7;
      const dx = config.offsetSymmetric(offset, gain);
      const dy = config.offsetSymmetric(offset, gain);
      const left = x + dx;
      const top = y + dy;
      const right = x + width + dx;
      const bottom = y + height + dy;
      let cursor: Point = { x: left + tl, y: top };
      ops.push(moveOp(cursor, pass));

      const curve = (first: Point, second: Point, end: Point) => {
        ops.push(curveToOp(first, second, end));
        cursor = end;
      };

      const edge = (end: Point) => {
        const start = cursor;
        const ex = end.x - start.x;
        const ey = end.y - start.y;
        const length = Math.sqrt(ex * ex + ey * ey);
        if (length === 0) return;

        // The pass offset and local wobble share the reserved ink bleed.
        const limit = offset * config.roughness * (1 - gain);
        const at = (t: number, across: number): Point => ({
          x: start.x + ex * t - (ey / length) * clamp(across, -limit, limit),
          y: start.y + ey * t + (ex / length) * clamp(across, -limit, limit),
        });
        if (length >= 48 && config.lineWobble > 0) {
          const segments = Math.max(2, Math.ceil(length / 48));
          const displacement: number[] = [];
          for (let i = 0; i <= segments; i++) {
            displacement.push(
              i === 0 || i === segments
                ? 0
                : clamp(config.offsetSymmetric(offset, config.lineWobble * gain), -limit, limit),
            );
          }
          for (let i = 0; i < segments; i++) {
            const before = displacement[Math.max(0, i - 1)] as number;
            const from = displacement[i] as number;
            const to = displacement[i + 1] as number;
            const after = displacement[Math.min(segments, i + 2)] as number;
            // Zero endpoint tangents join the corner arcs without knots.
            const first = i === 0 ? 0 : from + (to - before) / 6;
            const second = i === segments - 1 ? 0 : to - (after - from) / 6;
            curve(at((i + 1 / 3) / segments, first), at((i + 2 / 3) / segments, second), at((i + 1) / segments, to));
          }
          return;
        }

        // Bow a continuous stroke gently; longer edges can wander locally.
        // Endpoint handles stay tangent to the rounded corners.
        const bow = config.offsetSymmetric(Math.min(offset, length / 12), config.bowing * gain);
        const drift = config.offsetSymmetric(Math.min(offset, length / 12), config.lineWobble * gain);
        curve(at(1 / 6, 0), at(1 / 3, bow + drift), at(1 / 2, bow));
        curve(at(2 / 3, bow - drift), at(5 / 6, 0), end);
      };

      edge({ x: right - tr, y: top });
      curve(
        { x: right - tr + tr * KAPPA, y: top },
        { x: right, y: top + tr - tr * KAPPA },
        { x: right, y: top + tr },
      );
      edge({ x: right, y: bottom - br });
      curve(
        { x: right, y: bottom - br + br * KAPPA },
        { x: right - br + br * KAPPA, y: bottom },
        { x: right - br, y: bottom },
      );
      edge({ x: left + bl, y: bottom });
      curve(
        { x: left + bl - bl * KAPPA, y: bottom },
        { x: left, y: bottom - bl + bl * KAPPA },
        { x: left, y: bottom - bl },
      );
      edge({ x: left, y: top + tl });
      curve(
        { x: left, y: top + tl - tl * KAPPA },
        { x: left + tl - tl * KAPPA, y: top },
        { x: left + tl, y: top },
      );
    }

    const outline: OpSet = { type: "path", ops };
    return this.build(outline, roundedRectFillPoints(x, y, width, height, tl, tr, br, bl), "roundedRectangle");
  }
}

function roundedRectFillPoints(
  x: number,
  y: number,
  w: number,
  h: number,
  tl: number,
  tr: number,
  br: number,
  bl: number,
): Point[] {
  const points: Point[] = [];
  const steps = 8;
  for (let i = 0; i <= steps; i++) {
    const angle = Math.PI + (Math.PI / 2) * (i / steps);
    points.push({ x: x + tl + tl * Math.cos(angle), y: y + tl + tl * Math.sin(angle) });
  }
  for (let i = 0; i <= steps; i++) {
    const angle = -Math.PI / 2 + (Math.PI / 2) * (i / steps);
    points.push({ x: x + w - tr + tr * Math.cos(angle), y: y + tr + tr * Math.sin(angle) });
  }
  for (let i = 0; i <= steps; i++) {
    const angle = (Math.PI / 2) * (i / steps);
    points.push({ x: x + w - br + br * Math.cos(angle), y: y + h - br + br * Math.sin(angle) });
  }
  for (let i = 0; i <= steps; i++) {
    const angle = Math.PI / 2 + (Math.PI / 2) * (i / steps);
    points.push({ x: x + bl + bl * Math.cos(angle), y: y + h - bl + bl * Math.sin(angle) });
  }
  return points;
}
