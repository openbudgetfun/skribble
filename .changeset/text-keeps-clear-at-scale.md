---
skribble: patch
---

# Fields, tab bars, and app bars keep text clear of the ink

- `WiredInput`, `WiredTextArea`, `WiredAutocomplete`, `WiredSearchBar`, and `WiredCupertinoTextField` keep the standard density on desktop. Material's compact density had taken 4 pixels off each side, so on macOS a text area's hint sat 6 pixels from its border.
- `WiredTabBar`'s `height` is now a minimum. The bar grows with large text and keeps 8 pixels between each label and its underline, and it stays exactly `height` tall in an app bar's `bottom` slot.
- `WiredAppBar` applies its 1.34× text-scale limit to `leading` and `actions` as well as the title, so a text button in the fixed-height bar no longer presses against its line at 2× text.
