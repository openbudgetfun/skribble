---
skribble_leptoskit: minor
skribble_leptoskit_maps: patch
---

# Sunny colourways and the softer pen for leptoskit

`skribble_leptoskit` now draws with the same colours and pen as skribble's Flutter widgets and `skribble_jaspr` instead of its earlier near-black ink and single yellow accent.

**Colours.** The new `colorway` module holds skribble's colours with no leptoskit types, so any Rust UI layer can share them: an `Rgba` colour (`Rgba::new`, `Rgba::hex`, `css_hex`, WCAG `luminance` and `contrast`), the named `swatch`es (the same values as Flutter's `WiredPalette`), `Appearance`, the `Colorway`s (`Sunny`, the default, plus `Berry`, `Ocean`, `Citrus`, and the calm `Quiet`), `readable_on`, and the default `STROKE_WIDTH` and `ROUGHNESS`. `color(rgba)` turns one into a leptoskit `Color`.

**Theme.** `Theme::SKRIBBLE` is now the sunny colourway: plum ink on warm paper, paper ink on a plum night in dark mode, a sunshine marker, a tomato accent, and six washes, with 1.6-pixel outlines at playful roughness. `Theme::colorway(...)` and `Palette::colorway(...)` build any colourway. `Palette` gains `marker`, `muted_ink`, and `washes`, and loses `on_accent`. `Theme` gains `marker()`, `muted_ink()`, `accent_at(index)` for colour-coding, `on(wash)` for readable labels on a wash, and `on_marker()`. `on_accent()` now chooses by contrast.

**Components.** The primary `WiredButton` and `WiredBadge` fill with the tomato accent. Marker highlights, switch tracks, progress, `Sketch` fills, and the default fill of `WiredBox`, `WiredCard`, and `WiredCircle` use the sunshine marker. Text on any solid fill takes whichever of the ink and paper reads better on it, so labels on a sunshine card turn dark on night paper. Map areas and dots in `skribble_leptoskit_maps` default to the marker as well.

The leptoskit guide's stale notes that native drew sketched fills as tints and left `Sketch` empty are gone: native has drawn the same rough ink as the web since the `Vector` switch.
