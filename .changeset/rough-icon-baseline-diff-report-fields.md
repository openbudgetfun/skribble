---
skribble: patch
---

# Improve unresolved baseline comparison reporting for rough icon generation.

- `--unresolved-baseline` now records both regression and recovery context in
  unresolved JSON output
- New optional report fields when baseline comparison is enabled:
  - `baselineUnresolvedCount`
  - `resolvedSinceBaselineCount`
  - `resolvedSinceBaseline`

This makes baseline-driven CI runs easier to interpret by surfacing not only
new unresolved regressions, but also baseline entries that are now resolved.
