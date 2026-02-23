# Feedback Components

Hand-drawn feedback widgets for dialogs, notifications, and progress indicators.

## WiredDialog

A dialog container with a hand-drawn border.

![WiredDialog](https://f005.backblazeb2.com/file/skribble-screenshots/feedback/wired-dialog.png)

- `RoughBoxDecoration` border
- Configurable padding (default 20.0)
- Contains arbitrary child content

## WiredSnackBar

A toast notification with hand-drawn styling.

![WiredSnackBar](https://f005.backblazeb2.com/file/skribble-screenshots/feedback/wired-snack-bar.png)

- `showWiredSnackBar` helper function
- `WiredSnackBarContent` wrapper widget
- `RoughBoxDecoration` with `SolidFiller`

## WiredPopupMenuButton

A popup menu with custom hand-drawn items.

![WiredPopupMenuButton](https://f005.backblazeb2.com/file/skribble-screenshots/feedback/wired-popup-menu.png)

- Generic type support `WiredPopupMenuButton<T>`
- Custom `WiredPopupMenuItem` class
- `RoughBoxDecoration` styling on items

## WiredTooltip

A tooltip with hand-drawn border decoration.

![WiredTooltip](https://f005.backblazeb2.com/file/skribble-screenshots/feedback/wired-tooltip.png)

- `RoughBoxDecoration` with custom border
- Wraps any child widget
- Appears on long-press or hover

## WiredBadge

A badge overlay positioned on child widgets.

![WiredBadge](https://f005.backblazeb2.com/file/skribble-screenshots/feedback/wired-badge.png)

- Supports label or dot indicator
- Customizable background color
- Positioned at top-right with negative offset
