---
skribble: minor
---

Add a batch of hand-drawn Cupertino parity widgets, completing the highest
priority cupertino gaps from the planning audit:

- `WiredCupertinoActivityIndicator` — iOS-style sunburst spinner drawn with
  jittered rough strokes; `animating` toggles the continuous rotation
  (idle-safe for `pumpAndSettle` tests) and supports semantic labels.
- `WiredCupertinoListSection` — inset-grouped list section with a
  hand-drawn card, sketchy separators between rows, and header/footer
  support.
- `WiredCupertinoListTile` — iOS list tile with leading/title/subtitle/
  trailing/`additionalTrailingText` API, optional hand-drawn background
  fill, button semantics, and full-width tappable behavior.
- `WiredCupertinoSearchTextField` — stadium-shaped search input with a
  rough magnifier glyph, placeholder support, submit handling, and
  text-field semantics. Built on `EditableText` (widgets only).
- `WiredCupertinoTimerPicker` — hour/minute/second wheels composed on the
  `WiredCupertinoPicker` internals; `hm`/`hms`/`ms` modes with
  `minuteInterval`/`secondInterval` granularity.
- `WiredCupertinoFormSection` — grouped form rows with hand-drawn
  dividers plus header/footer support.

All new widgets are `HookWidget`s built exclusively on `flutter/widgets`
and the rough engine (`WiredCanvas`/`WiredPainterBase`), keeping the new
code free of material/cupertino imports. Includes 79 widget tests across
six test files, five new storybook page tests, storybook demos for every
new widget, a new `cupertino.md` catalog page (plus sidebar and API
overview updates), and a minor bump.
