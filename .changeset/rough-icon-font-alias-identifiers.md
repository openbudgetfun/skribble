---
skribble: patch
---

Expand generated rough icon font identifier coverage to include alias names.

- Update rough icon generator so `--font-dart-output` includes **all** resolved
  Flutter icon identifiers that share a codepoint, not just the first resolved
  identifier for that codepoint.
- This improves runtime lookup ergonomics for legacy aliases such as
  `trending_neutral` / `settings_display` while keeping codepoint behavior
  stable.
- Add parser + widget catalog tests for alias identifier lookups.
- Document alias-inclusive font helper behavior in rough icon docs.
