# Skribble UI Snapshots

Visual reference for all hand-drawn Flutter components in the Skribble design system.

Each category page shows screenshots of widgets with their descriptions and key properties.

## Categories

- [Buttons](./buttons.md) - Hand-drawn button variants (WiredButton, WiredElevatedButton, WiredOutlinedButton, WiredTextButton, WiredIconButton, WiredFAB, WiredSegmentedButton)
- [Inputs](./inputs.md) - Text fields, checkboxes, sliders, toggles, and progress indicators (WiredInput, WiredTextArea, WiredSearchBar, WiredCheckbox, WiredRadio, WiredSlider, WiredRangeSlider, WiredToggle, WiredSwitch, WiredProgress, WiredCircularProgress)
- [Navigation](./navigation.md) - App bars, tabs, drawers, and navigation rails (WiredAppBar, WiredBottomNavigationBar, WiredNavigationBar, WiredNavigationRail, WiredDrawer, WiredTabBar)
- [Selection](./selection.md) - Chips, filters, and list tile composites (WiredChip, WiredChoiceChip, WiredFilterChip, WiredCheckboxListTile, WiredRadioListTile, WiredSwitchListTile)
- [Feedback](./feedback.md) - Dialogs, snack bars, popups, tooltips, and badges (WiredDialog, WiredSnackBar, WiredPopupMenuButton, WiredTooltip, WiredBadge)
- [Layout](./layout.md) - Cards, dividers, list tiles, expansion tiles, bottom sheets, and tables (WiredCard, WiredDivider, WiredListTile, WiredExpansionTile, WiredBottomSheet, WiredDataTable)
- [Data Display](./data-display.md) - Calendar, date/time pickers, and steppers (WiredCalendar, WiredDatePicker, WiredTimePicker, WiredStepper)

## Screenshot Hosting

Screenshots are captured via integration tests and uploaded to Backblaze B2 storage. The base URL for all images is:

```
https://f005.backblazeb2.com/file/skribble-screenshots/
```

Screenshots are organized by category:

```
skribble-screenshots/
  buttons/
  inputs/
  navigation/
  selection/
  feedback/
  layout/
  data-display/
  home/
```

## Regenerating Screenshots

To capture screenshots locally:

```bash
melos run screenshot
```

This runs the integration tests that navigate through each storybook page and capture snapshots.
