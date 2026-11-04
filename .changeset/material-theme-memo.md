---
skribble: patch
---

# `WiredMaterialTheme` keeps its Material theme across rebuilds

`WiredMaterialTheme` converts its Wired theme to a Material `ThemeData` once per distinct theme and brightness, instead of on every build. Used as a `SkribbleApp` builder it rebuilt with the app, each time running `ColorScheme.fromSeed` and handing every Material descendant a new theme. `WiredThemeData` also gains dartdoc for its colours, stroke width, constructor, `defaultTheme`, and `copyWith`.
