---
title: Agents
description: Comprehensive guide for AI agents working with the skribble design system — conventions, patterns, workflows, and rules.
---

This document is the authoritative reference for AI coding agents (Claude, Copilot, Cursor, etc.) working in the skribble codebase. It covers every convention, pattern, constraint, and workflow an agent must follow to produce correct, mergeable contributions.

## Golden rules

1. **UI components use `HookWidget`.** Use `HookConsumerWidget` when Riverpod is needed. The motion layer uses standard Flutter state, ticker providers, and inherited scopes; see [Ink motion](../core/motion) when changing animation ownership or policy.
2. **Every widget name starts with `Wired`.** `WiredButton`, `WiredAppBar`, `WiredDatePicker` — no exceptions.
3. **Every widget reads theme from `WiredTheme.of(context)`.** Never hardcode colors, stroke widths, or roughness values.
4. **Every widget wraps its output with `RepaintBoundary`.** Use `buildWiredElement(child: ...)` or extend `WiredBaseWidget`.
5. **Every widget has 6+ tests, written against Skribble's public API.** Cover rendering, dimensions, interaction, state, edge cases, semantics, RTL, and text scaling. Never assert on the Material/Cupertino control the implementation currently wraps — see [Durable widget tests](#durable-widget-tests).
6. **Documentation must be updated when APIs change or features are added.** This includes the docs site content, dartdoc comments, and MDT template blocks.
7. **No new Material or Cupertino imports in library code.** `packages/skribble/lib` may import `package:flutter/widgets.dart` and below, never `package:flutter/material.dart` or `package:flutter/cupertino.dart`. Read [Architecture](/core/architecture) before touching a file that currently imports either; the audit is a migration tracker, not a precedent.

## Project structure

```
skribble/
├── packages/skribble/              # Main UI component library
│   ├── lib/
│   │   ├── skribble.dart           # Public barrel export (add new widgets here)
│   │   └── src/
│   │       ├── canvas/             # WiredCanvas, WiredPainter, WiredPainterBase
│   │       ├── rough/              # dart:ui painting layer over package:skribble_rough
│   │       ├── compat/             # Transitional Material/Cupertino interop (see below)
│   │       ├── generated/          # Generated icon font + map files
│   │       ├── wired_*.dart        # Widget implementations
│   │       ├── skribble_app.dart   # SkribbleApp widgets-based shell
│   │       ├── skribble_localizations.dart  # Widgets-only localization delegate
│   │       ├── wired_theme.dart    # WiredThemeData + WiredTheme inherited scope
│   │       ├── wired_base.dart     # Re-exports the three base libraries below
│   │       ├── wired_paint.dart    # WiredBase paint factories + constants
│   │       ├── wired_element.dart  # RepaintBoundary helpers
│   │       └── wired_painter_bases.dart  # Concrete rough painters
│   ├── test/
│   │   ├── rough/                  # Rough engine unit tests
│   │   ├── widgets/                # Widget tests (one file per widget)
│   │   ├── tool/                   # Guards, e.g. no Material test coupling
│   │   └── helpers/                # pumpWired host, finders, semantics, rendering
│   └── tool/                       # Icon generation CLI
├── packages/skribble_rough/        # Pure-Dart rough engine + SVG output (no Flutter)
├── packages/skribble_jaspr/        # Server-rendered Jaspr components (rough SVG + CSS)
├── js/                             # npm packages (pnpm workspace): @skribble.dev/rough + framework bindings
├── rust/                           # Cargo workspace: skribble_rough (Rust engine) + skribble_leptoskit
├── packages/skribble_lints/        # Shared lint rules (very_good_analysis based)
├── packages/skribble_*/            # Fonts, icon sets, emoji, maps, and charts (see CONTRIBUTING.md)
├── apps/skribble_storybook/        # Interactive demo app
│   ├── lib/pages/                  # Storybook category pages
│   └── integration_test/           # Screenshot capture tests
├── apps/skribble_site/             # skribble.dev landing page (Jaspr, static HTML)
└── docs/site/                      # This documentation site (Flutter)
```

## Creating a new widget — step by step

This is the most common task an agent will perform. Follow every step exactly.

### Step 1: Create the widget file

Create `packages/skribble/lib/src/wired_<name>.dart`:

<!-- {=docsAgentWidgetTemplate} -->

Use this template for ordinary UI components. For motion lifecycle wrappers, use standard Flutter state and ticker providers as described in the ink motion guide. Borrowed `Animation<double>` values remain owned by the consumer.

```dart
// Static example: pseudocode
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'rough/skribble_rough.dart';
import 'wired_base.dart';
import 'wired_theme.dart';

/// A hand-drawn <description> widget.
///
/// Reads colors from the nearest [WiredTheme] ancestor, falling back
/// to default constants when no theme is provided.
class Wired<Name> extends HookWidget {
  /// The widget content.
  final Widget child;

  /// Called when the widget is tapped.
  final VoidCallback? onPressed;

  /// Semantic label for accessibility.
  final String? semanticLabel;

  const Wired<Name>({
    super.key,
    required this.child,
    this.onPressed,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = WiredTheme.of(context);

    return Semantics(
      label: semanticLabel,
      child: buildWiredElement(
        child: Container(
          decoration: RoughBoxDecoration(
            shape: RoughBoxShape.rectangle,
            borderStyle: RoughDrawingStyle(
              width: theme.strokeWidth,
              color: theme.borderColor,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
```

<!-- {/docsAgentWidgetTemplate} -->

### Step 2: Export from the barrel file

Add one line to `packages/skribble/lib/skribble.dart`:

```dart
// Static example: api
export 'src/wired_<name>.dart';
```

Keep the exports in alphabetical order.

### Step 3: Write tests

Create `packages/skribble/test/widgets/wired_<name>_test.dart`:

<!-- {=docsAgentTestTemplate} -->

```dart
// Static example: test
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';

import '../helpers/skribble_test_support.dart';

void main() {
  group('Wired<Name>', () {
    testWidgets('renders and paints', (tester) async {
      await pumpWired(
        tester,
        Wired<Name>(child: const Text('Test'), onPressed: () {}),
      );
      expectRenders(tester, findWired<Wired<Name>>());
      expectPaints(findWired<Wired<Name>>());
    });

    testWidgets('renders child content', (tester) async {
      await pumpWired(
        tester,
        Wired<Name>(child: const Text('Hello'), onPressed: () {}),
      );
      expect(find.text('Hello'), findsOneWidget);
    });

    testWidgets('calls onPressed when tapped', (tester) async {
      var tapped = false;
      await pumpWired(
        tester,
        Wired<Name>(child: const Text('Tap'), onPressed: () => tapped = true),
      );
      await tapWired(tester, findWired<Wired<Name>>());
      expect(tapped, isTrue);
    });

    testWidgets('exposes a labelled button role', (tester) async {
      await pumpWired(
        tester,
        Wired<Name>(
          child: const Text('Label'),
          onPressed: () {},
          semanticLabel: 'My widget',
        ),
      );
      expectSemantics(
        tester,
        findWired<Wired<Name>>(),
        label: 'My widget',
        isButton: true,
        isEnabled: true,
      );
    });

    testWidgets('disabled widget ignores taps', (tester) async {
      await pumpWired(tester, const Wired<Name>(child: Text('Off')));
      await tapWired(tester, findWired<Wired<Name>>());
      expectSemantics(
        tester,
        findWired<Wired<Name>>(),
        isButton: true,
        isEnabled: false,
      );
    });

    testWidgets('lays out and paints in RTL', (tester) async {
      await pumpWiredRtl(
        tester,
        Wired<Name>(child: const Text('RTL'), onPressed: () {}),
      );
      expectRenders(tester, findWired<Wired<Name>>());
      expectPaints(findWired<Wired<Name>>());
    });

    testWidgets('scales text without clipping', (tester) async {
      await pumpWiredScaled(
        tester,
        Wired<Name>(child: const Text('Scaled'), onPressed: () {}),
      );
      expectRenders(tester, findWired<Wired<Name>>());
      expect(tester.takeException(), isNull);
    });
  });
}
```

<!-- {/docsAgentTestTemplate} -->

### Step 4: Add to the storybook

Add a showcase entry in the appropriate page under `apps/skribble_storybook/lib/pages/`. For example, if it's a button, add to `buttons_page.dart`.

### Step 5: Add dartdoc comment

Every public class and constructor parameter must have a `///` doc comment. The class comment should:

- Start with "A hand-drawn ..." or "A sketchy ..."
- Reference `WiredTheme` if the widget reads theme
- List related widgets with `[WiredOtherWidget]` links

### Step 6: Run quality gates

<!-- {=docsContribQualityGatesSection} -->

```bash
# Every lint check CI runs: dprint formatting, dart analyze with fatal infos
# (an undocumented public member fails it),
# MDT documentation sync, and monochange changeset and manifest rules
lint:all

# Zero Dart format drift
dart format --set-exit-if-changed -o none .

# Every Flutter and pure-Dart test suite
test:all
```

While iterating on one package, `dart analyze --fatal-infos .` and `flutter test --concurrency=2` from its directory are quicker. Changes under `js/` also need `pnpm install && pnpm run check`, and changes under `rust/` need the `cargo fmt`, `cargo clippy`, and `cargo test` commands from the commands list.

<!-- {/docsContribQualityGatesSection} -->

The icon and emoji packages exclude `lib/src/generated/**` from analysis: their catalogs are megabytes of machine-written Dart whose coverage comes from CI regenerating and diffing them (`icon-catalogs-sync`, `visual-assets-sync`) and from the test suites that compile them. Hand-written changes in those packages are still analyzed; changes to a generated catalog belong in the generator, not the file.

In a Claude Code cloud session, `.claude/hooks/session-start.sh` prepares these gates before the session starts: it installs the Flutter SDK pinned in `.fvmrc` at `.fvm/flutter_sdk` (the path melos and CI use), puts it on `PATH`, and runs `dart pub get` for the workspace. It skips devenv and Nix, so devenv-only tools such as `mdt`, `monochange`, `dprint` and `shfmt` are not installed there. The hook does nothing outside cloud sessions, and a warm container reuses the downloaded SDK.

### Step 7: Update documentation

When adding a new widget, update the docs site:

1. Add the widget to the appropriate `docs/site/content/widgets/<category>.md` page
2. If adding a new widget category, create a new page in `docs/site/content/widgets/`; the sidebar discovers it automatically, and an `order:` frontmatter key positions it within its group
3. Update any MDT template blocks if the widget introduces a reusable pattern (see [Shared documentation with MDT](#shared-documentation-with-mdt))
4. Run `mdt update` if MDT blocks were modified

## Widget implementation patterns

### Breathing room

<!-- {=docsInkPaddingRule} -->

Give the ink room to breathe. Content keeps at least `kWiredInkPadding` (8 pixels above and below, 12 at the sides) from any hand-drawn line around it; buttons and chips use `kWiredButtonPadding` (16 at the sides). Heights are minimums (`BoxConstraints(minHeight: kWiredButtonHeight)`), never fixed, so controls grow with larger fonts and text scaling instead of squeezing their text against the ink. `package:skribble/testing.dart` (`crampedText`, `squeezedText`) checks this; `crampedText(root, lines: true, icons: true)` also catches a hand-drawn line crossing text and an icon crowding its circle. The storybook and example app run all three checks on every page at 360, 768, and 1280 pixels and at 1.3× text, and the docs site runs them on every example at 340 and 720 pixels.

<!-- {/docsInkPaddingRule} -->

### Reading theme values

Every widget must read colors and config from the theme — never hardcode. The defaults are listed in [WiredThemeData defaults](#wiredthemedata-defaults-reference):

<!-- {=docsThemeReadPattern} -->

```dart
// Static example: custom-class
@override
Widget build(BuildContext context) {
  final theme = WiredTheme.of(context);

  // Use theme values for all visual properties
  final borderColor = theme.borderColor;
  final fillColor = theme.fillColor;
  final textColor = theme.textColor;
  final strokeWidth = theme.strokeWidth;
  final roughness = theme.roughness;
  final drawConfig = theme.drawConfig;
  final inkExtent = theme.inkExtent;
  // ...
}
```

<!-- {/docsThemeReadPattern} -->

### Using RoughBoxDecoration

Replace standard `BoxDecoration` with `RoughBoxDecoration` for hand-drawn borders:

```dart
// Static example: custom-class
Container(
  decoration: RoughBoxDecoration(
    shape: RoughBoxShape.rectangle,   // or roundedRectangle, circle, ellipse
    borderStyle: RoughDrawingStyle(
      width: theme.strokeWidth,
      color: theme.borderColor,
    ),
    color: theme.fillColor,  // level fill, inset to the pen's centre line
    borderRadius: BorderRadius.circular(8),  // only for roundedRectangle
    seed: 7,  // fixed per surface so the wobble never re-rolls
  ),
  child: child,
)
```

Use `fillStyle` with a `filler` for a sketched (hachure, zigzag, dots) fill, and `color` for a flat field under text. Decorations compare by value and interpolate, so keep `drawConfig` a shared instance and they stay cheap to rebuild and work inside `AnimatedContainer`. `Container(clipBehavior: ...)` clips at the pen's centre line.

Available `RoughBoxShape` values:

- `rectangle` — sharp-corner rectangle
- `roundedRectangle` — rounded corners (requires `borderRadius`)
- `circle` — perfect circle
- `ellipse` — oval shape

### RepaintBoundary isolation

Always wrap the widget output with `RepaintBoundary` to isolate repaints:

```dart
// Static example: custom-class
// Option 1: use the global helper function
return buildWiredElement(child: myContent);

// Option 2: extend WiredBaseWidget (override buildWiredElement())
class WiredFoo extends WiredBaseWidget {
  @override
  Widget buildWiredElement() => myContent;
}

// Option 3: use the mixin
class WiredFoo extends HookWidget with WiredRepaintMixin {
  @override
  Widget build(BuildContext context) {
    return buildWiredElement(child: myContent);
  }
}
```

### Using hooks for state

Use `flutter_hooks` for all state management:

```dart
// Static example: custom-class
class WiredCounter extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final count = useState(0);
    final controller = useAnimationController(duration: Duration(milliseconds: 300));
    final memoizedValue = useMemoized(() => expensiveComputation());

    return buildWiredElement(
      child: GestureDetector(
        onTap: () => count.value++,
        child: Text('${count.value}'),
      ),
    );
  }
}
```

Common hooks:

- `useState<T>(initialValue)` — reactive local state
- `useAnimationController(duration:)` — auto-disposed animation controller
- `useAnimation(controller)` — reactive animation value
- `useMemoized(() => value)` — cached computation
- `useEffect(() { ... return dispose; }, [deps])` — side effects
- `useTextEditingController()` — auto-disposed text controller
- `useFocusNode()` — auto-disposed focus node

### Custom painter pattern

For widgets that need custom drawing beyond `RoughBoxDecoration`:

```dart
// Static example: custom-class
class MyShapePainter extends WiredPainterBase {
  final Color borderColor;
  final double strokeWidth;

  MyShapePainter({
    required this.borderColor,
    required this.strokeWidth,
  });

  @override
  void paintRough(
    Canvas canvas,
    Size size,
    DrawConfig drawConfig,
    Filler filler,
  ) {
    final generator = Generator(drawConfig, filler);
    final shape = generator.rectangle(0, 0, size.width, size.height);
    canvas.drawRough(
      shape,
      WiredBase.pathPainter(strokeWidth, color: borderColor),
      WiredBase.fillPainter(borderColor),
    );
  }
}

// Use with WiredCanvas:
WiredCanvas(
  painter: MyShapePainter(
    borderColor: theme.borderColor,
    strokeWidth: theme.strokeWidth,
  ),
  fillerType: RoughFilter.hachureFiller,
)
```

### Fill patterns

The `RoughFilter` enum controls fill patterns:

| Filter          | Effect                        |
| --------------- | ----------------------------- |
| `noFiller`      | Stroke only, no interior fill |
| `hachureFiller` | Diagonal parallel lines       |
| `zigZagFiller`  | Zigzag pattern                |
| `hatchFiller`   | Cross-hatched grid            |
| `dotFiller`     | Scattered dots                |
| `dashedFiller`  | Dashed lines                  |
| `solidFiller`   | Solid color fill              |

### Accessibility

Every interactive widget must include accessibility support:

```dart
// Static example: custom-class
Semantics(
  label: semanticLabel,
  button: true,        // for buttons
  toggled: isSelected, // for toggles
  enabled: enabled,    // for interactive widgets
  child: buildWiredElement(child: ...),
)
```

## Testing patterns

### Test file location

Tests live in `packages/skribble/test/widgets/` and mirror the `lib/src/` structure:

```
lib/src/wired_button.dart    →  test/widgets/wired_button_test.dart
lib/src/wired_card.dart      →  test/widgets/wired_card_test.dart
lib/src/wired_checkbox.dart  →  test/widgets/wired_checkbox_test.dart
```

### Test host and helpers

New and converted tests use `pumpWired()` and the helpers in `packages/skribble/test/helpers/`. Import them through the single barrel:

```dart
// Static example: test
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';

import '../helpers/skribble_test_support.dart';
```

`pumpWired` supplies the minimal host a widget needs (theme, directionality, text scale, bounded surface). `pumpWiredRtl` and `pumpWiredScaled` are the same host with RTL or a scaled `TextScaler`, so those dimensions are one named argument away instead of a hand-built tree. `pumpApp()` still exists for files that have not been migrated, but it exposes Material slots new tests should not depend on.

See `packages/skribble/test/helpers/README.md` for the full helper table and the before/after migration pattern.

### Durable widget tests

Skribble's endgame removes Material from `packages/skribble/lib`. A test that asserts `find.byType(Checkbox)` or `tester.widget<TextButton>(...)` encodes the transitional implementation as the contract, breaks on the rewrite, and gives false confidence because it never exercises the Wired widget's own painting, hit area, or semantics.

Rules for every test you write or touch:

- Never name a Material or Cupertino type in a type lookup. The guard test `packages/skribble/test/tool/no_material_test_coupling_test.dart` enforces this with a shrinking allowlist of files that still need migrating; a new violation fails the suite with instructions.
- Assert behaviour: callbacks fired, semantics flags, rendered size, rough paint reached — not which internal widget holds a value.
- Use `findWired<T>()`, `expectSemantics(...)`, `expectRenders(...)`, `expectPaints(...)`, and `tapWired(...)` instead of raw framework lookups.
- Add the dimensions Material currently masks: disabled state, RTL, text scaling, and large/zero/small constraints.
- Do not assert painter classes or pixel output; the screenshot harnesses in `apps/skribble_storybook` cover ink fidelity.

### pumpApp helper (legacy)

`pumpApp()` remains for the files listed in the migration backlog. It wraps the widget in a Material app shell:

<!-- {=docsPumpAppExample} -->

```dart
// Static example: test
// Body slot (default)
await pumpApp(tester, myWidget);

// AppBar slot
await pumpApp(tester, WiredAppBar(title: Text('T')), asAppBar: true);

// BottomNavigationBar slot
await pumpApp(tester, myNavBar, asBottomNav: true);

// Drawer slot
await pumpApp(tester, WiredDrawer(child: Text('X')), asDrawer: true);

// With custom theme
await pumpApp(
  tester,
  myWidget,
  theme: WiredThemeData(borderColor: Colors.red),
);
```

<!-- {/docsPumpAppExample} -->

### Minimum 6 tests per widget

<!-- {=docsTestingRequirements} -->

Every widget test file has at least 6 `testWidgets`, written against skribble's public API, covering:

1. **Rendering**: renders without error, child content appears, rough paint is reached.
2. **Dimensions**: correct default size, custom size respected, sensible non-zero size.
3. **Interaction**: taps and input fire callbacks; a disabled widget ignores them.
4. **State**: rebuilds when values change; animations settle.
5. **Edge cases**: null values, empty strings, rapid interactions, overflow, and large, zero, or small constraints.
6. **Accessibility and direction**: semantic label, role, and state where applicable; RTL layout; scaled text.

Widget tests go in `packages/skribble/test/`, with one `test/widgets/wired_<name>_test.dart` per widget. Integration tests go in `apps/skribble_storybook/integration_test/`. Never assert on the Material or Cupertino control a widget currently wraps; `test/tool/no_material_test_coupling_test.dart` enforces this.

<!-- {/docsTestingRequirements} -->

### Testing value-driven widgets

For widgets like `WiredCheckbox` or `WiredSlider` that have a current value:

```dart
// Static example: test
testWidgets('updates when value changes', (tester) async {
  var currentValue = false;
  await pumpWired(
    tester,
    StatefulBuilder(
      builder: (context, setState) => WiredCheckbox(
        value: currentValue,
        onChanged: (v) => setState(() => currentValue = v!),
      ),
    ),
  );

  await tapWired(tester, findWired<WiredCheckbox>());
  await tester.pumpAndSettle();
  expect(currentValue, isTrue);
  expectSemantics(tester, findWired<WiredCheckbox>(), isChecked: true);
});
```

## Theming rules for agents

### Never hardcode visual values

```dart
// Static example: test
// WRONG — hardcoded colors
Container(color: WiredPalette.ink)

// CORRECT — read from theme
final theme = WiredTheme.of(context);
Container(color: theme.borderColor)
```

### WiredThemeData defaults (reference)

<!-- {=docsWiredThemeDataParameters} -->

| Parameter            | Type                  | Default                                              | Description                                                                                                                                                |
| -------------------- | --------------------- | ---------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `borderColor`        | `Color`               | `WiredPalette.ink`                                   | The color of every hand-drawn border, outline, and stroke. Plum ink by default.                                                                            |
| `textColor`          | `Color`               | `WiredPalette.ink`                                   | Primary text color for labels and button text.                                                                                                             |
| `disabledTextColor`  | `Color`               | `WiredPalette.mutedInk`                              | Text color for disabled widgets. A muted plum by default.                                                                                                  |
| `errorColor`         | `Color`               | `WiredPalette.coral`                                 | Ink for errors: the border of an input with error text and the error text itself.                                                                          |
| `fillColor`          | `Color`               | `WiredPalette.paper`                                 | Background fill for cards, inputs, dialogs, and other surfaces. Warm paper by default.                                                                     |
| `markerColor`        | `Color`               | `WiredPalette.lilac`                                 | The highlighter wash under selected and active things: navigation indicators, progress and slider fills, switch tracks, and selected segments.             |
| `strokeWidth`        | `double`              | `kWiredStrokeWidth` (1.6)                            | Width in logical pixels of the rough-drawn strokes.                                                                                                        |
| `roughnessLevel`     | `WiredRoughness`      | `WiredRoughness.playful`                             | Coordinated border, icon, pen, and Recursive lettering defaults: `gentle`, `playful`, or `expressive`.                                                     |
| `font`               | `WiredFont`           | `WiredFont.notoSketch`                               | The bundled typeface. Install the package that ships it.                                                                                                   |
| `fontFamilyFallback` | `List<String>?`       | `null`                                               | App font families tried after the main family, such as Skribble Noto kit scripts. Used as written, never prefixed with a package.                          |
| `roughness`          | `double?`             | `null`: the level's amplitude (1.1 for playful)      | Geometry amplitude override; `0` removes random displacement.                                                                                              |
| `fontFamily`         | `String?`             | `null`: the `font` family                            | Font override. Bundled families resolve to their font package (`WiredFont.packageFor`); custom families belong to the app.                                 |
| `drawConfig`         | `DrawConfig?`         | `null`: derived from the level                       | A complete drawing override. Otherwise the configuration derives its roughness, offset, and line wobble from the level and the amplitude.                  |
| `pen`                | `RoughPen?`           | `null`: the level's pen (`RoughPen.ink` for playful) | How lines are inked. `RoughPen.uniform` draws constant-width lines.                                                                                        |
| `motionEnabled`      | `bool`                | `true`                                               | Whether decorative ink motion is allowed. The platform's reduced-motion setting still wins.                                                                |
| `inkInteraction`     | `WiredInkInteraction` | `WiredInkInteraction.pressure`                       | Default decorative feedback for buttons: `none`, `pressure` (reinforces strokes on hover, focus, and press), or `redraw` (redraws outlines on each press). |

<!-- {/docsWiredThemeDataParameters} -->

New apps install the theme with `SkribbleApp`; see the [minimal app](/getting-started/quick-start#minimal-app). The `WiredMaterialApp` setup below is for apps that still need `MaterialApp`.

### WiredMaterialApp theme setup

`WiredMaterialApp` is the transitional Material compatibility shell for migrating apps, not skribble's app-level abstraction. See [Architecture](/core/architecture) and the [Material bridge](/core/material-bridge) before building new app-level patterns on it.

```dart
// Static example: setup
WiredMaterialApp(
  wiredTheme: WiredThemeData(
    borderColor: Color(0xFF4A3470),
    textColor: Color(0xFF2A2238),
    fillColor: Color(0xFFFFFCF1),
    roughness: 1.15,
  ),
  darkWiredTheme: WiredThemeData(
    borderColor: Color(0xFFB09BDC),
    textColor: Color(0xFFF0EBF5),
    fillColor: Color(0xFF1E1A26),
    roughness: 1.15,
  ),
  highContrastWiredTheme: WiredThemeData(
    borderColor: Colors.black,
    textColor: Colors.black,
    fillColor: Colors.white,
    strokeWidth: 3,
    roughness: 0.5,
  ),
  highContrastDarkWiredTheme: WiredThemeData(
    borderColor: Colors.white,
    textColor: Colors.white,
    fillColor: Colors.black,
    strokeWidth: 3,
    roughness: 0.5,
  ),
  themeMode: ThemeMode.system,
  home: MyHomePage(),
)
```

Theme resolution follows this fallback chain:

- Light mode: `wiredTheme`
- Dark mode: `darkWiredTheme` -> `wiredTheme`
- High contrast light: `highContrastWiredTheme` -> `wiredTheme`
- High contrast dark: `highContrastDarkWiredTheme` -> `darkWiredTheme` -> `wiredTheme`

### WiredMaterialApp.router setup

For apps using `go_router`, `auto_route`, or any `RouterConfig`, use the `.router` named constructor:

```dart
// Static example: setup
import 'package:go_router/go_router.dart';
import 'package:skribble/skribble.dart';

final router = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (context, state) => HomePage()),
    GoRoute(path: '/settings', builder: (context, state) => SettingsPage()),
  ],
);

WiredMaterialApp.router(
  wiredTheme: WiredThemeData(),
  darkWiredTheme: darkTheme,
  routerConfig: router,
  title: 'My App',
)
```

The `.router` constructor accepts the same theme parameters as the standard constructor but replaces `home`/`routes`/`initialRoute` with `routerConfig`/`routeInformationProvider`/`routerDelegate`/`backButtonDispatcher`.

## Common widget usage patterns for agents

### Form validation

Use `WiredForm` with `WiredInput` for validated forms:

```dart
// Live example: validated-form
HookBuilder(
  builder: (context) {
    final key = useMemoized(GlobalKey<FormState>.new);
    final accepted = useState(false);
    return WiredForm(
      formKey: key,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FormField<String>(
            validator: (value) => value != null && value.contains('@')
                ? null
                : 'Enter an email address.',
            builder: (field) => Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                WiredInput(labelText: 'Email', onChanged: field.didChange),
                if (field.errorText case final String error)
                  Semantics(liveRegion: true, child: Text(error)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          WiredFilledButton(
            onPressed: () => accepted.value = key.currentState!.validate(),
            child: const Text('Check the form'),
          ),
          if (accepted.value)
            const Text('The sample form is valid. Nothing was sent.'),
        ],
      ),
    );
  },
)
```

### Popup menus

```dart
// Live example: popup-menu-button
HookBuilder(
  builder: (context) {
    final selected = useState('Choose an action');
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        WiredPopupMenuButton<String>(
          items: const [
            WiredPopupMenuItem(value: 'Saved', child: Text('Save')),
            WiredPopupMenuItem(value: 'Shared', child: Text('Share')),
          ],
          onSelected: (value) => selected.value = value,
        ),
        Text(selected.value),
      ],
    );
  },
)
```

### Bottom sheets

```dart
// Live example: bottom-sheet
Builder(
  builder: (context) => WiredButton(
    onPressed: () => showWiredBottomSheet<void>(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Make something lovely'),
            WiredTextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Done'),
            ),
          ],
        ),
      ),
    ),
    child: const Text('Open the sheet'),
  ),
)
```

### Context menus

```dart
// Live example: context-menu
WiredContextMenu(
  actions: [
    WiredContextMenuAction(label: 'Save', onPressed: () {}),
    WiredContextMenuAction(label: 'Share', onPressed: () {}),
  ],
  child: Padding(
    padding: const EdgeInsets.all(24),
    child: Text('Make something lovely'),
  ),
)
```

### Steppers

```dart
// Live example: stepper
HookBuilder(
  builder: (context) {
    final current = useState(0);
    return WiredStepper(
      currentStep: current.value,
      onStepTapped: (index) => current.value = index,
      steps: const [
        WiredStep(
          title: Text('Imagine'),
          content: Text('Start with a small idea.'),
        ),
        WiredStep(title: Text('Make'), content: Text('Give it a little ink.')),
        WiredStep(title: Text('Share'), content: Text('Let someone try it.')),
      ],
    );
  },
)
```

### Data tables

```dart
// Live example: data-table
const WiredDataTable(
  columns: [
    WiredDataColumn(label: Text('Sketch')),
    WiredDataColumn(label: Text('Status')),
  ],
  rows: [
    WiredDataRow(cells: [Text('Paper boats'), Text('Ready')]),
    WiredDataRow(cells: [Text('Tiny gardens'), Text('Growing')]),
  ],
)
```

### Cupertino vs Material widget selection

skribble provides both Material and Cupertino variants for common patterns. Use the Cupertino variants when building iOS-native experiences:

| Material                   | Cupertino                        | When to use Cupertino     |
| -------------------------- | -------------------------------- | ------------------------- |
| `WiredButton`              | `WiredCupertinoButton`           | iOS press-opacity effect  |
| `WiredAppBar`              | `WiredCupertinoNavigationBar`    | iOS-style navigation bar  |
| `WiredBottomNavigationBar` | `WiredCupertinoTabBar`           | iOS tab bar look          |
| `WiredSwitch`              | `WiredCupertinoSwitch`           | iOS-style animated toggle |
| `WiredSlider`              | `WiredCupertinoSlider`           | iOS slider feel           |
| `WiredInput`               | `WiredCupertinoTextField`        | iOS rounded text field    |
| `WiredDialog`              | `WiredCupertinoAlertDialog`      | iOS alert style           |
| `WiredDatePicker`          | `WiredCupertinoDatePicker`       | iOS wheel picker          |
| `WiredSegmentedButton`     | `WiredCupertinoSegmentedControl` | iOS segmented control     |
| `WiredScaffold`            | `WiredPageScaffold`              | iOS page scaffold         |

For platform-adaptive apps, check `Theme.of(context).platform` and choose accordingly.

### Selection patterns

When implementing selection UI, choose the right widget:

| Pattern                      | Widget                                        | Use when                                       |
| ---------------------------- | --------------------------------------------- | ---------------------------------------------- |
| Single exclusive choice      | `WiredRadio` / `WiredRadioListTile`           | User picks exactly one option from a small set |
| Multiple independent choices | `WiredCheckbox` / `WiredCheckboxListTile`     | User can toggle multiple options on/off        |
| Tag-like selection           | `WiredChoiceChip` / `WiredFilterChip`         | Compact chip-based selection                   |
| Single exclusive (compact)   | `WiredSegmentedButton`                        | 2-5 mutually exclusive options                 |
| Dropdown single choice       | `WiredCombo`                                  | Long list, pick one                            |
| Color selection              | `WiredColorPicker`                            | Color swatch grid                              |
| Date selection               | `WiredDatePicker` / `WiredCalendarDatePicker` | Date input                                     |
| Time selection               | `WiredTimePicker`                             | Time input                                     |

## Rough engine reference for agents

### Generator shapes

```dart
// Static example: configuration
final generator = Generator(drawConfig, filler);

// Lines
generator.line(x1, y1, x2, y2);

// Rectangles
generator.rectangle(x, y, width, height);
generator.roundedRectangle(x, y, width, height, tl, tr, br, bl);

// Circles and ellipses
generator.circle(cx, cy, diameter);
generator.ellipse(cx, cy, width, height);

// Polygons
generator.polygon([PointD(x1, y1), PointD(x2, y2), ...]);

// Arcs
generator.arc(cx, cy, width, height, startAngle, stopAngle, closed);

// Multi-segment lines
generator.linearPath([PointD(x1, y1), PointD(x2, y2), ...]);
```

### DrawConfig tuning

```dart
// Static example: configuration
DrawConfig.build(
  maxRandomnessOffset: 2,    // Max random offset per point
  roughness: 1,              // 0 = smooth, 1 = standard, 2+ = very rough
  bowing: 1,                 // Arc bowing factor
  curveFitting: 0.95,        // Curve accuracy
  curveTightness: 0,         // Curve tension
  curveStepCount: 9,         // Curve segments
  seed: 42,                  // Fixed seed for deterministic output
)
```

### Rendering to canvas

```dart
// Static example: configuration
final drawable = generator.rectangle(0, 0, 100, 50);
canvas.drawRough(
  drawable,
  WiredBase.pathPainter(2, color: theme.borderColor), // stroke paint
  WiredBase.fillPainter(theme.fillColor),             // fill paint
);
```

## Base painters reference

These are the built-in painters agents should reuse where possible:

| Painter                     | Shape             | Key Parameters                                                         |
| --------------------------- | ----------------- | ---------------------------------------------------------------------- |
| `WiredRectangleBase`        | Rectangle         | `leftIndent`, `rightIndent`, `fillColor`, `borderColor`, `strokeWidth` |
| `WiredCircleBase`           | Circle            | `diameterRatio`, `fillColor`, `borderColor`, `strokeWidth`             |
| `WiredLineBase`             | Line              | `x1`, `y1`, `x2`, `y2`, `borderColor`, `strokeWidth`                   |
| `WiredRoundedRectangleBase` | Rounded rect      | `borderRadius`, `fillColor`, `borderColor`, `strokeWidth`              |
| `WiredInvertedTriangleBase` | Inverted triangle | `borderColor`, `strokeWidth`                                           |

## Constants reference

```dart
// Static example: api
const double kWiredButtonHeight = 42.0; // a minimum: buttons grow with text
const double kWiredChipHeight = 36.0; // a minimum: chips grow with text
const EdgeInsets kWiredInkPadding = EdgeInsets.symmetric(horizontal: 12, vertical: 8);
const EdgeInsets kWiredButtonPadding = EdgeInsets.symmetric(horizontal: 16, vertical: 8);
const Color _defaultBorderColor = WiredPalette.ink;
const Color _defaultFillColor = WiredPalette.paper;
```

## Commands reference

<!-- {=docsCommandsSection} -->

```bash
# Install dependencies
flutter pub get

# Run every lint check: dprint formatting, dart analyze, MDT docs sync, and monochange
lint:all

# Fix everything fixable: MDT docs sync, dprint formatting, then dart fix
fix:all

# Sync the shared MDT documentation blocks, or check that they are in sync
fix:docs
lint:docs

# Run dart analyze across all packages (infos are fatal)
melos run analyze

# Run the Flutter widget tests
melos run flutter-test

# Run every Flutter and pure-Dart test suite, or collect merged coverage
test:all
test:coverage

# Format all Dart code
melos run format

# Capture component screenshots
melos run screenshot

# Serve or build the documentation site
docs:site:serve
docs:site:build

# Build or serve the skribble.dev landing page (Jaspr)
site:build
site:serve

# Generate rough Material icon SVGs, or the icon font (TTF + Dart helpers)
melos run rough-icons
melos run rough-icons-font

# Run the CI rough icon checks, or verify every committed icon catalog
melos run rough-icons-ci-check
melos run icons-check

# Build, typecheck, and test the npm packages in js/
pnpm install && pnpm run check

# Format, lint, and test the Rust crates in rust/
cargo fmt --all && cargo clippy --workspace --all-targets --all-features -- -D warnings && cargo test --workspace --all-features
```

<!-- {/docsCommandsSection} -->

## Commit message conventions

<!-- {=docsCommitConventions} -->

Follow [Conventional Commits](https://www.conventionalcommits.org/):

```
feat: add WiredAvatar widget
fix: correct WiredSlider thumb offset
refactor: migrate WiredChip tests to pumpWired
test: add Generator.arc tests
docs: share the install snippet through mdt
chore: bump pnpm
```

<!-- {/docsCommitConventions} -->

## File naming conventions

| Type           | Location                              | Naming                            |
| -------------- | ------------------------------------- | --------------------------------- |
| Widget         | `packages/skribble/lib/src/`          | `wired_<name>.dart` (snake_case)  |
| Export         | `packages/skribble/lib/skribble.dart` | `export 'src/wired_<name>.dart';` |
| Test           | `packages/skribble/test/widgets/`     | `wired_<name>_test.dart`          |
| Storybook page | `apps/skribble_storybook/lib/pages/`  | `<category>_page.dart`            |
| Docs page      | `docs/site/content/widgets/`          | `<category>.md`                   |

## Brand and casing

<!-- {=docsBrandCasingRules} -->

- The brand word is always lowercase **skribble** — in READMEs, docs site pages and frontmatter, and source comments. Sentence position does not change it: a heading reads `# skribble`, and a page title reads `title: skribble — Hand-Drawn Flutter Design System`.
- Keep machine-readable names as they are: identifiers (`SkribbleIcons`), bundled font families (`Skribble`, `SkribbleGentle`), asset names (`Skribble-Bold.ttf`), the Figma URL slug (`Skribble-Design-System`), and runtime strings such as app titles, page names, and semantic labels.
- The root `README.md` keeps a centered header: the logo (240px, linked to the docs site), `<h1 align="center">skribble</h1>`, a one-line tagline, centered links into the documentation, then the badges. Those links point at `https://openbudgetfun.github.io/skribble/`.

<!-- {/docsBrandCasingRules} -->

More examples of names that stay machine-readable and keep their existing casing:

| Kind                    | Examples                                                        |
| ----------------------- | --------------------------------------------------------------- |
| Dart identifiers        | `SkribbleApp`, `SkribbleStorybookApp`, `SkribbleIcon`           |
| Bundled font families   | `Skribble`, `SkribbleGentle`, `SkribblePlayful`, `SkribbleMono` |
| Asset and release names | `Skribble-Bold.ttf`, `SkribbleRecursive-v1.0.0.zip`             |
| URL slugs               | `Skribble-Design-System` (Figma)                                |
| Runtime strings         | App titles, page names, `WiredLogo.semanticLabel`               |

The font-family column in the theming tables therefore keeps `Skribble` even though the surrounding prose is lowercase: it names a bundled family a consumer passes to Flutter.

## Shared documentation with MDT

<!-- {=docsMdtWorkflow} -->

Text that appears in more than one place, such as the install snippet, the minimal app, the commands list, these contributor rules, and repeated dartdoc, is written once as an [MDT](https://github.com/ifiokjr/mdt) **provider** in `templates/*.t.md` and copied into every **consumer** block. Never edit the text between a consumer's tags: `mdt update` overwrites it.

A provider lives only in a `templates/*.t.md` file:

```markdown
<!-- {@docsExampleSnippet} -->

The shared text, in Markdown.

<!-- {/docsExampleSnippet} -->
```

A consumer can sit in any scanned Markdown file, including READMEs, docs pages, `CONTRIBUTING.md`, and `AGENTS.md`:

```markdown
<!-- {=docsExampleSnippet} -->
<!-- {/docsExampleSnippet} -->
```

In Dart, the tags go inside `///` comments, and a `linePrefix` transformer re-adds the comment prefix, at the member's indentation, to each synced line:

```dart
// Static example: pseudocode
class WiredExample extends HookWidget {
  /// <!-- {=dartSemanticLabel|trim|linePrefix:"  /// "} -->
  /// <!-- {/dartSemanticLabel} -->
  final String? semanticLabel;
}
```

- **Look before adding.** Run `mdt list` to see every provider and where it is consumed, and reuse one before writing a near-duplicate. Name new providers `docs<Topic>` for Markdown and `dart<Topic>` for dartdoc.
- **Add a provider** only for text that appears in at least two places. Write it in a `templates/*.t.md` file, replace each copy with a consumer block, then run `mdt update`.
- **Render values from manifests.** `mdt.toml` declares `[data]` sources (the skribble pubspec and `.fvmrc`), so a provider can write `{{ skribble.environment.flutter }}` instead of a hand-typed version. Providers are therefore [minijinja](https://docs.rs/minijinja) templates: text that needs literal double braces goes inside a raw block.
- **Reach a new file type.** Markdown and Dart are scanned already; add other files to `[include] patterns` in `mdt.toml`.
- **Sync and check.** `fix:docs` runs `mdt update` and `lint:docs` runs `mdt check`; `fix:all` and `lint:all` include them, and CI fails when a consumer is stale. mdt formats synced Markdown with dprint, so run `dprint fmt` (or `fix:format`) after editing a template.

<!-- {/docsMdtWorkflow} -->

## Checklist for agents

Before marking any widget task as complete, verify:

- [ ] Widget file created at `packages/skribble/lib/src/wired_<name>.dart`
- [ ] UI components use `HookWidget`; motion lifecycle code uses standard Flutter state and tickers
- [ ] Name starts with `Wired` prefix
- [ ] Reads theme via `WiredTheme.of(context)` — no hardcoded colors
- [ ] Wraps output with `buildWiredElement()` or `RepaintBoundary`
- [ ] Has `///` doc comment on the class
- [ ] Has `semanticLabel` parameter for accessibility
- [ ] Exported from `packages/skribble/lib/skribble.dart`
- [ ] Test file at `packages/skribble/test/widgets/wired_<name>_test.dart`
- [ ] Test file has 6+ `testWidgets` covering all categories
- [ ] Tests use the `pumpWired()` host and public-API helpers
- [ ] Storybook entry added
- [ ] `dart format .` passes
- [ ] `dart analyze --fatal-infos .` passes
- [ ] `flutter test` passes
- [ ] Documentation updated (widget catalog page, any affected MDT blocks)
- [ ] Prose uses the lowercase brand word (`skribble`) — see [Brand and casing](#brand-and-casing)
- [ ] Changeset added and `monochange check` passes with no lint issues

## Common mistakes to avoid

1. **Using stateful UI components** — use `HookWidget` with `useState` for ordinary components. Keep the motion layer on standard Flutter lifecycle classes.
2. **Forgetting `RepaintBoundary`** — every widget must isolate repaints
3. **Hardcoding colors** — always read from `WiredTheme.of(context)`
4. **Skipping tests** — minimum 6 `testWidgets` per widget, no exceptions
5. **Wrong test helper** — use `pumpWired()`, not raw `tester.pumpWidget()` or the legacy `pumpApp()`
6. **Missing barrel export** — widget must be exported from `skribble.dart`
7. **Missing dartdoc** — every public class and parameter needs `///` comments; the shared `public_member_api_docs` lint fails `dart analyze --fatal-infos` on any undocumented public member
8. **Missing semantic label** — interactive widgets need a `semanticLabel` parameter
9. **Not updating docs** — when APIs change, update the docs site content
10. **Using `const` constructors for Wired widgets in tests** — many Wired widgets contain mutable rough drawing state, so tests may need non-const instances

## Working with the rough engine

### When to use RoughBoxDecoration vs custom painters

Use `RoughBoxDecoration` when:

- You need a standard shape (rectangle, rounded rect, circle, ellipse)
- You want drop-in replacement for `BoxDecoration`
- The widget uses `Container` or `DecoratedBox`

Use a custom `WiredPainterBase` when:

- You need a non-standard shape (star, wave, arrow, etc.)
- You need to draw multiple shapes in a single painter
- You need fine-grained control over the drawing sequence
- You need to animate the drawing

### DrawConfig and determinism

For consistent visual output in tests and screenshots, use a fixed seed:

```dart
// Static example: configuration
DrawConfig.build(seed: 42, roughness: 1)
```

Without a fixed seed, rough drawings will vary between renders, which can cause flaky visual regression tests.

### Where engine code lives

The engine is split across two packages. Geometry, fillers, pens, ink sampling, and SVG output belong in `packages/skribble_rough`, which must stay free of Flutter and `dart:ui` so servers and `skribble_jaspr` can use it; its tests use `package:test`. Anything that touches `Canvas`, `Paint`, or `Path` stays in `packages/skribble/lib/src/rough/`. When you add a public engine type that Flutter apps need, add it to the `show` list in `packages/skribble/lib/skribble.dart` too.

### Jaspr components

`packages/skribble_jaspr` holds `StatelessComponent`s that render on the server with zero client JavaScript. Follow its conventions:

- Draw ink with the helpers in `lib/src/ink.dart`: a nominal `InkCanvas`, a seeded generator per shape and fill, and a decorative overlay (`aria-hidden="true"`, `preserveAspectRatio="none"`, `vector-effect="non-scaling-stroke"`).
- Never use randomness outside the seed, so static builds stay byte-stable.
- Every new class name needs rules in `skribbleCss`, including `prefers-reduced-motion` handling for any motion.
- Test with `jaspr_test`'s `testServer`: structure, accessibility attributes, and identical markup for identical seeds. `test:all` runs these suites with `dart test`.

### npm packages

`js/` is a pnpm workspace of TypeScript packages: `@skribble.dev/rough` (a port of `skribble_rough`) and its React, React Native, Vue, and Svelte bindings. Follow its conventions:

- `@skribble.dev/rough` follows the Dart engine operation for operation, including Dart's `Random(seed)` stream, rounding, and sort order. When you change `packages/skribble_rough`, regenerate `js/rough/test/fixtures/dart-parity.json` with `dart run packages/skribble_rough/tool/js_parity_fixtures.dart` and port the change until the parity tests pass. When you add a shape, fill style, or pen, add cases for it to `tool/js_parity_fixtures.dart` too; the freshness check only covers cases the tool already writes.
- Framework packages stay thin: they map `SketchPath` entries from `sketch()` to their own path elements and add nothing the core could hold.
- Run `pnpm install && pnpm run check` (build, typecheck, test). The `npm-packages` CI job runs the same.
- Internal dependencies use plain semver ranges (`"@skribble.dev/rough": "^0.1.0"`), never the `workspace:` protocol. monochange rewrites those ranges on every release, and `npm publish`, which trusted publishing uses, would ship a `workspace:` range unchanged. `pnpm-workspace.yaml` sets `linkWorkspacePackages`, `preferWorkspacePackages`, and `saveWorkspaceProtocol: false`, so pnpm still links the local packages and `pnpm add` writes plain ranges.
- monochange owns the versions. The five packages form the `js` group in `monochange.toml`, share one version, and release under a `js/v<version>` tag. Changes under `js/` need a changeset for them, like any Dart package.
- Never publish to npm from a branch. The publish workflow publishes a `js/v<version>` tag with npm trusted publishing, and each package's `prepack` script builds it first.

### Rust crates

`rust/` holds a Cargo workspace (its manifest is the root `Cargo.toml`): `skribble_rough` (`rust/rough`, a port of `skribble_rough`) and `skribble_leptoskit` (`rust/leptoskit`, leptoskit components). Follow its conventions:

- `skribble_rough` follows the Dart engine operation for operation, like `@skribble.dev/rough`, and its `tests/parity.rs` replays the same `js/rough/test/fixtures/dart-parity.json`. When you change `packages/skribble_rough`, regenerate the fixtures and port the change to both the TypeScript and the Rust engines until both parity suites pass.
- The root `Cargo.toml` pins `leptoskit`, `leptoskit_native`, and `leptoskit_testing` to exactly `=0.3.0` (crates.io, tag `v0.3.0`) and pins the matching leptos release for every crate; bump the leptoskit crates together, and only there.
- The Rust crates release together as the monochange `rust` group (`rust/v<version>` tags, published to crates.io). In changesets, name the Rust engine `rust:skribble_rough` and the Dart engine `dart:skribble_rough`: both packages are called `skribble_rough`, so a bare `skribble_rough:` is ambiguous and fails `monochange check`.
- In `skribble_leptoskit`, components describe their drawing as an `Ink` and add `Ink::layer()` as their first child. Only `src/ink/` knows how ink is drawn: leptoskit `Vector` elements painted with `currentColor`, one per tone, so `dark:` text classes recolour them on every backend. Keep it that way.
- `skribble_leptoskit_maps` (`rust/leptoskit_maps`, `skribble_leptoskit_maps`) draws its own tiles-free vector maps on the same pattern: a flat Web Mercator `Camera` projects coordinates, and rough paths become `Vector` elements, one per tone, painted with `currentColor`. It depends on `skribble_leptoskit` for the theme, so never duplicate the tone-class or path-painting helpers it uses. Maps take an explicit size, cull off-screen features and pins, and follow the controlled pattern for zoom.
- Components are `#[component]` functions returning `Element`, with a `seed`, an optional `theme`, and an optional `class`. Controls are controlled: they take a value and a callback that proposes a change. Never use randomness outside the seed.
- Run `cargo fmt --all`, `cargo clippy --workspace --all-targets --all-features -- -D warnings`, `cargo test --workspace`, and `cargo test --workspace --all-features`. The `rust-crates` CI job runs the same. `cargo run -p skribble_leptoskit --example notebook -- notebook.html` renders every component for a visual check, in light and dark mode.

### The skribble.dev landing page

`apps/skribble_site` is the landing page, rendered with Jaspr into static HTML by `bin/build.dart` (`site:build`, or `site:serve` to preview). It uses `skribble_jaspr` components and its own seeded doodles from `skribble_rough`, so treat it like a Jaspr package:

- Seed every drawing. Stroked doodle paths carry `pathLength="1"` so `web/site.css` can draw them on; `web/site.js` only adds enhancements (reveals, theme toggle, copy buttons, slider values, seed shuffling). Every control is a native input that works without it.
- Respect `prefers-reduced-motion` for any new animation, and keep both the light and dark palettes in `web/site.css` in step.
- Load nothing from other origins. Fonts, emoji, and icons come from the workspace at build time (`lib/src/build.dart`); image files stay out of Git.
- Fonts ship as Latin-subset WOFF files made by `pyftsubset` (fontTools, in `devenv shell`) at build time, about a quarter of the TrueType size. A family in `fontFamilies` (`lib/src/assets.dart`) appears once its package is in the workspace. The faces in `criticalFaces` are preloaded, and the page stays hidden until they load (at most 3 seconds) so it never paints in a fallback font. Add a face there only if text above the fold uses it.
- Link to documentation with relative `docs/...` paths. `test/site_test.dart` fails when a link has no page under `docs/site/content/`.

The `Docs Pages` workflow publishes one GitHub Pages site: the landing page at the root, the Flutter docs under `docs/`, and the storybook under `docs/storybook/`. Pages serves only the root `404.html`, which sends links from before the move (the docs used to live at the root) on to `docs/`.

The website deploys with releases, not with every push to `main`. `skribble_site` is a monochange package that is never published to a registry: it is tagged `skribble_site/v<version>`, and the publish workflow's `website` job dispatches `Docs Pages` once per release (`scripts/release/deploy_website.sh`). Changes under `apps/skribble_site` need a changeset like any package. Use `feat`/`fix` for developer notes and `user_feat`/`user_fix` for what visitors notice; those land on the docs' What's new page (`docs/site/content/reference/whats-new.md`, written by monochange, so never edit its entries by hand). See [Releasing](/reference/releasing#the-website).

## Documentation update requirements

**Every change to the codebase must have corresponding documentation updates.** This is a hard rule, not a suggestion. No PR should be merged without documentation for what changed.

**When you add a widget:**

1. Add it to the appropriate widget catalog page in `docs/site/content/widgets/`
2. Include a code example, parameter table, and behavioral notes
3. Export it from `packages/skribble/lib/skribble.dart`
4. Add a `///` dartdoc comment on the class and all public parameters
5. Add the widget to the API overview at `docs/site/content/reference/api-overview.md`

**When you touch Material or Cupertino interop:**

1. Only `packages/skribble/lib/src/compat/` may import `package:flutter/material.dart` or `package:flutter/cupertino.dart`; every file there keeps the header note explaining why
2. Do not add Material parity to `WiredMaterialApp` — the bridge exists for interop and migration, not parity
3. Regenerate `docs/material-dependency-audit.txt` with `dart run tool/audit_material_dependencies.dart > docs/material-dependency-audit.txt` and describe the core-count change
4. Update `docs/site/content/core/material-bridge.md` and, for the app root, `docs/site/content/core/app-shell.md`

**When you modify a widget API:**

1. Update the widget's entry in the widget catalog
2. Update any code examples that reference the changed API
3. Update MDT template blocks if the change affects reusable patterns
4. Update the agents.md reference if it lists the widget's parameters

**When you add a feature:**

1. Add or update the relevant guide in `docs/site/content/guides/`
2. Update the getting-started pages if the feature is fundamental
3. Update this agents.md if the feature changes agent workflows
4. Update the API overview if new public types are introduced

**When you modify the theme system:**

1. Update `docs/site/content/core/theme-system.md`
2. Update the theming getting-started page
3. Update the `docsWiredThemeDataParameters` table in `templates/theme.t.md`, which this page and the theming guide share
4. Update the theming MDT template block in `templates/theme.t.md`

**When you modify tests or testing infrastructure:**

1. Update `docs/site/content/guides/testing.md`
2. Update the test template in this agents.md

**When you modify the rough engine:**

1. Update `docs/site/content/core/rough-engine.md`
2. Update `docs/site/content/core/painters.md` if painters are affected
3. Update the rough engine reference section in this agents.md

**When you add or modify devenv scripts:**

1. Update `docsCommandsSection` (or `docsReleaseCommandsSection`) in `templates/getting-started.t.md`, which `AGENTS.md`, `CONTRIBUTING.md`, the root README, and the contributing page share, then run `mdt update`
2. Update the workspace commands table at the bottom of this agents.md

**When you modify the docs site itself:**

1. Pages are discovered from `docs/site/content/**/*.md`; the navigation groups by the first path segment (`core/`, `guides/`, `reference/`, ...), so a new Markdown file needs no registration
2. A new content directory must be added to the `assets:` list in `docs/site/pubspec.yaml`
3. Update internal cross-links between pages

**When you change the architecture, layer boundaries, or Material dependencies:**

1. Update `docs/site/content/core/architecture.md` — it is the source of truth for direction; `PLANNING.md` is a historical tracker
2. Update `docs/site/content/core/material-bridge.md` when bridge behavior or framing changes
3. Regenerate `docs/material-dependency-audit.txt` with `dart run tool/audit_material_dependencies.dart`
4. Record superseding decisions in the architecture page's decision records instead of relitigating settled ones in a pull request

**When you modify release or publication automation:**

1. Update `docs/site/content/reference/releasing.md`
2. Run `monochange step validate` and `monochange check`
3. Preview release changes with `monochange step prepare-release --dry-run --diff`
4. Keep pub.dev publication in the two documented rate-limit batches

## Design handoff and the Figma workflow

Figma is a first-class design target. The editable design system is published as `skribble-design-system.fig` on the latest GitHub release; the generated design kit provides the fonts, SVG specimens, tokens, and manifest for a specific version. When a task asks for a design, a mockup, or a handoff, follow the [Figma workflow guide](../guides/figma) end to end.

Rules agents must keep:

- Design only with tokens and widgets that exist. A design the library cannot express is recorded as a gap in the bundle manifest and raised as an issue, never approximated with hardcoded values.
- Generate the kit from the release tag that matches the target `skribble` version, never from `main`; never hand-edit files under `build/design-kit/`.
- Verify the kit before sharing it: 36 font files, 18 specimens, and an accurate `manifest.json`.
- Copy the design kit README into every handover bundle so token tables travel with the assets.
- Figma text uses the real skribble font styles — no outlined text, no simulated bold or italic.
- Upload fonts to the Figma account (not only local installation) when the design will be edited through Figma's remote or agent runtimes.
- Reference the release version in design pointers so assets match the code version.

## Icon pipeline reference

### Generating Material rough icons

```bash
melos run rough-icons          # SVG output only
melos run rough-icons-font     # SVG + TTF font + Dart helpers
```

### Generating icon-set packages

Each icon set ships as its own package under `packages/`. Adding a set means creating the package, pointing a generator at a pinned source, and committing the resulting `.g.dart`.

- `SkribbleGlyphs` (in the core package) regenerate from the stroke SVGs and `glyphs.json` in `packages/skribble/tool/glyphs` with `melos run glyphs`.
- `skribble_icons_lucide`, `skribble_icons_bxs`, and `skribble_icons_cib` regenerate from Iconify `icons.json` payloads pinned in `tool/asset_sources.txt` by version and SHA-256.
- `skribble_icons_material` regenerates from the Flutter SDK through `svg2roughjs`; see `docs/rough-icon-pipeline.md`.

Codepoints are private-use and allocated per set so catalogs cannot collide:

| Set    | Band            |
| ------ | --------------- |
| simple | `0xF001–0xF0FF` |
| lucide | `0xE000–0xEFFF` |
| bxs    | `0xF100–0xF3FF` |
| cib    | `0xF400–0xF7FF` |

Core `skribble` owns no icon catalog. `WiredIcon` resolves `IconData` through `registerWiredIconCatalog`, which an icon-set package calls from its own `registerSkribbleMaterialIcons()`. Adding an icon set therefore never touches the core package.

`melos run icons-check` re-derives every catalog and fails on any byte difference, which is what the `icon-catalogs-sync` CI job enforces.

### Adding a curated custom icon

1. Create a manifest JSON:

```json
[
  {
    "identifier": "my_icon",
    "codepoint": "0xE001",
    "svg_path": "icons/my_icon.svg"
  }
]
```

2. Run the generator:

```bash
dart run tool/generate_rough_icons.dart \
  --kit svg-manifest \
  --manifest path/to/manifest.json \
  --output lib/src/generated/my_icons.g.dart \
  --map-name kMyRoughIcons
```

### Using icons in widgets

```dart
// Static example: external-asset
// Material rough icon
WiredIcon(icon: Icons.home)

// Custom SVG icon
WiredSvgIcon(data: myCustomIconData)
```

## Workspace commands quick reference

| Command                          | What it does                                                                                                    |
| -------------------------------- | --------------------------------------------------------------------------------------------------------------- |
| `melos run analyze`              | Dart analyze across all packages                                                                                |
| `melos run flutter-test`         | Run Flutter widget tests                                                                                        |
| `melos run format`               | Format all Dart code                                                                                            |
| `melos run screenshot`           | Capture component screenshots                                                                                   |
| `melos run rough-icons`          | Generate rough Material icon SVGs                                                                               |
| `melos run rough-icons-font`     | Generate icon font + Dart helpers                                                                               |
| `melos run rough-icons-ci-check` | CI-equivalent Material icon checks                                                                              |
| `melos run icons-iconify`        | Regenerate the Simple Icons, Lucide, Boxicons Solid, and CoreUI Brands catalogs                                 |
| `melos run icons-check`          | Verify every icon catalog matches its generator                                                                 |
| `melos run package-sizes`        | Verify each publishable package stays inside its compressed-size budget                                         |
| `lint:all`                       | All lint checks: dprint, dart analyze, `mdt check`, and `monochange check`                                      |
| `lint:push`                      | CI lint checks before `git push`                                                                                |
| `test:all`                       | All Flutter and pure-Dart tests; `MELOS_TEST_CONCURRENCY` parallelizes packages locally                         |
| `fix:all`                        | Auto-fix docs (`mdt update`), formatting, and lint issues                                                       |
| `fix:docs` / `lint:docs`         | Sync or check the shared MDT documentation blocks                                                               |
| `docs:site:serve`                | Serve docs site locally                                                                                         |
| `docs:site:build`                | Build static docs for deployment                                                                                |
| `site:build`                     | Build the skribble.dev landing page into `apps/skribble_site/build/web`                                         |
| `site:serve`                     | Build the landing page and serve it on `PORT` (default 8080)                                                    |
| `monochange step validate`       | Validate release configuration                                                                                  |
| `monochange check`               | Validate and lint config, changesets, manifests                                                                 |
| `monochange run release`         | Prepare, commit, and open or refresh the release PR (the `Release PR` workflow runs it on every push to `main`) |
| `monochange run release-local`   | Prepare a local release (plan, format, commit, tag, publish the GitHub release)                                 |
| `monochange run publish`         | Publish the packages in the current release                                                                     |
| `publish:owned <tag>`            | Publish the packages a tag owns, one at a time, then verify the registry                                        |
| `publish:tags`                   | Tag the merged release commit at HEAD and push its tags one at a time, watching each publish run                |

## Changeset lint rules

Changesets are linted by `monochange check`, which the CI `lint` job runs on every pull request. A changeset that breaks a rule fails CI, so follow these when authoring one:

- Exactly one H1 summary heading, 8–90 characters, no trailing period, no Conventional Commit prefix (`feat:` or `fix(scope):` headings are rejected).
- The first description sentence must add information beyond the heading, not restate it.
- At least 80 characters of body prose (120 plus a code block for `major` bumps).
- Keep entries in the inline `target: type` form; never use change types as section headings (`## Breaking`).
- One changeset file per concern. The only reason to give one change two files is a second audience: a `skribble_site` change visitors notice gets a `user_feat` or `user_fix` file for the What's new page next to its developer note, and every target in one file must share a stream.

Run `monochange check --fix` to auto-fix the style rules; everything else needs a manual edit. The full policy is documented in `docs/site/content/reference/releasing.md` under "Changeset lint rules".

## Visual asset checks

<!-- {=docsFigmaReleaseRule} -->

**Figma exports belong on the latest GitHub release, never in Git**, including renamed or archived copies. Save `.fig` files outside the checkout, publish them as `skribble-design-system.fig` on the release marked Latest, and verify the uploaded size and SHA-256 digest; `docs/design/README.md` describes the upload and verification. Link downloads through `releases/latest/download/skribble-design-system.fig`. The `design-asset-policy` CI job rejects tracked Figma exports.

<!-- {/docsFigmaReleaseRule} -->

See [the design-kit publishing instructions](https://github.com/openbudgetfun/skribble/blob/main/docs/design/README.md#publishing-a-figma-export).

When checking the Figma guide, inspect each complete page with component masters visible. Confirm that masters are children of the paper-backed guide, no sibling boards overlap, long text wraps within its container, and selected-state labels contrast with their backgrounds. Inspect old archive pages too, keeping intentional overlap within illustrations intact.

After changing fonts, SVG import, or painting, run the glyph/corpus/pixel regressions and inspect real browser screenshots. `dart run packages/skribble_emoji_gen/bin/update_assets.dart` rebuilds the pinned source assets. `dart run tool/font_specimen.dart` creates embedded-font HTML comparisons. Patrol notebook journeys use shared keys in `lib/testing/quality_keys.dart`; run them through Patrol CLI and retain screenshots. Report browser coverage separately from native-device coverage.

Emoji are skribble's own drawings. To add or change one, edit `packages/skribble_emoji/art/<group>/<art-key>.svg` following `art/STYLE.md` (palette tokens, not hex, except in flags; line widths; shade on the lower right; named parts), render contact sheets with `EMOJI_GALLERY=<folder or keys> flutter test test/art_gallery_test.dart` from `packages/skribble_emoji` and look at them, then run `melos run emoji` and commit the art with the regenerated catalog. `art_gallery_test.dart` fails on any art that breaks the authoring rules, and `generate_emoji.dart` fails when a Unicode emoji has no drawing.

Git hooks are managed by devenv with `prek` and installed the first time you enter the devenv shell. The pre-commit stage checks formatting with `lint:format` and scans staged changes for secrets with gitleaks; the pre-push stage runs the CI lint job (`lint:push`) and scans the full history for secrets. Hooks invoke devenv profile scripts by absolute path, so they work outside the devenv shell, and the pre-push script prepends `.devenv/profile/bin` to `PATH` so nested `dart`/`melos`/`mdt` calls resolve the pinned toolchain.

The automated PR review resolves the Flutter docs workspace package before repository-wide analysis. Its generated Markdown lives under `.audit/` so it does not fail its own formatting check, and test-file inventory paths are repository-relative without a duplicate package prefix.

Repository Markdown uses dprint with `textWrap: "never"`. Keep prose paragraphs unwrapped and run `dprint fmt` after editing Markdown.

### Executable documentation examples

Live Markdown fences begin with `// Live example: <stable-id>`. Define the matching compiled expression in the relevant `docs/site/lib/src/examples/*.examples.dart` category file, with an `@docs-example` doc comment. Editable values use the typed `ExampleSettings` fields. The generator parses setting references, so text and comments are never changed by string matching.

From `docs/site`, run `dart run tool/generate_examples.dart` after changing a builder. It extracts the displayed source and synchronizes marked Markdown fences and the shared button template. Run `--check` in CI. Unknown IDs, unused builders, and stale source must fail validation. Run `mdt update` after generation when changing template-owned examples.

Keep previews in the actual docs layout during tests: inherited typography and article padding can expose failures that an isolated widget hides. Configuration, shell commands, and platform setup remain source instructions rather than simulated widgets.

The web docs defer the live-example catalog until an article renders a live fence. `docs:site:build` also trims the release `FontManifest.json` to Noto Sketch, which letters the articles, and the Mono faces for code, and `tool/prepare_pages.dart` writes `DeferredFontManifest.json` for the font comparison page. The same script gives every page's `index.html` its own title, description, canonical link, and Open Graph and Twitter card tags from the page's frontmatter (`DOCS_SITE_URL` sets the origin, default `https://skribble.dev`), and the build then renders the shared preview image, `share-card.png`, with `flutter test tool/share_card_test.dart`. The image is generated on every build and never committed; `lib/src/share_card.dart` is its source. Keep the `DOCS_DEFER_FONTS` build define and the manifest preparation step together when changing that pipeline; development builds retain Flutter's complete font manifest.

The HTML loading mark remains visible until the first Flutter frame renders the requested article. `main.dart` must not mount a temporary router before `DocsApp`, since that replaces a deep-link URL with the home route.

Every Dart fence requires an explicit classification. Standalone widget expressions use a live example marker. Setup, configuration, API definitions, implementation lessons, tests, pseudocode, and examples requiring custom assets use `// Static example: <reason>` with a reason accepted by `tool/generate_examples.dart`. These internal markers are hidden from displayed and copied code. Do not classify a runnable widget demonstration as static just to bypass preview coverage.

### Image storage

<!-- {=docsImagesOutOfGit} -->

- **Keep image files out of Git**, including screenshots, design exports, and golden snapshots. Save them in gitignored local output directories, upload review images with `gh pr create/edit/comment --attach`, or use external file storage. Put the resulting attachment or download URL in the PR or a README. Prefer pixel assertions against in-memory renders when a visual test can express the expected behavior without a committed image.
- Before pushing, check staged additions and the branch's commits for image files. Remove newly introduced images from an unmerged branch's history before publishing the corrected branch; deleting them only in a later commit still leaves the repository bloated.

<!-- {/docsImagesOutOfGit} -->

### Screenshots for design changes

<!-- {=docsDesignScreenshotsRule} -->

- Every pull request that changes what skribble draws or how it lays out must show the change. That covers widget appearance, the rough engine, pens and fillers, icons and emoji, fonts, theme defaults, spacing, and the storybook or docs visuals.
- Capture **before and after** screenshots from the same harness: the storybook, `melos run screenshot`, or an in-memory render. Include both light and dark themes, and narrow and wide widths when layout changes.
- Upload them to the pull request itself with the GitHub CLI's `--attach` flag, never by committing them:
  - when opening: `gh pr create --attach './before.png#Before' --attach './after.png#After'`;
  - later captures: `gh pr edit <n> --attach ...` or `gh pr comment <n> --attach ...`.
- Text after `#` is the image's alt text. A local path already referenced in the body (`![Before](./before.png)`) is replaced with the uploaded URL; anything else is appended.
- Put the images in a collapsible `<details>` section of the description, and say what the captures do not cover. Inspect every image first so it exposes no secrets or personal data.

<!-- {/docsDesignScreenshotsRule} -->
