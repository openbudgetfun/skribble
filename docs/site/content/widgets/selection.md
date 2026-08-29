---
title: Selection
description: Hand-drawn chips, dropdowns, date/time pickers, and color pickers in the Skribble design system.
---

# Selection

Skribble provides selection widgets for choices, filtering, date/time picking, and color selection. Each widget replaces its Material or Cupertino counterpart with sketchy hand-drawn chrome. All selection widgets read their palette from `WiredTheme.of(context)`.

---

## WiredChip

A chip with a hand-drawn pill-shaped border (16px radius). Supports an optional avatar and delete action.

<!-- {=docsChipUsage} -->

```dart
WiredChip(
  label: Text('Flutter'),
  avatar: WiredIcon(icon: Icons.tag, size: 16),
  onDeleted: () => removeTag('Flutter'),
)
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

A selectable chip that toggles between selected and unselected states. When selected, it receives a hachure fill.

<!-- {=docsChoiceChipUsage} -->

```dart
WiredChoiceChip(
  label: Text('Small'),
  selected: size == 'small',
  onSelected: (selected) {
    setState(() => size = selected ? 'small' : null);
  },
)
```

### Notes

- Selected state applies a hachure fill behind the label, similar to `WiredToggleButtons`.
- The label text color switches to white when selected for contrast.

---

## WiredFilterChip

A chip with a checkmark indicator that can be toggled on and off for filtering. Shows a hand-drawn checkmark when selected.

<!-- {=docsFilterChipUsage} -->

```dart
WiredFilterChip(
  label: Text('Vegetarian'),
  selected: filters.contains('vegetarian'),
  onSelected: (selected) {
    setState(() {
      selected ? filters.add('vegetarian') : filters.remove('vegetarian');
    });
  },
)
```

---

## WiredInputChip

A chip representing a piece of user input (e.g., a tag or email address). Supports avatar, delete, and tap actions.

<!-- {=docsInputChipUsage} -->

```dart
WiredInputChip(
  label: Text('user@example.com'),
  avatar: WiredAvatar(radius: 12, child: Text('U')),
  onDeleted: () => removeRecipient('user@example.com'),
  onPressed: () => editRecipient('user@example.com'),
)
```

---

## WiredActionChip

A chip that triggers an action when tapped. Has a hand-drawn border but no selected state.

<!-- {=docsActionChipUsage} -->

```dart
WiredActionChip(
  label: Text('Share'),
  avatar: WiredIcon(icon: Icons.share, size: 16),
  onPressed: () => shareContent(),
)
```

---

## WiredCombo

A hand-drawn dropdown selector wrapping Flutter's `DropdownButton`. Displays a sketchy inverted triangle indicator and draws a hand-drawn rectangle around each dropdown item.

<!-- {=docsComboUsage} -->

```dart
WiredCombo<String>(
  value: selectedFruit,
  items: [
    DropdownMenuItem(value: 'apple', child: Text('Apple')),
    DropdownMenuItem(value: 'banana', child: Text('Banana')),
    DropdownMenuItem(value: 'cherry', child: Text('Cherry')),
  ],
  onChanged: (value) {
    setState(() => selectedFruit = value);
    return false; // Return false to let WiredCombo manage state
  },
)
```

### Constructor parameters

| Parameter   | Type                        | Default      | Description                                                               |
| ----------- | --------------------------- | ------------ | ------------------------------------------------------------------------- |
| `value`     | `T?`                        | `null`       | Currently selected value.                                                 |
| `items`     | `List<DropdownMenuItem<T>>` | **required** | Dropdown items.                                                           |
| `onChanged` | `bool? Function(T?)?`       | `null`       | Called on selection. Return `true` to indicate external state management. |

### Notes

- Item height is 60px.
- The inverted triangle indicator is drawn with `WiredInvertedTriangleBase` at the right edge.
- Each dropdown item is wrapped with a `WiredRectangleBase` border.
- The `onChanged` callback uses a `bool` return pattern: return `true` if managing state externally, `false` (or `null`) to let `WiredCombo` update its internal state.

---

## WiredDatePicker

A date picker dialog widget with hand-drawn calendar grid and navigation. Renders month headers and day cells with sketchy borders. Use `showWiredDatePicker` (top-level helper, shipped with the widget) to open it as a dialog.

<!-- {=docsDatePickerUsage} -->

```dart
final date = await showWiredDatePicker(
  context: context,
  initialDate: DateTime.now(),
);
```

---

## WiredDateRangePickerDialog

A hand-drawn dialog for selecting a date range, analogous to Material's
`showDateRangePicker`. A rough circle marks each range endpoint and
hachure-filled rectangles highlight the days in between. Days outside
`firstDate`..`lastDate` (and from neighbouring months) are dimmed and
disabled; the OK action stays disabled until the range is complete.

```dart
final range = await showWiredDateRangePicker(
  context: context,
  initialDateRange: DateTimeRange<DateTime>(
    start: DateTime(2026, 6, 5),
    end: DateTime(2026, 6, 12),
  ),
  firstDate: DateTime(2026),
  lastDate: DateTime(2027),
);
```

### Constructor parameters

| Parameter          | Type                       | Default                                | Description                                     |
| ------------------ | -------------------------- | -------------------------------------- | ----------------------------------------------- |
| `initialDateRange` | `DateTimeRange<DateTime>?` | `null`                                 | Pre-selected range shown when the dialog opens. |
| `firstDate`        | `DateTime?`                | month of `initialDateRange` (or today) | Earliest selectable date.                       |
| `lastDate`         | `DateTime?`                | one year after `firstDate`             | Latest selectable date.                         |
| `semanticLabel`    | `String?`                  | `'Date range picker'`                  | Semantic label for accessibility.               |

### Notes

- Prefer `showWiredDateRangePicker`, which pops the completed
  `DateTimeRange<DateTime>` (or `null` when cancelled) through the route.
- The month grid follows the `WiredCalendar` pattern: month navigation via
  hand-drawn `<<` / `>>` controls, clamped to `firstDate`..`lastDate`.
- The month shown on open defaults to the month of `initialDateRange` (or of
  `firstDate` when no range is given).
- Day cells expose `Semantics` with labels like `Select Jan 20, 2026`.

---

## WiredTimePicker

A time picker with hand-drawn clock face, clock hands, and drag-to-adjust hour/minute fields. The inline widget streams changes through `onTimeSelected`.

<!-- {=docsTimePickerUsage} -->

```dart
final time = await showWiredTimePicker(
  context: context,
  initialTime: TimeOfDay.now(),
);
if (time != null) {
  debugPrint('Selected ${time.format(context)}');
}
```

### Notes

- `showWiredTimePicker` opens a dialog containing `WiredTimePicker` plus hand-drawn Cancel/OK buttons; it returns the selected `TimeOfDay`, or `null` when cancelled or dismissed.
- Hours wrap modulo 24 (23 → 00) and minutes modulo 60 (00 → 59) when dragged.

---

## WiredCalendarDatePicker

An inline calendar date picker widget (not a dialog) with hand-drawn day cells and month navigation arrows.

<!-- {=docsCalendarDatePickerUsage} -->

```dart
WiredCalendarDatePicker(
  initialDate: DateTime.now(),
  firstDate: DateTime(2020),
  lastDate: DateTime(2030),
  onDateChanged: (date) => setState(() => selectedDate = date),
)
```

---

## WiredColorPicker

A color picker with a hand-drawn grid of color swatches. Each swatch is a sketchy circle that fills with hachure when selected.

<!-- {=docsColorPickerUsage} -->

```dart
WiredColorPicker(
  selectedColor: currentColor,
  onColorChanged: (color) => setState(() => currentColor = color),
)
```

---

## WiredCupertinoPicker

A Cupertino-style scrolling picker wheel with hand-drawn selection highlight. Mirrors the `CupertinoPicker` API.

<!-- {=docsCupertinoPickerUsage} -->

```dart
WiredCupertinoPicker(
  itemExtent: 32,
  onSelectedItemChanged: (index) => setState(() => selectedIndex = index),
  children: [
    Text('Item 1'),
    Text('Item 2'),
    Text('Item 3'),
  ],
)
```

---

## WiredCupertinoDatePicker

A Cupertino-style date picker with hand-drawn wheel columns. Mirrors the `CupertinoDatePicker` API.

<!-- {=docsCupertinoDatePickerUsage} -->

```dart
WiredCupertinoDatePicker(
  mode: CupertinoDatePickerMode.date,
  initialDateTime: DateTime.now(),
  onDateTimeChanged: (dateTime) => setState(() => selectedDate = dateTime),
)
```

---

## WiredCupertinoSegmentedControl

A Cupertino-style segmented control with hand-drawn segment borders and hachure selection fill.

<!-- {=docsCupertinoSegmentedControlUsage} -->

```dart
WiredCupertinoSegmentedControl<int>(
  groupValue: selectedSegment,
  onValueChanged: (value) => setState(() => selectedSegment = value),
  children: {
    0: Text('Day'),
    1: Text('Week'),
    2: Text('Month'),
  },
)
```
