---
skribble: patch
---

Add a kit-agnostic rough icon CLI entrypoint (`tool/generate_rough_icons.dart`),
keep `generate_material_rough_icons.dart` as a compatibility alias, and add
`--list-kits` support for discoverability. Update docs and workspace scripts to
use the new entrypoint.
