import { sketch, toSvgString } from "@skribble/rough";
import { describe, expect, it } from "vitest";
import { createSSRApp, h, nextTick, ref } from "vue";
import { renderToString } from "vue/server-renderer";
import { Sketch, useSketch } from "../src/index.js";

const shape = { type: "rectangle", x: 4, y: 4, width: 92, height: 42 } as const;

function render(props: Record<string, unknown>) {
  return renderToString(createSSRApp({ render: () => h(Sketch, props as never) }));
}

describe("<Sketch> for Vue", () => {
  it("matches the core SVG string", async () => {
    const html = await render({ shape, width: 100, height: 50, seed: 3, ink: false, fillStyle: "hachure", fill: "gold" });
    const expected = toSvgString(sketch(shape, { seed: 3, ink: false, fillStyle: "hachure", fill: "gold" }), {
      width: 100,
      height: 50,
    });
    expect(html).toBe(expected.replace(/\/>/g, "></path>"));
  });

  it("inks with the pen unless told otherwise", async () => {
    const html = await render({ shape, width: 100, height: 50, seed: 3 });
    for (const path of sketch(shape, { seed: 3 }).paths) expect(html).toContain(`d="${path.d}"`);
  });

  it("labels images and hides decoration", async () => {
    expect(await render({ shape, width: 10, height: 10 })).toContain('aria-hidden="true"');
    const labelled = await render({ shape, width: 10, height: 10, label: "A box" });
    expect(labelled).toContain('role="img" aria-label="A box"');
    expect(labelled).not.toContain("aria-hidden");
  });

  it("lets other attributes fall through", async () => {
    const html = await render({ shape, width: 10, height: 10, class: "doodle", "data-x": "1" });
    expect(html).toContain('class="doodle"');
    expect(html).toContain('data-x="1"');
  });

  it("accepts pen presets by name", async () => {
    const html = await render({ shape, width: 10, height: 10, pen: "uniform", stroke: "red" });
    expect(html).toContain('stroke="red"');
    expect(html.match(/<path /g)).toHaveLength(1);
  });
});

describe("useSketch", () => {
  it("follows reactive inputs", async () => {
    const seed = ref(1);
    const drawing = useSketch(shape, () => ({ seed: seed.value }));
    const first = drawing.value.paths;
    expect(first).toEqual(sketch(shape, { seed: 1 }).paths);
    seed.value = 2;
    await nextTick();
    expect(drawing.value.paths).toEqual(sketch(shape, { seed: 2 }).paths);
  });
});
