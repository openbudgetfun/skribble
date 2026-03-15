# skribble

[![CI](https://github.com/openbudgetfun/skribble/actions/workflows/ci.yml/badge.svg)](https://github.com/openbudgetfun/skribble/actions/workflows/ci.yml)
[![License](https://img.shields.io/github/license/openbudgetfun/skribble)](LICENSE)
[![Flutter](https://img.shields.io/badge/Flutter-%E2%89%A53.41-blue?logo=flutter)](https://flutter.dev)

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

All 79 widget files (90+ public widget classes) read from the nearest
`WiredTheme` ancestor and fall back to defaults when no theme is provided.

## Widget Catalog

### Buttons (10)

| Widget                      | Description                                        |
| --------------------------- | -------------------------------------------------- |
| `WiredButton`               | Hand-drawn rectangle border button                 |
| `WiredElevatedButton`       | Elevated button with offset shadow                 |
| `WiredFilledButton`         | Solid hachure-filled button                        |
| `WiredFloatingActionButton` | Hand-drawn circular FAB                            |
| `WiredIconButton`           | Icon button with circle border                     |
| `WiredOutlinedButton`       | Thick hand-drawn outlined button                   |
| `WiredTextButton`           | Text button with sketchy underline                 |
| `WiredToggleButtons`        | Multi-toggle button group                          |
| `WiredSegmentedButton`      | Segmented button group with `WiredButtonSegment`   |
| `WiredCupertinoButton`      | Cupertino-style press-opacity button (+ `.filled`) |

### Inputs (17)

| Widget                    | Description                              |
| ------------------------- | ---------------------------------------- |
| `WiredInput`              | Text field with sketchy rectangle border |
| `WiredTextArea`           | Multiline text input                     |
| `WiredSearchBar`          | Search input with sketchy border         |
| `WiredCheckbox`           | Hand-drawn checkbox                      |
| `WiredCheckboxListTile`   | Checkbox with list tile layout           |
| `WiredRadio`              | Hand-drawn radio button                  |
| `WiredRadioListTile`      | Radio with list tile layout              |
| `WiredSwitch`             | Hand-drawn toggle switch                 |
| `WiredSwitchListTile`     | Switch with list tile layout             |
| `WiredSlider`             | Slider with sketchy track and thumb      |
| `WiredRangeSlider`        | Dual-handle range slider                 |
| `WiredToggle`             | Simple on/off toggle                     |
| `WiredForm`               | Form container with validation           |
| `WiredAutocomplete`       | Autocomplete with sketchy dropdown       |
| `WiredCupertinoTextField` | Cupertino rounded border text field      |
| `WiredCupertinoSlider`    | Cupertino slider with hand-drawn track   |
| `WiredCupertinoSwitch`    | Cupertino toggle with animated thumb     |

### Navigation (14)

| Widget                        | Description                                                   |
| ----------------------------- | ------------------------------------------------------------- |
| `WiredAppBar`                 | App bar with sketchy bottom border                            |
| `WiredBottomNavigationBar`    | Bottom nav with sketchy top border                            |
| `WiredNavigationBar`          | M3 navigation bar with `WiredNavigationDestination`           |
| `WiredNavigationRail`         | Vertical rail with `WiredNavigationRailDestination`           |
| `WiredNavigationDrawer`       | M3 drawer with `WiredNavigationDrawerDestination`             |
| `WiredTabBar`                 | Tab bar with sketchy indicator                                |
| `WiredDrawer`                 | Side drawer panel                                             |
| `WiredPopupMenuButton`        | Popup menu with `WiredPopupMenuItem`                          |
| `WiredMenuBar`                | M3 menu bar with `WiredSubmenuButton` / `WiredMenuItemButton` |
| `WiredDropdownMenu`           | M3 dropdown menu (in `wired_menu_bar.dart`)                   |
| `WiredBottomAppBar`           | M3 bottom bar with sketchy top border                         |
| `WiredSliverAppBar`           | Collapsible sliver app bar                                    |
| `WiredCupertinoNavigationBar` | Cupertino nav bar                                             |
| `WiredCupertinoTabBar`        | Cupertino bottom tab bar                                      |

### Selection (13)

| Widget                                | Description                              |
| ------------------------------------- | ---------------------------------------- |
| `WiredChip`                           | Basic chip with hand-drawn border        |
| `WiredChoiceChip`                     | Selectable chip                          |
| `WiredFilterChip`                     | Filter chip with checkmark               |
| `WiredInputChip`                      | Deletable input chip                     |
| `WiredActionChip`                     | Action chip (in `wired_input_chip.dart`) |
| `WiredCombo`                          | Dropdown combo box                       |
| `WiredDatePicker` / `WiredTimePicker` | Date and time pickers                    |
| `WiredCalendarDatePicker`             | Inline calendar picker                   |
| `WiredColorPicker`                    | Grid of sketchy circle color swatches    |
| `WiredCupertinoPicker`                | Cupertino wheel picker                   |
| `WiredCupertinoDatePicker`            | Cupertino date/time picker               |
| `WiredCupertinoSegmentedControl`      | Cupertino segmented control              |
| `WiredSlidingSegmentedControl`        | Cupertino sliding segment control        |

### Feedback (13)

| Widget                                       | Description                                                   |
| -------------------------------------------- | ------------------------------------------------------------- |
| `WiredDialog`                                | Dialog with hand-drawn border                                 |
| `WiredSnackBarContent` / `showWiredSnackBar` | Snack bar with sketchy border                                 |
| `WiredTooltip`                               | Tooltip with hand-drawn background                            |
| `WiredProgress`                              | Linear progress bar with hachure fill                         |
| `WiredCircularProgress`                      | Circular progress with sketchy arc                            |
| `WiredBadge`                                 | Notification badge with hand-drawn circle                     |
| `WiredBottomSheet`                           | Bottom sheet with sketchy top border                          |
| `WiredAboutDialog` / `showWiredAboutDialog`  | Hand-drawn about dialog                                       |
| `WiredContextMenu`                           | Long-press context menu with `WiredContextMenuAction`         |
| `WiredAnimatedIcon`                          | Animated icon with Skribble styling                           |
| `WiredMaterialBanner`                        | Persistent banner with sketchy borders                        |
| `WiredCupertinoAlertDialog`                  | Cupertino alert with `WiredCupertinoDialogAction`             |
| `WiredCupertinoActionSheet`                  | Cupertino action sheet with `WiredCupertinoActionSheetAction` |

### Layout (14)

| Widget                                                | Description                                        |
| ----------------------------------------------------- | -------------------------------------------------- |
| `WiredCard`                                           | Card with hand-drawn rectangle border              |
| `WiredDivider`                                        | Hand-drawn horizontal line                         |
| `WiredListTile`                                       | List tile with sketchy border                      |
| `WiredExpansionTile`                                  | Expandable tile with sketchy border                |
| `WiredDataTable`                                      | Data table with `WiredDataColumn` / `WiredDataRow` |
| `WiredStepper`                                        | Step-by-step indicator with `WiredStep`            |
| `WiredCalendar`                                       | Full calendar with sketchy cells                   |
| `WiredScrollbar`                                      | Styled scrollbar with sketchy colors               |
| `WiredReorderableListView`                            | Reorderable list with sketchy items                |
| `WiredDismissible`                                    | Swipe-to-dismiss with sketchy background           |
| `WiredSelectableText`                                 | Selectable text with Skribble styling              |
| `WiredDrawerHeader` / `WiredUserAccountsDrawerHeader` | Drawer headers                                     |
| `WiredAvatar`                                         | Hand-drawn circle avatar                           |
| `WiredPageScaffold` / `WiredTabScaffold`              | Cupertino scaffold layouts                         |

### Theming

| Widget           | Description                                         |
| ---------------- | --------------------------------------------------- |
| `WiredTheme`     | `InheritedWidget` providing theme to descendants    |
| `WiredThemeData` | Border, text, fill colors + stroke width, roughness |

## API Patterns

All Skribble widgets follow familiar Flutter conventions:

- **`Wired*` prefix** mirrors the Flutter widget it replaces
- **Same constructor params**: `child`, `onPressed`, `onChanged`, `value`, `selectedIndex`
- **`HookWidget` only** — no `StatefulWidget` or `StatelessWidget`
- **`WiredTheme.of(context)`** for runtime color customization
- **`RepaintBoundary`** wraps every widget for render isolation

## Stats

| Metric              | Value                   |
| ------------------- | ----------------------- |
| Widget source files | 81                      |
| Widget test files   | 88                      |
| Widget tests        | 872                     |
| Rough engine tests  | 144                     |
| Smoke tests         | 6                       |
| Library total       | 1,022                   |
| Storybook tests     | 64 (56 page + 8 golden) |
| **Grand total**     | **1,086**               |
| `dart analyze`      | 0 issues                |
| `pumpApp` adoption  | 100% (82/82 files)      |

## Rough Icon Generation Pipeline

Generate/refresh rough Material icons:

```bash
# Optional: pre-fetch Deno deps for faster first run
cd packages/skribble
deno cache tool/deno/svg2roughjs_cli.ts

dart run tool/generate_rough_icons.dart \
  --kit flutter-material \
  --rough-output-dir tool/icon_exports/rough-svg \
  --font-output-dir tool/icon_exports/font \
  --font-dart-output lib/src/generated/material_rough_icon_font.g.dart
```

Workspace shortcuts:

```bash
melos run rough-icons
melos run rough-icons-font
melos run rough-icons-baseline
melos run rough-icons-ci-check
```

`rough-icons` and `rough-icons-font` both apply the committed supplemental
manifest (`tool/examples/material_rough_icons.supplemental.manifest.json`) and
enforce unresolved regression gating via
`--unresolved-baseline tool/examples/material_rough_icons.unresolved-baseline.json`
plus `--max-new-unresolved 0` (strict-mode equivalent). Use
`rough-icons-baseline` to refresh that committed `codePoints[]` baseline file
after intentional changes.

`rough-icons-ci-check` runs the same rough icon regression/sync checks enforced
by CI via `./scripts/check_rough_icons_ci.sh all`.

For targeted local debugging, run an individual CI-equivalent check:

- `./scripts/check_rough_icons_ci.sh regression`
- `./scripts/check_rough_icons_ci.sh baseline-sync`
- `./scripts/check_rough_icons_ci.sh generated-sync`

On sync-check failures, the script prints `git diff` output and writes:

- `rough-icons-baseline-sync.diff`
- `rough-icons-generated-sync.diff`

`regression` cleans up `packages/skribble/unresolved-report.json` after a
successful local run. Set `ROUGH_ICONS_KEEP_UNRESOLVED_REPORT=1` to keep it.
By default, regression/generated-sync checks use
`--max-new-unresolved 0` (strict-mode equivalent). Set
`ROUGH_ICONS_MAX_NEW_UNRESOLVED=<int>` to relax or tighten that threshold.

Pull-request CI explicitly sets `ROUGH_ICONS_MAX_NEW_UNRESOLVED=0` for those
checks to keep workflow configuration aligned with local defaults.

Pull-request CI also runs the unresolved gate in `--rough-only` mode, uploads a
`rough-icons-unresolved-report` artifact for diagnostics, verifies the
committed baseline file is up to date, checks that generated rough icon
catalog files are committed/synced, and uploads diff artifacts
(`rough-icons-baseline-sync-diff`, `rough-icons-generated-sync-diff`) when
those sync checks fail.

Useful flags:

- `--list-kits` to print available icon-kit providers.
- `--kit svg-manifest --manifest <path>` to rough non-Material icon sets from JSON manifests (unique `identifier`/`codePoint` required; `codePoint` supports int, decimal string, `0x` hex, bare hex, and `U+` hex forms).
- `--rough-only` to skip Dart map generation and emit rough SVGs only.
- `--rough-normalize-viewbox 128` to upscale SVG geometry before roughing.
- `--brand-icons-source <path>` to provide a local `simple-icons` package as fallback for brand identifiers missing in Material SVG packages.
- `--supplemental-manifest <path>` to provide custom SVGs for unresolved `flutter-material` identifiers/codepoints (workspace defaults use `tool/examples/material_rough_icons.supplemental.manifest.json`).
- `--unresolved-output <path>` to emit unresolved icon codepoints/identifiers as JSON for follow-up manifest authoring (includes `unresolved[]` plus `unresolvedCodePoints[]`, baseline-diff summary arrays when enabled, gate mode metadata, threshold metadata fields when unresolved gating thresholds are configured, a `wouldFail` summary boolean, per-gate failure booleans, an `activeGates[]` configured-gates summary list, and a `failedGates[]` summary list).
- `--unresolved-baseline-output <path>` to emit a normalized unresolved baseline for regression gating (defaults to `unresolved[]`).
- `--unresolved-baseline-output-format <unresolved|codepoints>` to choose unresolved baseline output shape (`unresolved[]` or `codePoints[]`; workspace defaults use `codepoints`).
- `--supplemental-manifest-output <path>` to emit a starter supplemental manifest template for unresolved icons.
- `--unresolved-baseline <path>` to compare unresolved output against a baseline report (`unresolved[]`), manifest (`icons[]`), or minimal baseline (`codePoints[]`, also accepts `codepoints[]`), including `newUnresolved` and `resolvedSinceBaseline` report fields. String code points accept decimal, `0x` hex, bare hex, and `U+` hex forms.
- `--max-unresolved <int>` to allow a bounded unresolved count before failing.
- `--fail-on-unresolved` to make the command exit non-zero if unresolved icons remain (cannot be combined with `--max-unresolved`).
- `--max-new-unresolved <int>` to allow a bounded number of newly unresolved entries versus baseline before failing (requires `--unresolved-baseline`).
- `--fail-on-new-unresolved` to fail only when unresolved entries regress versus baseline (cannot be combined with `--max-new-unresolved`).
- `--font-name skribble_rough_icons` to customize generated font family name.
- `--font-dart-output <path>` to emit Dart lookup helpers for generated font codepoints.
- `CHROME_PATH=/path/to/chrome` if Chromium/Chrome is not in a standard location.

Runtime helpers exposed by `wired_icon.dart`:

- `lookupMaterialRoughIconByIdentifier('search')` → `WiredSvgIconData?`
- `lookupMaterialRoughFontIcon('search')` → `IconData?` for generated font usage
- `materialRoughIconIdentifiers` / `materialRoughFontCodePoints` (includes legacy alias identifiers that share codepoints)
- `materialRoughFontFamily`

## Contributing

See [CONTRIBUTING.md](../../CONTRIBUTING.md) for development setup, widget
conventions, testing requirements, and quality gates.

## Docs

- [Parity Matrix](docs/ui-snapshots/parity-matrix.md) — coverage vs Flutter defaults
- [Screenshot Manifest](docs/ui-snapshots/screenshot-manifest.txt) — all visual snapshots
- [Rough Icon Pipeline](../../docs/rough-icon-pipeline.md) — icon generation and font tooling
- [CHANGELOG](CHANGELOG.md) — release history

## License

MIT — see [LICENSE](../../LICENSE) for details.
