---
title: Quick Start
description: Build a minimal Flutter app with SkribbleApp and a handful of hand-drawn widgets.
---

# Quick Start

This page walks you through a minimal skribble app. By the end you will have a running Flutter app with a hand-drawn app bar, button, text input, and checkbox -- all styled by a single `WiredThemeData`.

## Prerequisites

Make sure you have [installed skribble](/getting-started/installation) in your Flutter project.

## Minimal app

<!-- {=docsMinimalAppSection} -->

```dart
// Static example: setup
import 'package:flutter/widgets.dart';
import 'package:skribble/skribble.dart';

void main() {
  runApp(
    SkribbleApp(
      title: 'My sketchy app',
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

## How SkribbleApp works

`SkribbleApp` is an app shell built on Flutter's widgets-layer `WidgetsApp`. It does three things automatically:

1. **Installs the Wired theme** -- it places a `WiredThemeScope` at the top of the tree so every descendant Wired widget can call `WiredTheme.of(context)` to read theme values (border color, fill color, stroke width, roughness, text colors).

2. **Stays Material-free** -- nothing above your `home` widget imports Material or Cupertino, so a skribble app is a genuine peer of a Material or Cupertino app instead of a skin over one. `WiredScaffold` and `WiredAppBar` replace their Material counterparts.

3. **Localizes sensibly** -- it installs a widgets-only localization delegate that resolves left-to-right and right-to-left text direction. Add `flutter_localizations` delegates if you need translated Material or Cupertino strings; see [App shell](../core/app-shell#localization).

The app supports multiple theme variants:

```dart
// Static example: setup
SkribbleApp(
  wiredTheme: lightTheme,                      // optional -- light mode
  darkWiredTheme: darkTheme,                    // optional -- dark mode
  highContrastWiredTheme: highContrastTheme,    // optional -- accessibility
  highContrastDarkWiredTheme: hcDarkTheme,      // optional -- accessibility + dark
  themeMode: SkribbleThemeMode.system,          // follows platform brightness
  home: MyHomePage(),
)
```

If you omit `wiredTheme`, `WiredThemeData.defaultTheme` is used. If you omit `darkWiredTheme`, the light theme is used for both modes.

### Router variant

For apps using `go_router` or another `RouterConfig`, use the `.router` constructor:

```dart
// Static example: setup
SkribbleApp.router(
  wiredTheme: WiredThemeData(),
  routerConfig: goRouter,
)
```

### Already using MaterialApp?

Keep it while you migrate and use `WiredMaterialApp`, the transitional compatibility bridge. It wraps `MaterialApp`, syncs the Wired palette into Material's `ThemeData`, and accepts the same `wiredTheme` parameters plus `ThemeMode`. See the [Material bridge](../core/material-bridge) for the full migration path.

## Adding more widgets

Now let's build a more complete page. Replace the `home` parameter with a dedicated page widget:

```dart
// Static example: setup
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:skribble/skribble.dart';

void main() {
  runApp(
    SkribbleApp(
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

    return WiredScaffold(
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
                    DefaultTextStyle.merge(
                      style: TextStyle(fontSize: 24),
                      child: Text('Sign Up'),
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
3. It wraps standard Flutter interaction widgets (`TextButton`, `TextField`, `Checkbox`) so gestures, focus, and accessibility work out of the box. That Material wrapping is transitional debt: the [decoupling plan](/core/architecture#rewrite-order) replaces each wrapper with a `flutter/widgets` equivalent, and each rewrite re-verifies the semantics the wrapper supplied.
4. It is a `HookWidget`, so local state uses `useState`, `useTextEditingController`, and other hooks instead of `setState`.

## Next steps

- [Your First Widget](/getting-started/first-widget) -- deeper dive into individual widgets and event handling
- [Theming](/getting-started/theming) -- change colors, stroke width, and roughness
- [Widget Reference](/widgets) -- browse the full catalog of 80+ widgets

## Bring the ink to life

Wrap a card or section in `WiredDraw(child: ...)` for a one-time drawing entrance. Use `WiredDrawTransition(progress: animation, child: ...)` to control the timing with standard Flutter animations. Set `motionEnabled: false` in `WiredThemeData` to disable decorative ink app-wide. Platform reduced motion is respected automatically. See [Ink motion](../core/motion).
