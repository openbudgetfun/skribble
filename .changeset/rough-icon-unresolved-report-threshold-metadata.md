---
skribble: patch
---

# Add gating threshold metadata to the unresolved report

- `--unresolved-output` reports now include threshold fields when configured:
  - `maxUnresolved`, `maxUnresolvedExceeded`
  - `maxNewUnresolved`, `maxNewUnresolvedExceeded`
- Applies to both strict and threshold modes (`--fail-on-unresolved` / `--max-unresolved`, `--fail-on-new-unresolved` / `--max-new-unresolved`).
- Update parser tests plus rough icon docs/README.
