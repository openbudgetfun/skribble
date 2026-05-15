---
skribble_icons_custom: minor
skribble: patch
---

# Feat: add `skribble_icons_custom` standalone icon package and `--map-name` generator flag

Introduces `packages/skribble_icons_custom` — the first standalone Skribble
icon set package, demonstrating the `svg-manifest` kit workflow for
non-Material icon sets.

### New package: `skribble_icons_custom`

- 5 hand-drawn icons: `home`, `search`, `settings`, `star`, `favorite`
- Generated from plain SVG sources via the Skribble rough icon pipeline
- Public API:
  - `kCustomRoughIcons` — compile-time `Map<int, WiredSvgIconData>`
  - `kCustomRoughIconsCodePoints` — identifier → codepoint lookup
  - `lookupCustomRoughIconByIdentifier(String)` → `WiredSvgIconData?`
- Full test coverage (11 tests)
- New `melos run rough-icons-custom` script for regeneration

### Generator improvement: `--map-name`

Adds `--map-name <name>` flag to `generate_rough_icons.dart` so that
non-Material icon sets can name their generated Dart map constant correctly.
Defaults to `kMaterialRoughIcons` (no breaking change).
