---
skribble_font_recursive: minor
skribble_font_roughen: minor
skribble: patch
---

# Calm the Recursive lettering and protect the Noto Sketch default

Regenerate all Recursive Casual, Linear, and Mono faces with broader outline waves, no independent letter tilt, and smaller vertical movement that keeps base-outline extrema steady. Gentle, Playful, and Expressive now use strengths 6, 10, and 14 instead of 18, 27, and 36. Font names, coverage, advance widths, shaping features, and variable axes stay compatible.

The roughener CLI and `FontRoughener` now default to strength 14. Noto Sketch remains the default across light and dark themes and all roughness levels, with regression coverage for app startup and explicit Recursive selection. A reproducible specimen harness captures the bundled faces at reading sizes in both themes and narrow and wide layouts.
