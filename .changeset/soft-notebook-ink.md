---
skribble: minor
skribble_rough: minor
---

# Softer, lighter ink by default

skribble now draws like a careful notebook drawing instead of a heavy marker sketch. Apps that keep the default theme see the change without touching their code:

- **A finer pen.** `WiredThemeData.strokeWidth` defaults to the new `kWiredStrokeWidth`, 1.6 logical pixels instead of 2.4. Icons follow the theme pen, so they lighten in proportion.
- **Neater lines.** Playful, the default level, wavers less: roughness 1.1, offset 1.2, and line wobble 0.35 (was 1.5, 1.6, and 0.65). Gentle is tidier still at roughness 0.9 and offset 1. `DrawConfig.defaultValues` uses the playful geometry, so fills and standalone drawings match the borders around them.
- **A lighter second pass.** `RoughPen.ink` retraces less of each shape (`repeatWidth` 0.5 and `repeatCoverage` 0.45, was 0.6 and 0.7), so outlines read as one confident line with an occasional retrace.
- **Rounder corners.** Buttons default to 10 px corners (was 6), cards 16 (was 12), text fields 12 (was 8), checkboxes 6 (was 4), and `WiredTextArea` now has the same rounded corners as `WiredInput`.
- **Colour instead of ink slabs.** `WiredFilledButton`, `WiredFloatingActionButton`, and `WiredBadge` are washed with `markerColor` under ink text instead of being filled with `borderColor`. Pass `fillColor` or `backgroundColor` to keep a darker fill. A selected `WiredRadio` shows a neat solid dot, and `WiredElevatedButton` has a paper face over a light pencil shadow.
- **Colouring stays inside the lines.** Hachure no longer spills past rounded corners: the scanline fill in `skribble_rough` now starts a shallow edge at the scanline it joins. `WiredCanvas` draws fills with the theme's hand unless a `fillerConfig` says otherwise, and `WiredCard(fill: true)` colours in with even strokes 7 px apart.
- **Labelled badges fit their text.** A `WiredBadge` with a label draws a pill that grows with it, so "new" no longer spills past a 16 px circle.

To return to the heavier look, set `strokeWidth: 2.4` and `roughnessLevel: WiredRoughness.expressive` on `WiredThemeData`, or pass explicit `roughness` and `pen` values.
