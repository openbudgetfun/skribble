---
skribble: patch
---

# Add threshold-based unresolved baseline regression gating.

- Add `--max-new-unresolved <int>` to allow bounded unresolved baseline regressions.
- Treat `--fail-on-new-unresolved` as strict mode (equivalent to `--max-new-unresolved 0`).
- Enforce parser validation:
  - `--max-new-unresolved` must be `>= 0`
  - `--max-new-unresolved` requires `--unresolved-baseline`
  - `--fail-on-new-unresolved` and `--max-new-unresolved` are mutually exclusive
- Update docs/README/CLI help and add parser+behavior tests.
