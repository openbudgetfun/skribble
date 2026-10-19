import type { DrawConfig } from "./config.js";
import { clamp } from "./math.js";
import { curveToOp, lineToOp, moveOp, type Op, type OpSet, type Point } from "./types.js";

function line(
  x1: number,
  y1: number,
  x2: number,
  y2: number,
  config: DrawConfig,
  move: boolean,
  overlay: boolean,
): Op[] {
  const lengthSq = (x1 - x2) * (x1 - x2) + (y1 - y2) * (y1 - y2);
  const length = Math.sqrt(lengthSq);

  if (length >= 48 && config.roughness > 0 && config.lineWobble > 0) {
    return wanderingLine(x1, y1, x2, y2, config, overlay);
  }

  const roughnessGain = length < 200 ? 1 : length > 500 ? 0.4 : -0.0016668 * length + 1.233334;
  let offset = config.maxRandomnessOffset;
  if (offset * offset * 100 > lengthSq) {
    offset = length / 10;
  }

  const halfOffset = offset / 2;
  const divergePoint = 0.2 + config.randomizer.next() * 0.2;

  // Bowing grows with length, but never past the displacement painters
  // reserve as bleed: a very long edge would otherwise leave its card.
  const bowLimit = Math.abs(config.bowing) * config.maxRandomnessOffset;
  let offsetX = clamp((config.bowing * config.maxRandomnessOffset * (y2 - y1)) / 200, -bowLimit, bowLimit);
  let offsetY = clamp((config.bowing * config.maxRandomnessOffset * (x1 - x2)) / 200, -bowLimit, bowLimit);
  offsetX = config.offsetSymmetric(offsetX, roughnessGain);
  offsetY = config.offsetSymmetric(offsetY, roughnessGain);

  const ops: Op[] = [];
  const randomHalf = () => config.offsetSymmetric(halfOffset, roughnessGain);
  const randomFull = () => config.offsetSymmetric(offset, roughnessGain);

  if (move) {
    if (overlay) {
      ops.push(moveOp({ x: x1 + randomHalf(), y: y1 + randomHalf() }, 1));
    } else {
      ops.push(
        moveOp({
          x: x1 + config.offsetSymmetric(offset, roughnessGain),
          y: y1 + config.offsetSymmetric(offset, roughnessGain),
        }),
      );
    }
  }
  const random = overlay ? randomHalf : randomFull;
  ops.push(
    curveToOp(
      {
        x: offsetX + x1 + (x2 - x1) * divergePoint + random(),
        y: offsetY + y1 + (y2 - y1) * divergePoint + random(),
      },
      {
        x: offsetX + x1 + 2 * (x2 - x1) * divergePoint + random(),
        y: offsetY + y1 + 2 * (y2 - y1) * divergePoint + random(),
      },
      { x: x2 + random(), y: y2 + random() },
    ),
  );
  return ops;
}

// Long edges need local changes of direction: one cubic looks like a ruler
// even with displaced endpoints. Keep every control point within the pen's
// reserved jitter band so larger cards do not need larger painting insets.
function wanderingLine(
  x1: number,
  y1: number,
  x2: number,
  y2: number,
  config: DrawConfig,
  overlay: boolean,
): Op[] {
  const dx = x2 - x1;
  const dy = y2 - y1;
  const length = Math.sqrt(dx * dx + dy * dy);
  const segments = Math.ceil(length / 48);
  const limit = config.maxRandomnessOffset * config.roughness;
  const offset = config.maxRandomnessOffset * (overlay ? 0.85 : 1);
  const bow = config.offsetSymmetric(offset) * config.bowing * 0.3;
  const displacements: number[] = [];
  for (let i = 0; i <= segments; i++) {
    const t = i / segments;
    const endGain = i === 0 || i === segments ? 0.45 : 1;
    displacements.push(
      clamp(
        (config.offsetSymmetric(offset) * 0.7 * endGain + bow * Math.sin(t * Math.PI)) * config.lineWobble,
        -limit,
        limit,
      ),
    );
  }
  const at = (t: number, displacement: number): Point => ({
    x: x1 + dx * t - (dy / length) * displacement,
    y: y1 + dy * t + (dx / length) * displacement,
  });
  const ops: Op[] = [moveOp(at(0, displacements[0] as number), overlay ? 1 : 0)];

  for (let i = 0; i < segments; i++) {
    const before = displacements[Math.max(0, i - 1)] as number;
    const start = displacements[i] as number;
    const end = displacements[i + 1] as number;
    const after = displacements[Math.min(segments, i + 2)] as number;
    const control1 = clamp(start + (end - before) / 6, -limit, limit);
    const control2 = clamp(end - (after - start) / 6, -limit, limit);
    ops.push(
      curveToOp(at((i + 1 / 3) / segments, control1), at((i + 2 / 3) / segments, control2), at((i + 1) / segments, end)),
    );
  }
  return ops;
}

/** Parameters for ellipse generation: radii and angular increment. */
export interface EllipseParams {
  readonly rx: number;
  readonly ry: number;
  readonly increment: number;
}

/**
 * Builds {@link OpSet}s for rough shapes: lines, polygons, ellipses, arcs,
 * and curves.
 */
export const OpSetBuilder = {
  buildLine(x1: number, y1: number, x2: number, y2: number, config: DrawConfig): OpSet {
    return { type: "path", ops: OpsGenerator.doubleLine(x1, y1, x2, y2, config) };
  },

  ellipse(x: number, y: number, width: number, height: number, config: DrawConfig): OpSet {
    return ellipseSet(x, y, config, generateEllipseParams(width, height, config));
  },

  buildPolygon(points: readonly Point[], config: DrawConfig): OpSet {
    return OpSetBuilder.linearPath(points, true, config);
  },

  linearPath(points: readonly Point[], close: boolean, config: DrawConfig): OpSet {
    const len = points.length;
    if (len > 2) {
      const ops: Op[] = [];
      for (let i = 0; i < len - 1; i++) {
        const a = points[i] as Point;
        const b = points[i + 1] as Point;
        ops.push(...OpsGenerator.doubleLine(a.x, a.y, b.x, b.y, config));
      }
      if (close) {
        const last = points[len - 1] as Point;
        const first = points[0] as Point;
        ops.push(...OpsGenerator.doubleLine(last.x, last.y, first.x, first.y, config));
      }
      return { type: "path", ops };
    }
    if (len === 2) {
      const a = points[0] as Point;
      const b = points[1] as Point;
      return OpSetBuilder.buildLine(a.x, a.y, b.x, b.y, config);
    }
    return { type: "path", ops: [] };
  },

  arc(
    center: Point,
    width: number,
    height: number,
    start: number,
    stop: number,
    closed: boolean,
    roughClosure: boolean,
    config: DrawConfig,
  ): OpSet {
    const ops: Op[] = [];
    const cx = center.x;
    const cy = center.y;
    let rx = Math.abs(width / 2);
    let ry = Math.abs(height / 2);
    rx += config.offsetSymmetric(rx * 0.01);
    ry += config.offsetSymmetric(ry * 0.01);
    let strt = start;
    let stp = stop;
    while (strt < 0) {
      strt += Math.PI * 2;
      stp += Math.PI * 2;
    }
    if (stp - strt > Math.PI * 2) {
      strt = 0;
      stp = Math.PI * 2;
    }
    const ellipseInc = (Math.PI * 2) / config.curveStepCount;
    const arcIn = Math.min(ellipseInc / 2, (stp - strt) / 2);
    ops.push(
      ...OpsGenerator.arc(arcIn, cx, cy, rx, ry, strt, stp, 1, config),
      ...OpsGenerator.arc(arcIn, cx, cy, rx, ry, strt, stp, 1.5, config, 1),
    );
    if (closed) {
      if (roughClosure) {
        ops.push(
          ...OpsGenerator.doubleLine(cx, cy, cx + rx * Math.cos(strt), cy + ry * Math.sin(strt), config),
          ...OpsGenerator.doubleLine(cx, cy, cx + rx * Math.cos(stp), cy + ry * Math.sin(stp), config),
        );
      } else {
        ops.push(
          lineToOp({ x: cx, y: cy }),
          lineToOp({ x: cx + rx * Math.cos(strt), y: cy + ry * Math.sin(strt) }),
        );
      }
    }
    return { type: "path", ops };
  },

  arcPolygon(
    center: Point,
    width: number,
    height: number,
    startAngle: number,
    stopAngle: number,
    config: DrawConfig,
  ): Point[] {
    let radiusX = Math.abs(width / 2);
    let radiusY = Math.abs(height / 2);
    radiusX += config.offsetSymmetric(radiusX * 0.01);
    radiusY += config.offsetSymmetric(radiusY * 0.01);
    let start = startAngle;
    let stop = stopAngle;
    while (start < 0) {
      start += Math.PI * 2;
      stop += Math.PI * 2;
    }
    if (stop - start > Math.PI * 2) {
      start = 0;
      stop = Math.PI * 2;
    }
    const ellipseInc = (Math.PI * 2) / config.curveStepCount;
    const increment = Math.min(ellipseInc / 2, (stop - start) / 2);
    const points: Point[] = [];
    for (let angle = start; angle <= stop; angle = angle + increment) {
      points.push({ x: center.x + radiusX * Math.cos(angle), y: center.y + radiusY * Math.sin(angle) });
    }
    points.push({ x: center.x + radiusX * Math.cos(stop), y: center.y + radiusY * Math.sin(stop) }, center);
    return points;
  },

  curve(points: readonly Point[], config: DrawConfig): OpSet {
    const op1 = OpsGenerator.curveWithOffset(points, 1 * (1 + config.roughness * 0.2), config);
    const op2 = OpsGenerator.curveWithOffset(points, 1.5 * (1 + config.roughness * 0.2), config, 1);
    return { type: "path", ops: [...op1, ...op2] };
  },
};

/**
 * Low-level generator of {@link Op} lists for individual strokes, with
 * hand-drawn jitter from a {@link DrawConfig}.
 */
export const OpsGenerator = {
  doubleLine(x1: number, y1: number, x2: number, y2: number, config: DrawConfig): Op[] {
    const o1 = line(x1, y1, x2, y2, config, true, false);
    const o2 = line(x1, y1, x2, y2, config, true, true);
    return [...o1, ...o2];
  },

  /** Fits a Catmull-Rom curve through [points], drawn as pen [pass]. */
  curve(points: readonly Point[], config: DrawConfig, pass = 0): Op[] {
    const len = points.length;
    if (len > 3) {
      const ops: Op[] = [];
      const s = 1 - config.curveTightness;
      ops.push(moveOp(points[1] as Point, pass));
      for (let i = 1; i + 2 < len; i++) {
        const p = points[i] as Point;
        const next = points[i + 1] as Point;
        const afterNext = points[i + 2] as Point;
        const previous = points[i - 1] as Point;
        ops.push(
          curveToOp(
            { x: p.x + (s * next.x - s * previous.x) / 6, y: p.y + (s * next.y - s * previous.y) / 6 },
            { x: next.x + (s * p.x - s * afterNext.x) / 6, y: next.y + (s * p.y - s * afterNext.y) / 6 },
            { x: next.x, y: next.y },
          ),
        );
      }
      return ops;
    }
    if (len === 3) {
      return [moveOp(points[1] as Point, pass), curveToOp(points[1] as Point, points[2] as Point, points[2] as Point)];
    }
    if (len === 2) {
      const a = points[0] as Point;
      const b = points[1] as Point;
      return OpsGenerator.doubleLine(a.x, a.y, b.x, b.y, config);
    }
    return [];
  },

  curveWithOffset(points: readonly Point[], offset: number, config: DrawConfig, pass = 0): Op[] {
    const jitter = (p: Point): Point => ({
      x: p.x + config.offsetSymmetric(offset),
      y: p.y + config.offsetSymmetric(offset),
    });
    const result: Point[] = [jitter(points[0] as Point)];
    for (const p of points) result.push(jitter(p));
    result.push(jitter(points[points.length - 1] as Point));
    return OpsGenerator.curve(result, config, pass);
  },

  arc(
    increment: number,
    cx: number,
    cy: number,
    rx: number,
    ry: number,
    strt: number,
    stp: number,
    offset: number,
    config: DrawConfig,
    pass = 0,
  ): Op[] {
    const points: Point[] = [];
    const radOffset = strt + config.offsetSymmetric(0.1);
    points.push({
      x: config.offsetSymmetric(offset) + cx + 0.9 * rx * Math.cos(radOffset - increment),
      y: config.offsetSymmetric(offset) + cy + 0.9 * ry * Math.sin(radOffset - increment),
    });
    for (let angle = radOffset; angle <= stp; angle += increment) {
      points.push({
        x: config.offsetSymmetric(offset) + cx + rx * Math.cos(angle),
        y: config.offsetSymmetric(offset) + cy + ry * Math.sin(angle),
      });
    }
    const end: Point = { x: cx + rx * Math.cos(stp), y: cy + ry * Math.sin(stp) };
    points.push(end, { ...end });
    return OpsGenerator.curve(points, config, pass);
  },
};

/** Radii and step size for a rough ellipse [width] by [height]. */
export function generateEllipseParams(width: number, height: number, config: DrawConfig): EllipseParams {
  const halfWidth = width / 2;
  const halfHeight = height / 2;
  const psq = Math.sqrt(Math.PI * 2 * Math.sqrt((halfWidth * halfWidth + halfHeight * halfHeight) / 2));
  const stepCount = Math.max(config.curveStepCount, (config.curveStepCount / Math.sqrt(200)) * psq);
  const increment = (Math.PI * 2) / stepCount;
  const curveFitRandomness = 1 - config.curveFitting;

  let rx = Math.abs(width / 2);
  let ry = Math.abs(height / 2);
  rx += config.offsetSymmetric(rx * curveFitRandomness);
  ry += config.offsetSymmetric(ry * curveFitRandomness);
  return { increment, rx, ry };
}

/** The two-pass outline of a rough ellipse centred on ([x], [y]). */
export function ellipseSet(x: number, y: number, config: DrawConfig, params: EllipseParams): OpSet {
  const points1 = computeEllipseAllPoints({
    increment: params.increment,
    cx: x,
    cy: y,
    rx: params.rx,
    ry: params.ry,
    offset: 1,
    overlap: params.increment * config.offset(0.1, config.offset(0.4, 1)),
    config,
  });
  const points2 = computeEllipseAllPoints({
    increment: params.increment,
    cx: x,
    cy: y,
    rx: params.rx,
    ry: params.ry,
    offset: 1.5,
    overlap: 0,
    config,
  });
  const o1 = OpsGenerator.curve(points1, config);
  const o2 = OpsGenerator.curve(points2, config, 1);
  return { type: "path", ops: [...o1, ...o2] };
}

/** Jittered points around an ellipse, with the overlap that closes it. */
export function computeEllipseAllPoints(args: {
  increment: number;
  cx: number;
  cy: number;
  rx: number;
  ry: number;
  offset: number;
  overlap: number;
  config: DrawConfig;
}): Point[] {
  const { increment, cx, cy, rx, ry, offset, overlap, config } = args;
  const allPoints: Point[] = [];
  const radOffset = config.offsetSymmetric(0.5) - Math.PI / 2;
  allPoints.push({
    x: config.offsetSymmetric(offset) + cx + 0.9 * rx * Math.cos(radOffset - increment),
    y: config.offsetSymmetric(offset) + cy + 0.9 * ry * Math.sin(radOffset - increment),
  });
  for (let angle = radOffset; angle < Math.PI * 2 + radOffset - 0.01; angle = angle + increment) {
    allPoints.push({
      x: config.offsetSymmetric(offset) + cx + rx * Math.cos(angle),
      y: config.offsetSymmetric(offset) + cy + ry * Math.sin(angle),
    });
  }
  allPoints.push(
    {
      x: config.offsetSymmetric(offset) + cx + rx * Math.cos(radOffset + Math.PI * 2 + overlap * 0.5),
      y: config.offsetSymmetric(offset) + cy + ry * Math.sin(radOffset + Math.PI * 2 + overlap * 0.5),
    },
    {
      x: config.offsetSymmetric(offset) + cx + 0.98 * rx * Math.cos(radOffset + overlap),
      y: config.offsetSymmetric(offset) + cy + 0.98 * ry * Math.sin(radOffset + overlap),
    },
    {
      x: config.offsetSymmetric(offset) + cx + 0.9 * rx * Math.cos(radOffset + overlap * 0.5),
      y: config.offsetSymmetric(offset) + cy + 0.9 * ry * Math.sin(radOffset + overlap * 0.5),
    },
  );
  return allPoints;
}
