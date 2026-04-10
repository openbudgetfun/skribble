---
skribble: patch
---

Make all 8,600+ Flutter Material icons available through `skribble_icons` via
unified lookup API. Re-exports Material rough icons from `skribble` package,
keeps 30 curated custom icons, and provides `lookupSkribbleIconByIdentifier()`
that searches custom first then falls back to Material. Adds
`rough-icons-skribble` melos script for custom icon regeneration.
