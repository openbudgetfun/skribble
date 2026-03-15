---
skribble: patch
---

Add `failedGates` to rough icon unresolved report JSON.

- `--unresolved-output` now includes `failedGates[]`, listing which configured gates failed (`unresolved`, `newUnresolved`).
- Existing booleans (`wouldFail`, `unresolvedGateFailed`, `newUnresolvedGateFailed`) remain unchanged.
- Adds parser coverage for single-gate and dual-gate failure scenarios.
