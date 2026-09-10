---
skribble: patch
---

# Accept `unresolved-codepoints[]` as a minimal baseline key

The `--unresolved-baseline` loader in `generate_material_rough_icons.dart` now also reads `unresolved-codepoints` as the unresolved list key for minimal baseline objects, completing the accepted kebab-case spellings, with parser test coverage.
