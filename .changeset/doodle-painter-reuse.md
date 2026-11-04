---
skribble: patch
---

# `WiredDoodle` keeps its ink when its parent rebuilds

`WiredDoodle`'s painter now compares by value, like the painter bases and `WiredLogo`. Before, every parent rebuild handed `WiredCanvas` a new painter, which regenerated the doodle's curves and pen strokes and repainted it. The doodle geometry is also generated only when the canvas prepares its ink, not on every build.
