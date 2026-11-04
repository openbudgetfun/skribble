---
skribble: patch
---

# Material-backed widgets work in a SkribbleApp

`WiredMaterialTheme` now adds a transparent `Material` and a `ScaffoldMessenger` when there are none above it, and adds Cupertino localizations next to the Material ones. Used as `SkribbleApp(builder: (context, child) => WiredMaterialTheme(child: child!))`, it lets every skribble widget that still wraps Material run without a `MaterialApp`. Before, `WiredInput`, `WiredCheckbox`, `WiredSlider`, list tiles, drawers, menus, data tables, `showWiredSnackBar`, and the Cupertino date picker threw "No Material widget found" or a missing-localizations error.
