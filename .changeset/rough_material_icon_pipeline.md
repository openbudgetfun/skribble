---
skribble: minor
---

# Add rough icon rendering and the generation pipeline

`WiredIcon` and `WiredSvgIcon` render sketch-style icons and wire into `WiredIconButton` and `WiredFloatingActionButton`. The kit-agnostic CLI (keeping `generate_material_rough_icons.dart` as a compatibility alias, with `--list-kits` for discoverability) converts icon kits through a pluggable provider seam with a Deno conversion script and an optional SVG-to-TTF rough icon font step. `--font-dart-output` emits a Dart helper containing the font family constant, codepoint map, and lookup function, including every resolved Flutter identifier that shares a codepoint so legacy aliases such as `trending_neutral` resolve. Public catalog helpers expose identifier-based rough SVG and font `IconData` lookup plus font family and codepoint accessors, and generated Dart uses single-quoted string literals so output passes `dart analyze --fatal-infos`.
