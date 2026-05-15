---
skribble: patch
---

# Add per-gate failure booleans to rough icon unresolved report JSON.

- `--unresolved-output` now includes `unresolvedGateFailed` and `newUnresolvedGateFailed`.
- The existing `wouldFail` field remains as the aggregate failure summary.
- Update parser tests and rough icon docs/README.
