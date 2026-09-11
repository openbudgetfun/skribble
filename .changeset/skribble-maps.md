---
skribble_maps: minor
---

# Add the hand-drawn maps package on MapLibre

`skribble_maps` renders crisp global cartography through the MapLibre Flutter plugin with keyless OpenFreeMap presets — MapLibre owns basemap tiles, labels, and gestures while Skribble draws in app-owned overlays (an earlier custom vector-tile decoder, schema adapters, label placement, and rough basemap painter were removed in favour of the plugin). Hand-drawn overlays include pins with curved seedable ink contours, pastel category colours, cream sticker edges, and larger typed rough category icons; routes stay geometrically exact with rounded joins and caps; area hatching stays light so map labels remain readable. Markers and pins expose accessible long-press callbacks, decorative feature layers never block pan, pinch, or taps outside actionable features, demos support hold-to-select and reserve mobile map gestures inside scrollable pages, and documentation covers real-data loading. The package releases independently with the `skribble_maps/v<version>` tag namespace, and breaking `skribble` changes propagate as breaking maps changes.
