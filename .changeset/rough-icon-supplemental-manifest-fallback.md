---
skribble: patch
---

# Add a supplemental manifest fallback for `flutter-material` rough icon
generation.

- New CLI option: `--supplemental-manifest <path>`
- Manifest entries (`identifier`, `codePoint`, `svgPath`) are used as a final
  fallback when Material and brand SVG sources cannot resolve an icon

This makes it possible to supply custom SVGs for remaining unresolved Material
icon codepoints without switching to `--kit svg-manifest`.
