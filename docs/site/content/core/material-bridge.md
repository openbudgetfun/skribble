---
title: Material Bridge
description: The quarantined compatibility layer for Material and Cupertino interop -- convert themes both ways, mix Material and Wired widgets, and migrate a real app one screen at a time.
---

# Material Bridge

The Material bridge is a **transitional compatibility layer**. Its job is to let an existing Flutter app adopt skribble incrementally — a button here, a card there — without rewriting its app shell first. It is not skribble's intended architecture, and the documentation used to present it as "skribble sitting alongside Material". It is not.

Read [Architecture](/core/architecture) first for what skribble is: a standalone design system, a peer of `package:material_ui` and `package:cupertino_ui`. This page documents how to interoperate with Material **during migration**, and how to leave the bridge behind.

## Where this sits in the architecture

- **Today**, `WiredMaterialApp` is how most consumers run skribble: existing apps get Wired theming without replacing `MaterialApp`.
- **The shell** shipped as `SkribbleApp`, built on `WidgetsApp`; `WiredMaterialApp` remains as a thin compatibility bridge for apps that still need Material in the tree.
- **The compatibility promise**: `WiredMaterialApp`, `WiredTheme`, and `WiredThemeData.toThemeData()` keep their documented behavior and are not deprecated today. Removal is a breaking change with a changeset, changelog entry, and migration guide — never a side effect of a rewrite.

The bridge exists to make incremental adoption possible. Material supplies the shell and the `Navigator` plumbing during migration, and the token synchronization below keeps the Material widgets you have not replaced yet visually aligned. The Wired widgets' painting, engine, and theme scope do not require Material to function; the Material-facing conversions (`toThemeData()`, `toColorScheme()`) exist solely for this bridge.

Compatibility is not a compromise of that goal; it is an explicit, quarantined layer. Everything that needs Material or Cupertino lives in `lib/src/compat/`, is exported from `package:skribble/skribble.dart` as a clearly-labelled trailing group, and says so in every file header. The core never depends on it, and it does not grow Material parity. That keeps two promises at once: a pure library core, and an easy on-ramp for apps that already use Material or Cupertino.

## Coexistence

Four directions, each a small step rather than a rewrite:

| Situation                                  | Use                                              |
| ------------------------------------------ | ------------------------------------------------ |
| Wired widgets in a Skribble app            | Nothing — `SkribbleApp` installs the Wired theme |
| Wired widgets in an existing Material app  | `WiredThemeFromMaterial`                         |
| Wired widgets in an existing Cupertino app | `WiredThemeFromCupertino`                        |
| Material widgets in a Skribble app         | `WiredMaterialTheme`                             |

`Wired*` widgets already work under a plain `MaterialApp` without a `WiredTheme` ancestor: they fall back to `WiredThemeData.defaultTheme`, so a dropped-in button renders a consistent Skribble look instead of crashing. Wrap a subtree in `WiredThemeFromMaterial` when those widgets should inherit the host app's colors instead.

```dart
// Static example: setup
MaterialApp(
  theme: myTheme,
  home: WiredThemeFromMaterial(
    child: WiredScaffold(
      appBar: WiredAppBar(title: Text('Migrated screen')),
      body: WiredButton(onPressed: () {}, child: Text('Save')),
    ),
  ),
)
```

The opposite direction matters just as much: a `SkribbleApp` has no `MaterialApp` ancestor, so Material widgets — your own or a third-party package's — would otherwise fall back to `ThemeData.fallback()` and, for widgets such as `Scaffold`, fail their localization assertions. `WiredMaterialTheme` installs a Material `Theme` built from the active Wired tokens plus `DefaultMaterialLocalizations` when none are present:

```dart
// Static example: setup
SkribbleApp(
  builder: (context, child) => WiredMaterialTheme(child: child!),
  home: MyMaterialScreen(),
)
```

## Theme interop

Conversion works in both directions and reuses the conversions that already existed on `WiredThemeData` (`toThemeData`, `toColorScheme`) instead of re-implementing them.

From Material or Cupertino into Skribble:

```dart
// Static example: api
final fromMaterial = WiredThemeInterop.fromThemeData(Theme.of(context));
final fromScheme = WiredThemeInterop.fromColorScheme(colorScheme);
final fromCupertino = WiredThemeInterop.fromCupertinoTheme(CupertinoTheme.of(context));
```

`fromThemeData` maps `colorScheme.primary` to `borderColor`, `onSurface` to `textColor`, `surface` to `fillColor`, `ThemeData.disabledColor` to `disabledTextColor`, the first non-zero border width in the card/dialog/sheet/input/divider shape language to `strokeWidth`, and `textTheme.bodyMedium` to `fontFamily`. Roughness and motion are not expressible in `ThemeData`, so they keep the Skribble defaults and can be overridden with `copyWith`.

Back out to Cupertino:

```dart
// Static example: api
final cupertino = WiredThemeData().toCupertinoThemeData();
final themeMode = SkribbleThemeMode.dark.toThemeMode;
```

## Migration path

The layer exists so a real app can move without a big-bang rewrite:

1. **Adopt the palette.** Wrap one screen in `WiredThemeFromMaterial` (or `WiredThemeFromCupertino`) so Wired widgets on it match the host app.
2. **Replace widgets screen by screen.** Swap Material widgets for their `Wired*` equivalents. The names match where it is cheap to match — `onPressed`, `enabled` disabled states, `semanticLabel` — and the widget catalog notes the deliberate deviations.
3. **Keep Material where it earns its place.** When a screen needs Material widgets inside a Skribble app, wrap it in `WiredMaterialTheme` rather than reaching for `MaterialApp`.
4. **Move the root.** Replace `WiredMaterialApp` with `SkribbleApp` (or `SkribbleApp.router`), which takes the same `wiredTheme`, `darkWiredTheme`, `themeMode`, navigation, and localization parameters. `SkribbleThemeMode` converts to and from Material's `ThemeMode`.
5. **Drop Material when you are ready.** Once no screen needs a Material ancestor, remove the `WiredMaterialTheme` wrappers. The `docs/material-dependency-audit.txt` report tracks how much of the library itself still has to follow.

## WiredMaterialApp (transitional bridge)

**`WiredMaterialApp` is transitional.** It stays for apps that must keep `MaterialApp` while they migrate, and its public API does not change. New Skribble apps should use `SkribbleApp`, which is built on `WidgetsApp` and needs no Material ancestor. `WiredMaterialApp` now shares its theme resolution with `SkribbleApp` and lives in `lib/src/compat/wired_material_app.dart`.

`WiredMaterialApp` is a `HookWidget` that wraps `MaterialApp` with a `WiredTheme` ancestor. It accepts a `WiredThemeData`, converts it into Material `ThemeData` via `toThemeData()`, and passes both into the widget tree. Its job is interop, not parity: it forwards the `MaterialApp` parameters it already had and does not grow new passthroughs.

### Standard Constructor

Use the standard constructor for apps with `Navigator`-based routing:

```dart
// Static example: setup
WiredMaterialApp(
  wiredTheme: WiredThemeData(
    borderColor: Color(0xFF1A2B3C),
    fillColor: Color(0xFFFEFEFE),
  ),
  title: 'My skribble App',
  home: MyHomePage(),
)
```

### Router Constructor

Use `WiredMaterialApp.router()` for apps using `Router`-based navigation (GoRouter, auto_route, etc.):

```dart
// Static example: setup
WiredMaterialApp.router(
  wiredTheme: WiredThemeData(),
  routerConfig: goRouter,
  title: 'My skribble App',
)
```

The `.router()` constructor requires either `routerDelegate` or `routerConfig` -- the widget asserts at construction time if neither is provided.

## Parameters

`WiredMaterialApp` supports nearly every `MaterialApp` parameter. Here is the full list, grouped by category:

### Wired Theme Parameters

| Parameter                    | Type              | Default            | Description                                                                 |
| ---------------------------- | ----------------- | ------------------ | --------------------------------------------------------------------------- |
| `wiredTheme`                 | `WiredThemeData`  | required           | Primary (light) Wired theme                                                 |
| `darkWiredTheme`             | `WiredThemeData?` | `null`             | Dark mode Wired theme; falls back to `wiredTheme`                           |
| `highContrastWiredTheme`     | `WiredThemeData?` | `null`             | High-contrast light theme; falls back to `wiredTheme`                       |
| `highContrastDarkWiredTheme` | `WiredThemeData?` | `null`             | High-contrast dark theme; falls back to `darkWiredTheme`, then `wiredTheme` |
| `themeMode`                  | `ThemeMode`       | `ThemeMode.system` | Which theme variant to use                                                  |

### Navigation Parameters (Standard Constructor Only)

| Parameter                 | Type                         | Default |
| ------------------------- | ---------------------------- | ------- |
| `home`                    | `Widget?`                    | `null`  |
| `routes`                  | `Map<String, WidgetBuilder>` | `{}`    |
| `initialRoute`            | `String?`                    | `null`  |
| `onGenerateRoute`         | `RouteFactory?`              | `null`  |
| `onGenerateInitialRoutes` | `InitialRouteListFactory?`   | `null`  |
| `onUnknownRoute`          | `RouteFactory?`              | `null`  |
| `navigatorKey`            | `GlobalKey<NavigatorState>?` | `null`  |
| `navigatorObservers`      | `List<NavigatorObserver>`    | `[]`    |

### Navigation Parameters (Router Constructor Only)

| Parameter                  | Type                              | Default |
| -------------------------- | --------------------------------- | ------- |
| `routeInformationProvider` | `RouteInformationProvider?`       | `null`  |
| `routeInformationParser`   | `RouteInformationParser<Object>?` | `null`  |
| `routerDelegate`           | `RouterDelegate<Object>?`         | `null`  |
| `routerConfig`             | `RouterConfig<Object>?`           | `null`  |
| `backButtonDispatcher`     | `BackButtonDispatcher?`           | `null`  |

### App-Level Parameters (Both Constructors)

| Parameter                      | Type                                                    | Default                   |
| ------------------------------ | ------------------------------------------------------- | ------------------------- |
| `title`                        | `String`                                                | `''`                      |
| `onGenerateTitle`              | `GenerateAppTitle?`                                     | `null`                    |
| `onNavigationNotification`     | `NotificationListenerCallback<NavigationNotification>?` | `null`                    |
| `color`                        | `Color?`                                                | `null`                    |
| `builder`                      | `TransitionBuilder?`                                    | `null`                    |
| `locale`                       | `Locale?`                                               | `null`                    |
| `localizationsDelegates`       | `Iterable<LocalizationsDelegate>?`                      | `null`                    |
| `localeListResolutionCallback` | `LocaleListResolutionCallback?`                         | `null`                    |
| `localeResolutionCallback`     | `LocaleResolutionCallback?`                             | `null`                    |
| `supportedLocales`             | `Iterable<Locale>`                                      | `[Locale('en', 'US')]`    |
| `scaffoldMessengerKey`         | `GlobalKey<ScaffoldMessengerState>?`                    | `null`                    |
| `scrollBehavior`               | `ScrollBehavior?`                                       | `null`                    |
| `restorationScopeId`           | `String?`                                               | `null`                    |
| `shortcuts`                    | `Map<ShortcutActivator, Intent>?`                       | `null`                    |
| `actions`                      | `Map<Type, Action<Intent>>?`                            | `null`                    |
| `themeAnimationDuration`       | `Duration`                                              | `kThemeAnimationDuration` |
| `themeAnimationCurve`          | `Curve`                                                 | `Curves.linear`           |
| `themeAnimationStyle`          | `AnimationStyle?`                                       | `null`                    |

### Debug Parameters (Both Constructors)

| Parameter                       | Type   | Default |
| ------------------------------- | ------ | ------- |
| `debugShowMaterialGrid`         | `bool` | `false` |
| `showPerformanceOverlay`        | `bool` | `false` |
| `checkerboardRasterCacheImages` | `bool` | `false` |
| `checkerboardOffscreenLayers`   | `bool` | `false` |
| `showSemanticsDebugger`         | `bool` | `false` |
| `debugShowCheckedModeBanner`    | `bool` | `false` |

## How WiredThemeData Converts to Material ThemeData

This mapping exists so that standard Material widgets still in your tree (a `Scaffold` you have not replaced yet, a `Dialog`, a tooltip) do not clash with the Wired palette. It is synchronization for migration, not skribble's theming system.

When `WiredMaterialApp` builds, it calls `wiredTheme.toThemeData()` to generate a Material `ThemeData`. This happens for each theme variant:

```dart
// Static example: api
final theme = wiredTheme.toThemeData();
final darkTheme = effectiveDarkTheme.toThemeData(brightness: Brightness.dark);
final highContrastTheme = effectiveHighContrastTheme.toThemeData();
final highContrastDarkTheme = effectiveHighContrastDarkTheme.toThemeData(
  brightness: Brightness.dark,
);
```

These are passed directly to `MaterialApp`'s `theme`, `darkTheme`, `highContrastTheme`, and `highContrastDarkTheme` parameters.

## ColorScheme Generation

`WiredThemeData.toColorScheme()` builds a `ColorScheme` from `ColorScheme.fromSeed` using `borderColor` as the seed, then overrides specific slots:

```dart
// Static example: api
ColorScheme toColorScheme({Brightness brightness = Brightness.light}) {
  final base = ColorScheme.fromSeed(
    seedColor: borderColor,
    brightness: brightness,
    surface: fillColor,
  );
  return base.copyWith(
    primary: borderColor,
    onPrimary: _bestContrastingColor(borderColor),
    secondary: textColor,
    onSecondary: _bestContrastingColor(textColor),
    surface: fillColor,
    onSurface: textColor,
    outline: borderColor.withValues(alpha: 0.7),
    surfaceTint: borderColor,
    shadow: borderColor.withValues(alpha: 0.12),
  );
}
```

The `_bestContrastingColor` helper picks white or black based on the luminance of the input color:

```dart
// Static example: api
Color _bestContrastingColor(Color color) {
  return ThemeData.estimateBrightnessForColor(color) == Brightness.dark
      ? Colors.white
      : Colors.black;
}
```

## Theme Component Mapping

`toThemeData()` configures Material component themes to blend with the skribble look. All elevations are set to zero and surface tints are transparent, removing Material 3's default tinted surfaces.

### AppBar

```dart
// Static example: configuration
AppBarTheme(
  backgroundColor: paperBackgroundColor,
  foregroundColor: textColor,
  elevation: 0,
  shadowColor: Colors.transparent,
  surfaceTintColor: Colors.transparent,
)
```

### Card

```dart
// Static example: configuration
CardThemeData(
  color: fillColor,
  elevation: 0,
  surfaceTintColor: Colors.transparent,
  margin: EdgeInsets.zero,
)
```

### Dialog

```dart
// Static example: configuration
DialogThemeData(
  backgroundColor: fillColor,
  surfaceTintColor: Colors.transparent,
  elevation: 0,
)
```

### BottomSheet

```dart
// Static example: configuration
BottomSheetThemeData(
  backgroundColor: fillColor,
  surfaceTintColor: Colors.transparent,
  elevation: 0,
)
```

### SnackBar

```dart
// Static example: configuration
SnackBarThemeData(
  backgroundColor: fillColor,
  contentTextStyle: TextStyle(color: textColor),
  actionTextColor: borderColor,
)
```

### InputDecoration

```dart
// Static example: configuration
InputDecorationTheme(
  filled: true,
  fillColor: fillColor,
  border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(16),
    borderSide: BorderSide(color: borderColor, width: strokeWidth),
  ),
  enabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(16),
    borderSide: BorderSide(color: borderColor, width: strokeWidth),
  ),
  focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(16),
    borderSide: BorderSide(color: borderColor, width: strokeWidth + 0.5),
  ),
)
```

### Divider

```dart
// Static example: configuration
DividerThemeData(
  color: borderColor.withValues(alpha: 0.35),
  thickness: 1,
)
```

### Text, Icons, and Scaffold

```dart
// Static example: configuration
scaffoldBackgroundColor: paperBackgroundColor,
canvasColor: fillColor,
dividerColor: borderColor.withValues(alpha: 0.35),
textTheme: baseTextTheme.apply(
  bodyColor: textColor,
  displayColor: textColor,
),
iconTheme: IconThemeData(color: textColor),
primaryIconTheme: IconThemeData(color: colorScheme.onPrimary),
```

## Theme Resolution Logic

Both `WiredMaterialApp` and `SkribbleApp` resolve which `WiredThemeData` to inject based on the theme mode and the platform's high-contrast accessibility setting. The logic is shared in `resolveWiredAppTheme`; `WiredMaterialApp` maps Material's `ThemeMode` onto `SkribbleThemeMode` first:

```dart
// Static example: api
WiredThemeData _resolveWiredTheme({...}) {
  final isHighContrast = platformDispatcher
      .accessibilityFeatures.highContrast;

  switch (themeMode) {
    case ThemeMode.light:
      return isHighContrast ? effectiveHighContrastTheme : wiredTheme;
    case ThemeMode.dark:
      return isHighContrast
          ? effectiveHighContrastDarkTheme
          : effectiveDarkTheme;
    case ThemeMode.system:
      final isDark = platformDispatcher.platformBrightness == Brightness.dark;
      if (isDark) {
        return isHighContrast
            ? effectiveHighContrastDarkTheme
            : effectiveDarkTheme;
      }
      return isHighContrast ? effectiveHighContrastTheme : wiredTheme;
  }
}
```

Fallback chain:

- `darkWiredTheme` defaults to `wiredTheme`
- `highContrastWiredTheme` defaults to `wiredTheme`
- `highContrastDarkWiredTheme` defaults to `darkWiredTheme`, then `wiredTheme`

## Migrating from a Material app to a skribble shell

You do not have to swap the whole shell at once. Work downward through the tree:

1. **Adopt Wired widgets inside your existing `MaterialApp`.** Place a `WiredTheme` ancestor (or `WiredMaterialApp` if you are ready to change the root) and start replacing leaf widgets: buttons, inputs, checkboxes, cards.
2. **Replace containers and navigation.** Move `Scaffold` → `WiredScaffold`, `AppBar` → `WiredAppBar`, tabs and bottom navigation to their `Wired` counterparts. At this point Material is mostly gone from your own widget code.
3. **Replace the shell when the skribble shell ships.** Swap `WiredMaterialApp` for the skribble-owned app shell and remove `MaterialApp` from the tree. If you still need Material widgets after that, keep `WiredMaterialApp` as the compatibility wrapper — it is supported for the whole migration.
4. **Keep Material out of new code.** New screens should not add `import 'package:flutter/material.dart'`. If a Wired widget is missing, record the gap rather than reaching for the Material original (see [Architecture decision D3](/core/architecture#d3--no-new-material-or-cupertino-imports)).

## Using with GoRouter

```dart
// Static example: setup
import 'package:go_router/go_router.dart';
import 'package:skribble/skribble.dart';

final router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => HomeScreen(),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => SettingsScreen(),
    ),
  ],
);

class MyApp extends HookWidget {
  @override
  Widget build(BuildContext context) {
    return WiredMaterialApp.router(
      wiredTheme: WiredThemeData(
        borderColor: Color(0xFF2D3436),
        fillColor: Color(0xFFF5F0E1),
      ),
      routerConfig: router,
      title: 'skribble + GoRouter',
    );
  }
}
```

## Using with auto_route

```dart
// Static example: api
import 'package:auto_route/auto_route.dart';
import 'package:skribble/skribble.dart';

@AutoRouterConfig()
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
    AutoRoute(page: HomeRoute.page, initial: true),
    AutoRoute(page: SettingsRoute.page),
  ];
}

class MyApp extends HookWidget {
  final _router = AppRouter();

  @override
  Widget build(BuildContext context) {
    return WiredMaterialApp.router(
      wiredTheme: WiredThemeData(),
      routerConfig: _router.config(),
      title: 'skribble + AutoRoute',
    );
  }
}
```

## Using with routerDelegate Directly

If your router library provides a delegate and parser separately:

```dart
// Static example: setup
WiredMaterialApp.router(
  wiredTheme: WiredThemeData(),
  routeInformationParser: MyRouteParser(),
  routerDelegate: MyRouterDelegate(),
  backButtonDispatcher: RootBackButtonDispatcher(),
)
```

## Complete Example: Dark Mode with GoRouter

```dart
// Static example: setup
class MyApp extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final themeMode = useState(ThemeMode.system);

    return WiredMaterialApp.router(
      wiredTheme: WiredThemeData(
        borderColor: Color(0xFF1A2B3C),
        fillColor: Color(0xFFFEFEFE),
        textColor: Colors.black,
      ),
      darkWiredTheme: WiredThemeData(
        borderColor: Color(0xFFB0BEC5),
        fillColor: Color(0xFF263238),
        textColor: Color(0xFFECEFF1),
      ),
      themeMode: themeMode.value,
      routerConfig: router,
      title: 'Full Example',
    );
  }
}
```

## Cupertino Bridge

skribble provides Cupertino-style widgets that render with the hand-drawn aesthetic. These are standalone widgets (not wrappers around `CupertinoApp`) that work inside any `WiredTheme` scope, including one provided by `WiredMaterialApp`.

### Available Cupertino Widgets

| Widget                            | Cupertino Equivalent         |
| --------------------------------- | ---------------------------- |
| `WiredCupertinoButton`            | `CupertinoButton`            |
| `WiredCupertinoNavigationBar`     | `CupertinoNavigationBar`     |
| `WiredCupertinoTextField`         | `CupertinoTextField`         |
| `WiredCupertinoSearchTextField`   | `CupertinoSearchTextField`   |
| `WiredCupertinoSwitch`            | `CupertinoSwitch`            |
| `WiredCupertinoSlider`            | `CupertinoSlider`            |
| `WiredCupertinoTabBar`            | `CupertinoTabBar`            |
| `WiredCupertinoDatePicker`        | `CupertinoDatePicker`        |
| `WiredCupertinoPicker`            | `CupertinoPicker`            |
| `WiredCupertinoTimerPicker`       | `CupertinoTimerPicker`       |
| `WiredCupertinoActionSheet`       | `CupertinoActionSheet`       |
| `WiredCupertinoAlertDialog`       | `CupertinoAlertDialog`       |
| `WiredCupertinoSegmentedControl`  | `CupertinoSegmentedControl`  |
| `WiredCupertinoScaffold`          | `CupertinoPageScaffold`      |
| `WiredCupertinoActivityIndicator` | `CupertinoActivityIndicator` |
| `WiredCupertinoListSection`       | `CupertinoListSection`       |
| `WiredCupertinoListTile`          | `CupertinoListTile`          |
| `WiredCupertinoFormSection`       | `CupertinoFormSection`       |

### Usage

Cupertino widgets read from `WiredTheme.of(context)` just like their Material counterparts:

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

Example:

```dart
// Static example: setup
WiredTheme(
  data: WiredThemeData(),
  child: WiredCupertinoScaffold(
    navigationBar: WiredCupertinoNavigationBar(
      middle: Text('Cupertino Style'),
    ),
    child: Center(
      child: WiredCupertinoButton(
        onPressed: () {},
        child: Text('Tap Me'),
      ),
    ),
  ),
)
```

### Mixing Material and Cupertino

You can freely mix Material and Cupertino Wired widgets in the same tree. They all read from the same `WiredTheme`:

```dart
// Static example: setup
WiredMaterialApp(
  wiredTheme: WiredThemeData(),
  home: WiredScaffold(
    appBar: WiredAppBar(title: Text('Mixed')),
    body: Column(
      children: [
        WiredButton(
          onPressed: () {},
          child: Text('Material Button'),
        ),
        WiredCupertinoButton(
          onPressed: () {},
          child: Text('Cupertino Button'),
        ),
        WiredCupertinoSwitch(
          value: true,
          onChanged: (v) {},
        ),
      ],
    ),
  ),
)
```

Both sets of widgets produce the same hand-drawn aesthetic -- wobbly borders, hachure fills, and sketchy strokes -- regardless of whether the underlying API follows Material or Cupertino conventions.

## Compatibility widgets and converters

| Export                    | Purpose                                                                          |
| ------------------------- | -------------------------------------------------------------------------------- |
| `SkribbleApp` / `.router` | Widgets-based app shell (no Material ancestor)                                   |
| `WiredMaterialApp`        | Transitional `MaterialApp` bridge with synchronized Wired theming                |
| `WiredMaterialTheme`      | Material `Theme` + localizations for Material widgets inside a Skribble app      |
| `WiredThemeFromMaterial`  | Wired tokens derived from an ambient Material theme                              |
| `WiredThemeFromCupertino` | Wired tokens derived from an ambient Cupertino theme                             |
| `WiredThemeInterop`       | `fromThemeData`, `fromColorScheme`, `fromCupertinoTheme`, `toCupertinoThemeData` |
| `WiredThemeModeInterop`   | `SkribbleThemeMode` ⇄ Material `ThemeMode`                                       |

`WiredThemeScope` is the widgets-only theme boundary behind both `SkribbleApp` and `WiredTheme`. `WiredTheme.of(context)` finds either, so widget code does not need to know which one is installed.
