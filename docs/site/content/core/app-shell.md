---
title: App Shell
description: SkribbleApp is a widgets-based application shell — the Material-free root for a Skribble app, including its theme, navigation, router, and localization behaviour.
---

# App Shell

`SkribbleApp` is the root widget for a Skribble application. It is built on Flutter's widgets-layer `WidgetsApp`, so it does not need `package:flutter/material.dart` or `package:flutter/cupertino.dart` anywhere above your app's home widget. The design system stays a peer of Material and Cupertino instead of a skin over them, and your app no longer has to pretend to be a Material app to run.

## Minimal app

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

The shell installs a `WiredThemeScope` around `WidgetsApp`, so `WiredTheme.of(context)` works everywhere below `home` — no `MaterialApp`, no `WiredTheme` wrapper required.

```dart
// Static example: setup
SkribbleApp(
  wiredTheme: WiredThemeData(borderColor: Color(0xFF4A3470)),
  darkWiredTheme: WiredThemeData.cuddly(brightness: Brightness.dark),
  themeMode: SkribbleThemeMode.system,
  home: MyHomePage(),
)
```

## Navigation

`SkribbleApp` exposes the same navigation entry points as `MaterialApp`, using Flutter's widgets-layer types:

| Parameter                 | Purpose                                               |
| ------------------------- | ----------------------------------------------------- |
| `home`                    | Widget for the default route                          |
| `routes`                  | Named route table                                     |
| `initialRoute`            | First route shown when the app starts                 |
| `onGenerateRoute`         | Builds routes not found in `routes`                   |
| `onGenerateInitialRoutes` | Builds the initial route stack                        |
| `onUnknownRoute`          | Builds the fallback route                             |
| `navigatorKey`            | Addresses the app's navigator                         |
| `navigatorObservers`      | Observers attached to the navigator                   |
| `pageRouteBuilder`        | Builds page routes (defaults to a widgets-layer fade) |
| `builder`                 | Wraps the navigator for app-wide chrome               |

`pageRouteBuilder` exists because `MaterialPageRoute` is not available to a widgets-only shell. The default route is a `PageRouteBuilder` with a fade; pass your own factory when you want a different transition.

For `Router`-based navigation (GoRouter, auto_route, and friends), use the router constructor. It forwards the same theme, localization, and debugging parameters:

```dart
// Static example: setup
SkribbleApp.router(
  wiredTheme: WiredThemeData(),
  routerConfig: router,
  title: 'My sketchy app',
)
```

`SkribbleApp.router` requires either `routerDelegate` or `routerConfig`, and asserts at construction time when neither is provided.

## Theme

| Parameter                    | Default                    | Purpose                   |
| ---------------------------- | -------------------------- | ------------------------- |
| `wiredTheme`                 | `WiredThemeData()`         | Light theme               |
| `darkWiredTheme`             | `wiredTheme`               | Dark theme                |
| `highContrastWiredTheme`     | `wiredTheme`               | High-contrast light theme |
| `highContrastDarkWiredTheme` | `darkWiredTheme`           | High-contrast dark theme  |
| `themeMode`                  | `SkribbleThemeMode.system` | Which variant to install  |

`themeMode` is a `SkribbleThemeMode` rather than Material's `ThemeMode` because `ThemeMode` lives in `package:flutter/material.dart`. The compatibility layer converts between the two (`SkribbleThemeMode.dark.toThemeMode` and `WiredThemeModeInterop.fromThemeMode`), so a value can move between `SkribbleApp` and `WiredMaterialApp`.

High-contrast variants are selected from the platform accessibility features, and the platform brightness is read through `MediaQuery`, so a system appearance change rebuilds the shell.

## App-level parameters

| Parameter                                                                       | Purpose                                                     |
| ------------------------------------------------------------------------------- | ----------------------------------------------------------- |
| `title` / `onGenerateTitle`                                                     | Application description for the host operating system       |
| `color`                                                                         | Primary color reported to the host (defaults to the border) |
| `locale` / `supportedLocales` / `localizationsDelegates` / locale callbacks     | Localization                                                |
| `shortcuts` / `actions`                                                         | App-level keyboard shortcuts and intents                    |
| `restorationScopeId`                                                            | State-restoration bucket                                    |
| `showPerformanceOverlay`, `showSemanticsDebugger`, `debugShowCheckedModeBanner` | Debugging switches                                          |

`WiredThemeScope` is also public: it is the widgets-only theme boundary behind both `SkribbleApp` and `WiredTheme`, and it is the right tool for a nested theme override that must not touch Material theming.

## Localization

This is the one place where a widgets-only shell cannot fully replace `MaterialApp`.

`WidgetsApp` always installs `DefaultWidgetsLocalizations`, whose `textDirection` is hard-coded to left-to-right, and it has no translated strings. `MaterialApp` plugs that gap by adding `GlobalMaterialLocalizations` from `flutter_localizations`. `SkribbleApp` cannot: depending on `flutter_localizations` would put a localization package on every consumer of a design system, including apps that never localize.

So the shell takes the middle path:

- It appends `SkribbleLocalizationsDelegate`, a widgets-only delegate that provides the English widgets semantics labels and, importantly, a correct right-to-left `textDirection` for Arabic, Hebrew, Persian, Urdu, and the other right-to-left scripts. That is what makes `Directionality.of(context)` correct for a plain app.
- It appends its delegate **after** any delegates you pass. `Localizations` uses the first delegate of each resource type, so `GlobalWidgetsLocalizations.delegate` from your own `localizationsDelegates` list wins whenever you provide it.

When you need translated Material or Cupertino strings, pick one:

```dart
// Static example: setup
SkribbleApp(
  localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ],
  supportedLocales: AppLocalizations.supportedLocales,
  home: MyHomePage(),
)
```

```dart
// Static example: setup
// Or keep MaterialApp and the bridge:
WiredMaterialApp(
  wiredTheme: WiredThemeData(),
  localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ],
  home: MyHomePage(),
)
```

A `SkribbleApp` that hosts Material widgets can also use `WiredMaterialTheme`, which installs `DefaultMaterialLocalizations` (English) when Material localizations are missing, so widgets such as `Scaffold` keep working. See the material bridge page.

## Cupertino

There is deliberately no `SkribbleCupertinoApp`. A Cupertino-flavoured shell would exist to supply three things: `CupertinoThemeData`-driven colors, `CupertinoPageRoute` transitions, and `CupertinoLocalizations`. The first two are covered without a second shell:

- Every Wired Cupertino widget (`WiredCupertinoButton`, `WiredCupertinoSwitch`, and the rest) is a standalone widget that reads `WiredTheme`, not `CupertinoApp`.
- `WiredThemeFromCupertino` adapts an existing Cupertino app's palette for Wired widgets.
- Cupertino apps that want Wired widgets keep `CupertinoApp`; Skribble apps that want Cupertino styling use the Wired Cupertino widgets inside `SkribbleApp`.

Building a parallel app shell for that would duplicate the shell for a smaller ecosystem and invite the parity chase that `WiredMaterialApp` is already retiring from. The compatibility layer covers the theme conversion; the rest is a one-line wrapper.
