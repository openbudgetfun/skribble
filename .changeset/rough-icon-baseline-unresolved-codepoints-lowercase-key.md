---
skribble: patch
---

Allow rough icon unresolved baseline input to use `unresolvedCodepoints[]` (lowercase `p`).

- `--unresolved-baseline` now accepts minimal baseline objects keyed by `unresolvedCodepoints` in addition to `unresolvedCodePoints`, `codePoints`, and `codepoints`.
- Improves compatibility when baseline JSON uses lowercased key conventions.
- Update parser tests, CLI help, docs, and README.
