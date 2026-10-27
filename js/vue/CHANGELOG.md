# Changelog

All notable changes to this project will be documented in this file.

This changelog is managed by [monochange](https://github.com/monochange/monochange).

## js [0.1.0](https://github.com/openbudgetfun/skribble/releases/tag/js/v0.1.0) (2026-10-27)

### Features

#### Faster, safer sketches with a custom viewport and richer accessibility

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #269](https://github.com/openbudgetfun/skribble/pull/269)

##### Faster

`<Sketch>` now re-sketches only when the drawing itself changes. React and React Native memoise the component on a value key, so inline shape and option objects work without caller-side `useMemo`; Vue and Svelte derive options by reading only the option keys, so toggling a `class` or changing a label stops re-running the rough pipeline. Call-count regression tests in every package pin this behaviour, and `@skribble.dev/rough` gains a benchmark suite (`pnpm run bench`) wired into CI as a visible record.

```ts
import { pickSketchOptions } from "@skribble.dev/rough";
```

`pickSketchOptions(props)` joins `splitSketchOptions` for reactive frameworks: it reads nothing but the sketch-option keys.

##### New props

- `viewBox` overrides the default `"0 0 width height"` viewport on every `<Sketch>`, so shapes can crop, zoom, or use coordinates outside the positive quadrant.
- `title` and `description` render SVG `<title>` (also the browser's hover tooltip and a fallback accessible name) and `<desc>` elements on the web packages, and `toSvgString` accepts them too.
- The Vue package exports its `SketchProps` interface for wrapper components.

##### Compatibility and safety

React packages now require React 19 or newer (React Native 0.76+); `ref` behaves as a normal prop. All four buildable packages ship dual ESM/CJS bundles so Jest and other CommonJS tooling can `require()` them; the Svelte package stays compiled ESM source, the distribution Svelte bundlers consume. A filler constructed without a configuration now owns a fresh default random stream instead of advancing one shared stream, so identical calls draw identically regardless of order. Path data is validated before it is interpolated into SVG strings, so hand-assembled paths can never smuggle markup into a document.

### Changed

#### Draw skribble's hand-drawn shapes from JavaScript

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #254](https://github.com/openbudgetfun/skribble/pull/254)

`@skribble.dev/rough` is a dependency-free TypeScript port of `skribble_rough` that draws the same SVG as the Dart engine for the same seed, with a rough.js-style `rough.canvas()`, `rough.svg()`, and `rough.generator()` API and a framework-neutral `sketch()` that returns path data.

`@skribble.dev/react`, `@skribble.dev/react-native`, `@skribble.dev/vue`, and `@skribble.dev/svelte` add a `<Sketch>` component to each framework:

```tsx
import { Sketch } from "@skribble.dev/react";

<Sketch width={160} height={80} shape={{ type: "rectangle", x: 4, y: 4, width: 152, height: 72 }} fill="#ffd54f" seed={7} />;
```
