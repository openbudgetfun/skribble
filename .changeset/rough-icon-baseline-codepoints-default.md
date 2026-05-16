---
skribble: patch
---

# Switch rough icon baseline sync defaults to `codePoints[]` baseline output.

- `melos run rough-icons-baseline` now writes baseline JSON using
  `--unresolved-baseline-output-format codepoints`.
- CI/local baseline sync script (`scripts/check_rough_icons_ci.sh`) now uses the
  same `codepoints` baseline output format.
- Update committed baseline file
  `packages/skribble/tool/examples/material_rough_icons.unresolved-baseline.json`
  to `codePoints[]` shape.
- Update rough icon docs/README to note the committed baseline format.
