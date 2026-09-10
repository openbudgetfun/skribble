# Changelog

Earlier unpublished versions are documented in [the pre-release development history](PRE_RELEASE_HISTORY.md).

## [0.1.0](https://github.com/openbudgetfun/skribble/releases/tag/v0.1.0) (2026-09-10)

### Features

#### Add the `skribble_icons_custom` standalone icon package

Introduces `packages/skribble_icons_custom` — the first standalone Skribble icon set package, demonstrating the `svg-manifest` kit workflow for non-Material icon sets.

###### New package: `skribble_icons_custom`

- 5 hand-drawn icons: `home`, `search`, `settings`, `star`, `favorite`
- Generated from plain SVG sources via the Skribble rough icon pipeline
- Public API:
  - `kCustomRoughIcons` — compile-time `Map<int, WiredSvgIconData>`
  - `kCustomRoughIconsCodePoints` — identifier → codepoint lookup
  - `lookupCustomRoughIconByIdentifier(String)` → `WiredSvgIconData?`
- Full test coverage (11 tests)
- New `melos run rough-icons-custom` script for regeneration

###### Generator improvement: `--map-name`

Adds `--map-name <name>` flag to `generate_rough_icons.dart` so that non-Material icon sets can name their generated Dart map constant correctly. Defaults to `kMaterialRoughIcons` (no breaking change).

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #100](https://github.com/openbudgetfun/skribble/pull/100)
