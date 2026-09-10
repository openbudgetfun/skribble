# Changelog

All notable changes to this project will be documented in this file.

This changelog is managed by [monochange](https://github.com/ifiokjr/monochange).

## skribble_maps [0.1.0](https://github.com/openbudgetfun/skribble/releases/tag/skribble_maps/v0.1.0) (2026-09-10)

### Features

- **Add hand-drawn financial charts and live chart examples.** Add precise hand-drawn financial charts with exact OHLC data, interactive viewports, indicators, annotation editing and saved workspaces. Include live chart examples in the documentation and Storybook, and improve map previews, selection feedback, and responsive layouts in both applications. _Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #166](https://github.com/openbudgetfun/skribble/pull/166)
- **Add long-press selection and gesture-friendly map layers.** Add accessible long-press callbacks to map markers and pins, loosen pin contours and icons with stable pen wobble, and document real-data loading and map gestures. Decorative feature layers no longer block pan and pinch gestures or map taps outside actionable features. Interactive demos now support holding to select and reserve mobile map gestures inside scrollable pages. _Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #167](https://github.com/openbudgetfun/skribble/pull/167)
- **Replace the custom basemap renderer with MapLibre.** Remove the direct vector-tile decoder, custom schema adapters, label placement, and rough basemap painter. `WiredMap` now uses the maintained MapLibre Flutter plugin for crisp global cartography and keeps Skribble drawing in app-owned overlays. The new pin design uses a larger typed rough icon set and low-saturation example colors. _Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #160](https://github.com/openbudgetfun/skribble/pull/160)
- **Add MapLibre maps with hand-drawn overlays.** Introduces a MapLibre-backed map package with keyless OpenFreeMap presets, interactive Wired pins and markers, rough routes and areas, zoom controls, and attribution. MapLibre owns basemap rendering, labels, tile loading, and gestures. Pins use larger hand-drawn category icons and a quieter default treatment. _Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #156](https://github.com/openbudgetfun/skribble/pull/156)

### Fixes

- **Refine map pins, colors, and route styling.** Give map pins curved, seedable ink contours, pastel category colors, quieter icons, and cream sticker edges. Keep routes geometrically exact with rounded joins and caps, and lighten area hatching so map labels stay readable. _Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #163](https://github.com/openbudgetfun/skribble/pull/163)
- **Release Skribble Maps independently.** Give `skribble_maps` its own Monochange release identity and the `skribble_maps/v<version>` tag namespace. Breaking changes in `skribble` now propagate as breaking changes in the maps package. _Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #158](https://github.com/openbudgetfun/skribble/pull/158)

## 0.0.1

- Add the initial hand-drawn vector map viewport, renderer, providers, styles, overlays, controls, documentation, and tests.
