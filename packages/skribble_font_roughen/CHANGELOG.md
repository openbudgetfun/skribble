# Changelog

Earlier unpublished versions are documented in [the pre-release development history](PRE_RELEASE_HISTORY.md).

## [0.1.1](https://github.com/openbudgetfun/skribble/releases/tag/v0.1.1) (2026-09-12)

### Features

- **Add variable lettering and dedicated weights 300–900.** Ship shared variable fonts for all three roughness levels, with continuous weight, casualness, monospace, and slant axes plus cursive letterform selection. Generate matching upright and italic static weights for every bundled family. Add an interactive comparison, preserve expanded variation deltas while roughening, validate intermediate outlines and shaping, and expose variable family lookup through WiredFont. _Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #191](https://github.com/openbudgetfun/skribble/pull/191)

### Other

- **Compare experimental Casual and coding fonts.** Add a repository-only font experiment with real text ligatures, optional Casual swashes, a hand-drawn Recursive Code Casual family, and an interactive comparison. The CI job checks shaping, font metadata, character coverage and monospace advances. Published font assets and package font choices are unchanged. _Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #185](https://github.com/openbudgetfun/skribble/pull/185)

## [0.1.0](https://github.com/openbudgetfun/skribble/releases/tag/v0.1.0) (2026-09-11)

### Features

- **Generate the Skribble fonts from Recursive Casual outlines.** All Skribble typefaces are generated from Recursive Casual outlines via the FontForge `roughen_font.py` script, replacing the earlier Architects Daughter bundling and the `google_fonts` runtime dependency. Each family ships genuine regular, bold, italic, and bold-italic styles, produced with aggressive contour displacement applied to on-curve and off-curve Bezier control points. `WiredFont.casual`, `linear`, and `mono` are theme-level font choices, each following the Gentle, Playful, and Expressive roughness levels with matching four-style families, while `WiredThemeData.fontFamily` overrides and the Casual default are preserved. Themed pen widths, typography inheritance, clipping, and repaint stability were reworked, font spacing and shaping are preserved, the numeric roughening tool accepts named custom font families, and asset generation is reproducible with pixel regressions and a responsive notebook exercised by Patrol in Chromium. _Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #148](https://github.com/openbudgetfun/skribble/pull/148) · _Related issues:_ [#174](https://github.com/openbudgetfun/skribble/issues/174)

### Fixes

- **Correct the font notice and add a portable design kit.** Correct the Recursive-derived font notice and preserve it beside distributed font copies. Add a reproducible design kit with all bundled fonts, editable SVG pen specimens, layout metadata, and static motion references. Document Figma font upload and separate verified font and SVG icon export commands. _Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #164](https://github.com/openbudgetfun/skribble/pull/164) · _Related issues:_ [#174](https://github.com/openbudgetfun/skribble/issues/174)
