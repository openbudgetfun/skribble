---
skribble: patch
---

Add workspace-level unresolved baseline gating for rough icon generation.

- Add committed baseline report:
  - `packages/skribble/tool/examples/material_rough_icons.unresolved-baseline.json`
- Update melos scripts:
  - `rough-icons` and `rough-icons-font` now pass
    `--unresolved-baseline ... --fail-on-new-unresolved`
  - add `rough-icons-baseline` to refresh the committed baseline report
- Document baseline workflow in rough icon docs and package README.
