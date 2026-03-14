# Changelog

## 0.3.0

### Complete Theme Integration

Every widget and every painter base class now reads colors from
`WiredTheme.of(context)` at runtime. Setting a custom `WiredThemeData`
propagates `borderColor`, `fillColor`, `textColor`, and `disabledTextColor`
through the entire widget tree — no hardcoded constants remain.

- **Painter base classes** (`WiredRectangleBase`, `WiredLineBase`,
  `WiredRoundedRectangleBase`, `WiredCircleBase`, `WiredInvertedTriangleBase`)
  accept `borderColor` and `fillColor` parameters
- **108 painter constructor calls** across 65 widget files updated to pass
  `borderColor: theme.borderColor`
- **10 additional widgets** added `WiredTheme.of(context)`:
  `WiredBottomSheet`, `WiredCalendarDatePicker`, `WiredColorPicker`,
  `WiredCupertinoSlider`, `WiredCupertinoSwitch`, `WiredDismissible`,
  `WiredDivider`, `WiredDrawer`, `WiredForm`, `WiredNavigationDrawer`
- **Deleted `const.dart`** — defaults moved to private constants in
  `wired_base.dart`
- `WiredBase.pathPainter()` now accepts an optional `color` parameter
- Removed unused `WiredBase.pathPaint` and `WiredBase.fillPaint` static fields

### Lint Fixes

- Resolved all `dart analyze --fatal-infos` issues across library and storybook
- Fixed `comment_references`, `use_null_aware_elements`,
  `unnecessary_import`, `directives_ordering`, `discarded_futures`,
  `parameter_assignments`
- 0 infos, 0 warnings in both `packages/skribble` and `apps/skribble_storybook`

### Test Coverage

- Expanded 12 under-tested widget test files to ≥6 tests each
- All 88 widget test files now have ≥5 `testWidgets`

### Stats

- 81 widget files, 88 widget test files, 848 widget tests, 138 rough engine tests, 58 storybook tests
- 76 widget files resolve `WiredTheme.of(context)`
- 66 widget files pass `borderColor` to painter constructors
- 0 `StatelessWidget` — `HookWidget` exclusively
- 0 `const.dart` references

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
- `WiredCupertinoSlider` — Cupertino-style hand-drawn slider

#### Selection
- `WiredCombo` — dropdown selector with sketchy border
- `WiredChip` / `WiredChoiceChip` / `WiredFilterChip` / `WiredInputChip` / `WiredActionChip`
- `WiredSegmentedButton` — segmented toggle with hand-drawn dividers
- `WiredDatePicker` / `WiredTimePicker` / `WiredCalendarDatePicker`
- `WiredCupertinoPicker` / `WiredCupertinoDatePicker`
- `WiredCupertinoSegmentedControl` / `WiredSlidingSegmentedControl`
- `WiredColorPicker` — grid of hand-drawn circle swatches

#### Navigation
- `WiredAppBar` — app bar with sketchy bottom border
- `WiredBottomNavigationBar` — bottom nav with sketchy top border
- `WiredNavigationBar` — M3 navigation bar with pill indicators
- `WiredNavigationRail` — side rail with sketchy divider
- `WiredNavigationDrawer` — M3 navigation drawer with destinations
- `WiredDrawer` — material drawer with sketchy right border
- `WiredTabBar` — tab bar with sketchy underline
- `WiredPopupMenuButton` — popup menu with sketchy items
- `WiredMenuBar` / `WiredSubmenuButton` / `WiredMenuItemButton` — M3 menu bar
- `WiredDropdownMenu` — dropdown menu with sketchy border
- `WiredCupertinoNavigationBar` — Cupertino nav bar with sketchy border
- `WiredCupertinoTabBar` — Cupertino bottom tab bar
- `WiredBottomAppBar` — M3 bottom app bar with sketchy border
- `WiredDrawerHeader` / `WiredUserAccountsDrawerHeader`

#### Feedback
- `WiredDialog` — dialog with hand-drawn rectangle border
- `WiredSnackBarContent` — snack bar with sketchy styling
- `WiredTooltip` — tooltip wrapper
- `WiredBottomSheet` — bottom sheet with sketchy top border
- `WiredProgress` — linear progress with sketchy track
- `WiredCircularProgress` — circular progress with hand-drawn arcs
- `WiredBadge` — notification badge with sketchy circle
- `WiredMaterialBanner` — top banner with sketchy borders
- `WiredCupertinoAlertDialog` / `WiredCupertinoActionSheet`
- `WiredAboutDialog` — hand-drawn about dialog
- `WiredAnimatedIcon` — animated icon with Skribble styling

#### Layout
- `WiredCard` — card with hand-drawn border
- `WiredDivider` — hand-drawn horizontal line
- `WiredListTile` — list tile with sketchy bottom border
- `WiredExpansionTile` — expandable tile with sketchy dividers
- `WiredReorderableListView` — reorderable list with sketchy item borders
- `WiredScrollbar` — styled scrollbar with sketchy thumb
- `WiredSliverAppBar` — collapsible sliver bar
- `WiredDismissible` — swipe-to-dismiss with sketchy background
- `WiredSelectableText` — selectable text with Skribble styling
- `WiredCupertinoPageScaffold` / `WiredCupertinoTabScaffold`

#### Data Display
- `WiredCalendar` — month calendar with hand-drawn cells
- `WiredDataTable` — data table with sketchy borders
- `WiredStepper` — step-by-step wizard with sketchy connectors
- `WiredAvatar` — hand-drawn circle avatar

### Theme System
- `WiredTheme` — `InheritedWidget` providing `WiredThemeData` to all descendants
- `WiredThemeData` — configurable `borderColor`, `textColor`, `fillColor`,
  `disabledTextColor`, `strokeWidth`, `roughness`, and `DrawConfig`

### Infrastructure
- 81 widget test files with 795 tests
- 8 storybook pages with 34 page tests and 8 golden visual review tests
- Visual review golden file pipeline via `matchesGoldenFile`
- CI screenshot workflow with manifest validation and baseline diff
- `skribble_lints` shared lint rules package

## 0.1.0

- Initial release with hand-drawn UI widgets extracted from `openbudget_wired`.
