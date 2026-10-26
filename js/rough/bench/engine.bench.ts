/**
 * Benchmarks for the engine's hot paths: the full `sketch` pipeline (rough
 * generation, fill scanline, pen-ink sampling, SVG path output), the
 * `sketchKey` serialization that guards every framework memo, and the
 * `Randomizer` stream underlying it all.
 *
 * Run with `pnpm run bench`. Numbers are for comparing changes on one
 * machine; CI runs them on every PR as a visible, non-gating record.
 */
import { bench, describe } from "vitest";
import { Randomizer, sketch, sketchKey, type Shape } from "../src/index.js";

const rectangle: Shape = { type: "rectangle", x: 4, y: 4, width: 192, height: 92 };
const ellipse: Shape = { type: "ellipse", x: 100, y: 50, width: 180, height: 80 };
const squiggle: Shape = {
  type: "curve",
  points: [
    [4, 50],
    [40, 10],
    [80, 40],
    [116, 12],
    [150, 46],
    [186, 20],
  ],
};

describe("sketch", () => {
  bench("outline-only rectangle", () => {
    sketch(rectangle, { seed: 3 });
  });

  bench("hachure-filled rectangle with ink", () => {
    sketch(rectangle, { seed: 3, fill: "gold", fillStyle: "hachure" });
  });

  bench("dotted ellipse with ink", () => {
    sketch(ellipse, { seed: 3, fill: "gold", fillStyle: "dots" });
  });

  bench("arrowed curve with ink", () => {
    sketch({ ...squiggle, arrowhead: true }, { seed: 3 });
  });

  bench("eight-shape scene", () => {
    const scene = Array.from({ length: 8 }, (_, index): Shape => ({
      type: "roundedRectangle",
      x: 4 + index * 12,
      y: 4 + index * 8,
      width: 120,
      height: 64,
      radius: 8,
    }));
    sketch(scene, { seed: 3, fill: "gold" });
  });
});

describe("memo keys", () => {
  bench("sketchKey of a rectangle with options", () => {
    sketchKey(rectangle, { seed: 3, fill: "gold", roughness: 1.1, hachureGap: 8 });
  });
});

describe("random stream", () => {
  bench("Randomizer construction plus 1000 draws", () => {
    const random = new Randomizer(3);
    let total = 0;
    for (let i = 0; i < 1000; i++) total += random.next();
    return total;
  });
});
