---
skribble: patch
---

# Leaf controls stay readable in dark themes and at large text

- A selected `WiredInputChip` is filled with ink and writes its label in the paper colour, like the other chips. It wrote white text on a paper fill.
- Every chip keeps `kWiredButtonPadding` around its label.
- A selected `WiredSegmentedButton` segment is washed with `markerColor`; its hachure lines ran through the label. Segment labels use `theme.textColor`.
- `WiredInput` writes `errorText` and the `maxLength` counter below the ink, where they no longer touch the border, and writes its value in `theme.textColor`. `WiredTextArea` and `WiredAutocomplete` also write in the theme's colours, and the autocomplete suggestions sit on the theme's paper instead of showing the page through them.
- `WiredCupertinoAlertDialog` and `WiredCupertinoActionSheet` sit on the theme's `fillColor` with the ink drawn over it. They painted a white box over the outline, which hid half the line and made light text unreadable in dark themes. The dialog stacks its actions one per row when there are more than two or the text is scaled past 1.5×, so labels no longer break mid-word.
- `WiredToggleButtons.height` and `WiredCupertinoTabBar.height` are minimums, so larger text grows the control instead of clipping or overflowing it.
- `WiredSwitch` paints `inactiveColor` when it is set; it was ignored.
