---
skribble: patch
---

# Expose Material rough icon font catalog helpers from `wired_icon.dart`,
including identifier-based lookup for rough SVG data and generated font
`IconData`, along with public font family and codepoint catalog accessors.

Also update rough icon font Dart generation to emit single-quoted string
literals so generated files pass `dart analyze --fatal-infos`.
