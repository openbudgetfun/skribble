---
skribble: patch
---

Switch rough icon workspace shortcuts to explicit threshold-mode regression gating.

- Update `melos run rough-icons` and `melos run rough-icons-font` to use
  `--max-new-unresolved 0` instead of `--fail-on-new-unresolved`.
- Preserves strict behavior while matching the threshold-based workflow used in CI.
- Update rough icon docs/README to describe the strict-equivalent threshold mode.
