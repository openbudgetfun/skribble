---
skribble: minor
skribble_font_noto: minor
skribble_font_noto_sketch: minor
skribble_font_noto_lively: minor
---

# Skribble Noto: hand-drawn Google Noto in three packages, plus an all-scripts kit

Three new font packages redraw [Google Noto Sans](https://fonts.google.com/noto/specimen/Noto+Sans) with a round pen at three levels of hand-drawn character: `skribble_font_noto` (Soft, the calm default), `skribble_font_noto_sketch` (Sketch, with alternating letter drawings and a slight bounce), and `skribble_font_noto_lively` (Lively, with a wider pen and the strongest wobble). Each bundles Latin, Greek and Cyrillic. Every other Noto script, from Arabic and Devanagari to Chinese, Japanese and Korean, ships in a per-level font kit attached to the GitHub release by `scripts/release/publish_noto_kit.sh`.

`WiredFont` gains `noto`, `notoSketch` and `notoLively`. Unlike the Recursive families they are fixed levels, so `familyFor` ignores the roughness. `WiredFont.package`, `WiredFont.packageFor` and the `recursiveFonts` and `notoFonts` lists say which package ships a family, and `WiredThemeData.fontPackage` now resolves each family to its own package instead of always `skribble_font_recursive`. The default font is unchanged.

An exhaustive `switch` over `WiredFont` in app code needs cases for the three new values.

The generator lives in `tool/skribble_noto/` (Python: fontTools, pyclipper, scikit-image) and rebuilds byte-identical fonts from pinned Noto sources.
