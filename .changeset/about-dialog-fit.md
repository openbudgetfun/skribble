---
skribble: patch
---

# About dialog fits phones and dark themes

`WiredAboutDialog` covered its paper with a hard-coded white sheet, which hid the pale text of dark themes, and its two actions overflowed on 320 and 360 pixel screens and with larger text. The dialog now uses the theme's `fillColor`, stacks its actions when they do not fit side by side, and scrolls on short screens. **VIEW LICENSES** opens `WiredLicensePage` instead of Material's `LicensePage`, the actions are `WiredTextButton`s, and the fallback name comes from any app's title, including `SkribbleApp`.
