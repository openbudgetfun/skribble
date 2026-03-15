---
skribble: patch
---

Improve unresolved baseline parser error messages for object entries missing a codepoint field.

- Baseline object entries in `unresolved[]`/`icons[]` now throw a targeted `FormatException` when none of `codePoint`, `codepoint`, or `code_point` is present.
- This replaces the previous generic null-value error and clarifies accepted key names.
- Adds parser test coverage for this failure mode.
