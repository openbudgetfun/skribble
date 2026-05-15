---
skribble: patch
---

# Improve unresolved baseline parser compatibility for minimal baseline objects.

- `--unresolved-baseline` now accepts either `codePoints[]` or `codepoints[]`
  keys when loading minimal baseline JSON objects.
- Add parser coverage for lowercase `codepoints[]` baseline input.
- Update rough icon docs/README and CLI help text to document the accepted key
  alias.
