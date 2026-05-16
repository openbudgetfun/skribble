---
skribble: patch
---

# Improve rough icon CI/local check ergonomics by extending the shared check script.

- `scripts/check_rough_icons_ci.sh` now prints and writes sync diffs
  (`rough-icons-baseline-sync.diff`, `rough-icons-generated-sync.diff`) when
  baseline/catalog sync checks fail.
- `rough-icons-regression` local runs now clean up
  `packages/skribble/unresolved-report.json` on success by default
  (`ROUGH_ICONS_KEEP_UNRESOLVED_REPORT=1` keeps it).
- CI workflow now relies on the script for diff generation and keeps only the
  failure artifact upload steps.
- Update rough icon docs/README with the script’s diff and report behavior.
