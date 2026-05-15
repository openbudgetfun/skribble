---
skribble: patch
---

# Ship a committed supplemental manifest and SVG assets to resolve remaining
Material rough icon gaps (`face_unlock*`, `adobe*`) in default workflows.

- Add committed supplemental manifest + assets under:
  - `packages/skribble/tool/examples/material_rough_icons.supplemental.manifest.json`
  - `packages/skribble/tool/examples/supplemental/material/*.svg`
- Update rough icon scripts and CI regression gate to pass
  `--supplemental-manifest` by default.
- Refresh normalized unresolved baseline (now empty with supplemental fallback).
- Improve supplemental matching to also consider full declaration identifiers.
- Regenerate material rough icon catalogs and add tests covering supplemental
  fallback lookups.
