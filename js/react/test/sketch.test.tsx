import { sketch, toSvgString } from "@skribble.dev/rough";
import { renderToStaticMarkup } from "react-dom/server";
import { describe, expect, it } from "vitest";
import { Sketch, useSketch } from "../src/index.js";

const shape = { type: "rectangle", x: 4, y: 4, width: 92, height: 42 } as const;

describe("<Sketch>", () => {
  it("renders the same paths as the core sketch()", () => {
    const html = renderToStaticMarkup(<Sketch shape={shape} width={100} height={50} seed={3} />);
    for (const path of sketch(shape, { seed: 3 }).paths) {
      expect(html).toContain(`d="${path.d}"`);
    }
  });

  it("matches the core SVG string for centrelines", () => {
    const html = renderToStaticMarkup(
      <Sketch shape={shape} width={100} height={50} seed={3} ink={false} fillStyle="hachure" fill="gold" />,
    );
    const expected = toSvgString(sketch(shape, { seed: 3, ink: false, fillStyle: "hachure", fill: "gold" }), {
      width: 100,
      height: 50,
    });
    // React closes paths with an end tag; the markup is otherwise identical.
    expect(html).toBe(expected.replaceAll("/>", "></path>"));
  });

  it("is decorative without a label", () => {
    const html = renderToStaticMarkup(<Sketch shape={shape} width={100} height={50} />);
    expect(html).toContain('aria-hidden="true"');
    expect(html).not.toContain("role=");
  });

  it("is an image with a label", () => {
    const html = renderToStaticMarkup(<Sketch shape={shape} width={100} height={50} label="A box" />);
    expect(html).toContain('role="img"');
    expect(html).toContain('aria-label="A box"');
    expect(html).not.toContain("aria-hidden");
  });

  it("passes other attributes to the svg", () => {
    const html = renderToStaticMarkup(
      <Sketch shape={shape} width={100} height={50} className="doodle" style={{ color: "red" }} data-testid="s" />,
    );
    expect(html).toContain('class="doodle"');
    expect(html).toContain('style="color:red"');
    expect(html).toContain('data-testid="s"');
    expect(html).toContain('viewBox="0 0 100 50"');
  });

  it("draws several shapes", () => {
    const html = renderToStaticMarkup(
      <Sketch
        shape={[shape, { type: "line", x1: 0, y1: 0, x2: 100, y2: 50, arrowhead: true }]}
        width={100}
        height={50}
        pen="uniform"
      />,
    );
    expect(html.match(/<path /g)).toHaveLength(1);
  });

  it("changes with the seed", () => {
    const a = renderToStaticMarkup(<Sketch shape={shape} width={100} height={50} seed={1} />);
    const b = renderToStaticMarkup(<Sketch shape={shape} width={100} height={50} seed={2} />);
    expect(a).not.toBe(b);
  });

  it("crops and zooms through a custom viewBox", () => {
    const html = renderToStaticMarkup(
      <Sketch shape={shape} width={100} height={50} viewBox="-10 -5 60 30" />,
    );
    expect(html).toContain('viewBox="-10 -5 60 30"');
    expect(html).toContain('width="100"');
  });

  it("renders a title and description", () => {
    const html = renderToStaticMarkup(
      <Sketch shape={shape} width={100} height={50} title="A box" description="A wobbling rectangle" />,
    );
    expect(html).toContain('<title>A box</title>');
    expect(html).toContain('<desc>A wobbling rectangle</desc>');
    expect(html).toContain('role="img"');
    expect(html).not.toContain("aria-hidden");
  });

  it("keeps a label as the accessible name beside a title", () => {
    const html = renderToStaticMarkup(
      <Sketch shape={shape} width={100} height={50} label="Named" title="Hovered" />,
    );
    expect(html).toContain('aria-label="Named"');
    expect(html).toContain('<title>Hovered</title>');
  });
});

describe("useSketch", () => {
  it("returns the core sketch", () => {
    let result: ReturnType<typeof useSketch> | undefined;
    function Probe() {
      result = useSketch(shape, { seed: 5 });
      return null;
    }
    renderToStaticMarkup(<Probe />);
    expect(result?.paths).toEqual(sketch(shape, { seed: 5 }).paths);
  });
});
