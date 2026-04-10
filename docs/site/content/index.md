---
title: Skribble — Hand-Drawn Flutter Design System
description: A complete Flutter design system that renders every widget with a hand-drawn, sketchy aesthetic. 80+ widgets, full theming, Material and Cupertino bridges.
---

# Skribble

Skribble is a Flutter design system that replaces polished, pixel-perfect surfaces with a hand-drawn, sketchy aesthetic. Every widget renders with wobbly borders, hachure fills, and imperfect lines -- giving your app the feel of a whiteboard prototype that actually works.

The library ships 80+ production-ready widgets, each built on `HookWidget` and prefixed with `Wired`. Drop them into any Flutter project and get a cohesive hand-drawn look without writing custom painting code.

## What makes Skribble different

- **Hand-drawn rendering** -- borders wobble, corners overshoot, fills use hachure strokes. The rough-drawing engine is deterministic (seeded RNG), so output is consistent across rebuilds while still looking hand-sketched.
- **80+ widgets** -- buttons, inputs, cards, dialogs, navigation bars, sliders, steppers, date pickers, data tables, and more. Material and Cupertino variants are both covered.
- **HookWidget-based architecture** -- every widget uses `HookWidget` (or `HookConsumerWidget` for Riverpod). No `StatefulWidget` boilerplate anywhere.
- **Material and Cupertino bridges** -- `WiredMaterialApp` and the Cupertino widget set let you adopt Skribble incrementally. Material `ThemeData` stays in sync with the Wired theme automatically.
- **Centralized theming** -- one `WiredThemeData` object controls border color, fill color, stroke width, roughness, and text colors across every widget via `WiredTheme.of(context)`.

## Quick install

<!-- {=docsQuickInstallSection} -->

Add Skribble to your Flutter project:

```bash
dart pub add skribble
```

Then import and use any Wired widget:

```dart
import 'package:skribble/skribble.dart';
```

<!-- {/docsQuickInstallSection} -->

## Start here

Work through these pages in order to go from zero to a fully themed Skribble app:

1. [Installation](/getting-started/installation) -- add the package or set up the workspace for contributing
2. [Quick Start](/getting-started/quick-start) -- build a minimal app with `WiredMaterialApp`
3. [Your First Widget](/getting-started/first-widget) -- add buttons, inputs, and cards step by step
4. [Theming](/getting-started/theming) -- customize colors, stroke width, roughness, and dark mode

## Common workflows

### Add widgets to an existing app

Wrap your app in `WiredMaterialApp` (or place a `WiredTheme` ancestor manually), then swap Material widgets for their Wired counterparts. Each Wired widget reads theme values from `WiredTheme.of(context)`, so they integrate with the tree automatically.

### Customize the theme

Create a `WiredThemeData` with your brand colors and pass it to `WiredMaterialApp`. All Wired widgets pick up the new palette instantly. See [Theming](/getting-started/theming) for the full parameter reference.

### Create a custom Wired widget

Use `WiredPainterBase` for the rough shape, `WiredCanvas` to compose painters with fillers, and `WiredBaseWidget` for repaint isolation. The [Custom Widgets](/guides/custom-widgets) guide walks through each layer.

### Use hand-drawn icons

Skribble includes a generated rough icon font based on Material Icons. Use `WiredIcon` with `MaterialRoughIcons` for icon data. See [Icons](/guides/icons) for details.

## Widget catalog

Skribble organizes its 80+ widgets into categories:

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
| **Cupertino**   | `WiredCupertinoButton`, `WiredCupertinoTextField`, `WiredCupertinoSwitch`, `WiredCupertinoSlider`, `WiredCupertinoNavigationBar`, `WiredCupertinoTabBar`, `WiredCupertinoDatePicker`, `WiredCupertinoPicker`, `WiredCupertinoActionSheet`, `WiredCupertinoAlertDialog`, `WiredCupertinoSegmentedControl`, `WiredCupertinoScaffold` |

Browse the full [widget reference](/widgets) for API details and live examples.

## Contributor resources

- [GitHub repository](https://github.com/openbudgetfun/skribble) -- source code, issues, pull requests
- [pub.dev listing](https://pub.dev/packages/skribble) -- published package and API docs
- [Contributing guide](https://github.com/openbudgetfun/skribble/blob/main/CONTRIBUTING.md) -- how to set up the workspace and submit changes
- [Storybook app](https://github.com/openbudgetfun/skribble/tree/main/apps/skribble_storybook) -- live demo of every widget
