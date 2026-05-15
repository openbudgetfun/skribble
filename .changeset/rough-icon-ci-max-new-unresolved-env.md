---
skribble: patch
---

# Add threshold-mode baseline regression gating to the rough icon CI check script.

- `scripts/check_rough_icons_ci.sh` now supports optional env var
  `ROUGH_ICONS_MAX_NEW_UNRESOLVED=<int>`.
- When set, regression and generated-sync checks use
  `--max-new-unresolved <int>` instead of strict `--fail-on-new-unresolved`.
- Includes validation that the env var is a non-negative integer.
- Updates rough icon pipeline docs and package README with the new script option.
