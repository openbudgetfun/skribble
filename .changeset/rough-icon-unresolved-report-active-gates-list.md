---
skribble: patch
---

Add `activeGates` to rough icon unresolved report JSON.

- `--unresolved-output` now includes `activeGates[]`, listing which unresolved gates are configured (`unresolved`, `newUnresolved`).
- `failedGates[]` continues to report only gates that actually failed.
- Adds parser coverage for inactive, single-gate, and dual-gate configurations.
