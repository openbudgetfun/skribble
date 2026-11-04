---
skribble: patch
---

# Pull to refresh works with a real drag

`WiredCustomRefreshIndicator` only refreshed when a single overscroll step passed 50 pixels, which a real drag almost never does, and never on iOS, where lists bounce instead of reporting overscroll. It now adds up the pull across the drag, handles clamping and bouncing physics, refreshes once per pull, and no longer writes to its state when a refresh finishes after the widget is gone.
