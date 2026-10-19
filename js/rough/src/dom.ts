import { formatNumber } from "./math.js";
import type { SketchPath } from "./sketch.js";

const SVG_NS = "http://www.w3.org/2000/svg";

/** The subset of `Document` the DOM renderer uses. */
export interface DocumentLike {
  createElementNS(namespace: string, name: string): Element;
}

/**
 * Creates `<path>` elements for [paths], grouped in an SVG `<g>`.
 * Pass the document that will own the elements; defaults to the global one.
 */
export function createSvgGroup(
  paths: readonly SketchPath[],
  doc: DocumentLike = (globalThis as { document?: DocumentLike }).document as DocumentLike,
): SVGGElement {
  if (!doc) throw new Error("createSvgGroup needs a document outside the browser");
  const group = doc.createElementNS(SVG_NS, "g") as SVGGElement;
  for (const path of paths) {
    const element = doc.createElementNS(SVG_NS, "path");
    element.setAttribute("d", path.d);
    element.setAttribute("fill", path.fill);
    element.setAttribute("stroke", path.stroke);
    if (path.stroke !== "none") {
      element.setAttribute("stroke-width", formatNumber(path.strokeWidth, 2));
      element.setAttribute("stroke-linecap", "round");
      element.setAttribute("stroke-linejoin", "round");
    }
    group.appendChild(element);
  }
  return group;
}
