---
skribble: patch
---

Add configurable unresolved baseline output format for rough icon tooling.

- New flag: `--unresolved-baseline-output-format <unresolved|codepoints>`.
- `--unresolved-baseline-output` defaults to existing `unresolved[]` shape.
- `codepoints` format emits a minimal top-level `codePoints[]` list.
- Add validation for unsupported formats and for using custom format without
  `--unresolved-baseline-output`.
- Add parser tests and docs/README updates for the new output format.
