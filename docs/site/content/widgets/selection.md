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

| Parameter | Type | Default | Description |
|---|---|---|---|
| `label` | `Widget` | **required** | The chip label. |
| `avatar` | `Widget?` | `null` | Widget displayed before the label. |
| `onDeleted` | `VoidCallback?` | `null` | Called when the delete icon is tapped. Adds a close icon when set. |

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

| Parameter | Type | Default | Description |
|---|---|---|---|
| `value` | `T?` | `null` | Currently selected value. |
| `items` | `List<DropdownMenuItem<T>>` | **required** | Dropdown items. |
| `onChanged` | `bool? Function(T?)?` | `null` | Called on selection. Return `true` to indicate external state management. |

### Notes

- Item height is 60px.
- The inverted triangle indicator is drawn with `WiredInvertedTriangleBase` at the right edge.
- Each dropdown item is wrapped with a `WiredRectangleBase` border.
- The `onChanged` callback uses a `bool` return pattern: return `true` if managing state externally, `false` (or `null`) to let `WiredCombo` update its internal state.

---

## WiredDatePicker

A date picker dialog with hand-drawn calendar grid and navigation. Renders month headers and day cells with sketchy borders.

<!-- {=docsDatePickerUsage} -->
```dart
final date = await showDatePicker(
  context: context,
  initialDate: DateTime.now(),
  firstDate: DateTime(2020),
  lastDate: DateTime(2030),
  builder: (context, child) => WiredDatePicker(child: child!),
);
```

---

## WiredTimePicker

A time picker with hand-drawn clock face and input mode. Replaces the standard Material time picker overlay.

<!-- {=docsTimePickerUsage} -->
```dart
final time = await showTimePicker(
  context: context,
  initialTime: TimeOfDay.now(),
  builder: (context, child) => WiredTimePicker(child: child!),
);
```

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
