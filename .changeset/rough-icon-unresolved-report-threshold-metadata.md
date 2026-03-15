---
skribble: patch
---

Add unresolved gating threshold metadata to unresolved report JSON output.

- `--unresolved-output` reports now include threshold fields when configured:
  - `maxUnresolved`, `maxUnresolvedExceeded`
  - `maxNewUnresolved`, `maxNewUnresolvedExceeded`
- Applies to both strict and threshold modes (`--fail-on-unresolved` / `--max-unresolved`, `--fail-on-new-unresolved` / `--max-new-unresolved`).
- Update parser tests plus rough icon docs/README.
