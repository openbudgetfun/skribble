---
skribble: patch
---

Add CI verification that the committed rough icon unresolved baseline file is
kept in sync.

- Add a new CI job (`rough-icons-baseline-sync`) that regenerates
  `packages/skribble/tool/examples/material_rough_icons.unresolved-baseline.json`
  using the committed supplemental manifest.
- Fail the job when baseline regeneration leaves a diff, ensuring baseline
  updates are committed with related icon-pipeline changes.
- Print the baseline diff in CI logs when the sync check fails.
