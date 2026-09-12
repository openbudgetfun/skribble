---
title: Selection
description: Hand-drawn chips, dropdowns, date/time pickers, and color pickers in the Skribble design system.
---

# Selection

Skribble provides selection widgets for choices, filtering, date/time picking, and color selection. Each widget replaces its Material or Cupertino counterpart with sketchy hand-drawn chrome. All selection widgets read their palette from `WiredTheme.of(context)`.

---

## WiredChip

A chip with a hand-drawn pill-shaped border (16px radius). Supports an optional avatar and delete action.

```dart
// Live example: chip
WiredChip(label: Text('Make something lovely'))
```

### Constructor parameters

| Parameter   | Type            | Default      | Description                                                        |
| ----------- | --------------- | ------------ | ------------------------------------------------------------------ |
| `label`     | `Widget`        | **required** | The chip label.                                                    |
| `avatar`    | `Widget?`       | `null`       | Widget displayed before the label.                                 |
| `onDeleted` | `VoidCallback?` | `null`       | Called when the delete icon is tapped. Adds a close icon when set. |

### Notes

- Fixed height of 32px.
- The border uses `WiredRoundedRectangleBase` with `RoughFilter.noFiller`.
- The delete icon is a 16px `WiredIcon` with `Icons.close`.
- Text uses `theme.textColor` at 13px.

---

## WiredChoiceChip

A selectable chip that toggles between selected and unselected states. Selected chips use solid ink behind the label to keep small text clear.

```dart
// Live example: choice-chip
HookBuilder(
  builder: (context) {
    final selected = useState(false);
    return WiredChoiceChip(
      label: Text('Make something lovely'),
      selected: selected.value,
      onSelected: (value) => selected.value = value,
    );
  },
)
```

### Notes

- Selected state applies a solid `theme.borderColor` fill behind the label.
- The label uses `theme.fillColor` when selected. The outline retains the selected roughness level.

---

## WiredFilterChip

A chip with a checkmark indicator that can be toggled on and off for filtering. Selected chips use a solid ink fill and a hand-drawn checkmark.

```dart
// Live example: filter-chip
HookBuilder(
  builder: (context) {
    final selected = useState(true);
    return WiredFilterChip(
      label: Text('Make something lovely'),
      selected: selected.value,
      onSelected: (value) => selected.value = value,
    );
  },
)
```

---

## WiredInputChip

A chip representing a piece of user input (e.g., a tag or email address). Supports avatar, delete, and tap actions. Its selected state uses the same solid ink fill as choice and filter chips.

```dart
// Live example: input-chip
HookBuilder(
  builder: (context) {
    final visible = useState(true);
    return visible.value
        ? WiredInputChip(
            label: Text('Make something lovely'),
            onDeleted: () => visible.value = false,
          )
        : WiredTextButton(
            onPressed: () => visible.value = true,
            child: const Text('Restore tag'),
          );
  },
)
```

---

## WiredActionChip

A chip that triggers an action when tapped. Has a hand-drawn border but no selected state.

```dart
// Live example: action-chip
HookBuilder(
  builder: (context) {
    final count = useState(0);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        WiredActionChip(
          label: Text('Make something lovely'),
          onPressed: () => count.value++,
        ),
        Text('Pressed ${count.value} times'),
      ],
    );
  },
)
```

---

## WiredCombo

A hand-drawn dropdown selector wrapping Flutter's `DropdownButton`. Its rounded field border surrounds a centered label with 16 px side padding and a small outlined triangle. The example uses a compact 320 px width; the widget fills the width supplied by its parent.

```dart
// Live example: combo
SizedBox(
  width: 320,
  child: WiredCombo<String>.options(
    options: const {
      'paper': Text('Paper'),
      'ink': Text('Ink'),
      'ideas': Text('Ideas'),
    },
    value: 'paper',
  ),
)
```

### Constructor parameters

| Parameter   | Type                        | Default      | Description                                                               |
| ----------- | --------------------------- | ------------ | ------------------------------------------------------------------------- |
| `value`     | `T?`                        | `null`       | Currently selected value.                                                 |
| `items`     | `List<DropdownMenuItem<T>>` | **required** | Dropdown items.                                                           |
| `onChanged` | `bool? Function(T?)?`       | `null`       | Called on selection. Return `true` to indicate external state management. |

### Notes

- Field and item height starts at 60 px and grows with text scaling. Labels are vertically centered; long selected labels use an ellipsis and leave space for the indicator.
- The outlined triangle follows the trailing edge, including in right-to-left layouts. Its restrained roughness keeps it readable at a small size.
- The field retains its own rounded border when selection is null or the options are empty. Menu rows have separate rounded borders and padded labels.
- Menu items preserve their `enabled`, `onTap`, and `alignment` values.
- The `onChanged` callback uses a `bool` return pattern: return `true` if managing state externally, `false` (or `null`) to let `WiredCombo` update its internal state.

---

## WiredDatePicker

A date picker dialog widget with hand-drawn calendar grid and navigation. Renders month headers and day cells with sketchy borders. Use `showWiredDatePicker` (top-level helper, shipped with the widget) to open it as a dialog.

```dart
// Live example: date-picker
HookBuilder(
  builder: (context) {
    final selected = useState<DateTime?>(null);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        WiredButton(
          onPressed: () async {
            selected.value = await showWiredDatePicker(
              context: context,
              initialDate: DateTime(2026, 9, 9),
            );
          },
          child: Text('Make something lovely'),
        ),
        if (selected.value case final DateTime date)
          Text('${date.day}/${date.month}/${date.year}'),
      ],
    );
  },
)
```

---

## WiredDateRangePickerDialog

A hand-drawn dialog for selecting a date range, analogous to Material's `showDateRangePicker`. A rough circle marks each range endpoint and hachure-filled rectangles highlight the days in between. Days outside `firstDate`..`lastDate` (and from neighbouring months) are dimmed and disabled; the OK action stays disabled until the range is complete.

```dart
// Live example: date-range-picker
Builder(
  builder: (context) => WiredButton(
    onPressed: () => showWiredDateRangePicker(
      context: context,
      firstDate: DateTime(2026),
      lastDate: DateTime(2027),
    ),
    child: Text('Make something lovely'),
  ),
)
```

### Constructor parameters

| Parameter          | Type                       | Default                                | Description                                     |
| ------------------ | -------------------------- | -------------------------------------- | ----------------------------------------------- |
| `initialDateRange` | `DateTimeRange<DateTime>?` | `null`                                 | Pre-selected range shown when the dialog opens. |
| `firstDate`        | `DateTime?`                | month of `initialDateRange` (or today) | Earliest selectable date.                       |
| `lastDate`         | `DateTime?`                | one year after `firstDate`             | Latest selectable date.                         |
| `semanticLabel`    | `String?`                  | `'Date range picker'`                  | Semantic label for accessibility.               |

### Notes

- Prefer `showWiredDateRangePicker`, which pops the completed `DateTimeRange<DateTime>` (or `null` when cancelled) through the route.
- The month grid follows the `WiredCalendar` pattern: month navigation via hand-drawn `<<` / `>>` controls, clamped to `firstDate`..`lastDate`.
- The month shown on open defaults to the month of `initialDateRange` (or of `firstDate` when no range is given).
- Day cells expose `Semantics` with labels like `Select Jan 20, 2026`.

---

## WiredTimePicker

A time picker with hand-drawn clock face, clock hands, and drag-to-adjust hour/minute fields. The inline widget streams changes through `onTimeSelected`.

```dart
// Live example: time-picker
Builder(
  builder: (context) => WiredButton(
    onPressed: () => showWiredTimePicker(context: context),
    child: Text('Make something lovely'),
  ),
)
```

### Notes

- `showWiredTimePicker` opens a dialog containing `WiredTimePicker` plus hand-drawn Cancel/OK buttons; it returns the selected `TimeOfDay`, or `null` when cancelled or dismissed.
- Hours wrap modulo 24 (23 → 00) and minutes modulo 60 (00 → 59) when dragged.

---

## WiredCalendarDatePicker

An inline calendar date picker widget (not a dialog) with hand-drawn day cells and month navigation arrows.

```dart
// Live example: calendar-date-picker
WiredCalendarDatePicker(
  initialDate: DateTime(2026, 9, 9),
  firstDate: DateTime(2026),
  lastDate: DateTime(2027),
  onDateChanged: (date) {},
)
```

---

## WiredColorPicker

A color picker with a hand-drawn grid of color swatches. Each swatch is a sketchy circle that fills with hachure when selected.

```dart
// Live example: color-picker
HookBuilder(
  builder: (context) {
    final selected = useState(const Color(0xffe8957d));
    return WiredColorPicker(
      selectedColor: selected.value,
      onColorChanged: (color) => selected.value = color,
    );
  },
)
```

---

## WiredCupertinoPicker

Mouse and touch dragging both scroll the wheel. The picker adds mouse support to the surrounding scroll configuration without replacing its other settings. Labels inherit the active Wired theme's font family and roughness variant, including the asset package for bundled fonts. An explicit child text style still overrides those defaults.

A Cupertino-style scrolling picker wheel with hand-drawn selection highlight. Mirrors the `CupertinoPicker` API.

```dart
// Live example: cupertino-picker
SizedBox(
  height: 160,
  child: WiredCupertinoPicker(
    onSelectedItemChanged: (index) {},
    children: const [Text('Paper'), Text('Ink'), Text('Possibility')],
  ),
)
```

---

## WiredCupertinoDatePicker

A Cupertino-style date picker with hand-drawn wheel columns. Mirrors the `CupertinoDatePicker` API.

```dart
// Live example: cupertino-date-picker
SizedBox(
  height: 180,
  child: WiredCupertinoDatePicker(
    initialDateTime: DateTime(2026, 9, 9, 12),
    onDateTimeChanged: (date) {},
  ),
)
```

---

## WiredCupertinoSegmentedControl

A Cupertino-style segmented control with hand-drawn segment borders and hachure selection fill.

```dart
// Live example: cupertino-segmented-control
HookBuilder(
  builder: (context) {
    final selected = useState('paper');
    return WiredCupertinoSegmentedControl<String>(
      children: const {'paper': Text('Paper'), 'ink': Text('Ink')},
      groupValue: selected.value,
      onValueChanged: (value) => selected.value = value,
    );
  },
)
```

<!-- {=docsWidgetInkSection} -->

## Shared ink and typography

Borders in this category now use the nearest `WiredThemeData.strokeWidth` (2.4 logical pixels by default) and drawing configuration. Rounded pen caps and joins, bleed insets, and sufficient divider space keep the stroke visible. Labels that apply a local text style retain the inherited font family. Theme changes repaint the updated color and width. See [Theme System](../core/theme-system) for configuration and [the quality report](https://github.com/openbudgetfun/skribble/blob/main/docs/hand-drawn-quality.md) for the rendering checks.

<!-- {/docsWidgetInkSection} -->

`WiredCheckbox` is a binary checkbox: `null` is displayed as unchecked, and taps toggle false/true. Parent value changes reset its local visual state.

Chip labels in `WiredChip`, `WiredFilterChip`, and `WiredInputChip` now fit the available width. Long labels use an ellipsis while retaining their full text for accessibility, leaving room for checkmarks and delete actions.
