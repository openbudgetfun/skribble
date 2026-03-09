# Selection Components

Hand-drawn selection controls for filtering, choosing, and toggling options.

## WiredChip

A basic chip with optional avatar and delete icon.

![WiredChip](https://f005.backblazeb2.com/file/skribble-screenshots/selection/wired-chip.png)

- Optional `avatar` widget
- Optional `onDeleted` callback with delete icon
- `RoughBoxDecoration` with rounded corners

## WiredChoiceChip

A selectable chip that fills when selected.

![WiredChoiceChip](https://f005.backblazeb2.com/file/skribble-screenshots/selection/wired-choice-chip.png)

- `selected` boolean state
- Fill color applied when selected
- Single-choice selection pattern

## WiredFilterChip

A chip with optional checkmark indicator for filtering.

![WiredFilterChip](https://f005.backblazeb2.com/file/skribble-screenshots/selection/wired-filter-chip.png)

- Checkmark icon when selected
- Multi-select filtering pattern
- `onSelected` callback

## WiredCheckboxListTile

A checkbox combined with a list tile layout.

![WiredCheckboxListTile](https://f005.backblazeb2.com/file/skribble-screenshots/selection/wired-checkbox-list-tile.png)

- Composes `WiredCheckbox` with `WiredListTile`
- Title, subtitle, and leading widget support
- Toggle the full tile to check/uncheck

## WiredRadioListTile

A radio button combined with a list tile layout.

![WiredRadioListTile](https://f005.backblazeb2.com/file/skribble-screenshots/selection/wired-radio-list-tile.png)

- Generic type support `WiredRadioListTile<T>`
- Composes `WiredRadio` with `WiredListTile`
- Full-tile tap to select

## WiredSwitchListTile

A switch combined with a list tile layout.

![WiredSwitchListTile](https://f005.backblazeb2.com/file/skribble-screenshots/selection/wired-switch-list-tile.png)

- Composes `WiredSwitch` with `WiredListTile`
- Title, subtitle support
- Toggle the full tile to flip the switch
