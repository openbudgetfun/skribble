---
skribble: patch
---

# Build the WiredMaterialApp shell and Material theme bridge

`WiredMaterialApp` syncs `MaterialApp` with `WiredTheme`, including a `.router` constructor that keeps `MaterialApp.router` configuration and the hand-drawn theme synchronized. The bootstrapping surface covers locale resolution, restoration, scroll behaviour, shortcuts and actions, generated titles, `onGenerateInitialRoutes`, theme animation style, navigation notifications, performance and semantics debug flags, and checkerboard overlays for near drop-in parity with `MaterialApp`. `WiredThemeData` gains `paperBackgroundColor`, `toColorScheme()`, and `toThemeData()` helpers for aligning app-level `ThemeData` with the hand-drawn palette, and `WiredScaffold` provides the hand-drawn scaffold.
