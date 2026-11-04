---
skribble: patch
---

# Avatar outlines stay visible over photos

`WiredAvatar` painted its photo on top of its hand-drawn circle, hiding most of the ink. The outline is now drawn over background and foreground images, and the fallback icon follows the radius after `minRadius` and `maxRadius` clamp it.
