---
skribble: patch
---

# Accept flexible key and format spellings in unresolved baselines

Baseline files load as unresolved reports (`unresolved[]`), supplemental manifests (`icons[]`), or minimal top-level codepoint lists, with the list key accepted in every common spelling: `unresolvedCodePoints`, `unresolvedCodepoint`, `unresolved_code_points`, `unresolved_codepoint`, `unresolved-code-points`, `unresolved-codepoints`, `codePoints`, `codePoint`, `codepoints`, `codepoint`, `code_points`, and `code-points`, including the singular forms of each family. Object entries accept `codePoint`, `codepoint`, `code_point`, and `code-point` field aliases. Parser diagnostics name the keys found in unrecognized JSON objects, report recognized keys carrying non-list values, and raise a targeted `FormatException` when an entry lacks any codepoint field; every spelling and failure mode has parser test coverage.
