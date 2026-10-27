// @vitest-environment jsdom
//
// Performance regression gate: the sketch behind `<Sketch>` must recompute
// only when the shape or an option changes. Before the options getter read
// the whole reactive `props` object, changing `class` (or width, height,
// label) re-ran the entire rough pipeline; these tests count engine calls so
// that cannot come back silently.
import { createApp, defineComponent, h, nextTick, ref } from "vue";
import { afterEach, beforeEach, describe, expect, it, vi } from "vitest";

vi.mock("@skribble.dev/rough", async (importOriginal) => {
  const actual = await importOriginal<typeof import("@skribble.dev/rough")>();
  return { ...actual, sketch: vi.fn(actual.sketch) };
});

const { Sketch, useSketch } = await import("../src/index.js");
const { sketch } = await import("@skribble.dev/rough");
const sketchSpy = vi.mocked(sketch);

const shape = { type: "rectangle", x: 4, y: 4, width: 92, height: 42 } as const;

let container: HTMLElement;

beforeEach(() => {
  container = document.createElement("div");
  document.body.appendChild(container);
});

afterEach(() => {
  container.remove();
  sketchSpy.mockClear();
});

describe("<Sketch> for Vue reactivity", () => {
  it("does not redraw when only the class changes, and redraws when the seed does", async () => {
    const klass = ref("a");
    const seed = ref(3);
    const Host = defineComponent({
      render: () => h(Sketch as never, { shape, width: 100, height: 50, seed: seed.value, class: klass.value }),
    });
    const app = createApp(Host);
    app.mount(container);
    expect(sketchSpy.mock.calls.length).toBe(1);

    klass.value = "b";
    await nextTick();
    expect(container.querySelector("svg")?.getAttribute("class")).toBe("b");
    expect(sketchSpy.mock.calls.length).toBe(1);

    seed.value = 4;
    await nextTick();
    expect(sketchSpy.mock.calls.length).toBe(2);

    app.unmount();
  });

  it("does not redraw when only the label changes", async () => {
    const label = ref("One");
    const Host = defineComponent({
      render: () => h(Sketch as never, { shape, width: 100, height: 50, label: label.value }),
    });
    const app = createApp(Host);
    app.mount(container);
    expect(sketchSpy.mock.calls.length).toBe(1);

    label.value = "Two";
    await nextTick();
    expect(container.querySelector("svg")?.getAttribute("aria-label")).toBe("Two");
    expect(sketchSpy.mock.calls.length).toBe(1);

    app.unmount();
  });
});

describe("useSketch", () => {
  it("follows reactive inputs without recomputing on unrelated changes", async () => {
    const seed = ref(1);
    const drawing = useSketch(() => shape, () => ({ seed: seed.value }));
    expect(drawing.value.paths).toEqual(sketch(shape, { seed: 1 }).paths);
    const redrawn = sketch(shape, { seed: 2 }).paths;
    const calls = sketchSpy.mock.calls.length;

    seed.value = 2;
    await nextTick();
    // Computeds are lazy: reading the drawing is what recomputes it.
    expect(drawing.value.paths).toEqual(redrawn);
    expect(sketchSpy.mock.calls.length).toBe(calls + 1);
  });
});
