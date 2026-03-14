---
skribble: patch
---

Add unresolved report output support to rough icon generation.

- New CLI option: `--unresolved-output <path>`
- Emits a JSON report with `resolvedCount`, `unresolvedCount`, and unresolved
  entries (`codePoint`, `identifiers`)

This helps author follow-up supplemental manifests for unresolved
`flutter-material` icon codepoints.
