---
skribble_font_recursive: minor
skribble_font_roughen: minor
skribble: patch
---

# Give the Recursive lettering a gentle lean

Regenerate all 126 static faces and three variable faces with shorter, smooth waves and a deterministic per-glyph lean of at most 0.045 degrees per strength unit. Gentle, Playful, and Expressive now use strengths 12, 20, and 28, with maximum leans of 0.54, 0.9, and 1.26 degrees. Vertical movement is 0.3 of the strength, fades to zero at the base outline's top and bottom, and is reduced for short punctuation; there is no baseline bounce. Font names, coverage, advance widths, shaping, and variation axes stay compatible.

`FontRoughener` and the standalone CLI now default to strength 20 (Playful). The legacy Expressive tool and storybook copies are synchronized with the regenerated faces. Noto Sketch remains the system default, and no Noto font changed.
