import { describe, expect, it } from "vitest";
import {
  DashedFiller,
  DrawConfig,
  FillerConfig,
  Generator,
  HachureFiller,
  sketch,
  type Drawable,
  type Filler,
  type FillerConfigOptions,
} from "../src/index.js";

// Degenerate input must finish: each of these used to loop forever, run out
// of memory, or draw a shape inside out.

function generator(
  options: Parameters<typeof DrawConfig.build>[0] = { seed: 3 },
  makeFiller: (config: FillerConfig) => Filler = (config) => new HachureFiller(config),
  pattern: FillerConfigOptions = {},
): Generator {
  return new Generator(
    DrawConfig.build(options),
    makeFiller(FillerConfig.build({ ...pattern, drawConfig: DrawConfig.build(options) })),
  );
}

const opCount = (drawable: Drawable) => drawable.sets.reduce((sum, set) => sum + set.ops.length, 0);

describe("arcs", () => {
  it("draw nothing for empty, reversed, and non-finite sweeps", () => {
    for (const [start, stop] of [
      [1, 1],
      [1, 0.99],
      [Math.PI, 0],
      [-Infinity, 1],
      [0, Infinity],
      [Number.NaN, 1],
    ] as const) {
      for (const closed of [false, true]) {
        const drawable = generator().arc(50, 50, 100, 100, start, stop, closed);
        expect(opCount(drawable), `sweep ${start} to ${stop}`).toBe(0);
        // No filler ran, so the only set is the empty outline.
        expect(drawable.sets).toHaveLength(1);
      }
    }
  });

  it("keep the geometry of an ordinary sweep", () => {
    const draw = () => generator({ seed: 5 }).arc(100, 100, 160, 120, 0.3, Math.PI * 1.4, true);
    expect(opCount(draw())).toBeGreaterThan(0);
    expect(draw()).toEqual(draw());
  });

  it("finish for a far-off start and a sweep a hair above zero", () => {
    expect(opCount(generator().arc(50, 50, 100, 100, -1e12, -1e12 + 1))).toBeGreaterThan(0);
    // A progress ring at a tiny value: the sampler steps by half the sweep.
    expect(opCount(generator().arc(50, 50, 100, 100, 0, 1e-12))).toBeGreaterThan(0);
  });

  it("finish when the step count gives no forward step", () => {
    for (const curveStepCount of [-1, 1e300]) {
      generator({ seed: 3, curveStepCount }).arc(50, 50, 100, 100, 0, 1, true);
      generator({ seed: 3, curveStepCount }).ellipse(50, 50, 100, 100);
    }
  });

  it("sketch an empty progress ring as an empty drawing", () => {
    const empty = sketch({ type: "arc", x: 50, y: 50, width: 80, height: 80, start: 0, stop: 0 }, { fill: "red" });
    expect(empty.paths).toEqual([]);
  });
});

describe("rounded rectangles", () => {
  it("draw a negative size with square corners instead of inside-out ones", () => {
    for (const [width, height] of [
      [-10, 20],
      [20, -10],
    ] as const) {
      const rounded = generator({ seed: 2 }).roundedRectangle(0, 0, width, height, 4);
      const square = generator({ seed: 2 }).roundedRectangle(0, 0, width, height, 0);
      expect(rounded.sets.at(-1)?.ops.length).toBeGreaterThan(0);
      expect(rounded).toEqual(square);
    }
  });
});

describe("non-finite geometry", () => {
  it("finishes an infinite edge and inks nothing for it", () => {
    expect(sketch({ type: "line", x1: 0, y1: 0, x2: Infinity, y2: 0 }).paths).toEqual([]);
  });

  it("does not hachure an infinite box", () => {
    const drawable = generator().rectangle(0, 0, 100, Infinity);
    expect(drawable.sets[0]?.ops).toEqual([]);
  });

  it("returns no ops for a curve through no points", () => {
    expect(opCount(generator().curvePath([]))).toBe(0);
  });
});

describe("fill patterns", () => {
  it("draw undashed hachure for a dash pattern with no length", () => {
    const hachure = generator().rectangle(0, 0, 100, 100).sets[0]?.ops.length;
    for (const [dashOffset, dashGap] of [
      [0, 0],
      [-1, 1],
      [1e-12, 0],
      [Number.NaN, 2],
    ] as const) {
      const dashed = generator({ seed: 3 }, (config) => new DashedFiller(config), { dashOffset, dashGap });
      expect(dashed.rectangle(0, 0, 100, 100).sets[0]?.ops.length, `dash ${dashOffset} gap ${dashGap}`).toBe(
        hachure,
      );
    }
  });

  it("finish hachure gaps of zero or less", () => {
    for (const hachureGap of [0, -5, Infinity, Number.NaN]) {
      sketch({ type: "rectangle", x: 0, y: 0, width: 100, height: 100 }, { fill: "red", hachureGap });
    }
  });
});
