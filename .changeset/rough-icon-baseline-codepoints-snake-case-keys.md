---
skribble: patch
---

# Accept snake_case minimal baseline keys for rough icon unresolved regression checks.

- `--unresolved-baseline` now accepts `unresolved_code_points[]` and `code_points[]`.
- Existing key aliases continue to work (`unresolvedCodePoints`, `unresolvedCodepoints`, `codePoints`, `codepoints`).
- Adds parser test coverage and updates CLI/docs/README.
