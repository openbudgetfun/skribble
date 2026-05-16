---
skribble: patch
---

# Add unresolved threshold control to rough icon generation.

- New CLI option: `--max-unresolved <int>`
- Generator fails only when unresolved icon count exceeds the configured
  threshold
- `--fail-on-unresolved` remains supported as strict mode (`max = 0`)

This enables gradual CI enforcement while unresolved icon remediation is still
in progress.
