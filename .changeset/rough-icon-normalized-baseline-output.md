---
skribble: patch
---

# Add normalized unresolved baseline output for rough icon regression workflows.

- New CLI option: `--unresolved-baseline-output <path>`
  - emits a minimal JSON file containing only `unresolved[]` entries
  - uses deterministic sorting for stable baseline diffs
- Keep `--unresolved-output` as the richer diagnostics report (counts, kit, etc.)
- Update workspace baseline refresh script (`melos run rough-icons-baseline`) to
  use normalized baseline output
- Update docs and README to describe the new flag and workflow.
