---
skribble: patch
---

# Add strict unresolved failure mode to rough icon generation.

- New CLI option: `--fail-on-unresolved`
- When unresolved icons remain, the generator now exits with `StateError`
  instead of warning-only behavior

This allows CI to enforce complete rough icon coverage once supplemental
manifests are in place.
