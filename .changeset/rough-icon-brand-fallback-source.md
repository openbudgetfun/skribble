---
skribble: patch
---

Improve rough Material icon SVG resolution for brand/social glyphs by adding a
`simple-icons` fallback source to the generator.

- New CLI option: `--brand-icons-source <path>`
- Default behavior now attempts a best-effort `simple-icons` package fallback
- Adds `woo_commerce -> woocommerce` brand slug mapping for fallback lookup

This reduces unresolved Material rough icon codepoints when Flutter exposes
brand identifiers that are not present in upstream Material SVG packages.
