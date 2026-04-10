---
title: Quick Start
description: Build a minimal Flutter app with Skribble's WiredMaterialApp and a handful of hand-drawn widgets.
---

# Quick Start

This page walks you through a minimal Skribble app. By the end you will have a running Flutter app with a hand-drawn app bar, button, text input, and checkbox -- all styled by a single `WiredThemeData`.

## Prerequisites

Make sure you have [installed Skribble](/getting-started/installation) in your Flutter project.

## Minimal app

<!-- {=docsMinimalAppSection} -->
Replace your `main.dart` with the following:

```dart
import 'package:flutter/material.dart';
import 'package:skribble/skribble.dart';

void main() {
  runApp(
    WiredMaterialApp(
      wiredTheme: WiredThemeData(),
      home: Scaffold(
        appBar: WiredAppBar(title: Text('My Sketchy App')),
        body: Center(
          child: WiredButton(
            onPressed: () {},
            child: Text('Press Me'),
          ),
        ),
      ),
    ),
  );
}
```

Run it:

```bash
flutter run
```

You should see a full-screen app with a wobbly-bordered app bar and a hand-drawn button in the center.
<!-- {/docsMinimalAppSection} -->

## How WiredMaterialApp works

`WiredMaterialApp` is a `HookWidget` that wraps Flutter's `MaterialApp`. It does two things automatically:

1. **Injects `WiredTheme`** -- it places a `WiredTheme` `InheritedWidget` at the top of the tree so every descendant Wired widget can call `WiredTheme.of(context)` to read theme values (border color, fill color, stroke width, roughness, text colors).

2. **Syncs Material `ThemeData`** -- it calls `wiredTheme.toThemeData()` internally, producing a Material `ThemeData` whose `ColorScheme`, scaffold background, input decoration, card theme, dialog theme, and text theme all match the Wired palette. This means standard Material widgets (like `Scaffold`, `Text`, `Icon`) also look consistent.

The app supports multiple theme variants:

```dart
WiredMaterialApp(
  wiredTheme: lightTheme,                     // required -- used for light mode
  darkWiredTheme: darkTheme,                   // optional -- used for dark mode
  highContrastWiredTheme: highContrastTheme,   // optional -- accessibility
  highContrastDarkWiredTheme: hcDarkTheme,     // optional -- accessibility + dark
  themeMode: ThemeMode.system,                 // follows platform brightness
  home: MyHomePage(),
)
```

If you omit `darkWiredTheme`, the light theme is used for both modes. The `themeMode` parameter works exactly like `MaterialApp.themeMode`.

### Router variant

For apps using `go_router` or another `RouterConfig`, use the `.router` constructor:

```dart
WiredMaterialApp.router(
  wiredTheme: WiredThemeData(),
  routerConfig: goRouter,
)
```

## Adding more widgets

Now let's build a more complete page. Replace the `home` parameter with a dedicated page widget:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:skribble/skribble.dart';

void main() {
  runApp(
    WiredMaterialApp(
      wiredTheme: WiredThemeData(),
      home: const SketchyHomePage(),
    ),
  );
}

class SketchyHomePage extends HookWidget {
  const SketchyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final nameController = useTextEditingController();
    final isAgreed = useState(false);

    return Scaffold(
      appBar: WiredAppBar(title: Text('Sketchy Form')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hand-drawn card wrapping the form
            WiredCard(
              height: null, // auto-size to content
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sign Up',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 16),

                    // Hand-drawn text input
                    WiredInput(
                      controller: nameController,
                      labelText: 'Name',
                      hintText: 'Enter your name',
                      onChanged: (value) {
                        debugPrint('Name: $value');
                      },
                    ),
                    const SizedBox(height: 16),

                    // Hand-drawn checkbox
                    Row(
                      children: [
                        WiredCheckbox(
                          value: isAgreed.value,
                          onChanged: (value) {
                            isAgreed.value = value ?? false;
                          },
                        ),
                        const SizedBox(width: 8),
                        const Text('I agree to the terms'),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Hand-drawn button
                    WiredButton(
                      onPressed: () {
                        final name = nameController.text;
                        debugPrint('Submitted: $name, agreed: ${isAgreed.value}');
                      },
                      child: const Text('Submit'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

This gives you:

- **`WiredCard`** -- a container with hand-drawn rectangle borders. Set `height: null` to let it auto-size, or pass a fixed height. Set `fill: true` to add a hachure fill pattern.
- **`WiredInput`** -- a text field with a sketchy rectangle border. Supports `labelText`, `hintText`, `onChanged`, `obscureText`, and a `controller`.
- **`WiredCheckbox`** -- a checkbox drawn with rough rectangle borders and a hand-drawn checkmark. Supports tristate (`null`) values.
- **`WiredButton`** -- a tappable button with a wobbly rectangle border. Takes a `child` widget for the label and an `onPressed` callback.

All four widgets read their colors from `WiredTheme.of(context)` automatically. Change the theme in one place and every widget updates.

## What each widget does under the hood

Every Wired widget follows the same pattern:

1. It calls `WiredTheme.of(context)` to get the active `WiredThemeData`.
2. It uses the rough-drawing engine (`RoughBoxDecoration`, `WiredCanvas`, `WiredPainterBase`) to render sketchy borders and fills.
3. It wraps standard Flutter interaction widgets (`TextButton`, `TextField`, `Checkbox`) so gestures, focus, and accessibility work out of the box.
4. It is a `HookWidget`, so local state uses `useState`, `useTextEditingController`, and other hooks instead of `setState`.

## Next steps

- [Your First Widget](/getting-started/first-widget) -- deeper dive into individual widgets and event handling
- [Theming](/getting-started/theming) -- change colors, stroke width, and roughness
- [Widget Reference](/widgets) -- browse the full catalog of 80+ widgets
