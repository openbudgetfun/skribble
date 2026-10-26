// @vitest-environment jsdom
//
// Performance regression gates: these tests count how often the rough engine
// runs while a parent re-renders `<Sketch>`. A sketch that redraws on an
// unrelated prop change, or on a new-but-equal shape object, is a regression
// that turns every parent render into full geometry regeneration.
import { act } from "react";
import { createRoot, type Root } from "react-dom/client";
import { afterEach, beforeEach, describe, expect, it, vi } from "vitest";

vi.mock("@skribble.dev/rough", async (importOriginal) => {
  const actual = await importOriginal<typeof import("@skribble.dev/rough")>();
  return { ...actual, sketch: vi.fn(actual.sketch), splitSketchOptions: vi.fn(actual.splitSketchOptions) };
});

const { Sketch } = await import("../src/index.js");
const { sketch, splitSketchOptions } = await import("@skribble.dev/rough");
const sketchSpy = vi.mocked(sketch);
const splitSpy = vi.mocked(splitSketchOptions);

let container: HTMLElement;
let root: Root;

beforeEach(() => {
  (globalThis as { IS_REACT_ACT_ENVIRONMENT?: boolean }).IS_REACT_ACT_ENVIRONMENT = true;
  container = document.createElement("div");
  document.body.appendChild(container);
  root = createRoot(container);
});

afterEach(() => {
  act(() => root.unmount());
  container.remove();
  sketchSpy.mockClear();
  splitSpy.mockClear();
});

function render(element: React.ReactElement) {
  act(() => root.render(element));
}

const shape = { type: "rectangle", x: 4, y: 4, width: 92, height: 42 } as const;

describe("<Sketch> memoisation", () => {
  it("does not redraw when the parent re-renders with equal inline props", () => {
    render(<Sketch shape={{ ...shape }} width={100} height={50} seed={3} color="tomato" />);
    const sketches = sketchSpy.mock.calls.length;
    const renders = splitSpy.mock.calls.length;

    render(<Sketch shape={{ ...shape }} width={100} height={50} seed={3} color="tomato" />);

    expect(sketchSpy.mock.calls.length).toBe(sketches);
    expect(splitSpy.mock.calls.length).toBe(renders);
  });

  it("does not redraw when only a presentational prop changes", () => {
    render(<Sketch shape={shape} width={100} height={50} seed={3} color="tomato" />);
    const sketches = sketchSpy.mock.calls.length;
    const renders = splitSpy.mock.calls.length;

    render(<Sketch shape={shape} width={100} height={50} seed={3} color="plum" />);
    expect(container.querySelector("svg")?.getAttribute("color")).toBe("plum");
    expect(sketchSpy.mock.calls.length).toBe(sketches);
    expect(splitSpy.mock.calls.length).toBeGreaterThan(renders);
  });

  it("redraws when an option that changes the drawing changes", () => {
    render(<Sketch shape={shape} width={100} height={50} seed={3} />);
    expect(sketchSpy.mock.calls.length).toBe(1);

    render(<Sketch shape={shape} width={100} height={50} seed={4} />);
    expect(sketchSpy.mock.calls.length).toBe(2);
  });
});
