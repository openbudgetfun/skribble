---
"@skribble.dev/rough": minor
"@skribble.dev/react": minor
"@skribble.dev/react-native": minor
"@skribble.dev/vue": minor
"@skribble.dev/svelte": minor
---

# Faster, safer sketches with a custom viewport and richer accessibility

## Faster

`<Sketch>` now re-sketches only when the drawing itself changes. React and React Native memoise the component on a value key, so inline shape and option objects work without caller-side `useMemo`; Vue and Svelte derive options by reading only the option keys, so toggling a `class` or changing a label stops re-running the rough pipeline. Call-count regression tests in every package pin this behaviour, and `@skribble.dev/rough` gains a benchmark suite (`pnpm run bench`) wired into CI as a visible record.

```ts
import { pickSketchOptions } from "@skribble.dev/rough";
```

`pickSketchOptions(props)` joins `splitSketchOptions` for reactive frameworks: it reads nothing but the sketch-option keys.

## New props

- `viewBox` overrides the default `"0 0 width height"` viewport on every `<Sketch>`, so shapes can crop, zoom, or use coordinates outside the positive quadrant.
- `title` and `description` render SVG `<title>` (also the browser's hover tooltip and a fallback accessible name) and `<desc>` elements on the web packages, and `toSvgString` accepts them too.
- The Vue package exports its `SketchProps` interface for wrapper components.

## Compatibility and safety

React packages now require React 19 or newer (React Native 0.76+); `ref` behaves as a normal prop. All four buildable packages ship dual ESM/CJS bundles so Jest and other CommonJS tooling can `require()` them; the Svelte package stays compiled ESM source, the distribution Svelte bundlers consume. A filler constructed without a configuration now owns a fresh default random stream instead of advancing one shared stream, so identical calls draw identically regardless of order. Path data is validated before it is interpolated into SVG strings, so hand-assembled paths can never smuggle markup into a document.
