---
skribble: patch
---

# Add a `wouldFail` summary field to unresolved report JSON output.

- `--unresolved-output` now includes `wouldFail`, indicating whether configured unresolved gates would fail the current run.
- Works with both unresolved thresholds and baseline-regression thresholds.
- Update rough icon docs/README and parser test coverage.
