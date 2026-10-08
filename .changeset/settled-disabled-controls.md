---
skribble: patch
---

# Disabled switches, toggles, and action buttons settle again

A switch, toggle, or floating action button that could not be activated changed its focus node every time it rebuilt: the hook that created the node made it focusable again, and the keyboard layer added in 0.3.0 made it unfocusable. Each flip notified the node's listeners and scheduled another frame, so a screen that rebuilt in response, such as one locking a settings switch while it records, never settled and `pumpAndSettle` timed out in its tests.

The keyboard layer now owns whether the node can take focus, and rebuilding a control that cannot be activated leaves its focus node untouched.
