---
skribble: minor
---

# Hand-drawn borders for Material controls and text fields

Apps that still render Material widgets can now give them skribble's rough edge from their `ThemeData` instead of writing their own `ShapeBorder`:

- **`RoughOutlinedBorder`** is an `OutlinedBorder` that inks its `side` as a rough rounded rectangle. Use it as the `shape` of cards, buttons, chips, dialogs, and sheets, or in a `ShapeDecoration`. It lives in the core and imports only `flutter/painting.dart`.
- **`RoughInputBorder`** is the `InputBorder` for text fields, in the compatibility layer. It reports `isOutline: false`, so Material floats the label inside the field instead of cutting a gap the rough line cannot leave.

Both keep a fixed `seed`, so a control keeps its wobble while it is pressed, focused, or rebuilt. Their fill stops at the centre of the pen line, they compare by value, and they interpolate their side and corners. Prepared outlines are shared through one bounded cache (256 entries, least recently used evicted), so many equal-sized controls prepare their outline once.

`RoughBoxDecoration.inkInset` now uses the same inset helper, with no change in value. The compatibility layer grows from four files to five for `RoughInputBorder`, and the Material debt baseline records that.
