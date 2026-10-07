---
skribble: minor
---

# The ink gets room to breathe

Hand-drawn lines wobble and have width, so text that fits a straight border can look crushed against a sketched one. Every control now keeps at least 8 pixels above and below its content and 12 at the sides, and grows with its text instead of squeezing it.

- New constants: `kWiredInkPadding` (8 above and below, 12 at the sides), `kWiredButtonPadding` (16 at the sides), and `kWiredChipHeight` (36). `kWiredButtonHeight` is now a minimum.
- Buttons, segmented buttons, chips, autocomplete and search fields, Cupertino search fields, time-picker cells, stepper circles, and drawer and rail destinations grow with larger fonts and the platform's text scaling instead of clipping or crowding their labels.
- Chips are 36 pixels tall (were 32). Cupertino date and timer picker rows default to 40 pixels (were 32), and the Cupertino search field defaults to 40 (was 36).
- `WiredCupertinoDatePicker` writes its wheels in the theme's typeface under a single hand-drawn band, and on a narrow screen scales its wheels down instead of throwing.
- `WiredMaterialBanner` moves its actions below the message when it is under 480 pixels wide.
- Fixed: `WiredNavigationDrawer` destinations and `WiredReorderableListView` items now centre their content instead of pinning it to the top edge. `WiredCupertinoFormSection` pads its rows, and `WiredAvatar` initials shrink to stay inside the circle.
- New `package:skribble/testing.dart`: `crampedText` and `squeezedText` check a laid-out screen for text that crowds the ink or wraps into a narrow column, with no extra dependencies.
