---
skribble: feat
---

# Brand-aligned defaults, keyboard-accessible controls, and clearer first-run setup

Make the default `WiredThemeData` use the branded warm-paper / plum-ink palette (`WiredPalette.paper` / `ink` / `mutedInk`) instead of the generic navy-on-white, so a default `SkribbleApp` matches the documented identity, and add a `WiredPalette.coral` accent token. `WiredThemeData.cuddly()` remains the light/dark switcher.

Give `WiredFloatingActionButton`, `WiredSwitch`, and `WiredToggle` real keyboard, focus, and hover support via a new internal `WiredActivatable` wrapper: Space/Enter now activate them and focus traversal reaches them, which they previously lacked because they were built on a bare `GestureDetector`.

Fix inaccurate consumer docs: correct the bundled-font package references to `skribble_font_recursive` (was wrongly `skribble`), make the hand-drawn-font install step explicit, fix migration-guide widget names (`WiredFloatingActionButton`, `WiredBottomNavigationBar`, `showWiredSnackBar()`), and lead the README with `SkribbleApp` plus the live storybook link.

Memoize the filler and painter in `WiredCanvas` and give `FillerConfig` value equality, so ancestor rebuilds reuse the cached drawing geometry instead of repainting the rough paths every frame.
