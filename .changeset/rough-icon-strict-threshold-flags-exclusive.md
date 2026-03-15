---
skribble: patch
---

Clarify and enforce unresolved failure mode flag usage.

- `--fail-on-unresolved` and `--max-unresolved` are now mutually exclusive.
- Running with both flags now fails fast with an `ArgumentError`.
- Add parser test coverage for the conflicting-flag case.
- Update rough icon docs/README and CLI help text to document exclusivity.
