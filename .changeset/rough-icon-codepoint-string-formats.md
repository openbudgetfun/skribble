---
skribble: patch
---

Improve rough icon codepoint parsing ergonomics for manifests and baselines.

- `codePoint` parsing now accepts additional string forms:
  - bare hex (for example `"e001"`)
  - `U+`-prefixed hex (for example `"U+E001"`)
  - existing decimal and `0x`-prefixed formats remain supported
- `--unresolved-baseline` benefits from the same parsing support.
- Add parser tests for manifest and baseline codepoint string variants.
- Update rough icon pipeline docs/README with accepted `codePoint` formats.
