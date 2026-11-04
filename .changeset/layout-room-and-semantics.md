---
skribble: patch
---

# Layout widgets make room for their content

- `WiredDataTable` honours `WiredDataColumn.width`, which it used to ignore, gives other columns at least the new `minColumnWidth` (96 by default), and scrolls sideways on narrow screens instead of squeezing each column into a thin stack of lines. Column labels are announced as headers.
- `WiredDivider` draws its line in the middle of its 16 pixels instead of along the top, and no longer needs Material.
- `WiredGridTileBar.height` and `WiredReorderableListView.itemHeight` are minimums: the bar and the items grow with large text instead of overflowing or clipping, and list items keep 8 pixels above and below their content.
- `WiredStepper` circles grow enough to keep the ink's breathing room around the step number at large text, and the connecting line stays under the middle of the circle.
- `WiredColorPicker` honours `crossAxisCount`, which it used to ignore, and its swatches take keyboard focus and are announced as buttons named by their hex value with their selected state.
- `WiredBottomSheet` keeps its content above the home indicator.
- `WiredExpansionPanelList` headers and `WiredExpansionTile` report themselves as buttons with their expanded state.
