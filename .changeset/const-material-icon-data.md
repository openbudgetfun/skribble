---
skribble: patch
skribble_icons_material: patch
---

# Keep rough icon font lookups constant

`flutter build web --release` rejects an app that depends on `skribble_icons_material` (including through `skribble_icons`) because `lookupMaterialRoughIconsIconData` constructed `IconData` from a code point read at runtime. Icon tree-shaking requires every `IconData` it can see to be a constant, and it aborts rather than guessing which glyphs to keep.

The generator now emits `kMaterialRoughIconsByIdentifier`, a const map of `IconData`, and the lookup indexes that map. Apps that register the Material catalog still ship the whole rough icon font, because a const map keeps every entry alive. Named `static const` fields would let unused glyphs drop out, and that remains a follow-up. The storybook icon gallery still builds `IconData` from a runtime code point on purpose, so its web release build keeps `--no-tree-shake-icons`.
