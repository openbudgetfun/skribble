---
skribble_maps: minor
---

# Replace the custom basemap renderer with MapLibre

Remove the direct vector-tile decoder, custom schema adapters, label placement, and rough basemap painter. `WiredMap` now uses the maintained MapLibre Flutter plugin for crisp global cartography and keeps Skribble drawing in app-owned overlays. The new pin design uses a larger typed rough icon set and low-saturation example colors.
