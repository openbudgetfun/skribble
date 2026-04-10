---
title: API Overview
description: High-level map of the Skribble public API — exports, key types, and where to find them.
---

The main library is imported via a single barrel file:

```dart
import 'package:skribble/skribble.dart';
```

This exports 89 files covering the full widget set, rough engine, theming, and canvas system.

## API layers

The public API is organized into five layers, from lowest to highest:

### 1. Rough engine

The Dart port of rough.js that generates hand-drawn paths.

| Export                | Purpose                     |
| --------------------- | --------------------------- |
| `skribble_rough.dart` | Full rough engine re-export |

Key types:

- `DrawConfig` — roughness, bowing, seed, and curve settings
- `Generator` — creates `Drawable` shapes (rectangle, circle, polygon, arc, etc.)
- `Filler` — abstract fill pattern (HachureFiller, DotFiller, SolidFiller, etc.)
- `FillerConfig` — gap, angle, dash settings for fillers
- `RoughFilter` — enum mapping to filler types
- `Drawable` — output of Generator, contains OpSets for rendering
- `PointD` — 2D point with double precision
- `RoughBoxDecoration` — drop-in `BoxDecoration` replacement
- `RoughDrawingStyle` — stroke/fill style for decorations
- `RoughBoxShape` — shape enum (rectangle, roundedRectangle, circle, ellipse)

### 2. Canvas and painting

Low-level painting infrastructure.

| Export                    | Purpose                                              |
| ------------------------- | ---------------------------------------------------- |
| `wired_canvas.dart`       | HookWidget that renders rough shapes via CustomPaint |
| `wired_painter.dart`      | CustomPainter implementation for rough shapes        |
| `wired_painter_base.dart` | Abstract base class for shape painters               |

Key types:

- `WiredPainterBase` — override `paintRough(Canvas, Size, DrawConfig, Filler)`
- `WiredCanvas` — widget that takes a painter + filler type
- `WiredPainter` — CustomPainter adapter for WiredPainterBase

### 3. Base utilities

Shared constants, paint helpers, and repaint isolation.

| Export            | Purpose                                         |
| ----------------- | ----------------------------------------------- |
| `wired_base.dart` | WiredBase, WiredBaseWidget, painters, constants |

Key types:

- `WiredBase` — static `fillPainter(Color)` and `pathPainter(double, {Color})`
- `WiredBaseWidget` — abstract HookWidget with built-in RepaintBoundary
- `WiredRepaintMixin` — mixin for RepaintBoundary wrapping
- `buildWiredElement()` — standalone helper function
- `WiredRectangleBase`, `WiredCircleBase`, `WiredLineBase`, `WiredRoundedRectangleBase`, `WiredInvertedTriangleBase` — concrete painters
- `kWiredButtonHeight` — standard button height (42.0)

### 4. Theme system

Colors, roughness, and Material bridge.

| Export                    | Purpose                                     |
| ------------------------- | ------------------------------------------- |
| `wired_theme.dart`        | WiredThemeData + WiredTheme InheritedWidget |
| `wired_material_app.dart` | WiredMaterialApp (.router)                  |

Key types:

- `WiredThemeData` — borderColor, textColor, fillColor, strokeWidth, roughness, drawConfig
- `WiredTheme` — InheritedWidget, accessed via `WiredTheme.of(context)`
- `WiredMaterialApp` — MaterialApp wrapper that syncs WiredTheme + Material ThemeData

### 5. Widgets (80+)

All widgets follow the `Wired*` naming convention and extend `HookWidget`.

#### Buttons (10)

| Widget                      | File                          |
| --------------------------- | ----------------------------- |
| `WiredButton`               | `wired_button.dart`           |
| `WiredElevatedButton`       | `wired_elevated_button.dart`  |
| `WiredFilledButton`         | `wired_filled_button.dart`    |
| `WiredFloatingActionButton` | `wired_fab.dart`              |
| `WiredIconButton`           | `wired_icon_button.dart`      |
| `WiredOutlinedButton`       | `wired_outlined_button.dart`  |
| `WiredTextButton`           | `wired_text_button.dart`      |
| `WiredToggleButtons`        | `wired_toggle_buttons.dart`   |
| `WiredSegmentedButton`      | `wired_segmented_button.dart` |
| `WiredCupertinoButton`      | `wired_cupertino_button.dart` |

#### Inputs (17)

| Widget                    | File                              |
| ------------------------- | --------------------------------- |
| `WiredInput`              | `wired_input.dart`                |
| `WiredTextArea`           | `wired_text_area.dart`            |
| `WiredSearchBar`          | `wired_search_bar.dart`           |
| `WiredCheckbox`           | `wired_checkbox.dart`             |
| `WiredCheckboxListTile`   | `wired_checkbox_list_tile.dart`   |
| `WiredRadio`              | `wired_radio.dart`                |
| `WiredRadioListTile`      | `wired_radio_list_tile.dart`      |
| `WiredSwitch`             | `wired_switch.dart`               |
| `WiredSwitchListTile`     | `wired_switch_list_tile.dart`     |
| `WiredSlider`             | `wired_slider.dart`               |
| `WiredRangeSlider`        | `wired_range_slider.dart`         |
| `WiredToggle`             | `wired_toggle.dart`               |
| `WiredForm`               | `wired_form.dart`                 |
| `WiredAutocomplete`       | `wired_autocomplete.dart`         |
| `WiredCupertinoTextField` | `wired_cupertino_text_field.dart` |
| `WiredCupertinoSlider`    | `wired_cupertino_slider.dart`     |
| `WiredCupertinoSwitch`    | `wired_cupertino_switch.dart`     |

#### Navigation (13)

| Widget                        | File                                  |
| ----------------------------- | ------------------------------------- |
| `WiredAppBar`                 | `wired_app_bar.dart`                  |
| `WiredBottomNavigationBar`    | `wired_bottom_nav.dart`               |
| `WiredNavigationBar`          | `wired_navigation_bar.dart`           |
| `WiredNavigationRail`         | `wired_navigation_rail.dart`          |
| `WiredNavigationDrawer`       | `wired_navigation_drawer.dart`        |
| `WiredTabBar`                 | `wired_tab_bar.dart`                  |
| `WiredDrawer`                 | `wired_drawer.dart`                   |
| `WiredPopupMenuButton`        | `wired_popup_menu.dart`               |
| `WiredMenuBar`                | `wired_menu_bar.dart`                 |
| `WiredBottomAppBar`           | `wired_bottom_app_bar.dart`           |
| `WiredSliverAppBar`           | `wired_sliver_app_bar.dart`           |
| `WiredCupertinoNavigationBar` | `wired_cupertino_navigation_bar.dart` |
| `WiredCupertinoTabBar`        | `wired_cupertino_tab_bar.dart`        |

#### Selection (12)

| Widget                           | File                                     |
| -------------------------------- | ---------------------------------------- |
| `WiredChip`                      | `wired_chip.dart`                        |
| `WiredChoiceChip`                | `wired_choice_chip.dart`                 |
| `WiredFilterChip`                | `wired_filter_chip.dart`                 |
| `WiredInputChip`                 | `wired_input_chip.dart`                  |
| `WiredCombo`                     | `wired_combo.dart`                       |
| `WiredDatePicker`                | `wired_date_picker.dart`                 |
| `WiredTimePicker`                | `wired_time_picker.dart`                 |
| `WiredCalendarDatePicker`        | `wired_calendar_date_picker.dart`        |
| `WiredColorPicker`               | `wired_color_picker.dart`                |
| `WiredCupertinoPicker`           | `wired_cupertino_picker.dart`            |
| `WiredCupertinoDatePicker`       | `wired_cupertino_date_picker.dart`       |
| `WiredCupertinoSegmentedControl` | `wired_cupertino_segmented_control.dart` |

#### Feedback (13)

| Widget                      | File                                |
| --------------------------- | ----------------------------------- |
| `WiredDialog`               | `wired_dialog.dart`                 |
| `WiredSnackBarContent`      | `wired_snack_bar.dart`              |
| `WiredTooltip`              | `wired_tooltip.dart`                |
| `WiredProgress`             | `wired_progress.dart`               |
| `WiredCircularProgress`     | `wired_circular_progress.dart`      |
| `WiredBadge`                | `wired_badge.dart`                  |
| `WiredBottomSheet`          | `wired_bottom_sheet.dart`           |
| `WiredAboutDialog`          | `wired_about_dialog.dart`           |
| `WiredContextMenu`          | `wired_context_menu.dart`           |
| `WiredAnimatedIcon`         | `wired_animated_icon.dart`          |
| `WiredMaterialBanner`       | `wired_material_banner.dart`        |
| `WiredCupertinoAlertDialog` | `wired_cupertino_alert_dialog.dart` |
| `WiredCupertinoActionSheet` | `wired_cupertino_action_sheet.dart` |

#### Layout (16)

| Widget                     | File                               |
| -------------------------- | ---------------------------------- |
| `WiredCard`                | `wired_card.dart`                  |
| `WiredDivider`             | `wired_divider.dart`               |
| `WiredListTile`            | `wired_list_tile.dart`             |
| `WiredExpansionTile`       | `wired_expansion_tile.dart`        |
| `WiredDataTable`           | `wired_data_table.dart`            |
| `WiredStepper`             | `wired_stepper.dart`               |
| `WiredCalendar`            | `wired_calendar.dart`              |
| `WiredScrollbar`           | `wired_scrollbar.dart`             |
| `WiredScaffold`            | `wired_scaffold.dart`              |
| `WiredReorderableListView` | `wired_reorderable_list_view.dart` |
| `WiredDismissible`         | `wired_dismissible.dart`           |
| `WiredSelectableText`      | `wired_selectable_text.dart`       |
| `WiredDrawerHeader`        | `wired_drawer_header.dart`         |
| `WiredAvatar`              | `wired_avatar.dart`                |
| `WiredPageScaffold`        | `wired_cupertino_scaffold.dart`    |
| `WiredTabScaffold`         | `wired_cupertino_scaffold.dart`    |

#### Icons

| Widget              | File                       |
| ------------------- | -------------------------- |
| `WiredIcon`         | `wired_icon.dart`          |
| `WiredSvgIconData`  | `wired_svg_icon_data.dart` |
| `WiredAnimatedIcon` | `wired_animated_icon.dart` |

## Package dependencies

The main library depends on:

| Package         | Version   | Purpose                                   |
| --------------- | --------- | ----------------------------------------- |
| `flutter`       | SDK       | Core Flutter framework                    |
| `flutter_hooks` | `^0.21.3` | HookWidget, useState, useEffect, etc.     |
| `google_fonts`  | `^8.0.2`  | Hand-drawn font access                    |
| `path_parsing`  | `^1.1.0`  | SVG path parsing for rough icon rendering |

## Companion packages

| Package                 | Purpose                                            |
| ----------------------- | -------------------------------------------------- |
| `skribble_icons`        | 30 curated hand-drawn custom icons + unified API   |
| `skribble_emoji`        | Hand-drawn emoji from OpenMoji + WiredEmoji widget |
| `skribble_lints`        | Shared lint rules (extends `very_good_analysis`)   |
| `skribble_icons_custom` | Example custom icon set with SVG-manifest pipeline |

### skribble_icons

```dart
import 'package:skribble_icons/skribble_icons.dart';
```

| Export                             | Type                         | Purpose                                           |
| ---------------------------------- | ---------------------------- | ------------------------------------------------- |
| `kSkribbleIcons`                   | `Map<int, WiredSvgIconData>` | All custom icons keyed by codepoint               |
| `kSkribbleIconsCodePoints`         | `Map<String, int>`           | Icon identifier to codepoint mapping              |
| `lookupSkribbleIconByIdentifier()` | function                     | Look up custom icon data by name                  |
| `WiredSvgIconData`                 | class                        | SVG icon data (re-exported from `skribble`)       |
| `WiredSvgPrimitive`                | class                        | SVG primitive types (re-exported from `skribble`) |

### skribble_emoji

```dart
import 'package:skribble_emoji/skribble_emoji.dart';
```

| Export                           | Type                         | Purpose                                     |
| -------------------------------- | ---------------------------- | ------------------------------------------- |
| `kSkribbleEmoji`                 | `Map<int, WiredSvgIconData>` | All emoji keyed by Unicode codepoint        |
| `kSkribbleEmojiCodePoints`       | `Map<String, int>`           | Emoji name to Unicode codepoint mapping     |
| `lookupSkribbleEmojiByName()`    | function                     | Look up emoji data by name                  |
| `lookupSkribbleEmojiByUnicode()` | function                     | Look up emoji data by Unicode codepoint     |
| `WiredEmoji`                     | widget                       | HookWidget for rendering hand-drawn emoji   |
| `WiredSvgIconData`               | class                        | SVG icon data (re-exported from `skribble`) |

## API documentation

Full dartdoc API reference is available at:

- [pub.dev/documentation/skribble/latest/](https://pub.dev/documentation/skribble/latest/)
