---
skribble: patch
---

# Allow unresolved baseline regression checks to accept both report and manifest
JSON formats.

- `--unresolved-baseline` now supports:
  - unresolved report format (`unresolved[]`)
  - supplemental manifest format (`icons[]`)

This lets generated supplemental manifest templates be reused directly as
baseline inputs for `--fail-on-new-unresolved` checks.
