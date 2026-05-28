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
WiredMaterialApp(
  title: 'My App',
  theme: WiredThemeData(
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
ElevatedButton(
  onPressed: () {},
  child: Text('Click me'),
)
```

**After:**

```dart
WiredElevatedButton(
  onPressed: () {},
  child: Text('Click me'),
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
TextField(
  decoration: InputDecoration(
    labelText: 'Email',
    hintText: 'Enter your email',
  ),
)
```

**After:**

```dart
WiredInput(
  labelText: 'Email',
  hintText: 'Enter your email',
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
Card(
  child: Padding(
    padding: EdgeInsets.all(16),
    child: Text('Card content'),
  ),
)
```

**After:**

```dart
WiredCard(
  child: Padding(
    padding: EdgeInsets.all(16),
    child: Text('Card content'),
  ),
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
WiredListTile(
  leading: Icon(Icons.person),
  title: Text('John Doe'),
  subtitle: Text('john@example.com'),
  trailing: Icon(Icons.chevron_right),
  onTap: () {},
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
DropdownButton<String>(
  value: selectedValue,
  items: [...],
  onChanged: (value) {},
)
```

**After:**

```dart
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
CircularProgressIndicator()
```

**After:**

```dart
WiredCircularProgress()
```

## Step 4: Update Icons (Optional)

Replace Material icons with hand-drawn versions:

**Before:**

```dart
Icon(Icons.home)
```

**After:**

```dart
// Using pre-computed hand-drawn icons
SkribbleIcon(data: kSkribbleIcons[Icons.home.codePoint])

// Or using the WiredIcon widget (renders with rough engine)
WiredIcon(icon: Icons.home)
```

## Step 5: Update Fonts (Optional)

Use the Skribble font for a fully hand-drawn text experience:

**Before:**

```dart
Text(
  'Hello World',
  style: TextStyle(fontFamily: 'Roboto'),
)
```

**After:**

```dart
Text(
  'Hello World',
  style: TextStyle(fontFamily: 'Skribble'),
)
```

Or update your theme:

```dart
WiredMaterialApp(
  theme: WiredThemeData(
    fontFamily: 'Skribble',
    // ... other properties
  ),
)
```

## Step 6: Add Accessibility

All Wired widgets support accessibility through the `semanticLabel` property:

```dart
WiredCheckbox(
  value: true,
  onChanged: (value) {},
  semanticLabel: 'Accept terms and conditions',
)

WiredSlider(
  value: 0.5,
  onChanged: (value) => true,
  semanticLabel: 'Volume control',
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
WiredForm(
  child: Column(
    children: [
      WiredInput(
        labelText: 'Email',
        validator: (value) {
          if (value?.isEmpty ?? true) {
            return 'Email is required';
          }
          return null;
        },
      ),
      WiredElevatedButton(
        onPressed: () {
          if (WiredForm.of(context).validate()) {
            // Submit form
          }
        },
        child: Text('Submit'),
      ),
    ],
  ),
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
