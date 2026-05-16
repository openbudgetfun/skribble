---
skribble: patch
---

# Improve rough icon CI failure diagnostics for sync checks.

- `rough-icons-baseline-sync` now saves and uploads a
  `rough-icons-baseline-sync-diff` artifact when the regenerated baseline file
  differs from committed output.
- `rough-icons-generated-sync` now saves and uploads a
  `rough-icons-generated-sync-diff` artifact when regenerated rough icon
  catalogs differ from committed files.
- Update rough icon docs/README to describe these failure artifacts.
