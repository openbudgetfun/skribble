---
skribble: minor
---

# Align the button and boolean-input APIs with Material where it is additive

Auditing the public `Wired*` constructor surfaces against their Material counterparts found places where a migration needed manual edits because the Wired parameter was required or named differently. The additive, source-compatible fixes:

- `WiredCheckbox.onChanged` and `WiredCheckboxListTile.onChanged` are now optional `ValueChanged<bool?>?` instead of required. Passing null disables the control the Material way: the box renders disabled, the tile's tap action is dropped, and neither advertises a tap to assistive technology. Existing callers are unaffected.
- `WiredSlider.onChanged` and `WiredRangeSlider.onChanged` are now optional. Omitting them disables the slider; previously you had to pass `null` explicitly because the parameter was `required`.
- `WiredIconButton` accepts `iconSize` and `color`, mirroring `IconButton.iconSize` and `IconButton.color`. `iconSize` defaults to half of `size`, and `color` takes precedence over the existing `iconColor`, so existing callers are unaffected.

The changeset does not change the bool-returning change callbacks (`WiredToggle.onChange`, `WiredRadio.onChanged`, `WiredRadioListTile.onChanged`, `WiredSlider.onChanged`, `WiredRangeSlider.onChanged`), the `WiredToggle.onChange` name, or the `WiredIconButton.size`/`iconColor` names: those match Material's types and names only with a source-breaking change. They are documented as known deviations in the widget catalog instead.
