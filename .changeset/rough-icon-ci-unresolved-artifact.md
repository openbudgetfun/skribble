---
skribble: patch
---

Improve rough icon CI regression diagnostics by publishing unresolved reports.

- Update `rough-icons-regression` CI job to also pass
  `--unresolved-output` while running `--fail-on-new-unresolved` gating.
- Upload the generated report as a workflow artifact:
  `rough-icons-unresolved-report`.
- Document artifact availability in rough icon pipeline docs and README.
