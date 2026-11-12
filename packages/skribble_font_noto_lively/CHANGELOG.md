# Changelog

## [0.4.1](https://github.com/openbudgetfun/skribble/releases/tag/v0.4.1) (2026-11-12)

### Changed

- **No package-specific changes were recorded; `skribble_font_noto_lively` was updated to 0.4.1 as part of group `main`.**

## [0.4.0](https://github.com/openbudgetfun/skribble/releases/tag/v0.4.0) (2026-11-07)

### Features

#### Skribble Noto: hand-drawn Google Noto in three packages, plus an all-scripts kit

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #256](https://github.com/openbudgetfun/skribble/pull/256)

Three new font packages redraw [Google Noto Sans](https://fonts.google.com/noto/specimen/Noto+Sans) with a round pen at three levels of hand-drawn character: `skribble_font_noto` (Soft, the calmest), `skribble_font_noto_sketch` (Sketch, with alternating letter drawings and a slight bounce), and `skribble_font_noto_lively` (Lively, with a wider pen and the strongest wobble). Each bundles Latin, Greek and Cyrillic. Every other Noto script, from Arabic and Devanagari to Chinese, Japanese and Korean, ships in a per-level font kit attached to the GitHub release by `scripts/release/publish_noto_kit.sh`.

`WiredFont` gains `noto`, `notoSketch` and `notoLively`. Unlike the Recursive families they are fixed levels, so `familyFor` ignores the roughness. `WiredFont.package`, `WiredFont.packageFor` and the `recursiveFonts` and `notoFonts` lists say which package ships a family, and `WiredThemeData.fontPackage` now resolves each family to its own package instead of always `skribble_font_recursive`. The default font is unchanged.

`WiredThemeData.fontFamilyFallback` lists app fonts, such as kit scripts, tried after the main family. The theme scope and the Material and Cupertino text themes now apply the bundled family by its full asset name, `WiredThemeData.qualifiedFontFamily` (for example `packages/skribble_font_recursive/SkribblePlayful`), with no `package` on the style, so app fallbacks are no longer prefixed with the font package and keep resolving. Code that compares a themed `TextStyle.fontFamily` with the bare family name should compare with `qualifiedFontFamily` instead.

An exhaustive `switch` over `WiredFont` in app code needs cases for the three new values.

The generator lives in `tool/skribble_noto/` (Python: fontTools, pyclipper, scikit-image) and rebuilds byte-identical fonts from pinned Noto sources.

### Fixes

#### Bullets keep their round shape in Skribble Noto

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #263](https://github.com/openbudgetfun/skribble/pull/263)

The generator re-stroked every large solid shape into a pen-width line, so a bullet (•), the triangular bullet (‣), and the Latin sinological dot (ꞏ) came out as tiny dots. Solid round shapes now keep their Noto outline, like the dots on i and j. No other letters change.

The all-scripts font kit also gains Mende Kikakui and Znamenny Musical Notation, the two Noto scripts it was missing, so it now has 169 files per level. `tool/skribble_noto/coverage.py` checks a built level against every Noto source.

#### The package READMEs start with a working app

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #276](https://github.com/openbudgetfun/skribble/pull/276)

The `skribble` README on pub.dev now opens with the Flutter and Dart minimums, one `flutter pub add skribble skribble_font_noto_sketch` command, and the same minimal `SkribbleApp` the docs use, including the `WiredMaterialTheme` builder that `WiredInput` and the other Material-wrapping widgets need. It adds the typeface table and the package catalog, drops the contributor-only rough icon pipeline flags (they live in `docs/rough-icon-pipeline.md`), and fixes links that pointed at files outside the package.

The font package READMEs install with `flutter pub add` instead of a pinned version; `skribble_font_recursive` still asked for `^0.1.1`.
