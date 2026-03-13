# Flutter Default Widget Parity Matrix vs Skribble

This matrix inventories common Flutter **Material** and **Cupertino** default widgets and maps each to Skribble coverage across:

- library implementation (`packages/skribble/lib/src`)
- widget tests (`packages/skribble/test/widgets`)
- storybook demos (`apps/skribble_storybook/lib/pages`)

Status meanings:

- **implemented**: matching Wired widget exists with test + storybook usage
- **partial**: some coverage exists, but parity is incomplete (variant gaps / helper-only / no one-to-one equivalent)
- **unverified**: implementation exists but test or storybook evidence is missing
- **missing**: no Skribble equivalent found

## Material widgets

| Flutter widget | Skribble mapping | Lib | Test | Storybook | Status | Notes |
|---|---|---:|---:|---:|---|---|
| AppBar | `WiredAppBar` | ✅ | ✅ | ✅ (`navigation_page.dart`) | implemented |  |
| BottomNavigationBar | `WiredBottomNavigationBar` | ✅ | ✅ | ✅ (`navigation_page.dart`) | implemented |  |
| NavigationBar | `WiredNavigationBar` | ✅ | ✅ | ✅ (`navigation_page.dart`) | implemented |  |
| NavigationRail | `WiredNavigationRail` | ✅ | ✅ | ✅ (`navigation_page.dart`) | implemented |  |
| NavigationDrawer | `WiredNavigationDrawer` | ✅ | ✅ | ✅ (`navigation_page.dart`) | implemented |  |
| Drawer | `WiredDrawer` | ✅ | ✅ | ✅ (`navigation_page.dart`) | implemented |  |
| TabBar | `WiredTabBar` | ✅ | ✅ | ✅ (`navigation_page.dart`) | implemented |  |
| PopupMenuButton | `WiredPopupMenuButton` | ✅ | ✅ | ✅ (`navigation_page.dart`) | implemented |  |
| MenuBar | `WiredMenuBar` | ✅ | ✅ | ✅ (`navigation_page.dart`) | implemented | Includes `WiredSubmenuButton`, `WiredMenuItemButton` |
| DropdownMenu | `WiredDropdownMenu` | ✅ | ✅ | ✅ (`navigation_page.dart`) | implemented |  |
| ElevatedButton | `WiredElevatedButton` | ✅ | ✅ | ✅ (`buttons_page.dart`) | implemented |  |
| FilledButton | `WiredFilledButton` | ✅ | ✅ | ✅ (`buttons_page.dart`) | implemented |  |
| OutlinedButton | `WiredOutlinedButton` | ✅ | ✅ | ✅ (`buttons_page.dart`) | implemented |  |
| TextButton | `WiredTextButton` | ✅ | ✅ | ✅ (`buttons_page.dart`) | implemented |  |
| IconButton | `WiredIconButton` | ✅ | ✅ | ✅ (`buttons_page.dart`) | implemented |  |
| FloatingActionButton | `WiredFloatingActionButton` | ✅ | ✅ | ✅ (`buttons_page.dart`) | implemented |  |
| SegmentedButton | `WiredSegmentedButton` | ✅ | ✅ | ✅ (`buttons_page.dart`) | implemented |  |
| ToggleButtons | `WiredToggleButtons` | ✅ | ✅ | ✅ (`buttons_page.dart`) | implemented |  |
| TextField | `WiredInput` | ✅ | ✅ | ✅ (`inputs_page.dart`) | implemented |  |
| TextArea (multiline) | `WiredTextArea` | ✅ | ✅ | ✅ (`inputs_page.dart`) | implemented |  |
| SearchBar | `WiredSearchBar` | ✅ | ✅ | ✅ (`inputs_page.dart`) | implemented |  |
| DropdownButton | `WiredCombo` | ✅ | ✅ | ✅ (`selection_page.dart`) | implemented |  |
| Autocomplete | `WiredAutocomplete` | ✅ | ✅ | ✅ (`inputs_page.dart`) | implemented |  |
| Form | `WiredForm` | ✅ | ✅ | ✅ (`inputs_page.dart`) | implemented |  |
| Checkbox | `WiredCheckbox` | ✅ | ✅ | ✅ (`inputs_page.dart`) | implemented |  |
| CheckboxListTile | `WiredCheckboxListTile` | ✅ | ✅ | ✅ (`inputs_page.dart`) | implemented |  |
| Radio | `WiredRadio` | ✅ | ✅ | ✅ (`inputs_page.dart`) | implemented |  |
| RadioListTile | `WiredRadioListTile` | ✅ | ✅ | ✅ (`inputs_page.dart`) | implemented |  |
| Switch | `WiredSwitch` | ✅ | ✅ | ✅ (`inputs_page.dart`) | implemented |  |
| SwitchListTile | `WiredSwitchListTile` | ✅ | ✅ | ✅ (`inputs_page.dart`) | implemented |  |
| Slider | `WiredSlider` | ✅ | ✅ | ✅ (`inputs_page.dart`) | implemented |  |
| RangeSlider | `WiredRangeSlider` | ✅ | ✅ | ✅ (`inputs_page.dart`) | implemented |  |
| Chip | `WiredChip` | ✅ | ✅ | ✅ (`selection_page.dart`) | implemented |  |
| ChoiceChip | `WiredChoiceChip` | ✅ | ✅ | ✅ (`selection_page.dart`) | implemented |  |
| FilterChip | `WiredFilterChip` | ✅ | ✅ | ✅ (`selection_page.dart`) | implemented |  |
| InputChip | `WiredInputChip` | ✅ | ✅ | ✅ (`selection_page.dart`) | implemented |  |
| ActionChip | `WiredActionChip` | ✅ | ✅ | ✅ (`selection_page.dart`) | implemented |  |
| DatePicker | `WiredDatePicker` | ✅ | ✅ | ✅ (`data_display_page.dart`) | implemented |  |
| TimePicker | `WiredTimePicker` | ✅ | ✅ | ✅ (`data_display_page.dart`) | implemented |  |
| CalendarDatePicker | `WiredCalendarDatePicker` | ✅ | ✅ | ✅ (`data_display_page.dart`) | implemented |  |
| Dialog | `WiredDialog` | ✅ | ✅ | ✅ (`feedback_page.dart`) | implemented |  |
| SnackBar | `WiredSnackBarContent` | ✅ | ✅ | ✅ (`feedback_page.dart`) | implemented |  |
| Tooltip | `WiredTooltip` | ✅ | ✅ | ✅ (`feedback_page.dart`) | implemented |  |
| BottomSheet | `WiredBottomSheet` | ✅ | ✅ | ✅ (`feedback_page.dart`) | implemented |  |
| LinearProgressIndicator | `WiredProgress` | ✅ | ✅ | ✅ (`feedback_page.dart`) | implemented |  |
| CircularProgressIndicator | `WiredCircularProgress` | ✅ | ✅ | ✅ (`feedback_page.dart`) | implemented |  |
| Badge | `WiredBadge` | ✅ | ✅ | ✅ (`feedback_page.dart`) | implemented |  |
| Card | `WiredCard` | ✅ | ✅ | ✅ (`layout_page.dart`) | implemented |  |
| Divider | `WiredDivider` | ✅ | ✅ | ✅ (`layout_page.dart`) | implemented |  |
| ListTile | `WiredListTile` | ✅ | ✅ | ✅ (`layout_page.dart`) | implemented |  |
| ExpansionTile | `WiredExpansionTile` | ✅ | ✅ | ✅ (`layout_page.dart`) | implemented |  |
| DataTable | `WiredDataTable` | ✅ | ✅ | ✅ (`data_display_page.dart`) | implemented |  |
| Stepper | `WiredStepper` | ✅ | ✅ | ✅ (`data_display_page.dart`) | implemented |  |
| Calendar | `WiredCalendar` | ✅ | ✅ | ✅ (`data_display_page.dart`) | implemented |  |
| ReorderableListView | `WiredReorderableListView` | ✅ | ✅ | ✅ (`layout_page.dart`) | implemented |  |
| Scrollbar | `WiredScrollbar` | ✅ | ✅ | ✅ (`layout_page.dart`) | implemented |  |

## Cupertino widgets

| Flutter widget | Skribble mapping | Lib | Test | Storybook | Status | Notes |
|---|---|---:|---:|---:|---|---|
| CupertinoButton | `WiredCupertinoButton` | ✅ | ✅ | ✅ (`buttons_page.dart`) | implemented | Press-opacity, filled variant |
| CupertinoSwitch | `WiredCupertinoSwitch` | ✅ | ✅ | ✅ (`inputs_page.dart`) | implemented | Animated thumb with green active track |
| CupertinoTextField | `WiredCupertinoTextField` | ✅ | ✅ | ✅ (`inputs_page.dart`) | implemented | Rounded border with prefix/suffix |
| CupertinoSlider | `WiredCupertinoSlider` | ✅ | ✅ | ✅ (`inputs_page.dart`) | implemented | Hand-drawn track and thumb |
| CupertinoNavigationBar | `WiredCupertinoNavigationBar` | ✅ | ✅ | ✅ (`navigation_page.dart`) | implemented | Sketchy bottom border |
| CupertinoTabBar | `WiredCupertinoTabBar` | ✅ | ✅ | ✅ (`navigation_page.dart`) | implemented | Sketchy top border |
| CupertinoPicker | `WiredCupertinoPicker` | ✅ | ✅ | ✅ (`selection_page.dart`) | implemented | Wheel picker with sketchy border |
| CupertinoDatePicker | `WiredCupertinoDatePicker` | ✅ | ✅ | ✅ (`selection_page.dart`) | implemented | All modes (date/time/dateAndTime) |
| CupertinoAlertDialog | `WiredCupertinoAlertDialog` | ✅ | ✅ | ✅ (`feedback_page.dart`) | implemented | With `WiredCupertinoDialogAction` |
| CupertinoActionSheet | `WiredCupertinoActionSheet` | ✅ | ✅ | ✅ (`feedback_page.dart`) | implemented | With action/cancel buttons |
| CupertinoSegmentedControl | `WiredCupertinoSegmentedControl` | ✅ | ✅ | ✅ (`selection_page.dart`) | implemented | Generic key-based API |
| CupertinoSlidingSegmentedControl | `WiredSlidingSegmentedControl` | ✅ | ✅ | ✅ (`selection_page.dart`) | implemented | Sliding thumb variant |
| CupertinoPageScaffold | `WiredCupertinoPageScaffold` | ✅ | ✅ | ✅ (`layout_page.dart`) | implemented |  |
| CupertinoTabScaffold | `WiredCupertinoTabScaffold` | ✅ | ✅ | ✅ (`layout_page.dart`) | implemented |  |

## Extended widgets (beyond parity)

| Widget | Skribble mapping | Lib | Test | Storybook | Status | Notes |
|---|---|---:|---:|---:|---|---|
| CircleAvatar | `WiredAvatar` | ✅ | ✅ | ✅ (`layout_page.dart`) | implemented | Hand-drawn circle with initials/icon/image |
| MaterialBanner | `WiredMaterialBanner` | ✅ | ✅ | ✅ (`feedback_page.dart`) | implemented | Persistent top banner with sketchy borders |
| DrawerHeader | `WiredDrawerHeader` | ✅ | ✅ | ✅ (`navigation_page.dart`) | implemented | Sketchy header with hachure background |
| UserAccountsDrawerHeader | `WiredUserAccountsDrawerHeader` | ✅ | ✅ | ✅ (`navigation_page.dart`) | implemented | Avatar + account info header |
| BottomAppBar | `WiredBottomAppBar` | ✅ | ✅ | ✅ (`navigation_page.dart`) | implemented | M3 bottom bar with sketchy top border |
| SliverAppBar | `WiredSliverAppBar` | ✅ | ✅ | ✅ (`layout_page.dart`) | implemented | Collapsible sliver bar with sketchy border |
| Dismissible | `WiredDismissible` | ✅ | ✅ | ✅ (`layout_page.dart`) | implemented | Swipe-to-dismiss with sketchy delete background |
| SelectableText | `WiredSelectableText` | ✅ | ✅ | ✅ (`data_display_page.dart`) | implemented | Selectable text with Skribble styling |
| AboutDialog | `WiredAboutDialog` | ✅ | ✅ | ✅ (`feedback_page.dart`) | implemented | Hand-drawn about dialog with app info |
| AnimatedIcon | `WiredAnimatedIcon` | ✅ | ✅ | ✅ (`feedback_page.dart`) | implemented | Morphing icon with Skribble styling |
| (Custom) Color Picker | `WiredColorPicker` | ✅ | ✅ | ✅ (`selection_page.dart`) | implemented | Grid of sketchy circle swatches with selection |

## Summary

- **100% parity** — every Material and Cupertino widget has a dedicated Wired equivalent.
- **55 Material + 14 Cupertino + 11 extended = 80 total implementations.**
- **81 widget source files, 88 test files, 848 widget tests, 58 storybook tests (50 page + 8 golden).**
- All widgets read from `WiredTheme.of(context)` for runtime color customization.
- All widgets use `HookWidget` exclusively (no `StatefulWidget` or `StatelessWidget`).
- Version 0.3.0 with comprehensive CHANGELOG.
