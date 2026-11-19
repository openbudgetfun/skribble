---
skribble: minor
---

# Shrink long labels to fit on one line

`WiredFitText` draws one line of text that shrinks to fit the width it is given, instead of clipping, wrapping, or overflowing. A label that fits is drawn at full size. A longer one is scaled down until it fits, but never below `minScale` (`kWiredFitTextMinScale`, three quarters of its size) or `minFontSize` (`kWiredFitTextMinFontSize`, 9 px), whichever is larger, and only past that floor does it end in an ellipsis. It scales the laid-out line, so it works with any font, including the default Noto Sketch, keeps the reader's text scale, and adds no dependency. `WiredFitText.wrap` fits a label widget you already have.

Chip labels (`WiredChip`, `WiredChoiceChip`, `WiredFilterChip`, `WiredInputChip`) and navigation item labels (`WiredBottomNavigationBar`, `WiredNavigationBar`, `WiredNavigationRail`, `WiredTabBar`) now fit this way: a label such as "Notifications" in a 72 px navigation item shrinks a little rather than reading "Notifica…". A `WiredChoiceChip` label also stays on one line now instead of wrapping. Buttons keep wrapping by default; pass `WiredFitText` as a button's `child` to keep its label on one line.
