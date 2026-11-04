---
skribble: patch
---

# Material themes keep skribble's error and marker colors

`WiredThemeData.toColorScheme` (and so `toThemeData`, `WiredMaterialTheme`, and `WiredMaterialApp`) now sets Material's `error` to the theme's `errorColor`, so Material error text and outlines match skribble's instead of a red derived from the seed color. `WiredThemeInterop.fromThemeData` and `fromColorScheme` read `errorColor` from `colorScheme.error` and `markerColor` from `colorScheme.primaryContainer`, so a round trip keeps both.
