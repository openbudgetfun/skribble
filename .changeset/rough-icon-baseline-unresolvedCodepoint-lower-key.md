---
skribble: patch
---

# Accept singular `unresolvedCodepoint[]` minimal baseline keys

The `--unresolved-baseline` loader in `generate_material_rough_icons.dart` now also reads the singular `unresolvedCodepoint` key for minimal baseline objects, so one-entry baselines written with the lower-Pascal spelling parse like the plural form, with parser test coverage.
