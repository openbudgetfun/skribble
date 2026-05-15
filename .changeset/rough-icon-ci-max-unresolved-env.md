---
skribble: patch
---

# Add optional total unresolved gating to rough icon CI parity script.

- `scripts/check_rough_icons_ci.sh` now supports `ROUGH_ICONS_MAX_UNRESOLVED=<int>`.
- When set, regression/generated-sync checks pass `--max-unresolved <int>` to rough icon generation.
- Existing baseline-regression threshold behavior (`ROUGH_ICONS_MAX_NEW_UNRESOLVED`) is unchanged.
- Update rough icon docs and README.
