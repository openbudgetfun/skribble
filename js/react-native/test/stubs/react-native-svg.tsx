// A DOM stand-in for react-native-svg, so components render with react-dom.
// Native-only props become data attributes the tests can read.
import { createElement, type ReactNode } from "react";

type Props = Record<string, unknown> & { children?: ReactNode };

function toDom(props: Props): Record<string, unknown> {
  const result: Record<string, unknown> = {};
  for (const [key, value] of Object.entries(props)) {
    if (/^(accessib|important)/.test(key)) result[`data-${key.toLowerCase()}`] = String(value);
    else result[key] = value;
  }
  return result;
}

export function Svg(props: Props) {
  return createElement("svg", toDom(props), props.children);
}

export function Path(props: Props) {
  return createElement("path", toDom(props));
}

export type SvgProps = Props;
