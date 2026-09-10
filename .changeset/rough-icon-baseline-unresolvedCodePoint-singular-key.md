---
skribble: patch
---

# Accept singular `unresolvedCodePoint[]` minimal baseline keys

The `--unresolved-baseline` loader in `generate_material_rough_icons.dart` now also reads the singular PascalCase `unresolvedCodePoint` key for minimal baseline objects, so one-entry baselines parse like the plural form, with parser test coverage.
