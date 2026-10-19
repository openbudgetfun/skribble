import { describe, expect, it } from "vitest";
import rough, {
  DrawConfig,
  InkStroke,
  RoughPen,
  SvgInkOutline,
  createSvgGroup,
  drawOnCanvas,
  resolvePen,
  roughFillStyles,
  sketch,
  toSvgString,
  type CanvasContextLike,
  type DocumentLike,
  type Shape,
} from "../src/index.js";

const rectangle: Shape = { type: "rectangle", x: 4, y: 4, width: 192, height: 92 };

/** Records every call a renderer makes on a canvas context. */
function recordingContext() {
  const calls: string[] = [];
  const ctx = {
    strokeStyle: "" as unknown,
    fillStyle: "" as unknown,
    lineWidth: 1,
    lineCap: "butt",
    lineJoin: "miter",
  } as CanvasContextLike & { calls: string[] };
  for (const name of [
    "beginPath",
    "moveTo",
    "lineTo",
    "bezierCurveTo",
    "quadraticCurveTo",
    "closePath",
    "stroke",
    "fill",
    "save",
    "restore",
  ]) {
    (ctx as unknown as Record<string, unknown>)[name] = () => calls.push(name);
  }
  ctx.calls = calls;
  return ctx;
}

/** A minimal DOM: just enough for createSvgGroup. */
function fakeDocument() {
  class FakeElement {
    readonly attributes: Record<string, string> = {};
    readonly children: FakeElement[] = [];
    constructor(
      readonly namespace: string,
      readonly name: string,
    ) {}
    setAttribute(key: string, value: string) {
      this.attributes[key] = value;
    }
    appendChild(child: FakeElement) {
      this.children.push(child);
      return child;
    }
  }
  return {
    createElementNS: (namespace: string, name: string) => new FakeElement(namespace, name),
  } as unknown as DocumentLike;
}

describe("sketch", () => {
  it("draws the same paths for the same seed", () => {
    expect(sketch(rectangle, { seed: 3 }).paths).toEqual(sketch(rectangle, { seed: 3 }).paths);
  });

  it("draws different paths for different seeds", () => {
    expect(sketch(rectangle, { seed: 3 }).paths).not.toEqual(sketch(rectangle, { seed: 4 }).paths);
  });

  it("inks outlines as filled pen shapes by default", () => {
    const { paths } = sketch(rectangle, { seed: 1 });
    expect(paths.length).toBeGreaterThan(1);
    for (const path of paths) {
      expect(path.part).toBe("outline");
      expect(path.fill).toBe("currentColor");
      expect(path.stroke).toBe("none");
      expect(path.d).toMatch(/^M[\d.-]+ [\d.-]+/);
    }
    expect(new Set(paths.map((path) => path.key)).size).toBe(paths.length);
  });

  it("strokes centrelines with a uniform pen or ink turned off", () => {
    for (const options of [{ pen: "uniform" as const }, { ink: false }]) {
      const { paths } = sketch(rectangle, { ...options, stroke: "red", strokeWidth: 3 });
      expect(paths).toHaveLength(1);
      expect(paths[0]).toMatchObject({ part: "outline", fill: "none", stroke: "red", strokeWidth: 3 });
    }
  });

  it("paints fills before outlines", () => {
    const { paths } = sketch(rectangle, { fillStyle: "solid", fill: "gold", ink: false });
    expect(paths.map((path) => path.part)).toEqual(["solid", "outline"]);
    expect(paths[0]).toMatchObject({ fill: "gold", stroke: "none" });
    expect(paths[0]?.d.endsWith("Z")).toBe(true);
  });

  it("strokes sketched fills with the fill colour", () => {
    for (const fillStyle of roughFillStyles.filter((style) => style !== "none" && style !== "solid")) {
      const { paths } = sketch(rectangle, { fillStyle, fill: "teal", ink: false, sketchWidth: 0.5 });
      expect(paths[0]).toMatchObject({ part: "sketch", fill: "none", stroke: "teal", strokeWidth: 0.5 });
    }
  });

  it("draws every shape type", () => {
    const shapes: Shape[] = [
      rectangle,
      { type: "roundedRectangle", x: 2, y: 2, width: 120, height: 40, radius: 8 },
      { type: "roundedRectangle", x: 2, y: 2, width: 120, height: 40, radius: [0, 4, 8, 12] },
      { type: "ellipse", x: 50, y: 30, width: 90, height: 50 },
      { type: "circle", x: 20, y: 20, diameter: 30 },
      { type: "line", x1: 0, y1: 0, x2: 100, y2: 20, arrowhead: true },
      { type: "linearPath", points: [[0, 0], [40, 10], { x: 10, y: 30 }], closed: true },
      { type: "polygon", points: [[0, 0], [40, 10], [10, 30]] },
      { type: "arc", x: 50, y: 50, width: 80, height: 80, start: 0, stop: Math.PI, closed: true },
      { type: "curve", points: [[0, 0], [30, 20], [60, 0]], arrowhead: true },
    ];
    for (const shape of shapes) {
      const result = sketch(shape, { seed: 2, fillStyle: "hachure" });
      expect(result.paths.length, shape.type).toBeGreaterThan(0);
    }
  });

  it("adds two barbs for an arrowhead", () => {
    const line: Shape = { type: "line", x1: 0, y1: 0, x2: 100, y2: 0 };
    const plain = sketch(line, { ink: false }).drawable.sets.length;
    const arrow = sketch({ ...line, arrowhead: true }, { ink: false }).drawable.sets.length;
    expect(arrow).toBe(plain + 2);
  });

  it("hachures a fill colour without a fill style, like rough.js", () => {
    const { paths } = sketch(rectangle, { fill: "red", ink: false });
    expect(paths.map((path) => path.part)).toEqual(["sketch", "outline"]);
  });

  it("draws several shapes from one stream", () => {
    const both = sketch([rectangle, { type: "circle", x: 20, y: 20, diameter: 30 }], { ink: false });
    expect(both.drawable.shape).toBe("group");
    // Each closed shape carries its (empty) fill set and its outline.
    expect(both.drawable.sets).toHaveLength(4);
  });

  it("rejects a curve with fewer than two points", () => {
    expect(() => sketch({ type: "curve", points: [[0, 0]] })).toThrow(RangeError);
  });

  it("rejects unknown fill styles and pens", () => {
    expect(() => sketch(rectangle, { fillStyle: "plaid" as never })).toThrow(RangeError);
    expect(() => resolvePen("crayon" as never)).toThrow(RangeError);
  });
});

describe("toSvgString", () => {
  it("is decorative without a label", () => {
    const svg = toSvgString(sketch(rectangle, { ink: false }), { width: 200, height: 100 });
    expect(svg).toMatch(/^<svg xmlns="http:\/\/www.w3.org\/2000\/svg" width="200" height="100" viewBox="0 0 200 100" aria-hidden="true" focusable="false">/);
    expect(svg).toContain('stroke-linecap="round"');
    expect(svg.endsWith("</svg>")).toBe(true);
  });

  it("labels and escapes", () => {
    const svg = toSvgString(sketch(rectangle, { stroke: 'a"b' }), {
      width: 10,
      height: 10,
      label: "Fish & <chips>",
      className: "doodle",
    });
    expect(svg).toContain('role="img" aria-label="Fish &amp; &lt;chips&gt;"');
    expect(svg).toContain('class="doodle"');
    expect(svg).toContain('fill="a&quot;b"');
  });
});

describe("pens", () => {
  it("recognises the uniform pen", () => {
    expect(RoughPen.uniform.isUniform).toBe(true);
    expect(RoughPen.ink.isUniform).toBe(false);
    expect(RoughPen.brush.peakWidth).toBeCloseTo(1.28);
    expect(RoughPen.ink.reach).toBeCloseTo(0.57);
  });

  it("copies and compares", () => {
    const pen = RoughPen.ink.copyWith({ pressure: 0, startWidth: undefined });
    expect(pen.pressure).toBe(0);
    expect(pen.startWidth).toBe(RoughPen.ink.startWidth);
    expect(pen.equals(RoughPen.ink)).toBe(false);
    expect(new RoughPen().equals(RoughPen.ink)).toBe(true);
  });

  it("resolves names, pens, and options", () => {
    expect(resolvePen("brush")).toBe(RoughPen.brush);
    expect(resolvePen(RoughPen.fineliner)).toBe(RoughPen.fineliner);
    expect(resolvePen({ pressure: 0.5 })?.pressure).toBe(0.5);
    expect(resolvePen(undefined)).toBeUndefined();
  });

  it("cuts ink at a distance for draw-on animation", () => {
    const { drawable } = sketch(rectangle, { seed: 5 });
    const outline = drawable.sets.find((set) => set.type === "path")!;
    const stroke = new InkStroke(outline.ops, { width: 2, pen: RoughPen.ink });
    const whole = new SvgInkOutline();
    stroke.writeOutline(whole);
    const half = new SvgInkOutline();
    stroke.writeOutline(half, stroke.length / 2);
    expect(whole.toString()).toBe(stroke.svgPathData);
    expect(half.toString().length).toBeLessThan(whole.toString().length);
    expect(half.toString().endsWith("Z")).toBe(true);
  });
});

describe("DrawConfig", () => {
  it("keeps omitted values from the defaults", () => {
    const config = DrawConfig.build({ seed: 9, roughness: undefined });
    expect(config.roughness).toBe(DrawConfig.defaultValues.roughness);
    expect(config.seed).toBe(9);
  });

  it("gives every copy its own stream", () => {
    const a = DrawConfig.build({ seed: 4 });
    a.randomizer.next();
    const b = a.copyWith({ roughness: 1 });
    expect(b.randomizer.next()).toBe(DrawConfig.build({ seed: 4 }).randomizer.next());
  });

  it("rejects fractional seeds and accepts bigint seeds", () => {
    expect(() => DrawConfig.build({ seed: 1.5 })).toThrow(RangeError);
    expect(DrawConfig.build({ seed: 7n }).randomizer.next()).toBe(DrawConfig.build({ seed: 7 }).randomizer.next());
  });
});

describe("rough.js-style API", () => {
  it("gives unseeded shapes consecutive seeds", () => {
    const generator = rough.generator({ options: { ink: false } });
    const first = generator.rectangle(0, 0, 50, 50);
    const second = generator.rectangle(0, 0, 50, 50);
    expect(first.options.seed).toBe(1);
    expect(second.options.seed).toBe(2);
    expect(generator.toPaths(first)).not.toEqual(generator.toPaths(second));
    expect(generator.rectangle(0, 0, 50, 50, { seed: 1 }).sets).toEqual(first.sets);
  });

  it("applies defaults and per-shape options", () => {
    const generator = rough.generator({ options: { stroke: "blue", fill: "pink", fillStyle: "solid" } });
    const drawable = generator.circle(20, 20, 30, { stroke: "green" });
    expect(drawable.style.stroke).toBe("green");
    expect(drawable.style.fill).toBe("pink");
    expect(drawable.sets.map((set) => set.type)).toEqual(["fillPath", "path"]);
  });

  it("draws on a canvas in paint order", () => {
    const ctx = recordingContext();
    const rc = rough.canvas(ctx);
    rc.rectangle(10, 10, 100, 50, { fillStyle: "hachure", ink: false });
    expect(ctx.calls[0]).toBe("save");
    expect(ctx.calls.at(-1)).toBe("restore");
    expect(ctx.calls.filter((call) => call === "stroke")).toHaveLength(2);
    expect(ctx.calls).toContain("bezierCurveTo");
  });

  it("fills pen ink on a canvas", () => {
    const ctx = recordingContext();
    rough.canvas({ getContext: () => ctx }).ellipse(50, 50, 80, 40, { fillStyle: "solid" });
    expect(ctx.calls).toContain("quadraticCurveTo");
    expect(ctx.calls).not.toContain("stroke");
    expect(ctx.calls.filter((call) => call === "fill").length).toBeGreaterThan(1);
  });

  it("resolves currentColor on a canvas without a DOM", () => {
    const ctx = recordingContext();
    drawOnCanvas(ctx, sketch(rectangle, { ink: false }).drawable, {
      stroke: "currentColor",
      fill: "currentColor",
      strokeWidth: 1,
      sketchWidth: 1,
      ink: false,
    });
    expect(ctx.strokeStyle).toBe("#000");
  });

  it("creates SVG groups", () => {
    const doc = fakeDocument();
    const rs = rough.svg({ ownerDocument: doc }, { options: { ink: false } });
    const group = rs.polygon([
      [0, 0],
      [50, 10],
      [20, 40],
    ]) as unknown as { name: string; children: { name: string; attributes: Record<string, string> }[] };
    expect(group.name).toBe("g");
    expect(group.children).toHaveLength(1);
    expect(group.children[0]?.attributes).toMatchObject({ fill: "none", stroke: "currentColor", "stroke-width": "1.5" });
  });

  it("needs a document for SVG groups outside the browser", () => {
    expect(() => createSvgGroup([], undefined as unknown as DocumentLike)).toThrow();
  });
});

describe("framework helpers", () => {
  it("splits sketch options from other props", async () => {
    const { splitSketchOptions } = await import("../src/index.js");
    const [options, rest] = splitSketchOptions({ seed: 3, fill: "red", className: "x", roughness: undefined });
    expect(options).toEqual({ seed: 3, fill: "red" });
    expect(rest).toEqual({ className: "x" });
  });

  it("keys sketches by what they draw", async () => {
    const { sketchKey } = await import("../src/index.js");
    expect(sketchKey(rectangle, { seed: 1 })).toBe(sketchKey({ ...rectangle }, { seed: 1 }));
    expect(sketchKey(rectangle, { seed: 1 })).not.toBe(sketchKey(rectangle, { seed: 2 }));
    expect(sketchKey(rectangle, { seed: 2n })).toContain('"2n"');
    expect(sketchKey(rectangle, { pen: RoughPen.brush })).not.toBe(sketchKey(rectangle, { pen: RoughPen.ink }));
  });
});
