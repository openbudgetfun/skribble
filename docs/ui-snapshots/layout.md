# Layout Components

Hand-drawn layout primitives for structuring content with sketchy borders and separators.

## WiredCard

A container card with an optional hachure fill pattern.

![WiredCard](https://f005.backblazeb2.com/file/skribble-screenshots/layout/wired-card.png)

- Default height 130.0 (or null for intrinsic sizing)
- Optional `fill` parameter for hachure pattern
- Stack-based layout with `WiredCanvas` background
- `WiredRectangleBase` painter for border

## WiredDivider

A hand-drawn horizontal line divider.

![WiredDivider](https://f005.backblazeb2.com/file/skribble-screenshots/layout/wired-divider.png)

- Rough-drawn line with natural irregularity
- Configurable thickness
- Used between content sections

## WiredListTile

A list item with optional leading, trailing, title, and subtitle.

![WiredListTile](https://f005.backblazeb2.com/file/skribble-screenshots/layout/wired-list-tile.png)

- Supports leading, title, subtitle, trailing
- Optional bottom separator line
- Consistent padding and spacing

## WiredExpansionTile

An expandable tile with animated content reveal.

![WiredExpansionTile](https://f005.backblazeb2.com/file/skribble-screenshots/layout/wired-expansion-tile.png)

- `useState` for expansion state
- `AnimatedRotation` for the expand/collapse arrow
- Animated content height transition

## WiredBottomSheet

A modal bottom sheet with a hand-drawn drag handle.

![WiredBottomSheet](https://f005.backblazeb2.com/file/skribble-screenshots/layout/wired-bottom-sheet.png)

- `showWiredBottomSheet` helper function
- Drag handle with rounded rectangle
- Rough-drawn top border

## WiredDataTable

A data table with hand-drawn grid lines.

![WiredDataTable](https://f005.backblazeb2.com/file/skribble-screenshots/layout/wired-data-table.png)

- Custom `WiredDataColumn` and `WiredDataRow` classes
- Hand-drawn header and data row separators
- Grid cell borders for the sketchy look
