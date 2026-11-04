---
skribble: patch
---

# Buttons are one labelled node and keep their padding everywhere

`WiredButton`, `WiredElevatedButton`, `WiredFilledButton`, `WiredOutlinedButton`, `WiredTextButton`, and `WiredIconButton` now expose a single semantics node: a button with its enabled state, tap and focus actions, and its label. They used to add an empty button node around the real one, and `semanticLabel` left the inner node unlabelled. A `semanticLabel` now replaces the label text instead of being read alongside it.

A disabled `WiredElevatedButton`, `WiredOutlinedButton`, or `WiredTextButton` writes its label in `theme.disabledTextColor`, as the docs already promised. It used Material's default disabled grey, which vanished on dark paper. A disabled `WiredIconButton` dims its default glyph the same way.

The rectangular buttons keep `kWiredButtonPadding` on macOS, Windows, and Linux, where Material's compact desktop density took 8 pixels off it and left large text touching the ink. `WiredTextButton` keeps `kWiredInkPadding` at every text scale, so its underline never touches the label.

`WiredButton`, `WiredElevatedButton`, and `WiredFilledButton` accept `seed`, as `WiredOutlinedButton` already did.
