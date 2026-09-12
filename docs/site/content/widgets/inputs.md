---
title: Inputs
description: Hand-drawn form controls, text fields, toggles, and sliders in the Skribble design system.
---

# Inputs

Input borders inherit the shared roughness of 1.8 and 2.4-pixel pen. Long outlines use two locally wandering strokes. Small circular switch and slider thumbs reduce their jitter with their size, preserving a visible paper centre under the stronger theme.

Skribble replaces standard form controls with sketchy, hand-drawn equivalents. All input widgets read their palette from `WiredTheme.of(context)` and extend `HookWidget`.

---

## WiredInput

The default ink corners have an 8 px radius. Set `borderRadius: BorderRadius.zero` for square corners or supply another `BorderRadius`. Focus adds 0.6 px to the pen without adding a second field border.

A single-line text field wrapped in a hand-drawn rectangle border. Supports labels, hints, and password masking.

```dart
// Live example: input
WiredInput(
  labelText: 'Make something lovely',
  hintText: 'A tiny spark of an idea…',
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

```dart
// Live example: text-area
WiredTextArea(
  hintText: 'Make something lovely',
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

```dart
// Live example: search-bar
WiredSearchBar(hintText: 'Make something lovely')
```

### Constructor parameters

| Parameter     | Type                     | Default | Description                                                                                       |
| ------------- | ------------------------ | ------- | ------------------------------------------------------------------------------------------------- |
| `controller`  | `TextEditingController?` | `null`  | Text controller.                                                                                  |
| `hintText`    | `String?`                | `null`  | Placeholder text. Defaults to `'Search...'`.                                                      |
| `onChanged`   | `ValueChanged<String>?`  | `null`  | Called on every keystroke.                                                                        |
| `onSubmitted` | `ValueChanged<String>?`  | `null`  | Called when the user submits.                                                                     |
| `leading`     | `Widget?`                | `null`  | Custom leading widget. Defaults to a `WiredIcon` search icon.                                     |
| `trailing`    | `Widget?`                | `null`  | Optional trailing widget (e.g., a clear button).                                                  |
| `onTap`       | `VoidCallback?`          | `null`  | Called when the bar is tapped. Pair with `WiredSearchAnchor` (e.g. `onTap: controller.openView`). |
| `autoFocus`   | `bool`                   | `false` | Whether the internal text field requests focus on first build.                                    |

### Notes

- Fixed height of 48px.
- The default leading icon uses `WiredIcon` with `WiredIconFillStyle.solid`.
- The hint color uses `theme.disabledTextColor`.

---

## WiredSearchAnchor

A search anchor that pairs a collapsed search field with an in-place suggestions view, analogous to Material 3's `SearchAnchor`. The collapsed state is built by `builder` (which receives a `WiredSearchController` whose `openView()` opens the view); the open state renders a wired search bar plus the widgets returned by `suggestionsBuilder`, which re-runs on every keystroke so suggestions can filter live.

```dart
// Live example: search-anchor
WiredSearchAnchor(
  builder: (context, controller) => WiredSearchBar(
    controller: controller,
    hintText: 'Make something lovely',
    onTap: controller.openView,
  ),
  suggestionsBuilder: (context, controller) => [
    for (final option in ['Paper', 'Ink', 'Possibility'].where(
      (option) => option.toLowerCase().contains(controller.text.toLowerCase()),
    ))
      WiredListTile(
        title: Text(option),
        showDivider: false,
        onTap: () => controller.closeView(option),
      ),
  ],
)
```

Also exported: `WiredSearchController` (a `TextEditingController` plus `openView()` / `closeView([String? selectedText])` / `isOpen`).

### Constructor parameters

| Parameter            | Type                       | Default  | Description                                                                                  |
| -------------------- | -------------------------- | -------- | -------------------------------------------------------------------------------------------- |
| `searchController`   | `WiredSearchController?`   | `null`   | Controller for the query text and open state. Created internally when omitted.               |
| `builder`            | `WiredSearchAnchorBuilder` | required | Builds the collapsed field. Call `controller.openView()` on tap to open.                     |
| `suggestionsBuilder` | `WiredSuggestionsBuilder`  | required | Builds the suggestion widgets; re-invoked on every view rebuild.                             |
| `viewHintText`       | `String?`                  | `null`   | Hint text for the view's bar. Defaults to `'Search...'`.                                     |
| `viewLeading`        | `Widget?`                  | `null`   | Leading widget for the view's bar. Defaults to a hand-drawn back arrow that closes the view. |
| `viewTrailing`       | `Widget?`                  | `null`   | Trailing widget for the view's bar.                                                          |
| `viewEmptyWidget`    | `Widget?`                  | `null`   | Widget shown when `suggestionsBuilder` returns an empty list.                                |

### Notes

- The search view renders in place (replacing the collapsed field) with a rough-bordered container, matching the wired card visual language.
- Selection flow: call `controller.closeView(option)` from a suggestion's tap handler; the view closes and the query text is replaced with the selection.
- When the anchor creates its own controller, it is disposed with the widget; controllers passed via `searchController` are not disposed for you.

---

## WiredCheckbox

The 27 px visual now uses 4 px rounded ink corners. Override `borderRadius` when needed; compose it with a label and a larger touch area for small-screen use.

A hand-drawn checkbox with a sketchy rectangle border. The checkmark is rendered by an underlying transparent `Checkbox` widget, scaled up for visual presence.

```dart
// Live example: checkbox
HookBuilder(
  builder: (context) {
    final checked = useState(false);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        WiredCheckbox(
          value: checked.value,
          onChanged: (value) => checked.value = value ?? false,
          semanticLabel: 'Keep this idea',
        ),
        const SizedBox(width: 12),
        Flexible(child: Text('Make something lovely')),
      ],
    );
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

```dart
// Live example: checkbox-list-tile
HookBuilder(
  builder: (context) {
    final checked = useState(true);
    return WiredCheckboxListTile(
      value: checked.value,
      onChanged: (value) => checked.value = value ?? false,
      title: Text('Make something lovely'),
      showDivider: false,
    );
  },
)
```

---

## WiredRadio

A hand-drawn radio button with a sketchy circle border. When selected, the inner circle fills with a hachure pattern.

```dart
// Live example: radio
HookBuilder(
  builder: (context) {
    final selected = useState('paper');
    return Wrap(
      children: [
        for (final value in ['paper', 'ink'])
          WiredRadio<String>(
            value: value,
            groupValue: selected.value,
            semanticLabel: value,
            onChanged: true
                ? (value) {
                    selected.value = value!;
                    return true;
                  }
                : null,
          ),
      ],
    );
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

```dart
// Live example: radio-list-tile
HookBuilder(
  builder: (context) {
    final selected = useState('paper');
    return Column(
      children: [
        for (final value in ['paper', 'ink'])
          WiredRadioListTile<String>(
            title: Text(value),
            value: value,
            groupValue: selected.value,
            showDivider: false,
            onChanged: true
                ? (value) {
                    selected.value = value!;
                    return true;
                  }
                : null,
          ),
      ],
    );
  },
)
```

---

## WiredSwitch

A toggle switch with a hand-drawn rounded rectangle track and a circle thumb that animates between on and off positions.

```dart
// Live example: switch
HookBuilder(
  builder: (context) {
    final enabled = useState(true);
    return WiredSwitch(
      value: enabled.value,
      onChanged: (value) {
        enabled.value = value;
      },
    );
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

```dart
// Live example: switch-list-tile
HookBuilder(
  builder: (context) {
    final enabled = useState(true);
    return WiredSwitchListTile(
      value: enabled.value,
      onChanged: (value) => enabled.value = value,
      title: Text('Make something lovely'),
      showDivider: false,
    );
  },
)
```

---

## WiredSlider

A slider with a sketchy track line and a hand-drawn circle thumb. Supports divisions and labels.

```dart
// Live example: slider
WiredSlider(
  value: .6,
  divisions: 10,
  semanticLabel: 'Amount',
  onChanged: true ? (value) => true : null,
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

```dart
// Live example: range-slider
HookBuilder(
  builder: (context) {
    final range = useState((start: .2, end: .8));
    return WiredRangeSlider.between(
      start: range.value.start,
      end: range.value.end,
      divisions: 10,
      onChanged: true
          ? (start, end) {
              range.value = (start: start, end: end);
              return true;
            }
          : null,
    );
  },
)
```

---

## WiredToggle

A simple on/off toggle with a hand-drawn rectangle track and an animated circle thumb. More minimal than `WiredSwitch`.

```dart
// Live example: toggle
HookBuilder(
  builder: (context) {
    final enabled = useState(false);
    return WiredToggle(
      value: enabled.value,
      semanticLabel: 'Ink enabled',
      onChange: (value) {
        enabled.value = value;
        return true;
      },
    );
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

```dart
// Live example: form
WiredForm(
  borderRadius: BorderRadius.circular(8),
  child: WiredInput(labelText: 'Make something lovely', hintText: 'Your next idea'),
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

```dart
// Live example: autocomplete
WiredAutocomplete<String>(
  options: const ['Apple', 'Apricot', 'Banana', 'Cherry'],
  displayStringForOption: (value) => value,
  hintText: 'Make something lovely',
  optionsWidth: 260,
)
```

---

## WiredCupertinoTextField

A Cupertino-styled text field with a hand-drawn rounded rectangle border. Mirrors the `CupertinoTextField` API.

```dart
// Live example: cupertino-text-field
WiredCupertinoTextField(
  placeholder: 'Make something lovely',
  enabled: true,
  borderRadius: BorderRadius.circular(8),
)
```

---

## WiredCupertinoSlider

A Cupertino-styled slider with a sketchy track and thumb. Mirrors the `CupertinoSlider` API.

```dart
// Live example: cupertino-slider
HookBuilder(
  builder: (context) {
    final value = useState(.6);
    return WiredCupertinoSlider(
      value: value.value,
      onChanged: true ? (next) => value.value = next : null,
    );
  },
)
```

---

## WiredCupertinoSwitch

A Cupertino-styled toggle switch with hand-drawn track and thumb. Mirrors the `CupertinoSwitch` API.

```dart
// Live example: cupertino-switch
HookBuilder(
  builder: (context) {
    final value = useState(true);
    return WiredCupertinoSwitch(
      value: value.value,
      onChanged: true ? (next) => value.value = next : null,
    );
  },
)
```

## Handwriting and large text

`WiredInput` places its label above the sketch border, where a long label can wrap. The field grows with text scaling and uses one transparent Material input decoration, leaving the hand-drawn border visible. Focus adds 0.6 logical pixels to the themed pen. Put forms in a scrollable parent when large text exceeds the viewport height.

`WiredTextArea` likewise avoids an opaque second input border. Checkbox and slider state follows subsequent external value changes, including a parent reset after interaction. Slider updates no longer schedule a new future on each build. Pixel and interaction regressions cover these paths alongside input text at 100–300% scaling.

The switch thumb has an opaque paper fill and a full-size sketch outline, so the track cannot show through it. Its semantics expose the disabled state.

`WiredSlider` positions its thumb during the first layout, including custom nonzero ranges, and keeps both endpoints inside its bounds. A null callback disables interaction. `WiredInput` hints merge the themed secondary text color with any explicit hint style so empty fields remain readable on dark paper.

Input lettering inherits the active `WiredRoughness` level. Changing the root theme or a nested `WiredTheme` changes both the input border and font without clearing controller text. An explicit text style or drawing configuration continues to override inherited defaults.

## Ink entrances

Rough borders in input components inherit `WiredDrawTransition` progress. Their text, focus, hit targets, and existing functional state animations remain available throughout the reveal. See [Ink motion](../core/motion) for opt-in entrances and reduced-motion behavior. The slider's endpoint thumb now paints into its reserved outer padding, so its circle remains whole at both minimum and maximum values.

## Numeric range endpoints

`WiredRangeSlider.between(start: .2, end: .8, onChanged: (start, end) => true)` accepts numbers directly. Return `true` to accept an interaction or `false` to keep the current range. A null callback disables input. Rebuilding with different endpoints updates the displayed range. Both thumbs use the theme's rough drawing configuration.

`WiredCombo.options(options: {'one': Text('One')}, value: 'one', onChanged: (value) => true)` accepts a map of values to labels without requiring Material dropdown items. Return true when the caller owns the value and rebuilds it; return false or null, or omit the callback, to update the selection internally.

Give `WiredCalendar` a bounded height, for example `SizedBox(height: 360, child: WiredCalendar(...))`. Its month heading and weekday columns adapt to narrow widths.
