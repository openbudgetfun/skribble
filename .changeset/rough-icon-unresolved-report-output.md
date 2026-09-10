---
skribble: patch
---

# Report unresolved icons and gate generation on thresholds

`--unresolved-output` writes a JSON report containing `resolvedCount`, `unresolvedCount`, unresolved entries with identifiers, hex summaries (`unresolvedCodePoints[]` and, with a baseline, `newUnresolvedCodePoints[]`), gate configuration and outcomes (`activeGates[]`, `failedGates[]`, per-gate failure booleans, and the aggregate `wouldFail`), and threshold metadata including each gate's mode (`disabled`, `strict`, or `threshold`) and configured maxima. Gating comes in strict and threshold forms for both total unresolved icons (`--fail-on-unresolved` / `--max-unresolved`) and baseline regressions (`--fail-on-new-unresolved` / `--max-new-unresolved` against `--unresolved-baseline`, reporting `baselineUnresolvedCount`, `resolvedSinceBaseline*`, and `newUnresolved*` diff fields). Mutually exclusive flag combinations, negative thresholds, and thresholds without a baseline fail fast.
