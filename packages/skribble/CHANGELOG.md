# Changelog

## 0.2.0

### New Widgets

#### Buttons
- `WiredButton` — hand-drawn rectangle border button
- `WiredElevatedButton` — elevated button with offset shadow
- `WiredFilledButton` — solid hachure-filled button
- `WiredFloatingActionButton` — hand-drawn circular FAB
- `WiredIconButton` — icon button with circle border
- `WiredOutlinedButton` — thick hand-drawn outlined button
- `WiredTextButton` — text button with sketchy underline
- `WiredToggleButtons` — multi-toggle button group
- `WiredCupertinoButton` — Cupertino-style press-opacity button

#### Inputs
- `WiredInput` — text field with sketchy rectangle border
- `WiredCheckbox` / `WiredCheckboxListTile` — hand-drawn checkbox
- `WiredRadio` / `WiredRadioListTile` — hand-drawn radio button
- `WiredSwitch` / `WiredSwitchListTile` — hand-drawn toggle switch
- `WiredSlider` — slider with sketchy track and thumb
- `WiredRangeSlider` — dual-handle range slider
- `WiredToggle` — simple on/off toggle
- `WiredSearchBar` — search input with sketchy border
- `WiredTextArea` — multiline text input
- `WiredForm` — form container with hand-drawn border and validation
- `WiredAutocomplete` — autocomplete with sketchy dropdown
- `WiredCupertinoTextField` — Cupertino rounded border text field
- `WiredCupertinoSlider` — Cupertino slider with hand-drawn track
- `WiredCupertinoSwitch` — Cupertino toggle with animated thumb

#### Navigation
- `WiredAppBar` — app bar with sketchy bottom border
- `WiredBottomNavigationBar` — bottom nav with sketchy top border
- `WiredNavigationBar` — M3 navigation bar
- `WiredNavigationRail` — vertical navigation rail
- `WiredNavigationDrawer` — M3 navigation drawer
- `WiredTabBar` — tab bar with sketchy indicator
- `WiredDrawer` — side drawer panel
- `WiredPopupMenuButton` — popup menu with sketchy border
- `WiredMenuBar` / `WiredSubmenuButton` / `WiredMenuItemButton` — M3 menu bar
- `WiredDropdownMenu` — M3 dropdown menu
- `WiredBottomAppBar` — M3 bottom bar with sketchy top border
- `WiredSliverAppBar` — collapsible sliver app bar
- `WiredCupertinoNavigationBar` — Cupertino nav bar
- `WiredCupertinoTabBar` — Cupertino bottom tab bar

#### Selection
- `WiredChip` / `WiredChoiceChip` / `WiredFilterChip` — selection chips
- `WiredInputChip` / `WiredActionChip` — interactive chips
- `WiredCombo` — dropdown combo box
- `WiredSegmentedButton` — segmented button group
- `WiredDatePicker` / `WiredTimePicker` — date and time pickers
- `WiredCalendarDatePicker` — inline calendar picker
- `WiredColorPicker` — grid of sketchy circle color swatches
- `WiredCupertinoPicker` — Cupertino wheel picker
- `WiredCupertinoDatePicker` — Cupertino date/time picker
- `WiredCupertinoSegmentedControl` — Cupertino segmented control
- `WiredSlidingSegmentedControl` — Cupertino sliding segment control

#### Feedback
- `WiredDialog` — dialog with hand-drawn border
- `WiredSnackBar` — snack bar with sketchy border
- `WiredTooltip` — tooltip with hand-drawn background
- `WiredProgress` — linear progress bar with hachure fill
- `WiredCircularProgress` — circular progress with sketchy arc
- `WiredBadge` — notification badge with hand-drawn circle
- `WiredBottomSheet` — bottom sheet with sketchy top border
- `WiredAboutDialog` — about dialog with hand-drawn border
- `WiredContextMenu` — long-press context menu overlay
- `WiredAnimatedIcon` — animated icon with Skribble styling
- `WiredCupertinoAlertDialog` — Cupertino alert dialog
- `WiredCupertinoActionSheet` — Cupertino action sheet

#### Layout
- `WiredCard` — card with hand-drawn rectangle border
- `WiredDivider` — hand-drawn horizontal line
- `WiredListTile` — list tile with sketchy border
- `WiredExpansionTile` — expandable tile with sketchy border
- `WiredDataTable` — data table with hand-drawn borders
- `WiredStepper` — step-by-step progress indicator
- `WiredScrollbar` — styled scrollbar with sketchy colors
- `WiredReorderableListView` — reorderable list with sketchy items
- `WiredDismissible` — swipe-to-dismiss with sketchy background
- `WiredSelectableText` — selectable text with Skribble styling
- `WiredMaterialBanner` — persistent banner with sketchy borders
- `WiredDrawerHeader` — drawer header with hachure background
- `WiredUserAccountsDrawerHeader` — avatar and account info header
- `WiredAvatar` — hand-drawn circle avatar
- `WiredCupertinoPageScaffold` — Cupertino page layout
- `WiredCupertinoTabScaffold` — Cupertino tab layout

### Theme System
- `WiredTheme` — `InheritedWidget` providing `WiredThemeData` to all descendants
- `WiredThemeData` — configurable `borderColor`, `textColor`, `fillColor`,
  `disabledTextColor`, `strokeWidth`, `roughness`, and `DrawConfig`
- Core widgets (`WiredButton`, `WiredCard`, `WiredDialog`) read from
  `WiredTheme.of(context)` with automatic fallback to defaults

### Infrastructure
- 81 widget test files with 895+ tests
- 8 storybook pages (Buttons, Inputs, Navigation, Selection, Feedback,
  Layout, Data Display, Home) with 34 page tests
- Visual review golden file pipeline via `matchesGoldenFile`
- CI screenshot workflow with manifest validation and baseline diff
- `skribble_lints` shared lint rules package

## 0.1.0

- Initial release with hand-drawn UI widgets extracted from `openbudget_wired`.
