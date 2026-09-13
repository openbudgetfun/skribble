---
skribble: patch
---

# Fix disabled, RTL, and controlled-value behaviour in input widgets

Button-family widgets now expose `enabled: false` to assistive technology when their callback is null, `WiredSwitch`, `WiredToggle`, and `WiredRadio` no longer advertise a tap action while disabled, `WiredSwitch` and `WiredToggle` mirror their thumb travel in right-to-left layouts, `WiredToggle` follows external value changes, and `WiredSlider` no longer asserts when laid out at zero width. Widget tests for the button, boolean-input, and value-input families were rewritten against Skribble's public API and semantics, with a new guard that blocks reintroducing Material type coupling.
