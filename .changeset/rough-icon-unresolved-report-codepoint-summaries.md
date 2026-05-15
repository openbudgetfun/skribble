---
skribble: patch
---

# Enhance unresolved rough icon report JSON with codepoint summary arrays.

- `--unresolved-output` now includes `unresolvedCodePoints[]` (hex strings)
  alongside existing `unresolved[]` entries.
- When baseline comparison is enabled, reports now include
  `newUnresolvedCodePoints[]` in addition to `newUnresolved[]`.
- Add parser test coverage for the new summary fields.
- Update rough icon docs/README to document the report payload additions.
