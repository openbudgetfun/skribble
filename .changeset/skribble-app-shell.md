---
skribble: minor
---

# Add `SkribbleApp`, a widgets-based app shell

`SkribbleApp` (and `SkribbleApp.router`) is a new application shell built on Flutter's widgets-layer `WidgetsApp` instead of `MaterialApp`. A Skribble app no longer needs a Material ancestor to run, and the shell installs the Skribble theme by default so `WiredTheme.of(context)` works inside it.

The shell exposes the app-level capability a real app needs using Flutter's own widgets-layer types: `home`, `routes`, `initialRoute`, `onGenerateRoute`, `onGenerateInitialRoutes`, `onUnknownRoute`, `navigatorKey`, `navigatorObservers`, `routerConfig` and the other `Router` hooks, `title`, `onGenerateTitle`, `color`, `builder`, `locale`, `localizationsDelegates`, `supportedLocales`, locale resolution callbacks, `shortcuts`, `actions`, `restorationScopeId`, `pageRouteBuilder`, and the debug switches. `themeMode` uses the new `SkribbleThemeMode` because `ThemeMode` lives in Material; the compatibility layer converts between them.

Two supporting additions:

- `WiredThemeScope` is the Material-free theme boundary behind `WiredTheme`. `WiredTheme.of(context)` now finds either boundary, and `WiredTheme` builds on the scope. Existing behaviour is unchanged.
- `SkribbleLocalizations` and `SkribbleLocalizationsDelegate` provide a widgets-only default localization delegate with correct right-to-left text direction. The shell appends it after any callers' delegates, so apps that pass `flutter_localizations` delegates keep full per-locale strings; the core still does not depend on `flutter_localizations`.

`WiredMaterialApp` remains available with an unchanged public API and is now documented as the transitional Material bridge. It shares the new theme-resolution code path and moved to `lib/src/compat/wired_material_app.dart` (the export from `package:skribble/skribble.dart` is unchanged).
