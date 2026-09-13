---
skribble: minor
---

# Add a quarantined Material/Cupertino compatibility layer

Material and Cupertino interop now lives in one clearly-labelled group, exported from `package:skribble/skribble.dart` and sourced from `lib/src/compat/`. It is the single sanctioned exception to the rule that Skribble core imports only `flutter/widgets.dart` and below.

What it exposes:

- `WiredThemeInterop` converts theme objects both ways: `fromThemeData`, `fromColorScheme`, and `fromCupertinoTheme` derive Skribble tokens (colors, disabled state, stroke width from the shape language, font family), while the existing `toThemeData`/`toColorScheme` gain `toCupertinoThemeData`. `WiredThemeModeInterop` converts `SkribbleThemeMode` to and from Material's `ThemeMode`.
- `WiredMaterialTheme` installs the Material theme and English Material localizations a `SkribbleApp` cannot provide, so Material widgets keep working inside a Skribble app.
- `WiredThemeFromMaterial` and `WiredThemeFromCupertino` let existing Material and Cupertino apps give Wired widgets the host app's palette a screen at a time.
- `WiredMaterialApp` remains for apps that keep `MaterialApp` while migrating.

The compatibility group's job is interop and migration, not Material parity: it does not add new `MaterialApp` passthroughs to `WiredMaterialApp`.
