---
skribble: patch
---

# Improve Flutter Material rough icon SVG alias resolution in the generator:

- map `label_outline` variants to `label`
- map `wifi_tethering_error_rounded` variants to `wifi_tethering_error`

This recovers rough SVG coverage for these icon codepoints and reduces
runtime fallback-to-`Icon` cases.
