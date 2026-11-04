---
skribble: patch
---

# Bars keep their content clear of the hand-drawn line

`WiredBottomAppBar` centres its content inside 8 pixels of ink padding, so plain text no longer sits on its top line. Its `height` is now a minimum, so the bar grows with large text, and it stays above the home indicator on notched phones. A bar holding 48-pixel buttons is now 64 pixels tall instead of 56. `WiredGridTileBar` uses `kWiredInkPadding`, so a subtitle no longer touches its bottom line at large text sizes. The selected item in `WiredBottomNavigationBar` has a slightly larger ring, so the ring keeps clear of the icon's corners.

`crampedText(root, lines: true, icons: true)` now runs on every storybook page, example app screen, and docs example.
