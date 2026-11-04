---
skribble: minor
---

# `crampedText` can check lines and icons too

`crampedText` takes two new switches, both off by default:

- `lines: true` reports a hand-drawn line (a `WiredLineBase` divider, underline, or tab indicator) whose ink crosses or touches a text's glyph box.
- `icons: true` reports a hand-drawn icon whose ink comes within `iconGap` pixels (4 by default) of the shape around it, such as an icon button's circle. Circles are measured along their curve, so a round icon is not penalised for its bounding box.

Each `CrampedText` now carries an `ink` field, a new `CrampedInk` value, saying which check found it.
