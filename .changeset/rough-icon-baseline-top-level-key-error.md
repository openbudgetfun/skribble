---
skribble: patch
---

Improve unresolved baseline parser diagnostics when baseline objects omit recognized top-level list keys.

The `FormatException` now includes the keys found in the provided JSON object.
