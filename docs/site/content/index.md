---
title: skribble — Hand-Drawn Flutter Design System
description: A standalone Flutter design system that renders every widget with a hand-drawn, sketchy aesthetic. 80+ widgets, full theming, and a migration bridge for existing Material and Cupertino apps.
---

# skribble

skribble is a standalone Flutter design system that replaces polished, pixel-perfect surfaces with a hand-drawn, sketchy aesthetic. It is a peer of `package:material_ui` / `package:cupertino_ui`, not a theme or a skin over either. Every widget renders with wobbly borders, hachure fills, and imperfect lines -- giving your app the feel of a whiteboard prototype that actually works.

The library ships 80+ production-ready widgets, each built on `HookWidget` and prefixed with `Wired`. Drop them into any Flutter project and get a cohesive hand-drawn look without writing custom painting code.

## What makes skribble different

- **Hand-drawn rendering** -- borders wobble, corners overshoot, fills use hachure strokes. The rough-drawing engine is deterministic (seeded RNG), so output is consistent across rebuilds while still looking hand-sketched.
- **80+ widgets** -- buttons, inputs, cards, dialogs, navigation bars, sliders, steppers, date pickers, data tables, and more. Material and Cupertino variants are both covered.
- **HookWidget-based widget layer** -- every widget uses `HookWidget` (or `HookConsumerWidget` for Riverpod). The motion layer uses standard Flutter state and tickers by design; see [Architecture](/core/architecture).
- **Standalone dependency rule** -- `packages/skribble/lib` imports `flutter/widgets` and below, never Material or Cupertino. A [transitional Material bridge](/core/material-bridge) exists so existing apps can adopt skribble incrementally, and it will remain a compatibility layer while the decoupling finishes.
- **A widgets-based app shell** -- `skribbleApp` builds on `WidgetsApp`, so a skribble app needs no Material ancestor. The quarantined compatibility layer (`WiredMaterialApp`, `WiredMaterialTheme`, `WiredThemeFromMaterial`) keeps Material and Cupertino adoption incremental.
- **Centralized theming** -- one `WiredThemeData` object controls border color, fill color, stroke width, roughness, and text colors across every widget via `WiredTheme.of(context)`.

## Quick install

<!-- {=docsQuickInstallSection} -->

```bash
dart pub add skribble
```

Then import it in your application code:

```dart
// Static example: setup
import 'package:skribble/skribble.dart';
```

<!-- {/docsQuickInstallSection} -->

## Start here

Use **Find** in the header, or press ⌘F on macOS or Ctrl+F elsewhere, to search the current article. The find bar marks matching text and moves between matching sections. The sidebar search finds pages across the whole documentation site.

Work through these pages in order to go from zero to a fully themed skribble app:

1. [Installation](/getting-started/installation) -- add the package or set up the workspace for contributing
2. [Quick Start](/getting-started/quick-start) -- build a minimal app with `skribbleApp`
3. [Your First Widget](/getting-started/first-widget) -- add buttons, inputs, and cards step by step
4. [Theming](/getting-started/theming) -- customize colors, stroke width, roughness, and dark mode

## Common workflows

### Add widgets to an existing app

Wrap your app in `skribbleApp` (or keep `WiredMaterialApp` while you migrate), then swap Material widgets for their Wired counterparts. Each Wired widget reads theme values from `WiredTheme.of(context)`, so they integrate with the tree automatically.

### Customize the theme

Create a `WiredThemeData` with your brand colors and pass it to `skribbleApp`. All Wired widgets pick up the new palette instantly. See [Theming](/getting-started/theming) for the full parameter reference.

### Create a custom Wired widget

Use `WiredPainterBase` for the rough shape, `WiredCanvas` to compose painters with fillers, and `WiredBaseWidget` for repaint isolation. The [Custom Widgets](/guides/custom-widgets) guide walks through each layer.

### Use hand-drawn icons

skribble includes a generated rough icon font based on Material Icons. Use `WiredIcon` with `MaterialRoughIcons` for icon data. See [Icons](/guides/icons) for details.

## Widget catalog

skribble organizes its 80+ widgets into categories:

| Category        | Widgets                                                                                                                                                                                                                                                                                                                            |
| --------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Buttons**     | `WiredButton`, `WiredElevatedButton`, `WiredFilledButton`, `WiredOutlinedButton`, `WiredTextButton`, `WiredIconButton`, `WiredFab`                                                                                                                                                                                                 |
| **Inputs**      | `WiredInput`, `WiredTextArea`, `WiredSearchBar`, `WiredAutocomplete`, `WiredCombo`                                                                                                                                                                                                                                                 |
| **Selection**   | `WiredCheckbox`, `WiredRadio`, `WiredSwitch`, `WiredToggle`, `WiredToggleButtons`, `WiredSlider`, `WiredRangeSlider`                                                                                                                                                                                                               |
| **Layout**      | `WiredCard`, `WiredDivider`, `WiredListTile`, `WiredExpansionTile`, `WiredStepper`, `WiredReorderableListView`                                                                                                                                                                                                                     |
| **Navigation**  | `WiredAppBar`, `WiredSliverAppBar`, `WiredBottomNav`, `WiredBottomAppBar`, `WiredNavigationBar`, `WiredNavigationRail`, `WiredNavigationDrawer`, `WiredDrawer`, `WiredTabBar`                                                                                                                                                      |
| **Feedback**    | `WiredDialog`, `WiredSnackBar`, `WiredTooltip`, `WiredProgress`, `WiredCircularProgress`, `WiredBadge`, `WiredMaterialBanner`                                                                                                                                                                                                      |
| **Surfaces**    | `WiredScaffold`, `WiredBottomSheet`, `WiredPopupMenu`, `WiredContextMenu`, `WiredMenuBar`                                                                                                                                                                                                                                          |
| **Date & Time** | `WiredDatePicker`, `WiredCalendar`, `WiredCalendarDatePicker`, `WiredTimePicker`                                                                                                                                                                                                                                                   |
| **Chips**       | `WiredChip`, `WiredChoiceChip`, `WiredFilterChip`, `WiredInputChip`                                                                                                                                                                                                                                                                |
| **Data**        | `WiredDataTable`                                                                                                                                                                                                                                                                                                                   |
| **Maps**        | `WiredMap`, `WiredMapController`, `WiredMapMarkerLayer`, `WiredMapPin`, `WiredMapFeatureLayer`                                                                                                                                                                                                                                     |
| **Cupertino**   | `WiredCupertinoButton`, `WiredCupertinoTextField`, `WiredCupertinoSwitch`, `WiredCupertinoSlider`, `WiredCupertinoNavigationBar`, `WiredCupertinoTabBar`, `WiredCupertinoDatePicker`, `WiredCupertinoPicker`, `WiredCupertinoActionSheet`, `WiredCupertinoAlertDialog`, `WiredCupertinoSegmentedControl`, `WiredCupertinoScaffold` |

Browse the full [widget reference](/widgets) for API details and live examples.

## Contributor resources

- [GitHub repository](https://github.com/openbudgetfun/skribble) -- source code, issues, pull requests
- [pub.dev listing](https://pub.dev/packages/skribble) -- published package and API docs
- [Contributing guide](https://github.com/openbudgetfun/skribble/blob/main/CONTRIBUTING.md) -- how to set up the workspace and submit changes
- [Storybook app](https://github.com/openbudgetfun/skribble/tree/main/apps/skribble_storybook) -- live demo of every widget
