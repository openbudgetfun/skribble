---
skribble: minor
---

# Let `WiredButton` render a disabled state

`WiredButton.onPressed` is now nullable, matching `WiredFilledButton`, `WiredElevatedButton`, `WiredOutlinedButton`, `WiredTextButton`, and `WiredIconButton`. Passing null disables the button: taps are ignored and the label renders with the theme's `disabledTextColor`. Existing callers that pass a non-null callback are unaffected.
