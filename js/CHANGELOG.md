# Changelog

All notable changes to this project will be documented in this file.

This changelog is managed by [monochange](https://github.com/monochange/monochange).

## js [0.1.0](https://github.com/openbudgetfun/skribble/releases/tag/js/v0.1.0) (2026-11-07)

Grouped release for `js`.

### Features

#### Faster, safer sketches with a custom viewport and richer accessibility

_Packages:_ 🟠 _@skribble.dev/rough_, 🟠 _@skribble.dev/react_, 🟠 _@skribble.dev/react-native_, 🟠 _@skribble.dev/vue_, 🟠 _@skribble.dev/svelte_

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

### Fixes

#### Vue skips redraws for equal inline shapes, and Svelte exports SketchProps

_Packages:_ 🟢 _@skribble.dev/rough_, 🟢 _@skribble.dev/react_, 🟢 _@skribble.dev/react-native_, 🟢 _@skribble.dev/vue_, 🟢 _@skribble.dev/svelte_

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #276](https://github.com/openbudgetfun/skribble/pull/276)

Vue's `useSketch`, and so `<Sketch>`, now keys the drawing on what it draws, as the React packages do. A template that passes an inline `:shape` or option literal builds a fresh object on every render, which re-ran the whole rough pipeline whenever the parent re-rendered, for example on a `class` change. With Vue 3.4 or newer an equal shape no longer redraws; Vue 3.3 keeps the old behaviour.

`@skribble.dev/svelte` exports a `SketchProps` type, as the React, React Native, and Vue packages already did, for typing wrapper components.

Each buildable package's `main` field now points at the CommonJS build, with a `module` field for the ES modules, so tools that read `main` instead of the `exports` map can `require()` them. The `label` prop's documentation now calls it what it is, the sketch's accessible name, and the `@skribble.dev/rough` README no longer claims the package is ESM-only.

#### Empty arcs, negative boxes, and zero-length dashes no longer hang

_Packages:_ 🟢 _@skribble.dev/rough_

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #276](https://github.com/openbudgetfun/skribble/pull/276)

The JavaScript engine takes the Dart engine's arc fix. `Generator.arc`, `OpSetBuilder.arc`, and `OpSetBuilder.arcPolygon` draw nothing for a sweep that is empty (`start === stop`, such as a progress ring at zero), reversed, or not finite. Before, a zero sweep never advanced, and a reversed or infinite one walked away from its stop, so the page froze until it ran out of memory. A start angle far below zero is normalised in one step, and an arc sweep a hair above zero, or a `curveStepCount` of zero or less, finishes instead of sampling forever.

`roundedRectangle` with a negative width or height keeps square corners instead of drawing its corners inside out, as the Dart engine now does.

Other input that used to hang now finishes:

- a `"dashed"` fill whose `dashOffset` and `dashGap` add up to less than 0.1 draws undashed hachure lines;
- an edge with an infinite coordinate draws no ink and no hachure;
- an ellipse with an infinite size or a huge `curveStepCount`.

`Generator.curvePath([])` returns an empty outline instead of throwing a `TypeError`. Ordinary shapes draw exactly as before, and the Dart parity fixtures are unchanged.

### Changed

#### Draw skribble's hand-drawn shapes from JavaScript

_Packages:_ 🔴 _@skribble.dev/rough_, 🔴 _@skribble.dev/react_, 🔴 _@skribble.dev/react-native_, 🔴 _@skribble.dev/vue_, 🔴 _@skribble.dev/svelte_

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #254](https://github.com/openbudgetfun/skribble/pull/254)

`@skribble.dev/rough` is a dependency-free TypeScript port of `skribble_rough` that draws the same SVG as the Dart engine for the same seed, with a rough.js-style `rough.canvas()`, `rough.svg()`, and `rough.generator()` API and a framework-neutral `sketch()` that returns path data.

`@skribble.dev/react`, `@skribble.dev/react-native`, `@skribble.dev/vue`, and `@skribble.dev/svelte` add a `<Sketch>` component to each framework:

```tsx
import { Sketch } from "@skribble.dev/react";

<Sketch width={160} height={80} shape={{ type: "rectangle", x: 4, y: 4, width: 152, height: 72 }} fill="#ffd54f" seed={7} />;
```
