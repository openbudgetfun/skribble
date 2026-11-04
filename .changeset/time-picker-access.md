---
skribble: patch
---

# Time picker works from the keyboard and screen readers

`WiredTimePicker` could only be changed by dragging. Its hour and minute fields now take focus, step with the up and down arrow keys, and are announced as `Hour` and `Minute` with values screen readers can raise and lower. With large text the fields shrink to fit the picker instead of overflowing it, and the digits keep `kWiredInkPadding` from the ink. `WiredTimePicker` and `WiredDatePicker` are no longer announced as buttons.
