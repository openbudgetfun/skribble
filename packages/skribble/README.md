# skribble

[![CI](https://github.com/openbudgetfun/skribble/actions/workflows/ci.yml/badge.svg)](https://github.com/openbudgetfun/skribble/actions/workflows/ci.yml) [![License](https://img.shields.io/github/license/openbudgetfun/skribble)](LICENSE) [![Flutter](https://img.shields.io/badge/Flutter-%E2%89%A53.47-blue?logo=flutter)](https://flutter.dev)

Hand-drawn UI components for Flutter. Every widget looks like it was sketched by hand, with APIs that feel familiar if you know Material and Cupertino.

**[Live demo](https://openbudgetfun.github.io/skribble/storybook/)** · **[Docs](https://openbudgetfun.github.io/skribble/)** · **[Quick Start](https://openbudgetfun.github.io/skribble/getting-started/quick-start)** · **[Pub](https://pub.dev/packages/skribble)**

## Getting Started

<!-- {=docsRequirements} -->

skribble needs Flutter 3.47.0 or later (Dart 3.13.0 or later). Run `flutter --version` to check yours.

<!-- {/docsRequirements} -->

<!-- {=docsQuickInstallSection|replace:"// Static example: setup\n":""} -->

```bash
flutter pub add skribble skribble_font_noto_sketch
```

`skribble` draws the widgets; `skribble_font_noto_sketch` adds the default hand-drawn lettering. Without the font package, borders still look sketchy but text falls back to the system font. Then import the library:

```dart
import 'package:skribble/skribble.dart';
```

<!-- {/docsQuickInstallSection} -->

Wrap your app in `SkribbleApp`. It installs the Wired theme, needs no Material ancestor, and every sketchy widget reads its colors from it:

<!-- {=docsMinimalAppSection|replace:"// Static example: setup\n":""} -->

```dart
import 'package:flutter/widgets.dart';
import 'package:skribble/skribble.dart';

void main() {
  runApp(
    SkribbleApp(
      title: 'My sketchy app',
      // Supplies the Material theme and localizations that some Wired
      // widgets, such as WiredInput, still need while they wrap Material.
      builder: (context, child) => WiredMaterialTheme(child: child!),
      home: WiredScaffold(
        appBar: WiredAppBar(title: Text('My sketchy app')),
        body: Center(
          child: WiredButton(
            onPressed: () {},
            child: Text('Press me'),
          ),
        ),
      ),
    ),
  );
}
```

<!-- {/docsMinimalAppSection} -->

Customize the look with a `WiredThemeData`:

```dart
SkribbleApp(
  wiredTheme: WiredThemeData(
    borderColor: WiredPalette.ink, // sketchy border color (plum ink)
    fillColor: WiredPalette.paper, // warm paper background
    strokeWidth: 2.4,
    roughnessLevel: WiredRoughness.gentle,
  ),
  builder: (context, child) => WiredMaterialTheme(child: child!),
  home: const MyHomePage(),
);
```

Already have a `MaterialApp` you're not ready to replace? Keep it and use `WiredMaterialApp`, the transitional bridge that wraps `MaterialApp` and syncs the Wired palette into `ThemeData`:

```dart
WiredMaterialApp(
  wiredTheme: WiredThemeData(),
  home: const MyHomePage(),
);
```

Router-based apps are supported too, on both shells:

```dart
SkribbleApp.router(
  wiredTheme: WiredThemeData(),
  routerConfig: appRouter,
);
```

### Typefaces

<!-- {=docsTypefaceTable} -->

| Typeface                                  | Package                     | Select with                                                  | Follows the roughness level |
| ----------------------------------------- | --------------------------- | ------------------------------------------------------------ | --------------------------- |
| Skribble Noto Sketch (default)            | `skribble_font_noto_sketch` | nothing: it is the default, or `WiredFont.notoSketch`        | No                          |
| Skribble Noto Soft                        | `skribble_font_noto`        | `WiredThemeData(font: WiredFont.noto)`                       | No                          |
| Skribble Noto Lively                      | `skribble_font_noto_lively` | `WiredThemeData(font: WiredFont.notoLively)`                 | No                          |
| Recursive Casual, Linear, and Mono (code) | `skribble_font_recursive`   | `WiredThemeData(font: WiredFont.casual)`, `.linear`, `.mono` | Yes                         |

Install the package for each typeface you select; every package bundles its own font files, so it works offline. The Skribble Noto packages cover Latin, Greek, and Cyrillic in one Regular face, and Flutter synthesizes bold and italic. Recursive has seven real weights with italics. An explicit `fontFamily` on `WiredThemeData` overrides the choice.

<!-- {/docsTypefaceTable} -->

### Companion packages

<!-- {=docsPackageCatalog} -->

| Package                                                                           | What it adds                                                                                 |
| --------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------- |
| [`skribble`](https://pub.dev/packages/skribble)                                   | The Wired widgets, `SkribbleApp`, the theme, and the Flutter painting layer. Start here.     |
| [`skribble_font_noto_sketch`](https://pub.dev/packages/skribble_font_noto_sketch) | Skribble Noto Sketch, the default hand-drawn lettering                                       |
| [`skribble_font_noto`](https://pub.dev/packages/skribble_font_noto)               | Skribble Noto Soft, the calmest Noto level                                                   |
| [`skribble_font_noto_lively`](https://pub.dev/packages/skribble_font_noto_lively) | Skribble Noto Lively, the most playful Noto level                                            |
| [`skribble_font_recursive`](https://pub.dev/packages/skribble_font_recursive)     | Roughened Recursive Casual, Linear, and Mono, which follow the roughness level               |
| [`skribble_icons`](https://pub.dev/packages/skribble_icons)                       | Every icon set behind one import, with a unified lookup                                      |
| [`skribble_icons_material`](https://pub.dev/packages/skribble_icons_material)     | Flutter's Material icons as hand-drawable geometry                                           |
| [`skribble_icons_lucide`](https://pub.dev/packages/skribble_icons_lucide)         | Lucide outline icons                                                                         |
| [`skribble_icons_bxs`](https://pub.dev/packages/skribble_icons_bxs)               | Boxicons Solid icons                                                                         |
| [`skribble_icons_simple`](https://pub.dev/packages/skribble_icons_simple)         | Simple Icons brand marks                                                                     |
| [`skribble_icons_cib`](https://pub.dev/packages/skribble_icons_cib)               | CoreUI Brands marks                                                                          |
| [`skribble_emoji`](https://pub.dev/packages/skribble_emoji)                       | skribble's own hand-drawn emoji for every Unicode emoji                                      |
| [`skribble_maps`](https://pub.dev/packages/skribble_maps)                         | MapLibre maps with hand-drawn pins, routes, areas, and controls                              |
| [`skribble_charts`](https://pub.dev/packages/skribble_charts)                     | Exact OHLC data, hand-drawn financial charts, indicators, and drawing tools                  |
| [`skribble_rough`](https://pub.dev/packages/skribble_rough)                       | The pure-Dart rough engine, with SVG path output and no Flutter dependency                   |
| [`skribble_jaspr`](https://pub.dev/packages/skribble_jaspr)                       | Server-rendered hand-drawn components for Jaspr sites                                        |
| [`skribble_font_roughen`](https://pub.dev/packages/skribble_font_roughen)         | A command-line tool that roughens your own fonts                                             |
| [`skribble_emoji_gen`](https://pub.dev/packages/skribble_emoji_gen)               | The generator that compiles emoji, glyph art, and icon sets into Dart catalogs (maintainers) |
| [`skribble_lints`](https://pub.dev/packages/skribble_lints)                       | Shared lint rules, extending `very_good_analysis`                                            |

<!-- {/docsPackageCatalog} -->

## Widget Catalog

### Buttons

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

### Inputs

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

### Navigation

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

### Selection

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

### Feedback

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
| `WiredAnimatedIcon`                          | Animated icon with skribble styling                           |
| `WiredMaterialBanner`                        | Persistent banner with sketchy borders                        |
| `WiredCupertinoAlertDialog`                  | Cupertino alert with `WiredCupertinoDialogAction`             |
| `WiredCupertinoActionSheet`                  | Cupertino action sheet with `WiredCupertinoActionSheetAction` |

### Layout

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
| `WiredScaffold`                                       | Page shell with a paper-like background            |
| `WiredReorderableListView`                            | Reorderable list with sketchy items                |
| `WiredDismissible`                                    | Swipe-to-dismiss with sketchy background           |
| `WiredSelectableText`                                 | Selectable text with skribble styling              |
| `WiredDrawerHeader` / `WiredUserAccountsDrawerHeader` | Drawer headers                                     |
| `WiredAvatar`                                         | Hand-drawn circle avatar                           |
| `WiredPageScaffold` / `WiredTabScaffold`              | Cupertino scaffold layouts                         |

### Make it vivid

skribble ships bright colourways and lively motion, and looks best when you use them. These rules are written so you can paste them into a coding agent's instructions too; [Vivid and alive](https://openbudgetfun.github.io/skribble/guides/vivid-design) has live examples.

<!-- {=docsVividDesignRules} -->

skribble is a sticker book, not a pencil sketch on grey paper. Whether you are a person or an agent, build with colour and motion by default, and tone it down only when the brief asks for calm.

**Colour**

- Start from a colourway: `WiredThemeData.colorway(WiredColorway.sunny)` (the default), `berry`, `ocean`, or `citrus`, and pass the same colourway with `brightness: Brightness.dark` as the dark theme. Use `WiredColorway.quiet` only when the brief asks for a calm, muted look.
- Give each screen one loud action: `WiredFilledButton` fills with the theme's `accentColor`. Secondary actions use `WiredOutlinedButton` or `WiredTextButton`.
- Colour-code content. Cards, chips, tags, and chart series take `theme.accentAt(index)`, as in `WiredCard(color: theme.accentAt(i), ...)`. Five cards should be five colours, not five beige boxes.
- Mark the words that matter with `WiredHighlight`, and fill empty space with a `WiredDoodle` (sun, sparkle, rainbow, confetti) in an accent colour.
- Keep plum ink on paper for running text, and put the colour in fills, washes, highlights, and doodles. Labels on a wash use `theme.onColor(wash)`, or `theme.inkOn(wash)` for a whole subtree, which keeps 4.5:1 contrast in light and dark themes.
- Don't reach for greys, beiges, or washed-out pastels to look tasteful, and don't hardcode hex colours: use the theme and `WiredPalette`.

**Motion**

- Bring screens in. `WiredCascade` springs a column of cards in one after another, `WiredEntrance.staggered(index: i, ...)` does the same for lazily built list items, and `WiredEntrance` brings in a single hero. Their ink draws itself on as they land.
- Let a few focal drawings boil with `WiredBoil`: a logo, an empty-state doodle, a celebration. Wrap a handful of elements, never a whole screen.
- Time your own animations with `WiredCurves.springy`, `snappy`, or `bouncy`, and anything that draws with `WiredCurves.pen`: `AnimatedContainer(curve: WiredCurves.springy, ...)`.
- Give the one or two most important buttons `inkInteraction: WiredInkInteraction.redraw`.
- Motion is decoration, so never hide content behind it. skribble settles everything when motion is off or the platform asks for reduced motion; check `WiredMotion.enabledOf(context)` in animations of your own.

**On the web**, `skribble_jaspr`'s stylesheet uses the same sunny colours. Colour-code boxes with the `skribble-wash-1` to `skribble-wash-6` classes, stagger entrances with `skribble-pop` and an inline `--i`, draw ink on with `skribble-draw`, and lift cards on hover with `skribble-lift`.

<!-- {/docsVividDesignRules} -->

<!-- {=docsVividThemeExample} -->

```dart
// Static example: setup
SkribbleApp(
  wiredTheme: WiredThemeData.colorway(WiredColorway.berry),
  darkWiredTheme: WiredThemeData.colorway(
    WiredColorway.berry,
    brightness: Brightness.dark,
  ),
  home: const Garden(),
)

class Garden extends StatelessWidget {
  const Garden({super.key});

  static const plants = ['Fern', 'Cactus', 'Basil', 'Monstera'];

  @override
  Widget build(BuildContext context) {
    final theme = WiredTheme.of(context);
    return WiredScaffold(
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          WiredEntrance(
            child: Text.rich(
              TextSpan(
                children: [
                  const TextSpan(text: 'Your garden is '),
                  WidgetSpan(child: WiredHighlight(child: Text('thriving'))),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          WiredCascade(
            spacing: 12,
            children: [
              for (final (i, plant) in plants.indexed)
                WiredCard(
                  height: null,
                  color: theme.accentAt(i),
                  child: Text(plant),
                ),
            ],
          ),
          const SizedBox(height: 16),
          WiredFilledButton(
            inkInteraction: WiredInkInteraction.redraw,
            onPressed: () {},
            child: const Text('Water everything'),
          ),
        ],
      ),
    );
  }
}
```

<!-- {/docsVividThemeExample} -->

### Theming

| Widget                           | Description                                          |
| -------------------------------- | ---------------------------------------------------- |
| `WiredTheme`                     | Scope that provides the theme to descendants         |
| `WiredThemeData`                 | Border, text, fill colors + stroke width, roughness  |
| `WiredThemeData.colorway`        | Sunny, berry, ocean, citrus, or quiet colours        |
| `WiredColorway` / `WiredPalette` | Named colourways and every palette colour            |
| `WiredThemeData.toThemeData()`   | Material `ThemeData` bridge for app-level theming    |
| `WiredMaterialApp`               | Material app wrapper that syncs `WiredTheme` + theme |
| `WiredMaterialApp.router`        | Router-based app wrapper with the same theme syncing |
| High-contrast wired themes       | Optional high-contrast light/dark app theme variants |

## API Patterns

All skribble widgets follow familiar Flutter conventions:

- **`Wired*` prefix** mirrors the Flutter widget it replaces
- **Same constructor params**: `child`, `onPressed`, `onChanged`, `value`, `selectedIndex`
- **Hooks for UI state**: interactive widgets are `HookWidget`s; the motion layer uses standard Flutter `State` and tickers
- **`WiredTheme.of(context)`** for runtime color customization
- **`RepaintBoundary`** isolates each widget's rough painting

### Choose the amount of hand-drawn ink

Set `WiredThemeData(roughnessLevel: WiredRoughness.gentle)` on your `SkribbleApp`. The `gentle`, `playful`, and `expressive` presets coordinate borders, rough icons, pens, and the Recursive lettering; Skribble Noto lettering stays the same at every level. Playful is the default. Nested `WiredTheme` scopes can select another level while retaining the parent palette through `copyWith`; explicit fonts and drawing configurations remain overrides. See the [theming guide](https://openbudgetfun.github.io/skribble/getting-started/theming) for custom font generation and inheritance details.

### Brand icons

Use `WiredSvgIcon(data: WiredBrandIcon.github.data)` for a curated Simple Icons brand mark. GitHub, Dart, Flutter, and Figma support solid and hatched ink through the same vector renderer as Material icons. Add `skribble_icons` for the full Material, Lucide, Boxicons, and brand catalogs. [See the examples](https://openbudgetfun.github.io/skribble/widgets/icons).

## Quality

- `dart analyze --fatal-infos .` passes with zero issues.
- Widget, rough-engine, tool, and storybook suites are validated in CI.
- Screenshot artifacts are tracked in the repository's [screenshot manifest](https://github.com/openbudgetfun/skribble/blob/main/docs/ui-snapshots/screenshot-manifest.txt).

## Contributing

See [CONTRIBUTING.md](https://github.com/openbudgetfun/skribble/blob/main/CONTRIBUTING.md) for development setup, widget conventions, testing requirements, and quality gates. The rough Material icon pipeline (`melos run rough-icons`, `rough-icons-font`, `rough-icons-baseline`, and `rough-icons-ci-check`) is documented in [the rough icon pipeline guide](https://github.com/openbudgetfun/skribble/blob/main/docs/rough-icon-pipeline.md).

## Docs

- [Documentation site](https://openbudgetfun.github.io/skribble/) — guides, the widget catalog, and live examples
- [Parity Matrix](https://github.com/openbudgetfun/skribble/blob/main/docs/ui-snapshots/parity-matrix.md) — coverage vs Flutter defaults
- [Rough Icon Pipeline](https://github.com/openbudgetfun/skribble/blob/main/docs/rough-icon-pipeline.md) — icon generation and font tooling
- [CHANGELOG](CHANGELOG.md) — release history

## License

MIT — see [LICENSE](LICENSE) for details.
