---
skribble: patch
---

# Accept additional codepoint field aliases in unresolved baseline object entries.

- `--unresolved-baseline` now accepts `codepoint` and `code_point` for object entries in `unresolved[]` and `icons[]` (in addition to `codePoint`).
- Keeps existing minimal list-key aliases unchanged.
- Updates parser tests, CLI help, and docs/README.
