---
skribble: patch
---

# Add regression and recovery fields to the unresolved baseline diff

- `--unresolved-baseline` now records both regression and recovery context in unresolved JSON output
- New optional report fields when baseline comparison is enabled:
  - `baselineUnresolvedCount`
  - `resolvedSinceBaselineCount`
  - `resolvedSinceBaseline`

This makes baseline-driven CI runs easier to interpret by surfacing not only new unresolved regressions, but also baseline entries that are now resolved.
