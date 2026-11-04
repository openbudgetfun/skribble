---
skribble: patch
---

# `RoughBoxDecoration` hatches the same way with a shared filler

A `RoughBoxDecoration` now replays its filler's random stream before it prepares a shape, as `WiredCanvas` already did. A `filler` instance shared between decorations, or kept in a constant, used to carry on from wherever the previous box stopped, so two equal boxes hatched differently and a box re-hatched itself whenever it was resized.
