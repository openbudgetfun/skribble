# Changelog

Earlier unpublished versions are documented in [the pre-release development history](PRE_RELEASE_HISTORY.md).

## [0.4.0](https://github.com/openbudgetfun/skribble/releases/tag/v0.4.0) (2026-11-05)

### Features

#### Calm the Recursive lettering and protect the Noto Sketch default

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #273](https://github.com/openbudgetfun/skribble/pull/273)

Regenerate all Recursive Casual, Linear, and Mono faces with broader outline waves, no independent letter tilt, and smaller vertical movement that keeps base-outline extrema steady. Gentle, Playful, and Expressive now use strengths 6, 10, and 14 instead of 18, 27, and 36. Font names, coverage, advance widths, shaping features, and variable axes stay compatible.

The roughener CLI and `FontRoughener` now default to strength 14. Noto Sketch remains the default across light and dark themes and all roughness levels, with regression coverage for app startup and explicit Recursive selection. A reproducible specimen harness captures the bundled faces at reading sizes in both themes and narrow and wide layouts.

#### Give the Recursive lettering a gentle lean

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #274](https://github.com/openbudgetfun/skribble/pull/274)

Regenerate all 126 static faces and three variable faces with shorter, smooth waves and a deterministic per-glyph lean of at most 0.045 degrees per strength unit. Gentle, Playful, and Expressive now use strengths 12, 20, and 28, with maximum leans of 0.54, 0.9, and 1.26 degrees. Vertical movement is 0.3 of the strength, fades to zero at the base outline's top and bottom, and is reduced for short punctuation; there is no baseline bounce. Font names, coverage, advance widths, shaping, and variation axes stay compatible.

`FontRoughener` and the standalone CLI now default to strength 20 (Playful). The legacy Expressive tool and storybook copies are synchronized with the regenerated faces. Noto Sketch remains the system default, and no Noto font changed.

### Fixes

- **skribble_font_roughen lists pub.dev topics.** The package now declares `fonts`, `typography`, `hand-drawn`, `cli`, and `tooling` topics, like the other skribble packages, so it shows up in pub.dev topic searches. _Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #276](https://github.com/openbudgetfun/skribble/pull/276)

#### Every public member is documented

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #276](https://github.com/openbudgetfun/skribble/pull/276)

Every public class, member, and parameter in `skribble`, `skribble_rough`, and `skribble_font_roughen` now has a `///` doc comment that says what it does, its default, and its units. Parameters that pass straight through to Flutter, such as the `MaterialApp` options on `WiredMaterialApp`, link to the Flutter member they mirror.

`skribble_lints` now turns on `public_member_api_docs`, so `dart analyze --fatal-infos` fails on any undocumented public member in a package that includes it. It also drops the dead `missing_return` entry; the analyzer reports a missing return as the `body_might_complete_normally` compile error.

## [0.3.1](https://github.com/openbudgetfun/skribble/releases/tag/v0.3.1) (2026-10-08)

### Changed

- **No package-specific changes were recorded; `skribble_font_roughen` was updated to 0.3.1 as part of group `main`.**

## [0.3.0](https://github.com/openbudgetfun/skribble/releases/tag/v0.3.0) (2026-10-08)

### Changed

#### No package-specific changes were recorded; `skribble_font_roughen` was updated to 0.3.0 as part of group `main`.

## [0.2.1](https://github.com/openbudgetfun/skribble/releases/tag/v0.2.1) (2026-09-22)

### Changed

- **No package-specific changes were recorded; `skribble_font_roughen` was updated to 0.2.1 as part of group `main`.**

## [0.2.0](https://github.com/openbudgetfun/skribble/releases/tag/v0.2.0) (2026-09-14)

### Documentation

- **Lowercase the skribble brand word across documentation.** READMEs, docs site pages and titles, package descriptions, and source comments now write the brand word as lowercase skribble. Dart identifiers, bundled font families such as SkribbleGentle, asset names, and runtime strings keep their casing, so no API or behaviour changes. _Owner:_ Ifiok Jr. · _Introduced in:_ [5e3937c](https://github.com/openbudgetfun/skribble/commit/5e3937ccb6db77bc38e9ac95d273e018def98843) · _Last updated in:_ [77bb664](https://github.com/openbudgetfun/skribble/commit/77bb6649c58d5be1876aec0eb1cc3a2389c7dc89)

## [0.1.1](https://github.com/openbudgetfun/skribble/releases/tag/v0.1.1) (2026-09-13)

### Features

- **Add variable lettering and dedicated weights 300–900.** Ship shared variable fonts for all three roughness levels, with continuous weight, casualness, monospace, and slant axes plus cursive letterform selection. Generate matching upright and italic static weights for every bundled family. Add an interactive comparison, preserve expanded variation deltas while roughening, validate intermediate outlines and shaping, and expose variable family lookup through WiredFont. _Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #191](https://github.com/openbudgetfun/skribble/pull/191)

### Other

- **Compare experimental Casual and coding fonts.** Add a repository-only font experiment with real text ligatures, optional Casual swashes, a hand-drawn Recursive Code Casual family, and an interactive comparison. The CI job checks shaping, font metadata, character coverage and monospace advances. Published font assets and package font choices are unchanged. _Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #185](https://github.com/openbudgetfun/skribble/pull/185)

## [0.1.0](https://github.com/openbudgetfun/skribble/releases/tag/v0.1.0) (2026-09-11)

### Features

- **Generate the skribble fonts from Recursive Casual outlines.** All skribble typefaces are generated from Recursive Casual outlines via the FontForge `roughen_font.py` script, replacing the earlier Architects Daughter bundling and the `google_fonts` runtime dependency. Each family ships genuine regular, bold, italic, and bold-italic styles, produced with aggressive contour displacement applied to on-curve and off-curve Bezier control points. `WiredFont.casual`, `linear`, and `mono` are theme-level font choices, each following the Gentle, Playful, and Expressive roughness levels with matching four-style families, while `WiredThemeData.fontFamily` overrides and the Casual default are preserved. Themed pen widths, typography inheritance, clipping, and repaint stability were reworked, font spacing and shaping are preserved, the numeric roughening tool accepts named custom font families, and asset generation is reproducible with pixel regressions and a responsive notebook exercised by Patrol in Chromium. _Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #148](https://github.com/openbudgetfun/skribble/pull/148) · _Related issues:_ [#174](https://github.com/openbudgetfun/skribble/issues/174)

### Fixes

- **Correct the font notice and add a portable design kit.** Correct the Recursive-derived font notice and preserve it beside distributed font copies. Add a reproducible design kit with all bundled fonts, editable SVG pen specimens, layout metadata, and static motion references. Document Figma font upload and separate verified font and SVG icon export commands. _Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #164](https://github.com/openbudgetfun/skribble/pull/164) · _Related issues:_ [#174](https://github.com/openbudgetfun/skribble/issues/174)
