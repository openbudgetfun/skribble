# skribble

Hand-drawn UI components for Flutter with drop-in familiar, Material-style APIs.

## Public API surface

Import the package barrel to access all public widgets and supporting types:

```dart
import 'package:skribble/skribble.dart';
```

The barrel exports all implemented `wired_*.dart` widgets under `lib/src`, plus drawing primitives used by advanced custom widgets.

### Widget coverage (Flutter-familiar naming)

- **Buttons & actions**: `WiredButton`, `WiredElevatedButton`, `WiredOutlinedButton`, `WiredTextButton`, `WiredIconButton`, `WiredFloatingActionButton`, `WiredSegmentedButton`, `WiredPopupMenuButton`
- **Inputs**: `WiredInput`, `WiredTextArea`, `WiredSearchBar`, `WiredCombo`, `WiredSlider`, `WiredRangeSlider`
- **Selection**: `WiredCheckbox`, `WiredRadio`, `WiredSwitch`, `WiredChip`, `WiredChoiceChip`, `WiredFilterChip`, `WiredToggle`
- **List tiles & composites**: `WiredListTile`, `WiredCheckboxListTile`, `WiredRadioListTile`, `WiredSwitchListTile`, `WiredExpansionTile`
- **Navigation**: `WiredAppBar`, `WiredTabBar`, `WiredBottomNavigationBar`, `WiredNavigationBar`, `WiredNavigationRail`, `WiredDrawer`
- **Feedback & overlays**: `WiredDialog`, `WiredBottomSheet`, `WiredTooltip`, `WiredSnackBarContent`, `WiredBadge`
- **Data & layout**: `WiredCard`, `WiredDivider`, `WiredDataTable`, `WiredStepper`, `WiredCalendar`
- **Pickers**: `WiredDatePicker`, `WiredTimePicker`
- **Progress**: `WiredProgress`, `WiredCircularProgress`
- **Theming & rendering base**: `WiredTheme`, `WiredThemeData`, `WiredBase`, `WiredCanvas`, `WiredPainter`

## API consistency guidelines

Skribble follows familiar Flutter patterns for easier adoption:

- `Wired*` class naming mirrors Flutter Material widget intent.
- Constructors prefer common Flutter parameter names (`child`, `children`, `onPressed`, `onChanged`, `value`, `selectedIndex`, etc.) where applicable.
- Supporting models use paired names with their host widgets (for example, `WiredNavigationDestination` with `WiredNavigationBar`).

For widget parity status and evidence, see:

- `docs/ui-snapshots/parity-matrix.md`
