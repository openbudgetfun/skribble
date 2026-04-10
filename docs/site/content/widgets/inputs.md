---
title: Inputs
description: Hand-drawn form controls, text fields, toggles, and sliders in the Skribble design system.
---

# Inputs

Skribble replaces standard form controls with sketchy, hand-drawn equivalents. All input widgets read their palette from `WiredTheme.of(context)` and extend `HookWidget`.

---

## WiredInput

A single-line text field wrapped in a hand-drawn rectangle border. Supports labels, hints, and password masking.

<!-- {=docsInputUsage} -->

```dart
WiredInput(
  labelText: 'Name',
  hintText: 'Enter your name',
  onChanged: (value) => print(value),
)
```

### Constructor parameters

| Parameter     | Type                     | Default | Description                               |
| ------------- | ------------------------ | ------- | ----------------------------------------- |
| `controller`  | `TextEditingController?` | `null`  | External text controller.                 |
| `style`       | `TextStyle?`             | `null`  | Text style for the input value.           |
| `labelText`   | `String?`                | `null`  | Label displayed to the left of the field. |
| `labelStyle`  | `TextStyle?`             | `null`  | Style for the label text.                 |
| `hintText`    | `String?`                | `null`  | Placeholder text inside the field.        |
| `hintStyle`   | `TextStyle?`             | `null`  | Style for the hint text.                  |
| `onChanged`   | `void Function(String)?` | `null`  | Called on every text change.              |
| `obscureText` | `bool`                   | `false` | Hides input for passwords.                |

### Notes

- The field is 48px tall with a `WiredRectangleBase` border.
- When `labelText` is set, the label and field are arranged in a `Row` with 10px spacing.
- Uses `InputBorder.none` internally since the sketchy border replaces the standard decoration.

---

## WiredTextArea

A multi-line text input with a hand-drawn rectangle border. The border fills behind the text area using `Positioned.fill`.

<!-- {=docsTextAreaUsage} -->

```dart
WiredTextArea(
  hintText: 'Write something...',
  maxLines: 8,
  minLines: 4,
  onChanged: (value) {},
)
```

### Constructor parameters

| Parameter    | Type                     | Default | Description               |
| ------------ | ------------------------ | ------- | ------------------------- |
| `controller` | `TextEditingController?` | `null`  | External text controller. |
| `style`      | `TextStyle?`             | `null`  | Text style.               |
| `hintText`   | `String?`                | `null`  | Placeholder text.         |
| `hintStyle`  | `TextStyle?`             | `null`  | Hint text style.          |
| `onChanged`  | `void Function(String)?` | `null`  | Called on text changes.   |
| `maxLines`   | `int`                    | `5`     | Maximum visible lines.    |
| `minLines`   | `int`                    | `3`     | Minimum visible lines.    |

### Notes

- Content padding is 8px on all sides.
- The sketchy border scales automatically with the text area height.

---

## WiredSearchBar

A search input with a pill-shaped hand-drawn border (24px border radius). Includes a leading search icon and optional trailing widget.

<!-- {=docsSearchBarUsage} -->

```dart
WiredSearchBar(
  hintText: 'Search widgets...',
  onChanged: (query) => filterResults(query),
  onSubmitted: (query) => search(query),
)
```

### Constructor parameters

| Parameter     | Type                     | Default | Description                                                   |
| ------------- | ------------------------ | ------- | ------------------------------------------------------------- |
| `controller`  | `TextEditingController?` | `null`  | Text controller.                                              |
| `hintText`    | `String?`                | `null`  | Placeholder text. Defaults to `'Search...'`.                  |
| `onChanged`   | `ValueChanged<String>?`  | `null`  | Called on every keystroke.                                    |
| `onSubmitted` | `ValueChanged<String>?`  | `null`  | Called when the user submits.                                 |
| `leading`     | `Widget?`                | `null`  | Custom leading widget. Defaults to a `WiredIcon` search icon. |
| `trailing`    | `Widget?`                | `null`  | Optional trailing widget (e.g., a clear button).              |

### Notes

- Fixed height of 48px.
- The default leading icon uses `WiredIcon` with `WiredIconFillStyle.solid`.
- The hint color uses `theme.disabledTextColor`.

---

## WiredCheckbox

A hand-drawn checkbox with a sketchy rectangle border. The checkmark is rendered by an underlying transparent `Checkbox` widget, scaled up for visual presence.

<!-- {=docsCheckboxUsage} -->

```dart
WiredCheckbox(
  value: isChecked,
  onChanged: (newValue) {
    setState(() => isChecked = newValue ?? false);
  },
)
```

### Constructor parameters

| Parameter   | Type                   | Default      | Description                                        |
| ----------- | ---------------------- | ------------ | -------------------------------------------------- |
| `value`     | `bool?`                | **required** | Current checked state. Supports tristate (`null`). |
| `onChanged` | `void Function(bool?)` | **required** | Called when the user taps the checkbox.            |

### Notes

- The checkbox is 27x27 logical pixels.
- The underlying `Checkbox` uses transparent fill with `theme.borderColor` for the check color.
- Internal state is managed with `useState` for immediate visual feedback.

---

## WiredCheckboxListTile

Combines `WiredCheckbox` with a `WiredListTile`-style layout including title, subtitle, and optional secondary widget. Follows the same API pattern as Material's `CheckboxListTile`.

<!-- {=docsCheckboxListTileUsage} -->

```dart
WiredCheckboxListTile(
  title: Text('Accept terms'),
  value: accepted,
  onChanged: (value) => setState(() => accepted = value ?? false),
)
```

---

## WiredRadio

A hand-drawn radio button with a sketchy circle border. When selected, the inner circle fills with a hachure pattern.

<!-- {=docsRadioUsage} -->

```dart
WiredRadio<String>(
  value: 'option1',
  groupValue: selectedValue,
  onChanged: (value) {
    setState(() => selectedValue = value);
  },
)
```

### Constructor parameters

| Parameter    | Type                 | Default      | Description                                |
| ------------ | -------------------- | ------------ | ------------------------------------------ |
| `value`      | `T`                  | **required** | The value this radio represents.           |
| `groupValue` | `T?`                 | **required** | The currently selected value in the group. |
| `onChanged`  | `bool Function(T?)?` | **required** | Called when this radio is selected.        |

### Notes

- The outer circle is 48x48px using `WiredCircleBase` with a 0.7 diameter ratio.
- The inner selection indicator is 24x24px with a hachure fill (gap: 1.0).
- An underlying `Radio` with transparent fill handles hit testing.

---

## WiredRadioListTile

Combines `WiredRadio` with a list tile layout. Follows the `RadioListTile` API pattern.

<!-- {=docsRadioListTileUsage} -->

```dart
WiredRadioListTile<String>(
  title: Text('Option A'),
  value: 'a',
  groupValue: selected,
  onChanged: (value) => setState(() => selected = value),
)
```

---

## WiredSwitch

A toggle switch with a hand-drawn rounded rectangle track and a circle thumb that animates between on and off positions.

<!-- {=docsSwitchUsage} -->

```dart
WiredSwitch(
  value: isEnabled,
  onChanged: (newValue) {
    setState(() => isEnabled = newValue);
  },
)
```

### Constructor parameters

| Parameter       | Type                  | Default      | Description                                           |
| --------------- | --------------------- | ------------ | ----------------------------------------------------- |
| `value`         | `bool`                | **required** | Current on/off state.                                 |
| `onChanged`     | `ValueChanged<bool>?` | `null`       | Called when toggled.                                  |
| `activeColor`   | `Color?`              | `null`       | Track color when on. Defaults to `theme.borderColor`. |
| `inactiveColor` | `Color?`              | `null`       | Track color when off. Defaults to `theme.fillColor`.  |
| `semanticLabel` | `String?`             | `null`       | Accessibility label.                                  |

### Notes

- Track dimensions: 60x24 logical pixels.
- Thumb diameter: 24px.
- Animation duration: 200ms with `Curves.easeInOut`.
- The active track uses hachure fill; the inactive track has no fill.

---

## WiredSwitchListTile

Combines `WiredSwitch` with a list tile layout. Follows the `SwitchListTile` API pattern.

<!-- {=docsSwitchListTileUsage} -->

```dart
WiredSwitchListTile(
  title: Text('Dark mode'),
  value: isDark,
  onChanged: (value) => setState(() => isDark = value),
)
```

---

## WiredSlider

A slider with a sketchy track line and a hand-drawn circle thumb. Supports divisions and labels.

<!-- {=docsSliderUsage} -->

```dart
WiredSlider(
  value: volume,
  min: 0,
  max: 100,
  divisions: 10,
  label: 'Volume',
  onChanged: (newValue) {
    setState(() => volume = newValue);
    return true; // Return true to accept the change
  },
)
```

### Constructor parameters

| Parameter   | Type                     | Default      | Description                                            |
| ----------- | ------------------------ | ------------ | ------------------------------------------------------ |
| `value`     | `double`                 | **required** | Current slider value.                                  |
| `divisions` | `int?`                   | `null`       | Number of discrete steps.                              |
| `label`     | `String?`                | `null`       | Label displayed above the thumb.                       |
| `min`       | `double`                 | `0.0`        | Minimum value.                                         |
| `max`       | `double`                 | `1.0`        | Maximum value.                                         |
| `onChanged` | `bool Function(double)?` | **required** | Called on drag. Return `true` to accept the new value. |

### Notes

- The track is drawn with `WiredLineBase` at full width.
- The thumb is a 24px `WiredCircleBase` with a 0.7 diameter ratio and hachure fill.
- The `onChanged` callback returns a `bool` -- return `true` to accept the value and update the thumb position.

---

## WiredRangeSlider

A dual-handle variant of `WiredSlider` for selecting a range of values. Follows the `RangeSlider` API.

<!-- {=docsRangeSliderUsage} -->

```dart
WiredRangeSlider(
  values: RangeValues(20, 80),
  min: 0,
  max: 100,
  onChanged: (values) => setState(() => range = values),
)
```

---

## WiredToggle

A simple on/off toggle with a hand-drawn rectangle track and an animated circle thumb. More minimal than `WiredSwitch`.

<!-- {=docsToggleUsage} -->

```dart
WiredToggle(
  value: isOn,
  onChange: (newValue) {
    setState(() => isOn = newValue);
    return true; // Return true to accept the change
  },
)
```

### Constructor parameters

| Parameter       | Type                   | Default      | Description                             |
| --------------- | ---------------------- | ------------ | --------------------------------------- |
| `value`         | `bool`                 | **required** | Current toggle state.                   |
| `onChange`      | `bool Function(bool)?` | `null`       | Called on tap. Return `true` to accept. |
| `thumbRadius`   | `double`               | `24.0`       | Radius of the thumb circle.             |
| `semanticLabel` | `String?`              | `null`       | Accessibility label.                    |

### Notes

- Track width is `thumbRadius * 2.5`; track height is `thumbRadius`.
- The thumb animates with a 250ms ease-in curve.
- The `onChange` callback uses a `bool` return value pattern -- the toggle position only updates when `true` is returned, enabling controlled state management.

---

## WiredForm

A hand-drawn wrapper around Flutter's `Form` widget. Draws a sketchy rounded rectangle border around form content.

<!-- {=docsFormUsage} -->

```dart
final formKey = GlobalKey<FormState>();

WiredForm(
  formKey: formKey,
  autovalidateMode: AutovalidateMode.onUserInteraction,
  child: Column(
    children: [
      WiredInput(labelText: 'Email', hintText: 'you@example.com'),
      SizedBox(height: 16),
      WiredButton(
        onPressed: () => formKey.currentState?.validate(),
        child: Text('Submit'),
      ),
    ],
  ),
)
```

### Constructor parameters

| Parameter          | Type                    | Default                     | Description                         |
| ------------------ | ----------------------- | --------------------------- | ----------------------------------- |
| `child`            | `Widget`                | **required**                | Form content.                       |
| `formKey`          | `GlobalKey<FormState>?` | `null`                      | Key for the underlying `Form`.      |
| `autovalidateMode` | `AutovalidateMode`      | `AutovalidateMode.disabled` | When to auto-validate.              |
| `onChanged`        | `VoidCallback?`         | `null`                      | Called when any form field changes. |
| `padding`          | `EdgeInsetsGeometry`    | `EdgeInsets.all(16)`        | Padding around the form content.    |
| `borderRadius`     | `BorderRadius`          | `BorderRadius.circular(16)` | Corner radius of the border.        |

### Notes

- The border is drawn with `WiredRoundedRectangleBase` behind the form content.
- The form itself is a standard Flutter `Form`, so all `FormField` widgets work as expected.

---

## WiredAutocomplete

A hand-drawn autocomplete field that displays suggestions in a sketchy dropdown as the user types. Wraps Flutter's `Autocomplete` widget.

<!-- {=docsAutocompleteUsage} -->

```dart
WiredAutocomplete<String>(
  optionsBuilder: (textEditingValue) {
    return suggestions.where(
      (s) => s.toLowerCase().contains(textEditingValue.text.toLowerCase()),
    );
  },
  onSelected: (selection) => print('Selected: $selection'),
)
```

---

## WiredCupertinoTextField

A Cupertino-styled text field with a hand-drawn rounded rectangle border. Mirrors the `CupertinoTextField` API.

<!-- {=docsCupertinoTextFieldUsage} -->

```dart
WiredCupertinoTextField(
  placeholder: 'Enter text',
  onChanged: (value) => print(value),
)
```

---

## WiredCupertinoSlider

A Cupertino-styled slider with a sketchy track and thumb. Mirrors the `CupertinoSlider` API.

<!-- {=docsCupertinoSliderUsage} -->

```dart
WiredCupertinoSlider(
  value: brightness,
  min: 0,
  max: 1,
  onChanged: (value) => setState(() => brightness = value),
)
```

---

## WiredCupertinoSwitch

A Cupertino-styled toggle switch with hand-drawn track and thumb. Mirrors the `CupertinoSwitch` API.

<!-- {=docsCupertinoSwitchUsage} -->

```dart
WiredCupertinoSwitch(
  value: isActive,
  onChanged: (value) => setState(() => isActive = value),
)
```
