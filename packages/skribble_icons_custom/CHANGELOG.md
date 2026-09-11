# Changelog

Earlier unpublished versions are documented in [the pre-release development history](PRE_RELEASE_HISTORY.md).

## [0.1.0](https://github.com/openbudgetfun/skribble/releases/tag/v0.1.0) (2026-09-11)

### Features

- **Add the skribble_icons and skribble_icons_custom icon packages.** `skribble_icons` makes the full Material icon catalogue available as rough icons — more than 8,600 codepoints alongside a curated custom set — with roughened paths baked in at build time for 10-18x faster rendering and a unified `lookupSkribbleIconByIdentifier()` that searches custom artwork before falling back to Material. A runtime-roughening `skribble_icons_dynamic` variant was evaluated and removed again as deprioritized with zero dependents. `skribble_icons_custom` is the standalone icon-set package (hand-drawn home, search, settings, star, and favorite) generated through the `svg-manifest` kit workflow, exposing `kCustomRoughIcons`, codepoint and identifier lookups, and a `melos run rough-icons-custom` regeneration script. _Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #116](https://github.com/openbudgetfun/skribble/pull/116) · _Closed issues:_ [#111](https://github.com/openbudgetfun/skribble/issues/111), [#172](https://github.com/openbudgetfun/skribble/issues/172) · _Related issues:_ [#154](https://github.com/openbudgetfun/skribble/issues/154)
