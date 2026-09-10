---
title: Migration Guide
description: How to migrate an existing Flutter app from Material Design to Skribble's hand-drawn aesthetic.
---

# Migration Guide

This guide walks you through migrating an existing Flutter app from Material Design to Skribble's hand-drawn aesthetic. The migration is straightforward because Skribble's Wired widgets follow similar APIs to their Material counterparts.

## Overview

Migrating to Skribble involves:

1. Adding the Skribble package to your project
2. Replacing Material widgets with their Wired equivalents
3. Wrapping your app with `WiredTheme` and `WiredMaterialApp`
4. Updating the font family (optional)
5. Testing and adjusting the visual appearance

## Step 1: Add Skribble

Add the Skribble package to your `pubspec.yaml`:

```yaml
dependencies:
  skribble: ^0.1.0
  skribble_icons: ^0.1.0 # Optional: for hand-drawn icons
  skribble_emoji: ^0.1.0 # Optional: for hand-drawn emoji
```

Run `dart pub get` to install the packages.

## Step 2: Replace MaterialApp

Replace your `MaterialApp` with `WiredMaterialApp`:

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
WiredMaterialApp(
  title: 'My App',
  wiredTheme: WiredThemeData(
    borderColor: Colors.blue,
    textColor: Colors.black,
    fillColor: Colors.white,
  ),
  home: MyHomePage(),
)
```

## Step 3: Replace Common Widgets

### Buttons

| Material               | Skribble              |
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

| Material        | Skribble                          |
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

| Material              | Skribble              |
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

| Material      | Skribble           |
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

| Material           | Skribble                |
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

| Material          | Skribble               |
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

| Material                    | Skribble                  |
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

## Step 4: Update Icons (Optional)

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

## Step 5: Update Fonts (Optional)

Use the Skribble font for a fully hand-drawn text experience:

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
    fontFamily: 'Skribble',
    // ... other properties
  ),
)
```

## Step 6: Add Accessibility

All Wired widgets support accessibility through the `semanticLabel` property:

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

## Step 7: Test and Adjust

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
  fontFamily: 'Skribble',        // Font family for text
)
```

### Responsive Layout

Skribble widgets work with Flutter's responsive layout system:

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
2. Use the Material widget directly - it will still work within Skribble apps
3. Consider wrapping it with `WiredCanvas` for a hand-drawn border

### Styling differences

Wired widgets may have slightly different default styling than Material widgets. Adjust using:

- `WiredThemeData` for global styling
- Widget-specific properties for individual customization
- The `WiredCanvas` widget for custom hand-drawn shapes

### Performance

If you experience performance issues:

1. Use `RepaintBoundary` around complex widget subtrees
2. Consider using pre-computed icons (`SkribbleIcon`) instead of runtime roughening
3. Test on target devices early and often

## Next Steps

- [Theming Guide](/getting-started/theming) - Customize the hand-drawn palette
- [Widget Catalog](/widgets/buttons) - Browse all available Wired widgets
- [Core Concepts](/core/architecture) - Understand the rough engine and painting system

## Roughness-level theme scopes

`WiredThemeData(roughnessLevel: WiredRoughness.gentle)` selects matching drawing and font defaults; the other levels are `playful` and `expressive`; Playful is the default. Existing `roughness:`, `fontFamily:`, `drawConfig:`, constructor calls, and `WiredTheme.of(context)` remain supported.

`WiredTheme` is now a `HookWidget` with an internal `InheritedTheme` so it can propagate typography alongside drawing data. If your code directly used `dependOnInheritedWidgetOfExactType<WiredTheme>()`, replace that implementation-dependent lookup with `WiredTheme.of(context)`.
