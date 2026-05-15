---
skribble: patch
---

# Allow rough icon unresolved baseline input to use `unresolvedCodePoints[]`.

- `--unresolved-baseline` now accepts minimal baseline objects keyed by `unresolvedCodePoints` (in addition to `codePoints`/`codepoints`).
- This lets baseline regression checks consume unresolved report summary shape more directly.
- Update parser tests and docs/README.
