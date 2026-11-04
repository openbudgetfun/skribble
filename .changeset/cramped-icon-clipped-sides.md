---
skribble: patch
---

# crampedText ignores the clipped side of an icon's shape

`crampedText(root, icons: true)` no longer reports an icon whose shape is partly scrolled out of view or clipped, such as a chip half under an app bar. As with text, a side that a clip has cut off shows nothing to crowd.
