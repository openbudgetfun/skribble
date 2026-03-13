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
| NavigationBar (M3) | `WiredNavigationBar` | ✅ | ✅ | ✅ (`navigation_page.dart`) | implemented |  |
| NavigationRail | `WiredNavigationRail` | ✅ | ✅ | ✅ (`navigation_page.dart`) | implemented |  |
| BottomNavigationBar | `WiredBottomNavigationBar` | ✅ | ✅ | ✅ (`navigation_page.dart`) | implemented |  |
| Drawer | `WiredDrawer` | ✅ | ✅ | ✅ (`navigation_page.dart`) | implemented |  |
| TabBar | `WiredTabBar` | ✅ | ✅ | ✅ (`navigation_page.dart`) | implemented |  |
| ListTile | `WiredListTile` | ✅ | ✅ | ✅ (`layout_page.dart`) | implemented |  |
| ExpansionTile | `WiredExpansionTile` | ✅ | ✅ | ✅ (`layout_page.dart`) | implemented |  |
| ElevatedButton | `WiredElevatedButton` | ✅ | ✅ | ✅ (`buttons_page.dart`) | implemented |  |
| OutlinedButton | `WiredOutlinedButton` | ✅ | ✅ | ✅ (`buttons_page.dart`) | implemented |  |
| TextButton | `WiredTextButton` | ✅ | ✅ | ✅ (`buttons_page.dart`) | implemented |  |
| IconButton | `WiredIconButton` | ✅ | ✅ | ✅ (`buttons_page.dart`) | implemented |  |
| FloatingActionButton | `WiredFloatingActionButton` (`wired_fab.dart`) | ✅ | ✅ | ✅ (`buttons_page.dart`) | implemented |  |
| FilledButton | `WiredFilledButton` | ✅ | ✅ | ✅ (`buttons_page.dart`) | implemented | Dedicated hachure-filled button class |
| SegmentedButton | `WiredSegmentedButton` | ✅ | ✅ | ✅ (`buttons_page.dart`) | implemented |  |
| Checkbox | `WiredCheckbox` | ✅ | ✅ | ✅ (`inputs_page.dart`) | implemented |  |
| Radio | `WiredRadio` | ✅ | ✅ | ✅ (`inputs_page.dart`) | implemented |  |
| Switch | `WiredSwitch` | ✅ | ✅ | ✅ (`inputs_page.dart`) | implemented |  |
| Slider | `WiredSlider` | ✅ | ✅ | ✅ (`inputs_page.dart`) | implemented |  |
| RangeSlider | `WiredRangeSlider` | ✅ | ✅ | ✅ (`data_display_page.dart`) | implemented |  |
| DropdownButton / DropdownMenu | `WiredCombo` / `WiredDropdownMenu` | ✅ | ✅ | ✅ (`inputs_page.dart`, `navigation_page.dart`) | implemented | WiredCombo for M2, WiredDropdownMenu for M3 |
| TextField | `WiredInput` | ✅ | ✅ | ✅ (`inputs_page.dart`) | implemented |  |
| SearchBar / SearchAnchor | `WiredSearchBar` | ✅ | ✅ | ✅ (`inputs_page.dart`) | implemented |  |
| Chip | `WiredChip` | ✅ | ✅ | ✅ (`selection_page.dart`) | implemented |  |
| FilterChip | `WiredFilterChip` | ✅ | ✅ | ✅ (`selection_page.dart`) | implemented |  |
| ChoiceChip | `WiredChoiceChip` | ✅ | ✅ | ✅ (`selection_page.dart`) | implemented |  |
| InputChip / ActionChip | `WiredInputChip` / `WiredActionChip` | ✅ | ✅ | ✅ (`selection_page.dart`) | implemented | Dedicated chip variants with selection, deletion, avatar |
| Badge | `WiredBadge` | ✅ | ✅ | ✅ (`feedback_page.dart`) | implemented |  |
| Tooltip | `WiredTooltip` | ✅ | ✅ | ✅ (`feedback_page.dart`) | implemented |  |
| SnackBar | `showWiredSnackBar` / `WiredSnackBar` | ✅ | ✅ | ✅ (`feedback_page.dart`) | implemented |  |
| Dialog / AlertDialog | `WiredDialog` | ✅ | ✅ | ✅ (`feedback_page.dart`) | implemented |  |
| BottomSheet | `showWiredBottomSheet` / `WiredBottomSheet` | ✅ | ✅ | ✅ (`feedback_page.dart`) | implemented |  |
| DatePicker | `showWiredDatePicker` / `WiredDatePicker` | ✅ | ✅ | ✅ (`data_display_page.dart`) | implemented |  |
| TimePicker | `WiredTimePicker` | ✅ | ✅ | ✅ (`data_display_page.dart`) | implemented |  |
| CalendarDatePicker | `WiredCalendar` / `WiredCalendarDatePicker` | ✅ | ✅ | ✅ (`data_display_page.dart`) | implemented | WiredCalendar (custom) + WiredCalendarDatePicker (full API parity) |
| Card | `WiredCard` | ✅ | ✅ | ✅ (`layout_page.dart`) | implemented |  |
| Divider | `WiredDivider` | ✅ | ✅ | ✅ (`layout_page.dart`) | implemented |  |
| DataTable | `WiredDataTable` | ✅ | ✅ | ✅ (`data_display_page.dart`) | implemented |  |
| LinearProgressIndicator | `WiredProgress` | ✅ | ✅ | ✅ (`feedback_page.dart`) | implemented |  |
| CircularProgressIndicator | `WiredCircularProgress` | ✅ | ✅ | ✅ (`feedback_page.dart`) | implemented |  |
| Stepper | `WiredStepper` | ✅ | ✅ | ✅ (`data_display_page.dart`) | implemented |  |
| PopupMenuButton / MenuAnchor | `WiredPopupMenu` | ✅ | ✅ | ✅ (`navigation_page.dart`) | implemented | Storybook example added under navigation page |
| ToggleButtons | `WiredToggleButtons` | ✅ | ✅ | ✅ (`buttons_page.dart`) | implemented | Multi-toggle group with hand-drawn borders and selection fill |
| Form | `WiredForm` | ✅ | ✅ | ✅ (`inputs_page.dart`) | implemented | Hand-drawn border form container with validation |
| Autocomplete | `WiredAutocomplete` | ✅ | ✅ | ✅ (`inputs_page.dart`) | implemented | Filtering + hand-drawn field and overlay borders |
| ReorderableListView | `WiredReorderableListView` | ✅ | ✅ | ✅ (`layout_page.dart`) | implemented | Drag-handle items with hand-drawn borders |
| MenuBar / DropdownMenu (M3 menu system) | `WiredMenuBar` / `WiredDropdownMenu` | ✅ | ✅ | ✅ (`navigation_page.dart`) | implemented | Full M3 menu bar + dropdown with hand-drawn borders |
| NavigationDrawer (M3) | `WiredDrawer` / `WiredNavigationDrawer` | ✅ | ✅ | ✅ (`navigation_page.dart`) | implemented | WiredDrawer (M2) + WiredNavigationDrawer (M3 destinations API) |

## Cupertino widgets

| Flutter Cupertino widget | Skribble mapping | Lib | Test | Storybook | Status | Notes |
|---|---|---:|---:|---:|---|---|
| CupertinoNavigationBar | `WiredAppBar` (style-only alternative) | ✅ | ✅ | ✅ | partial | Not Cupertino API-compatible |
| CupertinoButton | `WiredButton` / `WiredTextButton` | ✅ | ✅ | ✅ | partial | Visual alternative only |
| CupertinoSwitch | `WiredSwitch` | ✅ | ✅ | ✅ | partial | Not Cupertino-specific implementation |
| CupertinoSlider | `WiredSlider` | ✅ | ✅ | ✅ | partial |  |
| CupertinoTextField | `WiredInput` / `WiredTextArea` | ✅ | ✅ | ✅ | partial |  |
| CupertinoPicker | `WiredCupertinoPicker` | ✅ | ✅ | ✅ (`selection_page.dart`) | implemented | Scroll picker with sketchy border + selection highlight |
| CupertinoDatePicker | `WiredDatePicker` / `WiredTimePicker` | ✅ | ✅ | ✅ | partial | API + iOS wheel UX not matched |
| CupertinoAlertDialog | `WiredDialog` | ✅ | ✅ | ✅ | partial |  |
| CupertinoActionSheet | `WiredBottomSheet` / `WiredPopupMenu` | ✅ | ✅ | ❌ (popup menu) | partial | Not dedicated Cupertino action sheet |
| CupertinoTabBar | `WiredBottomNavigationBar` | ✅ | ✅ | ✅ | partial |  |
| CupertinoTabScaffold | `WiredTabScaffold` | ✅ | ✅ | ✅ (`layout_page.dart`) | implemented | Tabbed layout with hand-drawn bottom tab bar |
| CupertinoPageScaffold | `WiredPageScaffold` | ✅ | ✅ | ✅ (`layout_page.dart`) | implemented | Page scaffold with optional nav bar |
| CupertinoContextMenu | `WiredContextMenu` | ✅ | ✅ | ✅ (`feedback_page.dart`) | implemented | Long-press overlay with actions and dismiss |
| CupertinoScrollbar | `WiredScrollbar` | ✅ | ✅ | ✅ (`feedback_page.dart`) | implemented | Styled scrollbar with sketchy thumb |
| CupertinoSegmentedControl / SlidingSegmentedControl | `WiredSegmentedButton` | ✅ | ✅ | ✅ | partial | Similar interaction; different API |

## Summary

- **Strongly covered Material surface:** navigation, core buttons, selection controls, dialogs/overlays, data display, progress, and many list/layout primitives.
- **No currently unverified implemented Material widgets** in this matrix (lib + test + storybook evidence present for mapped items).
- **Main gaps for “default Flutter parity”:** higher-level form wrappers, autocomplete/reorderable/menu-bar surfaces, and most Cupertino-specific scaffolds/pickers/context widgets.
- **Cupertino parity is mostly “style-adjacent”, not API-level parity.**
