---
skribble: patch
---

# Gate rough icon regressions in CI with a committed baseline

`melos run rough-icons` and `rough-icons-font` generate against the committed baseline `material_rough_icons.unresolved-baseline.json` with `--max-new-unresolved 0`, and `melos run rough-icons-baseline` refreshes it from normalized output (`--unresolved-baseline-output`, with `--unresolved-baseline-output-format codepoints` as the default shape). `scripts/check_rough_icons_ci.sh` drives `regression`, `baseline-sync`, and `generated-sync` modes (workspace shortcut `melos run rough-icons-ci-check`) with optional `ROUGH_ICONS_MAX_UNRESOLVED` and `ROUGH_ICONS_MAX_NEW_UNRESOLVED` thresholds that default to zero, prints and saves sync diffs, and cleans up report files on success. CI runs the same checks, uploads the unresolved report plus baseline and generated sync-diff artifacts on failure, and verifies the committed generated catalogs stay in sync with the current generator.
