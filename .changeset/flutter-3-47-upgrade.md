---
skribble: patch
---

Upgrade the workspace to Flutter 3.47.0 / Dart 3.13.0.

- Bump the pinned SDK in `.fvmrc` from 3.41.1 to 3.47.0
- Raise Dart SDK constraints to `^3.13.0` and Flutter constraints to `^3.47.0`
- Regenerate rough-icon catalogs with the Dart 3.13 formatter (canonical
  output shape changes for long single-argument calls)
- Resolve new analyzer diagnostics (`unnecessary_unawaited`,
  `prefer_initializing_formals`, `prefer_if_elements_to_conditional_expressions`,
  deprecated `one_member_abstracts`, `strict_top_level_inference` batch)
