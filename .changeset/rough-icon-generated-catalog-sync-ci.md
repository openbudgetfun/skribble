---
skribble: patch
---

# Sync and enforce committed rough icon generated catalogs.

- Regenerate committed rough icon catalogs with the current generator +
  supplemental manifest:
  - `packages/skribble/lib/src/generated/material_rough_icons.g.dart`
  - `packages/skribble/lib/src/generated/material_rough_icon_font.g.dart`
- Update `rough-icons-font` workspace script to also emit
  `material_rough_icon_font.g.dart`.
- Add CI verification job (`rough-icons-generated-sync`) that regenerates and
  checks these generated files are committed and up to date.
- Add widget test coverage for committed supplemental fallback icon lookups
  (`adobe`, `face_unlock_sharp`).
