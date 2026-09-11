---
skribble: patch
---

# Stop rebuilding a themed subtree when the theme has not changed

`WiredThemeData` had no value equality, so the inherited theme compared object identity and notified every descendant on each rebuild — the documented `copyWith`-per-build pattern rebuilt the whole subtree every frame. Theme data now compares by value and builds its `DrawConfig` once per instance, and `WiredMaterialApp` caches its four `ThemeData` conversions instead of re-running `ColorScheme.fromSeed` on each frame. System dark mode and high contrast are read through `MediaQuery`, so toggling either repaints the app rather than waiting for an unrelated rebuild.
