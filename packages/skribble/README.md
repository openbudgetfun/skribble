# skribble

Hand-drawn UI components for Flutter — every widget looks like it was sketched by hand, with drop-in familiar Material and Cupertino APIs.

## Getting Started

```dart
import 'package:skribble/skribble.dart';
```

Wrap your app in a `WiredTheme` to customize colors across all Skribble widgets:

```dart
WiredTheme(
  data: WiredThemeData(
    borderColor: Color(0xFF2D1B69),  // Sketchy border color
    textColor: Colors.black87,
    fillColor: Color(0xFFFFF8E1),    // Warm paper background
    strokeWidth: 2,
    roughness: 1,
  ),
  child: MaterialApp(/* ... */),
);
```

All 79 widgets read from the nearest `WiredTheme` ancestor and fall back to
defaults when no theme is provided.

## Widget Catalog

### Buttons (10)

| Widget | Description |
|---|---|
| `WiredButton` | Hand-drawn rectangle border button |
| `WiredElevatedButton` | Elevated button with offset shadow |
| `WiredFilledButton` | Solid hachure-filled button |
| `WiredFloatingActionButton` | Hand-drawn circular FAB |
| `WiredIconButton` | Icon button with circle border |
| `WiredOutlinedButton` | Thick hand-drawn outlined button |
| `WiredTextButton` | Text button with sketchy underline |
| `WiredToggleButtons` | Multi-toggle button group |
| `WiredSegmentedButton` | Segmented button group |
| `WiredCupertinoButton` | Cupertino-style press-opacity button |

### Inputs (14)

| Widget | Description |
|---|---|
| `WiredInput` | Text field with sketchy rectangle border |
| `WiredTextArea` | Multiline text input |
| `WiredSearchBar` | Search input with sketchy border |
| `WiredCheckbox` / `WiredCheckboxListTile` | Hand-drawn checkbox |
| `WiredRadio` / `WiredRadioListTile` | Hand-drawn radio button |
| `WiredSwitch` / `WiredSwitchListTile` | Hand-drawn toggle switch |
| `WiredSlider` | Slider with sketchy track and thumb |
| `WiredRangeSlider` | Dual-handle range slider |
| `WiredToggle` | Simple on/off toggle |
| `WiredForm` | Form container with validation |
| `WiredAutocomplete` | Autocomplete with sketchy dropdown |
| `WiredCupertinoTextField` | Cupertino rounded border text field |
| `WiredCupertinoSlider` | Cupertino slider with hand-drawn track |
| `WiredCupertinoSwitch` | Cupertino toggle with animated thumb |

### Navigation (14)

| Widget | Description |
|---|---|
| `WiredAppBar` | App bar with sketchy bottom border |
| `WiredBottomNavigationBar` | Bottom nav with sketchy top border |
| `WiredNavigationBar` | M3 navigation bar |
| `WiredNavigationRail` | Vertical navigation rail |
| `WiredNavigationDrawer` | M3 navigation drawer |
| `WiredTabBar` | Tab bar with sketchy indicator |
| `WiredDrawer` | Side drawer panel |
| `WiredPopupMenuButton` | Popup menu with sketchy border |
| `WiredMenuBar` / `WiredSubmenuButton` / `WiredMenuItemButton` | M3 menu bar |
| `WiredDropdownMenu` | M3 dropdown menu |
| `WiredBottomAppBar` | M3 bottom bar with sketchy top border |
| `WiredSliverAppBar` | Collapsible sliver app bar |
| `WiredCupertinoNavigationBar` | Cupertino nav bar |
| `WiredCupertinoTabBar` | Cupertino bottom tab bar |

### Selection (14)

| Widget | Description |
|---|---|
| `WiredChip` / `WiredChoiceChip` / `WiredFilterChip` | Selection chips |
| `WiredInputChip` / `WiredActionChip` | Interactive chips |
| `WiredCombo` | Dropdown combo box |
| `WiredDatePicker` / `WiredTimePicker` | Date and time pickers |
| `WiredCalendarDatePicker` | Inline calendar picker |
| `WiredColorPicker` | Grid of sketchy circle color swatches |
| `WiredCupertinoPicker` | Cupertino wheel picker |
| `WiredCupertinoDatePicker` | Cupertino date/time picker |
| `WiredCupertinoSegmentedControl` | Cupertino segmented control |
| `WiredSlidingSegmentedControl` | Cupertino sliding segment control |

### Feedback (12)

| Widget | Description |
|---|---|
| `WiredDialog` | Dialog with hand-drawn border |
| `WiredSnackBarContent` / `showWiredSnackBar` | Snack bar with sketchy border |
| `WiredTooltip` | Tooltip with hand-drawn background |
| `WiredProgress` | Linear progress bar with hachure fill |
| `WiredCircularProgress` | Circular progress with sketchy arc |
| `WiredBadge` | Notification badge with hand-drawn circle |
| `WiredBottomSheet` | Bottom sheet with sketchy top border |
| `WiredAboutDialog` / `showWiredAboutDialog` | Hand-drawn about dialog |
| `WiredContextMenu` | Long-press context menu overlay |
| `WiredAnimatedIcon` | Animated icon with Skribble styling |
| `WiredCupertinoAlertDialog` | Cupertino alert dialog |
| `WiredCupertinoActionSheet` | Cupertino action sheet |

### Layout (15)

| Widget | Description |
|---|---|
| `WiredCard` | Card with hand-drawn rectangle border |
| `WiredDivider` | Hand-drawn horizontal line |
| `WiredListTile` | List tile with sketchy border |
| `WiredExpansionTile` | Expandable tile with sketchy border |
| `WiredDataTable` | Data table with hand-drawn borders |
| `WiredStepper` | Step-by-step progress indicator |
| `WiredCalendar` | Full calendar with sketchy cells |
| `WiredScrollbar` | Styled scrollbar with sketchy colors |
| `WiredReorderableListView` | Reorderable list with sketchy items |
| `WiredDismissible` | Swipe-to-dismiss with sketchy background |
| `WiredSelectableText` | Selectable text with Skribble styling |
| `WiredMaterialBanner` | Persistent banner with sketchy borders |
| `WiredDrawerHeader` / `WiredUserAccountsDrawerHeader` | Drawer headers |
| `WiredAvatar` | Hand-drawn circle avatar |
| `WiredCupertinoPageScaffold` / `WiredCupertinoTabScaffold` | Cupertino layouts |

### Theming

| Widget | Description |
|---|---|
| `WiredTheme` | `InheritedWidget` providing theme to descendants |
| `WiredThemeData` | Border, text, fill colors + stroke width, roughness |

## API Patterns

All Skribble widgets follow familiar Flutter conventions:

- **`Wired*` prefix** mirrors the Flutter widget it replaces
- **Same constructor params**: `child`, `onPressed`, `onChanged`, `value`, `selectedIndex`
- **`HookWidget` only** — no `StatefulWidget` or `StatelessWidget`
- **`WiredTheme.of(context)`** for runtime color customization

## Docs

- [Parity Matrix](../../docs/ui-snapshots/parity-matrix.md) — coverage vs Flutter defaults
- [Screenshot Manifest](../../docs/ui-snapshots/screenshot-manifest.txt) — all visual snapshots
