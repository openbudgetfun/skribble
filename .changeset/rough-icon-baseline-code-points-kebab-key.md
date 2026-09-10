---
skribble: patch
---

# Accept `code-points[]` as a minimal unresolved baseline key

The `--unresolved-baseline` loader in `generate_material_rough_icons.dart` now also reads `code-points` as the codepoint list key for minimal baseline objects, alongside `codePoints`, `code_points`, `codepoints`, and `codepoint`, with parser test coverage.
