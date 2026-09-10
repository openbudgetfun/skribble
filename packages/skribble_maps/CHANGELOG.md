# Changelog

All notable changes to this project will be documented in this file.

This changelog is managed by [monochange](https://github.com/ifiokjr/monochange).

## skribble_maps [0.1.0](https://github.com/openbudgetfun/skribble/releases/tag/skribble_maps/v0.1.0) (2026-09-10)

### Features

- **Add the hand-drawn maps package on MapLibre.** `skribble_maps` renders crisp global cartography through the MapLibre Flutter plugin with keyless OpenFreeMap presets — MapLibre owns basemap tiles, labels, and gestures while Skribble draws in app-owned overlays (an earlier custom vector-tile decoder, schema adapters, label placement, and rough basemap painter were removed in favour of the plugin). Hand-drawn overlays include pins with curved seedable ink contours, pastel category colours, cream sticker edges, and larger typed rough category icons; routes stay geometrically exact with rounded joins and caps; area hatching stays light so map labels remain readable. Markers and pins expose accessible long-press callbacks, decorative feature layers never block pan, pinch, or taps outside actionable features, demos support hold-to-select and reserve mobile map gestures inside scrollable pages, and documentation covers real-data loading. The package releases independently with the `skribble_maps/v<version>` tag namespace, and breaking `skribble` changes propagate as breaking maps changes. _Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #156](https://github.com/openbudgetfun/skribble/pull/156)

## 0.0.1

- Add the initial hand-drawn vector map viewport, renderer, providers, styles, overlays, controls, documentation, and tests.
