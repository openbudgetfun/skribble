import type { Point } from "./types.js";

/** Creates a point. */
export function point(x: number, y: number): Point {
  return { x, y };
}

/** The orientation of three ordered points, used by intersection tests. */
export const Orientation = {
  Collinear: 0,
  Clockwise: 1,
  Counterclockwise: 2,
} as const;

/** One of the {@link Orientation} values. */
export type Orientation = (typeof Orientation)[keyof typeof Orientation];

/** Returns the orientation of the ordered triplet ([p], [q], [r]). */
export function orientation(p: Point, q: Point, r: Point): Orientation {
  const value = (q.x - p.x) * (r.y - q.y) - (q.y - p.y) * (r.x - q.x);
  if (value === 0) return Orientation.Collinear;
  return value > 0 ? Orientation.Clockwise : Orientation.Counterclockwise;
}

/**
 * A segment between [source] and [target], with the geometric helpers the
 * fill algorithms use.
 */
export class Line {
  constructor(
    public source: Point,
    public target: Point,
  ) {}

  get length(): number {
    const dx = this.source.x - this.target.x;
    const dy = this.source.y - this.target.y;
    return Math.sqrt(dx * dx + dy * dy);
  }

  onSegment(p: Point): boolean {
    const { source, target } = this;
    return (
      p.x <= Math.max(source.x, target.x) &&
      p.x >= Math.min(source.x, target.x) &&
      p.y <= Math.max(source.y, target.y) &&
      p.y >= Math.min(source.y, target.y)
    );
  }

  intersects(line: Line): boolean {
    const { source, target } = this;
    const o1 = orientation(source, target, line.source);
    const o2 = orientation(source, target, line.target);
    const o3 = orientation(line.source, line.target, source);
    const o4 = orientation(line.source, line.target, target);

    if (o1 !== o2 && o3 !== o4) return true;
    if (o1 === Orientation.Collinear && new Line(source, target).onSegment(line.source)) {
      return true;
    }
    if (o2 === Orientation.Collinear && new Line(source, target).onSegment(line.target)) {
      return true;
    }
    if (o3 === Orientation.Collinear && new Line(line.source, line.target).onSegment(source)) {
      return true;
    }
    if (o4 === Orientation.Collinear && new Line(line.source, line.target).onSegment(target)) {
      return true;
    }
    return false;
  }

  intersectionWith(line: Line): Point | null {
    const { source, target } = this;
    const yDiff = target.y - source.y;
    const xDiff = source.x - target.x;
    const diff = yDiff * source.x + xDiff * source.y;
    const lineYDiff = line.target.y - line.source.y;
    const lineXDiff = line.source.x - line.target.x;
    const lineDiff = lineYDiff * line.source.x + lineXDiff * line.source.y;
    const determinant = yDiff * lineXDiff - lineYDiff * xDiff;

    return determinant !== 0
      ? {
          x: (lineXDiff * diff - xDiff * lineDiff) / determinant,
          y: (yDiff * lineDiff - lineYDiff * diff) / determinant,
        }
      : null;
  }

  isMidPointInPolygon(polygon: readonly Point[]): boolean {
    return isInPolygon(
      { x: (this.source.x + this.target.x) / 2, y: (this.source.y + this.target.y) / 2 },
      polygon,
    );
  }
}

/** Whether [p] lies inside the polygon through [points]. */
export function isInPolygon(p: Point, points: readonly Point[]): boolean {
  const vertices = points.length;
  if (vertices < 3) return false;

  const extreme: Point = { x: Number.MAX_VALUE, y: p.y };
  let count = 0;
  for (let i = 0; i < vertices; i++) {
    const current = points[i] as Point;
    const next = points[(i + 1) % vertices] as Point;
    if (new Line(current, next).intersects(new Line(p, extreme))) {
      if (orientation(current, p, next) === Orientation.Collinear) {
        return new Line(current, next).onSegment(p);
      }
      count++;
    }
  }
  return count % 2 === 1;
}

/** Rotates [p] around [center] by [degrees]. */
export function rotatePoint(p: Point, center: Point, degrees: number): Point {
  const angle = (Math.PI / 180) * degrees;
  const cos = Math.cos(angle);
  const sin = Math.sin(angle);
  return {
    x: (p.x - center.x) * cos - (p.y - center.y) * sin + center.x,
    y: (p.x - center.x) * sin + (p.y - center.y) * cos + center.y,
  };
}

/** Rotates every point in [points] around [center] by [degrees]. */
export function rotatePoints(points: readonly Point[], center: Point, degrees: number): Point[] {
  return points.map((p) => rotatePoint(p, center, degrees));
}

/** Rotates both ends of every line around [center] by [degrees]. */
export function rotateLines(lines: readonly Line[], center: Point, degrees: number): Line[] {
  return lines.map(
    (line) => new Line(rotatePoint(line.source, center, degrees), rotatePoint(line.target, center, degrees)),
  );
}
