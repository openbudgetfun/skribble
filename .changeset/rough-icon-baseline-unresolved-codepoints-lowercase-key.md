---
skribble: patch
---

# Accept `unresolvedCodepoints` as an unresolved baseline key

- `--unresolved-baseline` now accepts minimal baseline objects keyed by `unresolvedCodepoints` in addition to `unresolvedCodePoints`, `codePoints`, and `codepoints`.
- Improves compatibility when baseline JSON uses lowercased key conventions.
- Update parser tests, CLI help, docs, and README.
