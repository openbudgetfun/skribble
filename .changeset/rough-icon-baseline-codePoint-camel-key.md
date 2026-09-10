---
skribble: patch
---

# Accept `codePoint[]` as a minimal unresolved baseline key

The `--unresolved-baseline` loader in `generate_material_rough_icons.dart` now also reads the singular camelCase `codePoint` key for minimal baseline objects, so baselines written with the one-entry spelling parse like the plural forms, with parser test coverage.
