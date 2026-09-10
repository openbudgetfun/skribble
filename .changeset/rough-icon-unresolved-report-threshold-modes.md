---
skribble: patch
---

# Add gate mode metadata to the unresolved report JSON

- `--unresolved-output` now includes:
  - `unresolvedThresholdMode` (`disabled|strict|threshold`)
  - `newUnresolvedThresholdMode` (`disabled|strict|threshold`)
- Keeps existing threshold fields (`maxUnresolved*`, `maxNewUnresolved*`) unchanged.
- Adds parser test coverage for strict/threshold/disabled mode reporting and updates docs/README.
