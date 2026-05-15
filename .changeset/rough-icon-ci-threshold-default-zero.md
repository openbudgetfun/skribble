---
skribble: patch
---

# Default `scripts/check_rough_icons_ci.sh` to threshold gating mode with a strict-equivalent value.

- Regression and generated-sync checks now default to `--max-new-unresolved 0` when `ROUGH_ICONS_MAX_NEW_UNRESOLVED` is unset.
- This keeps local script behavior aligned with CI/workspace threshold conventions.
- Docs and README were updated to reflect the new default.
