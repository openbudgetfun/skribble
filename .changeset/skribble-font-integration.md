---
skribble: minor
---

# Bundle the Architects Daughter hand-drawn font and integrate it into the theming
system. Add `fontFamily` property to `WiredThemeData` (default:
`skribbleFontFamily`) so all Wired widgets and Material text styles
automatically use the hand-drawn font. Remove `google_fonts` runtime dependency
in favor of the bundled asset.
