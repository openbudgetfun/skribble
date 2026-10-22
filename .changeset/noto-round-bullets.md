---
skribble_font_noto: patch
skribble_font_noto_sketch: patch
skribble_font_noto_lively: patch
---

# Bullets keep their round shape in Skribble Noto

The generator re-stroked every large solid shape into a pen-width line, so a bullet (•), the triangular bullet (‣), and the Latin sinological dot (ꞏ) came out as tiny dots. Solid round shapes now keep their Noto outline, like the dots on i and j. No other letters change.

The all-scripts font kit also gains Mende Kikakui and Znamenny Musical Notation, the two Noto scripts it was missing, so it now has 169 files per level. `tool/skribble_noto/coverage.py` checks a built level against every Noto source.
