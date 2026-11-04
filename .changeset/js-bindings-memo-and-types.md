---
"@skribble.dev/vue": patch
"@skribble.dev/svelte": patch
"@skribble.dev/rough": patch
"@skribble.dev/react": patch
"@skribble.dev/react-native": patch
---

# Vue skips redraws for equal inline shapes, and Svelte exports SketchProps

Vue's `useSketch`, and so `<Sketch>`, now keys the drawing on what it draws, as the React packages do. A template that passes an inline `:shape` or option literal builds a fresh object on every render, which re-ran the whole rough pipeline whenever the parent re-rendered, for example on a `class` change. With Vue 3.4 or newer an equal shape no longer redraws; Vue 3.3 keeps the old behaviour.

`@skribble.dev/svelte` exports a `SketchProps` type, as the React, React Native, and Vue packages already did, for typing wrapper components.

Each buildable package's `main` field now points at the CommonJS build, with a `module` field for the ES modules, so tools that read `main` instead of the `exports` map can `require()` them. The `label` prop's documentation now calls it what it is, the sketch's accessible name, and the `@skribble.dev/rough` README no longer claims the package is ESM-only.
