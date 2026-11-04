---
skribble: patch
---

# Keyboard focus and Enter/Space for every leaf control

Chips (`WiredChoiceChip`, `WiredFilterChip`, `WiredInputChip`, `WiredActionChip`), `WiredToggleButtons`, `WiredSegmentedButton`, `WiredCupertinoButton`, `WiredCupertinoSwitch`, the segments of `WiredCupertinoSegmentedControl` and `WiredSlidingSegmentedControl`, the tabs of `WiredCupertinoTabBar`, Cupertino dialog and action sheet actions, and the back buttons of `WiredCupertinoNavigationBar` and `WiredSearchAnchor` can now be reached with Tab and activated with Enter or Space. Each reports its role and enabled state, and selected or toggled state where it has one.

The focus outline is drawn by hand in the theme's `borderColor`, a few pixels outside the control. It was a straight, fixed dark ring that disappeared on dark paper.

Disabled controls no longer take focus or offer a tap action: a `WiredRadio` without `onChanged` kept its inner control enabled and focusable, chips without a callback still offered a tap, and `WiredRadioListTile` and `WiredSwitchListTile` stayed tappable when disabled.

`WiredChip` is no longer announced as a button; its close icon is a separate, labelled button. `WiredChip` and `WiredInputChip` gain `deleteButtonSemanticLabel` to change that label from `Delete`.
