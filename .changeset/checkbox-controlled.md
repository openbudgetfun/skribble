---
skribble: patch
---

# WiredCheckbox shows the value it is given

`WiredCheckbox` no longer keeps its own copy of `value`. Before, a tap checked the box even when the parent ignored `onChanged`, so the box could disagree with the app's state. It now behaves like Material's `Checkbox`: a tap reports the new value, and the box changes when the parent rebuilds it. A disabled checkbox is now drawn in the theme's disabled color instead of looking enabled.
