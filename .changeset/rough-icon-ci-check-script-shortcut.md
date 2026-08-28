---
skribble: patch
---

# Improve rough icon CI/local parity ergonomics with reusable check scripts.

- Add `scripts/check_rough_icons_ci.sh` with `regression`, `baseline-sync`,
  `generated-sync`, and `all` modes.
- Refactor rough icon CI jobs to use this script instead of duplicating command
  blocks.
- Add workspace shortcut `melos run rough-icons-ci-check`.
- Update rough icon docs/README with local CI-equivalent check commands.
