---
skribble: patch
---

# Extend unresolved baseline parsing to accept a minimal `codePoints[]` format.

- `--unresolved-baseline` now accepts JSON objects with a top-level
  `codePoints` list (int or hex-string entries), in addition to existing
  `unresolved[]` report and `icons[]` manifest formats.
- Add parser coverage for the new baseline format.
- Update rough icon docs/README and CLI usage text accordingly.
