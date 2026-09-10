---
skribble: patch
---

# Accept `unresolved-code-points[]` as a minimal baseline key

The `--unresolved-baseline` loader in `generate_material_rough_icons.dart` now also reads `unresolved-code-points` as the unresolved list key for minimal baseline objects, alongside the existing camelCase, PascalCase, and snake_case spellings, with parser test coverage.
