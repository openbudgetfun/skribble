---
skribble: patch
skribble_font_noto: patch
skribble_font_noto_sketch: patch
skribble_font_noto_lively: patch
skribble_font_recursive: patch
---

# The package READMEs start with a working app

The `skribble` README on pub.dev now opens with the Flutter and Dart minimums, one `flutter pub add skribble skribble_font_noto_sketch` command, and the same minimal `SkribbleApp` the docs use, including the `WiredMaterialTheme` builder that `WiredInput` and the other Material-wrapping widgets need. It adds the typeface table and the package catalog, drops the contributor-only rough icon pipeline flags (they live in `docs/rough-icon-pipeline.md`), and fixes links that pointed at files outside the package.

The font package READMEs install with `flutter pub add` instead of a pinned version; `skribble_font_recursive` still asked for `^0.1.1`.
