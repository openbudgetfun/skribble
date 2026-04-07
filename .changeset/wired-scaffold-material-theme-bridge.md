---
skribble: patch
---

Add `WiredScaffold` as a Material shell with Skribble's paper-like background,
introduce `WiredMaterialApp` for syncing `MaterialApp` with `WiredTheme`, and
extend `WiredThemeData` with `paperBackgroundColor`, `toColorScheme()`, and
`toThemeData()` helpers for aligning app-level `ThemeData` with the
hand-drawn palette.
