---
title: Migration Guide
description: How to migrate an existing Flutter app from Material Design to skribble's hand-drawn aesthetic.
---

# Migration Guide

This guide walks you through migrating an existing Flutter app from Material Design to skribble's hand-drawn aesthetic. The migration is straightforward because skribble's Wired widgets follow similar APIs to their Material counterparts.

## Overview

Skribble's compatibility layer is built for an incremental migration: you do not have to convert the whole app at once, and you do not have to delete Material to get started.

1. Add the Skribble package to your project
2. Give one screen the Skribble palette (`WiredThemeFromMaterial`), or keep Material where it is
3. Replace Material widgets with their Wired equivalents, screen by screen
4. Move the app root to `SkribbleApp` when the screens are ready
5. Update the font family (optional) and adjust the visual appearance

You can stay on `WiredMaterialApp` (the transitional bridge over `MaterialApp`) for as long as you need. Nothing breaks by migrating gradually; see the [Material bridge](../core/material-bridge) for the coexistence rules and both theme directions.

## Step 1: Add skribble

Add the skribble package to your `pubspec.yaml`:

```yaml
dependencies:
  skribble: ^0.1.0
  skribble_icons: ^0.1.0 # Optional: for hand-drawn icons
  skribble_emoji: ^0.1.0 # Optional: for hand-drawn emoji
```

Run `dart pub get` to install the packages.

## Step 2: Adopt the palette

Start by giving one screen the Skribble palette derived from the Material theme you already have. Material widgets on that screen keep working:

```dart
// Static example: setup
MaterialApp(
  theme: myTheme,
  home: WiredThemeFromMaterial(
    child: MyFirstMigratedScreen(),
  ),
)
```

## Step 3: Move the app root

When enough screens are converted, replace `MaterialApp` with `SkribbleApp`:

**Before:**

```dart
// Static example: pseudocode
MaterialApp(
  title: 'My App',
  theme: ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
    useMaterial3: true,
  ),
  home: MyHomePage(),
)
```

**After:**

```dart
// Static example: setup
SkribbleApp(
  title: 'My App',
  wiredTheme: WiredThemeData(
    borderColor: Color(0xFF1E88E5),
    textColor: Color(0xFF000000),
    fillColor: Color(0xFFFFFFFF),
  ),
  home: MyHomePage(),
)
```

`SkribbleApp` takes the same `wiredTheme` variants as `WiredMaterialApp`. `themeMode` becomes a `SkribbleThemeMode` because the widgets layer has no `ThemeMode`; the compatibility layer converts between them. Any screen that still needs Material widgets gets a `WiredMaterialTheme` wrapper instead of a nested `MaterialApp`.

The existing bridge is still there if you are not ready for the new root:

```dart
// Static example: setup
WiredMaterialApp(
  title: 'My App',
  wiredTheme: WiredThemeData(borderColor: Color(0xFF1E88E5)),
  home: MyHomePage(),
)
```

## Step 4: Replace Common Widgets

### Buttons

| Material               | skribble              |
| ---------------------- | --------------------- |
| `ElevatedButton`       | `WiredElevatedButton` |
| `TextButton`           | `WiredTextButton`     |
| `OutlinedButton`       | `WiredOutlinedButton` |
| `IconButton`           | `WiredIconButton`     |
| `FloatingActionButton` | `WiredFab`            |

**Before:**

```dart
// Static example: pseudocode
ElevatedButton(
  onPressed: () {},
  child: Text('Click me'),
)
```

**After:**

```dart
// Live example: elevated-button
WiredElevatedButton(
  borderRadius: BorderRadius.circular(8),
  onPressed: true ? () {} : null,
  inkInteraction: WiredInkInteraction.pressure,
  child: Text('Make something lovely'),
)
```

### Inputs

| Material        | skribble                          |
| --------------- | --------------------------------- |
| `TextField`     | `WiredInput`                      |
| `TextFormField` | `WiredInput` (with form handling) |
| `Checkbox`      | `WiredCheckbox`                   |
| `Radio`         | `WiredRadio`                      |
| `Switch`        | `WiredSwitch`                     |
| `Slider`        | `WiredSlider`                     |

**Before:**

```dart
// Static example: pseudocode
TextField(
  decoration: InputDecoration(
    labelText: 'Email',
    hintText: 'Enter your email',
  ),
)
```

**After:**

```dart
// Live example: input
WiredInput(
  labelText: 'Make something lovely',
  hintText: 'A tiny spark of an idea…',
)
```

### Navigation

| Material              | skribble              |
| --------------------- | --------------------- |
| `AppBar`              | `WiredAppBar`         |
| `NavigationBar`       | `WiredNavigationBar`  |
| `NavigationRail`      | `WiredNavigationRail` |
| `Drawer`              | `WiredDrawer`         |
| `BottomNavigationBar` | `WiredBottomNav`      |
| `TabBar`              | `WiredTabBar`         |

**Before:**

```dart
// Static example: pseudocode
Scaffold(
  appBar: AppBar(title: Text('My App')),
  body: MyContent(),
  bottomNavigationBar: BottomNavigationBar(
    items: [...],
  ),
)
```

**After:**

```dart
// Static example: pseudocode
WiredScaffold(
  appBar: WiredAppBar(title: Text('My App')),
  body: MyContent(),
  bottomNavigationBar: WiredBottomNav(
    items: [...],
  ),
)
```

### Cards and Containers

| Material      | skribble           |
| ------------- | ------------------ |
| `Card`        | `WiredCard`        |
| `Dialog`      | `WiredDialog`      |
| `BottomSheet` | `WiredBottomSheet` |
| `SnackBar`    | `WiredSnackBar`    |

**Before:**

```dart
// Static example: pseudocode
Card(
  child: Padding(
    padding: EdgeInsets.all(16),
    child: Text('Card content'),
  ),
)
```

**After:**

```dart
// Live example: card
WiredCard(
  fill: true,
  child: Center(child: Text('Make something lovely')),
)
```

### Lists

| Material           | skribble                |
| ------------------ | ----------------------- |
| `ListTile`         | `WiredListTile`         |
| `CheckboxListTile` | `WiredCheckboxListTile` |
| `RadioListTile`    | `WiredRadioListTile`    |
| `SwitchListTile`   | `WiredSwitchListTile`   |
| `ExpansionTile`    | `WiredExpansionTile`    |

**Before:**

```dart
// Static example: pseudocode
ListTile(
  leading: Icon(Icons.person),
  title: Text('John Doe'),
  subtitle: Text('john@example.com'),
  trailing: Icon(Icons.chevron_right),
  onTap: () {},
)
```

**After:**

```dart
// Live example: list-tile
WiredListTile(
  title: Text('Make something lovely'),
  subtitle: const Text('A little note for later'),
  showDivider: false,
  onTap: true ? () {} : null,
)
```

### Selections

| Material          | skribble               |
| ----------------- | ---------------------- |
| `DropdownButton`  | `WiredCombo`           |
| `DropdownMenu`    | `WiredDropdownMenu`    |
| `Chip`            | `WiredChip`            |
| `ChoiceChip`      | `WiredChoiceChip`      |
| `FilterChip`      | `WiredFilterChip`      |
| `SegmentedButton` | `WiredSegmentedButton` |

**Before:**

```dart
// Static example: pseudocode
DropdownButton<String>(
  value: selectedValue,
  items: [...],
  onChanged: (value) {},
)
```

**After:**

```dart
// Static example: pseudocode
WiredCombo<String>(
  value: selectedValue,
  items: [...],
  onChanged: (value) {},
)
```

### Data Display

| Material                    | skribble                  |
| --------------------------- | ------------------------- |
| `DataTable`                 | `WiredDataTable`          |
| `PaginatedDataTable`        | `WiredPaginatedDataTable` |
| `CircularProgressIndicator` | `WiredCircularProgress`   |
| `LinearProgressIndicator`   | `WiredProgress`           |
| `Divider`                   | `WiredDivider`            |
| `Tooltip`                   | `WiredTooltip`            |

**Before:**

```dart
// Static example: pseudocode
CircularProgressIndicator()
```

**After:**

```dart
// Live example: circular-progress
WiredCircularProgress(value: .6)
```

## Step 5: Update Icons (Optional)

Replace Material icons with hand-drawn versions:

**Before:**

```dart
// Static example: pseudocode
Icon(Icons.home)
```

**After:**

```dart
// Live example: icon
const Wrap(
  spacing: 24,
  children: [
    WiredIcon(
      icon: IconData(0xe318, fontFamily: 'MaterialIcons'),
      semanticLabel: 'Home',
      size: 48,
    ),
    WiredIcon(
      icon: IconData(0xe25b, fontFamily: 'MaterialIcons'),
      semanticLabel: 'Favourite',
      size: 48,
    ),
    WiredIcon(
      icon: IconData(0xe047, fontFamily: 'MaterialIcons'),
      semanticLabel: 'Add',
      size: 48,
    ),
  ],
)
```

## Step 6: Update Fonts (Optional)

Use the skribble font for a fully hand-drawn text experience:

**Before:**

```dart
// Static example: api
Text(
  'Hello World',
  style: TextStyle(fontFamily: 'Roboto'),
)
```

**After:**

```dart
// Live example: lettering-pattern
Text(
  'Make something lovely',
  style: const TextStyle(
    fontFamily: skribbleFontFamily,
    package: 'skribble',
    fontSize: 24,
  ),
)
```

Or update your theme:

```dart
// Static example: pseudocode
WiredMaterialApp(
  wiredTheme: WiredThemeData(
    fontFamily: 'skribble',
    // ... other properties
  ),
)
```

## Step 7: Add Accessibility

Interactive Wired widgets expose a `semanticLabel` parameter where they render their own semantics:

```dart
// Live example: accessible-inputs
HookBuilder(
  builder: (context) {
    final checked = useState(false);
    return Column(
      children: [
        WiredCheckbox(
          value: checked.value,
          onChanged: (value) => checked.value = value ?? false,
          semanticLabel: 'Accept terms and conditions',
        ),
        const SizedBox(height: 16),
        WiredSlider(
          value: .6,
          onChanged: (value) => true,
          semanticLabel: 'Volume control',
        ),
      ],
    );
  },
)
```

Do not assume a widget's current screen-reader behavior is permanent. Many Wired widgets get semantics from the Material widget they currently wrap; that semantics disappears when the wrapper is [rewritten onto `flutter/widgets`](/core/architecture#rewrite-order). Verify each widget you migrate with the accessibility inspector or a screen reader, and see [Accessibility testing](/reference/accessibility-testing).

## Step 7: Test and Adjust
## Step 8: Test and Adjust

After migration:

1. **Test all interactions** - Ensure tap targets, scrolling, and navigation work correctly
2. **Check accessibility** - Use Flutter's accessibility inspector and test with screen readers
3. **Adjust theme** - Fine-tune colors, stroke width, and roughness to match your brand
4. **Test on multiple platforms** - Verify appearance on iOS, Android, and web

## Common Patterns

### Theme Customization

```dart
// Static example: configuration
WiredThemeData(
  borderColor: Colors.blue,      // Border color for hand-drawn shapes
  textColor: Colors.black,       // Text color
  fillColor: Colors.white,       // Fill color for shapes
  strokeWidth: 2.0,              // Stroke width for hand-drawn lines
  roughness: 1.0,                // Roughness level (0.0 = smooth, 2.0 = very rough)
  fontFamily: 'skribble',        // Font family for text
)
```

### Responsive Layout

skribble widgets work with Flutter's responsive layout system:

```dart
// Static example: pseudocode
LayoutBuilder(
  builder: (context, constraints) {
    if (constraints.maxWidth < 600) {
      return WiredNavigationBar(...);
    } else {
      return WiredNavigationRail(...);
    }
  },
)
```

### Form Handling

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

## Troubleshooting

### Widget not found

If you can't find a Wired equivalent for a Material widget, check:

1. The widget catalog in the documentation
2. Use the Material widget directly for now - it still works inside a migrating app. (The no-new-Material rule applies to `packages/skribble/lib`, not to your application.) Consider recording the gap so a Wired equivalent can be prioritized
3. Consider wrapping it with `WiredCanvas` for a hand-drawn border

### Styling differences

Wired widgets may have slightly different default styling than Material widgets. Adjust using:

- `WiredThemeData` for global styling
- Widget-specific properties for individual customization
- The `WiredCanvas` widget for custom hand-drawn shapes

### Performance

If you experience performance issues:

1. Use `RepaintBoundary` around complex widget subtrees
2. Consider using pre-computed icons (`skribbleIcon`) instead of runtime roughening
3. Test on target devices early and often

## Next Steps

- [Theming Guide](/getting-started/theming) - Customize the hand-drawn palette
- [Widget Catalog](/widgets/buttons) - Browse all available Wired widgets
- [Core Concepts](/core/architecture) - Understand the rough engine and painting system

## Roughness-level theme scopes

`WiredThemeData(roughnessLevel: WiredRoughness.gentle)` selects matching drawing and font defaults; the other levels are `playful` and `expressive`; Playful is the default. Existing `roughness:`, `fontFamily:`, `drawConfig:`, constructor calls, and `WiredTheme.of(context)` remain supported.

`WiredTheme` is now a `HookWidget` with an internal `InheritedTheme` so it can propagate typography alongside drawing data. If your code directly used `dependOnInheritedWidgetOfExactType<WiredTheme>()`, replace that implementation-dependent lookup with `WiredTheme.of(context)`.
