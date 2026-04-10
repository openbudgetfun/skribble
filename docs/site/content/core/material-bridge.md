---
title: Material Bridge
description: How WiredMaterialApp synchronizes Skribble theming with Material, including router configuration, ColorScheme generation, component mapping, and Cupertino bridge widgets.
---

# Material Bridge

Skribble is not a Material replacement -- it sits alongside Material. `WiredMaterialApp` bridges the two systems, ensuring that the Wired theme and Material `ThemeData` stay synchronized. Standard Material widgets (like `Scaffold`, `AppBar`, `Dialog`) automatically inherit colors from the active `WiredThemeData`.

## WiredMaterialApp

`WiredMaterialApp` is a `HookWidget` that wraps `MaterialApp` with a `WiredTheme` ancestor. It accepts a `WiredThemeData`, converts it into Material `ThemeData` via `toThemeData()`, and passes both into the widget tree.

### Standard Constructor

Use the standard constructor for apps with `Navigator`-based routing:

```dart
WiredMaterialApp(
  wiredTheme: WiredThemeData(
    borderColor: Color(0xFF1A2B3C),
    fillColor: Color(0xFFFEFEFE),
  ),
  title: 'My Skribble App',
  home: MyHomePage(),
)
```

### Router Constructor

Use `WiredMaterialApp.router()` for apps using `Router`-based navigation (GoRouter, auto_route, etc.):

```dart
WiredMaterialApp.router(
  wiredTheme: WiredThemeData(),
  routerConfig: goRouter,
  title: 'My Skribble App',
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

When `WiredMaterialApp` builds, it calls `wiredTheme.toThemeData()` to generate a Material `ThemeData`. This happens for each theme variant:

```dart
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
Color _bestContrastingColor(Color color) {
  return ThemeData.estimateBrightnessForColor(color) == Brightness.dark
      ? Colors.white
      : Colors.black;
}
```

## Theme Component Mapping

`toThemeData()` configures Material component themes to blend with the Skribble look. All elevations are set to zero and surface tints are transparent, removing Material 3's default tinted surfaces.

### AppBar

```dart
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
CardThemeData(
  color: fillColor,
  elevation: 0,
  surfaceTintColor: Colors.transparent,
  margin: EdgeInsets.zero,
)
```

### Dialog

```dart
DialogThemeData(
  backgroundColor: fillColor,
  surfaceTintColor: Colors.transparent,
  elevation: 0,
)
```

### BottomSheet

```dart
BottomSheetThemeData(
  backgroundColor: fillColor,
  surfaceTintColor: Colors.transparent,
  elevation: 0,
)
```

### SnackBar

```dart
SnackBarThemeData(
  backgroundColor: fillColor,
  contentTextStyle: TextStyle(color: textColor),
  actionTextColor: borderColor,
)
```

### InputDecoration

```dart
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
DividerThemeData(
  color: borderColor.withValues(alpha: 0.35),
  thickness: 1,
)
```

### Text, Icons, and Scaffold

```dart
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

`WiredMaterialApp` resolves which `WiredThemeData` to inject into the `WiredTheme` ancestor based on `themeMode` and the platform's high-contrast accessibility setting:

```dart
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

## Using with GoRouter

```dart
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
      title: 'Skribble + GoRouter',
    );
  }
}
```

## Using with auto_route

```dart
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
      title: 'Skribble + AutoRoute',
    );
  }
}
```

## Using with routerDelegate Directly

If your router library provides a delegate and parser separately:

```dart
WiredMaterialApp.router(
  wiredTheme: WiredThemeData(),
  routeInformationParser: MyRouteParser(),
  routerDelegate: MyRouterDelegate(),
  backButtonDispatcher: RootBackButtonDispatcher(),
)
```

## Complete Example: Dark Mode with GoRouter

```dart
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

Skribble provides Cupertino-style widgets that render with the hand-drawn aesthetic. These are standalone widgets (not wrappers around `CupertinoApp`) that work inside any `WiredMaterialApp`.

### Available Cupertino Widgets

| Widget                           | Material Equivalent         |
| -------------------------------- | --------------------------- |
| `WiredCupertinoButton`           | `CupertinoButton`           |
| `WiredCupertinoNavigationBar`    | `CupertinoNavigationBar`    |
| `WiredCupertinoTextField`        | `CupertinoTextField`        |
| `WiredCupertinoSwitch`           | `CupertinoSwitch`           |
| `WiredCupertinoSlider`           | `CupertinoSlider`           |
| `WiredCupertinoTabBar`           | `CupertinoTabBar`           |
| `WiredCupertinoDatePicker`       | `CupertinoDatePicker`       |
| `WiredCupertinoPicker`           | `CupertinoPicker`           |
| `WiredCupertinoActionSheet`      | `CupertinoActionSheet`      |
| `WiredCupertinoAlertDialog`      | `CupertinoAlertDialog`      |
| `WiredCupertinoSegmentedControl` | `CupertinoSegmentedControl` |
| `WiredCupertinoScaffold`         | `CupertinoPageScaffold`     |

### Usage

Cupertino widgets read from `WiredTheme.of(context)` just like their Material counterparts:

<!-- {=docsThemeReadPattern} -->

```dart
final theme = WiredTheme.of(context);
// Use theme.borderColor, theme.fillColor, theme.textColor, etc.
```

<!-- {/docsThemeReadPattern} -->

Example:

```dart
WiredMaterialApp(
  wiredTheme: WiredThemeData(),
  home: WiredCupertinoScaffold(
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
