// @vitest-environment jsdom
//
// Performance regression gate: the `$derived` sketch behind `<Sketch>` must
// recompute only when the shape or an option changes. When the derivation
// read the whole `rest` props object, changing `class` (or width, height,
// label) re-ran the entire rough pipeline; this test counts engine calls so
// that cannot come back silently.
import { flushSync, mount, unmount } from "svelte";
import { beforeEach, describe, expect, it, vi } from "vitest";

const actualRough = await vi.importActual<typeof import("@skribble.dev/rough")>("@skribble.dev/rough");
const spy = vi.fn((...args: Parameters<typeof actualRough.sketch>) => actualRough.sketch(...args));
vi.mock("@skribble.dev/rough", async () => ({
  ...(await vi.importActual<typeof import("@skribble.dev/rough")>("@skribble.dev/rough")),
  sketch: spy,
}));

const { default: Host, host } = await import("./host.svelte");

const shape = { type: "rectangle", x: 4, y: 4, width: 92, height: 42 } as const;

describe("<Sketch> for Svelte reactivity", () => {
  beforeEach(() => {
    host.class = "a";
    host.seed = 3;
    host.label = "One";
  });

  it("redraws only when the drawing itself changes", () => {
    const target = document.createElement("div");
    document.body.appendChild(target);
    const component = mount(Host, { target, props: { shape } });
    expect(spy.mock.calls.length).toBe(1);

    host.class = "b";
    flushSync();
    expect(target.querySelector("svg")?.getAttribute("class")).toBe("b");

    host.label = "Two";
    flushSync();
    expect(target.querySelector("svg")?.getAttribute("aria-label")).toBe("Two");

    // Class and label changes together must still cost nothing.
    expect(spy.mock.calls.length).toBe(1);

    host.seed = 4;
    flushSync();
    expect(spy.mock.calls.length).toBe(2);

    unmount(component);
    target.remove();
    spy.mockClear();
  });
});
