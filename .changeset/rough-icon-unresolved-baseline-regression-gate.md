---
skribble: patch
---

# Add unresolved baseline regression gating to rough icon generation.

- New option: `--unresolved-baseline <path>` to load previous unresolved report
- New option: `--fail-on-new-unresolved` to fail only when new unresolved
  codepoints appear versus baseline
- Unresolved JSON output now includes optional baseline diff fields:
  `newUnresolvedCount` and `newUnresolved`

This supports incremental CI enforcement by preventing unresolved regressions
without blocking on existing unresolved debt.
