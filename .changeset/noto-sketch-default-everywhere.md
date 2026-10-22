---
skribble_jaspr: minor
skribble: patch
---

# Noto Sketch is the default lettering outside Flutter too

`skribbleCss` now lists `SkribbleNotoSketch` first in `--skribble-font`, then a locally installed "Skribble Noto Sketch", then the previous Recursive `Skribble` family, so pages that self-host only the old font keep working. Self-host `SkribbleNotoSketch-Regular.ttf` from `skribble_font_noto_sketch` to use the default.

`WiredLoadingScreen`, `WiredCupertinoPicker`, and `WiredCupertinoDatePicker` now pass the theme's `fontFamilyFallback` through with the qualified family, so kit scripts such as Japanese or Korean render in Noto Sketch there as well. The design kit exported by `packages/skribble/tool/design_kit.dart` includes the three Skribble Noto faces, with Noto Sketch marked as the default.
