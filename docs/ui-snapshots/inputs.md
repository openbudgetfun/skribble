# Input Components

Hand-drawn input controls for collecting user data with a sketchy aesthetic.

## WiredInput

A single-line text field with a rough-drawn border and optional label.

![WiredInput](https://f005.backblazeb2.com/file/skribble-screenshots/inputs/wired-input.png)

- Supports `labelText`, `hintText`, `obscureText`
- `RoughBoxDecoration` border
- Standard `TextField` wrapped in hand-drawn chrome

## WiredTextArea

A multi-line text input with configurable line count.

![WiredTextArea](https://f005.backblazeb2.com/file/skribble-screenshots/inputs/wired-text-area.png)

- Configurable `maxLines` and `minLines`
- Rough-drawn border that grows with content
- Ideal for comments, notes, and descriptions

## WiredSearchBar

A rounded search field with leading search icon and optional trailing actions.

![WiredSearchBar](https://f005.backblazeb2.com/file/skribble-screenshots/inputs/wired-search-bar.png)

- Rounded rectangle with rough strokes
- Leading search icon
- Optional trailing clear/action icons

## WiredCheckbox

A hand-drawn checkbox with a rough square border.

![WiredCheckbox](https://f005.backblazeb2.com/file/skribble-screenshots/inputs/wired-checkbox.png)

- 27x27 pixel size
- Internal `Checkbox` with scale transform
- `RoughBoxDecoration` square border
- `useState` hook for state management

## WiredRadio

A circular radio button with hand-drawn indicators.

![WiredRadio](https://f005.backblazeb2.com/file/skribble-screenshots/inputs/wired-radio.png)

- Generic type support `WiredRadio<T>`
- Filled circle indicator when selected
- Groups via `groupValue` parameter

## WiredSlider

A hand-drawn slider with a dot-style thumb.

![WiredSlider](https://f005.backblazeb2.com/file/skribble-screenshots/inputs/wired-slider.png)

- `WiredLineBase` for the track
- `WiredCircleBase` for the thumb
- Controlled via `onChanged` returning `bool`
- Supports `divisions` and `label`

## WiredRangeSlider

A dual-handle range slider for selecting value ranges.

![WiredRangeSlider](https://f005.backblazeb2.com/file/skribble-screenshots/inputs/wired-range-slider.png)

- Custom thumb shape with rough circles
- `RangeValues` for start/end
- Hand-drawn track between handles

## WiredToggle

A custom toggle switch with animation.

![WiredToggle](https://f005.backblazeb2.com/file/skribble-screenshots/inputs/wired-toggle.png)

- `AnimationController` with `Curves.easeIn`
- Configurable `thumbRadius` (default 24.0)
- Controlled via `onChange` returning `bool`

## WiredSwitch

A Material-style switch with hand-drawn aesthetic.

![WiredSwitch](https://f005.backblazeb2.com/file/skribble-screenshots/inputs/wired-switch.png)

- Active/inactive color customization
- Animated thumb position
- Roughened track and thumb

## WiredProgress

A linear progress bar with animated fill.

![WiredProgress](https://f005.backblazeb2.com/file/skribble-screenshots/inputs/wired-progress.png)

- Animated fill via `AnimationController`
- Separate background and progress layers
- Value from 0.0 to 1.0

## WiredCircularProgress

A circular progress indicator in both determinate and indeterminate modes.

![WiredCircularProgress](https://f005.backblazeb2.com/file/skribble-screenshots/inputs/wired-circular-progress.png)

- Custom `_ArcPainter` for arc drawing
- Determinate mode with value
- Indeterminate mode with continuous animation
