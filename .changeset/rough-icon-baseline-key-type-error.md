---
skribble: patch
---

# Improve unresolved baseline parser diagnostics when recognized baseline keys exist but are not arrays.

The parser now reports which recognized keys have non-list values (for example `codePoints (String)`).
