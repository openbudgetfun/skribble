---
title: Quick Start
description: Build, run, and test a minimal Flutter app with SkribbleApp and a handful of hand-drawn widgets.
order: 2
---

# Quick Start

This page walks you through a minimal skribble app. By the end you will have a running Flutter app with a hand-drawn app bar, button, text input, and checkbox -- all styled by a single `WiredThemeData` -- and a widget test for it.

## Create the app

Start from any Flutter app. To make a new one and add skribble with its default hand-drawn typeface:

```bash
flutter create --empty my_sketchy_app
cd my_sketchy_app
flutter pub add skribble skribble_font_noto_sketch
```

[Installation](/getting-started/installation) covers the requirements, other typefaces, and optional packages.

## Minimal app

Replace the contents of `lib/main.dart` with:

<!-- {=docsMinimalAppSection} -->

```dart
// Static example: setup
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

Run it with `flutter run` and pick a device. You should see a sketchy app bar and a wobbly button, lettered in Skribble Noto Sketch. If the text is in the system font, see [Troubleshooting](/getting-started/installation#troubleshooting).

`SkribbleApp` is the recommended app shell for new apps. Keeping an existing `MaterialApp` is covered [below](#already-using-materialapp).

## How SkribbleApp works

`SkribbleApp` is an app shell built on Flutter's widgets-layer `WidgetsApp`. It does three things automatically:

1. **Installs the Wired theme** -- it places a `WiredThemeScope` at the top of the tree so every descendant Wired widget can call `WiredTheme.of(context)` to read theme values (border color, fill color, stroke width, roughness, text colors).

2. **Stays Material-free** -- nothing above your `home` widget imports Material or Cupertino, so a skribble app is a genuine peer of a Material or Cupertino app instead of a skin over one. `WiredScaffold` and `WiredAppBar` replace their Material counterparts.

3. **Localizes sensibly** -- it installs a widgets-only localization delegate that resolves left-to-right and right-to-left text direction. Add `flutter_localizations` delegates if you need translated Material or Cupertino strings; see [App shell](../core/app-shell#localization).

The `builder` line is the one piece of Material the minimal app still carries. Several Wired widgets, `WiredInput` among them, wrap a Material control while skribble rewrites them on `flutter/widgets`, and those controls need a Material theme and localizations above them. `WiredMaterialTheme` supplies both from your Wired theme without a `MaterialApp`, and your own code still imports only `package:flutter/widgets.dart`. Leave it out and a screen with a text field fails with `No MaterialLocalizations found`.

The app supports multiple theme variants. In this fragment, `lightTheme`, `darkTheme`, `highContrastTheme`, and `hcDarkTheme` stand for `WiredThemeData` values you define, and `MyHomePage` for your own page widget ([Theming](/getting-started/theming) builds a complete example):

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

For apps using `go_router` or another `RouterConfig`, use the `.router` constructor. Here `goRouter` is your app's `RouterConfig<Object>`:

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

Now let's build a more complete page. It keeps its form state in [flutter_hooks](https://pub.dev/packages/flutter_hooks), the same hooks skribble's widgets use, so add that package first:

```bash
flutter pub add flutter_hooks
```

Then replace `lib/main.dart` with a dedicated page widget:

```dart
// Static example: setup
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:skribble/skribble.dart';

void main() => runApp(const SketchyApp());

class SketchyApp extends StatelessWidget {
  const SketchyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return SkribbleApp(
      title: 'Sketchy form',
      // Supplies the Material theme and localizations that some Wired
      // widgets, such as WiredInput, still need while they wrap Material.
      builder: (context, child) => WiredMaterialTheme(child: child!),
      home: const SketchyHomePage(),
    );
  }
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
                          semanticLabel: 'I agree to the terms',
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

## Test it

Wired widgets work with the standard `flutter_test` finders. Save this as `test/widget_test.dart` and run `flutter test`:

```dart
// Static example: test
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_sketchy_app/main.dart';
import 'package:skribble/skribble.dart';

void main() {
  testWidgets('the sign-up form takes a name and an agreement', (
    tester,
  ) async {
    await tester.pumpWidget(const SketchyApp());

    await tester.enterText(find.byType(EditableText), 'Ada');
    await tester.tap(find.byType(WiredCheckbox));
    await tester.pumpAndSettle();

    expect(find.text('Ada'), findsOneWidget);
    expect(
      tester.widget<WiredCheckbox>(find.byType(WiredCheckbox)).value,
      isTrue,
    );
  });
}
```

Replace `my_sketchy_app` with your app's package name from `pubspec.yaml`. The [Testing guide](/guides/testing) covers skribble's own test helpers, semantics checks, and screenshot tests.

## What each widget does under the hood

Every Wired widget follows the same pattern:

1. It calls `WiredTheme.of(context)` to get the active `WiredThemeData`.
2. It uses the rough-drawing engine (`RoughBoxDecoration`, `WiredCanvas`, `WiredPainterBase`) to render sketchy borders and fills.
3. It wraps standard Flutter interaction widgets (`TextButton`, `TextField`, `Checkbox`) so gestures, focus, and accessibility work out of the box. That Material wrapping is transitional debt: the [decoupling plan](/core/architecture#rewrite-order) replaces each wrapper with a `flutter/widgets` equivalent, and each rewrite re-verifies the semantics the wrapper supplied.
4. It is a `HookWidget`, so local state uses `useState`, `useTextEditingController`, and other hooks instead of `setState`.

## Next steps

- [Your First Widget](/getting-started/first-widget) -- deeper dive into individual widgets and event handling
- [Theming](/getting-started/theming) -- change colors, stroke width, and roughness
- [Widget Reference](/widgets/buttons) -- browse the full catalog of more than 100 widgets

## Bring the ink to life

Wrap a card or section in `WiredDraw(child: ...)` for a one-time drawing entrance. Use `WiredDrawTransition(progress: animation, child: ...)` to control the timing with standard Flutter animations. Set `motionEnabled: false` in `WiredThemeData` to disable decorative ink app-wide. Platform reduced motion is respected automatically. See [Ink motion](../core/motion).
