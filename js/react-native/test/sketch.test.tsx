import { sketch } from "@skribble.dev/rough";
import { renderToStaticMarkup } from "react-dom/server";
import { describe, expect, it } from "vitest";
import { Sketch, useSketch } from "../src/index.js";

const shape = { type: "ellipse", x: 50, y: 25, width: 90, height: 40 } as const;

describe("<Sketch> on React Native", () => {
  it("paints the core sketch's paths", () => {
    const html = renderToStaticMarkup(<Sketch shape={shape} width={100} height={50} seed={4} fillStyle="dots" />);
    const { paths } = sketch(shape, { seed: 4, fillStyle: "dots" });
    expect(html.match(/<path /g)).toHaveLength(paths.length);
    for (const path of paths) expect(html).toContain(`d="${path.d}"`);
    expect(html).toContain('viewBox="0 0 100 50"');
  });

  it("strokes centrelines with a uniform pen", () => {
    const html = renderToStaticMarkup(<Sketch shape={shape} width={100} height={50} pen="uniform" stroke="#123" />);
    expect(html).toContain('stroke="#123"');
    expect(html).toContain('stroke-linecap="round"');
  });

  it("hides decorative sketches from screen readers", () => {
    const html = renderToStaticMarkup(<Sketch shape={shape} width={100} height={50} />);
    expect(html).toContain('data-accessibilityelementshidden="true"');
    expect(html).toContain('data-importantforaccessibility="no-hide-descendants"');
  });

  it("labels images for screen readers", () => {
    const html = renderToStaticMarkup(<Sketch shape={shape} width={100} height={50} label="A ring" />);
    expect(html).toContain('data-accessibilitylabel="A ring"');
    expect(html).toContain('data-accessibilityrole="image"');
    expect(html).not.toContain("data-accessibilityelementshidden");
  });

  it("passes other props to the Svg", () => {
    const html = renderToStaticMarkup(<Sketch shape={shape} width={100} height={50} color="tomato" />);
    expect(html).toContain('color="tomato"');
  });

  it("memoises through useSketch", () => {
    let result: ReturnType<typeof useSketch> | undefined;
    function Probe() {
      result = useSketch(shape, { seed: 9 });
      return null;
    }
    renderToStaticMarkup(<Probe />);
    expect(result?.paths).toEqual(sketch(shape, { seed: 9 }).paths);
  });

  it("crops and zooms through a custom viewBox", () => {
    const html = renderToStaticMarkup(<Sketch shape={shape} width={100} height={50} viewBox="-10 -5 60 30" />);
    expect(html).toContain('viewBox="-10 -5 60 30"');
    expect(html).toContain('width="100"');
  });
});
