---
skribble: patch
---

# Add supplemental manifest template output support to ...

- New CLI option: `--supplemental-manifest-output <path>`
- Emits a starter JSON manifest for unresolved icons using the same `icons[]`
  schema consumed by `--supplemental-manifest`

This streamlines unresolved icon remediation workflows by generating an editable
manifest template directly from unresolved results.
