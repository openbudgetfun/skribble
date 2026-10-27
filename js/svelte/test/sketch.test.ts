import { sketch, toSvgString } from "@skribble.dev/rough";
import { render } from "svelte/server";
import { describe, expect, it } from "vitest";
import { Sketch } from "../src/lib/index.js";

const shape = { type: "rectangle", x: 4, y: 4, width: 92, height: 42 } as const;

/** The rendered markup without Svelte's hydration comments. */
function html(props: Record<string, unknown>): string {
  return render(Sketch, { props: props as never }).body.replace(/<!--[^>]*-->/g, "");
}

describe("<Sketch> for Svelte", () => {
  it("paints the core sketch's paths", () => {
    const body = html({ shape, width: 100, height: 50, seed: 3, ink: false, fillStyle: "hachure", fill: "gold" });
    const expected = toSvgString(sketch(shape, { seed: 3, ink: false, fillStyle: "hachure", fill: "gold" }), {
      width: 100,
      height: 50,
    });
    for (const path of expected.match(/<path [^>]*>/g) ?? []) {
      expect(body).toContain(path.replace(/\/>$/, "></path>"));
    }
    expect(body).toContain('viewBox="0 0 100 50"');
  });

  it("inks with the pen by default", () => {
    const body = html({ shape, width: 100, height: 50, seed: 3 });
    const { paths } = sketch(shape, { seed: 3 });
    expect(body.match(/<path /g)).toHaveLength(paths.length);
  });

  it("labels images and hides decoration", () => {
    expect(html({ shape, width: 10, height: 10 })).toContain('aria-hidden="true"');
    const labelled = html({ shape, width: 10, height: 10, label: "A box" });
    expect(labelled).toContain('role="img"');
    expect(labelled).toContain('aria-label="A box"');
    expect(labelled).not.toContain("aria-hidden");
  });

  it("passes other attributes to the svg", () => {
    const body = html({ shape, width: 10, height: 10, class: "doodle", "data-x": "1" });
    expect(body).toContain('class="doodle"');
    expect(body).toContain('data-x="1"');
  });

  it("crops and zooms through a custom viewBox", () => {
    const body = html({ shape, width: 100, height: 50, viewBox: "-10 -5 60 30" });
    expect(body).toContain('viewBox="-10 -5 60 30"');
    expect(body).toContain('width="100"');
  });

  it("renders a title and description", () => {
    const body = html({ shape, width: 10, height: 10, title: "A box", description: "A wobbling rectangle" });
    expect(body).toContain("<title>A box</title>");
    expect(body).toContain("<desc>A wobbling rectangle</desc>");
    expect(body).toContain('role="img"');
    expect(body).not.toContain("aria-hidden");
  });

  it("keeps a label as the accessible name beside a title", () => {
    const body = html({ shape, width: 10, height: 10, label: "Named", title: "Hovered" });
    expect(body).toContain('aria-label="Named"');
    expect(body).toContain("<title>Hovered</title>");
  });
});
