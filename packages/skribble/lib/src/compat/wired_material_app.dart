// COMPATIBILITY LAYER -- transitional, sanctioned Material import.
//
// See `wired_theme_interop.dart` and docs/site/content/core/material-bridge.md
// for why this directory is the one place allowed to import Material.

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../skribble_app.dart';
import '../wired_theme.dart';

/// A convenience [MaterialApp] wrapper that keeps Material theming and
/// [WiredTheme] in sync.
///
/// **Transitional bridge.** This widget exists for apps that already depend on
/// Material and are migrating to Skribble incrementally. New Skribble apps
/// should use `SkribbleApp`, which is built on [WidgetsApp] and needs no
/// Material ancestor at all. `WiredMaterialApp` stays because removing it
/// would be a breaking change for existing consumers; its theme resolution is
/// shared with `SkribbleApp`.
///
/// Its job is interop, not parity expansion: it forwards the [MaterialApp]
/// parameters it already had and deliberately does not grow new `MaterialApp`
/// passthroughs. For Material widgets inside a `SkribbleApp`, use
/// `WiredMaterialTheme`; to adapt an existing Material app's palette for Wired
/// widgets, use `WiredThemeFromMaterial`.
class WiredMaterialApp extends HookWidget {
  const WiredMaterialApp({
    super.key,
    required this.wiredTheme,
    this.darkWiredTheme,
    this.highContrastWiredTheme,
    this.highContrastDarkWiredTheme,
    this.themeMode = ThemeMode.system,
    this.title = '',
    this.onGenerateTitle,
    this.onNavigationNotification,
    this.color,
    this.home,
    this.routes = const <String, WidgetBuilder>{},
    this.initialRoute,
    this.onGenerateRoute,
    this.onGenerateInitialRoutes,
    this.onUnknownRoute,
    this.navigatorKey,
    this.navigatorObservers = const <NavigatorObserver>[],
    this.builder,
    this.locale,
    this.localizationsDelegates,
    this.localeListResolutionCallback,
    this.localeResolutionCallback,
    this.supportedLocales = const <Locale>[Locale('en', 'US')],
    this.scaffoldMessengerKey,
    this.scrollBehavior,
    this.restorationScopeId,
    this.shortcuts,
    this.actions,
    this.themeAnimationDuration = kThemeAnimationDuration,
    this.themeAnimationCurve = Curves.linear,
    this.themeAnimationStyle,
    this.debugShowMaterialGrid = false,
    this.showPerformanceOverlay = false,
    this.checkerboardRasterCacheImages = false,
    this.checkerboardOffscreenLayers = false,
    this.showSemanticsDebugger = false,
    this.debugShowCheckedModeBanner = false,
    // Kept for MaterialApp parity; removing it is a breaking change.
    @Deprecated(
      'Remove this parameter as it is now ignored. '
      'MaterialApp never introduces its own MediaQuery; the View widget takes '
      'care of that. This feature was deprecated after v3.7.0-29.0.pre.',
    )
    this.useInheritedMediaQuery = false,
  }) : routeInformationProvider = null,
       routeInformationParser = null,
       routerDelegate = null,
       routerConfig = null,
       backButtonDispatcher = null,
       _useRouter = false;

  const WiredMaterialApp.router({
    super.key,
    required this.wiredTheme,
    this.darkWiredTheme,
    this.highContrastWiredTheme,
    this.highContrastDarkWiredTheme,
    this.themeMode = ThemeMode.system,
    this.title = '',
    this.onGenerateTitle,
    this.onNavigationNotification,
    this.color,
    this.builder,
    this.locale,
    this.localizationsDelegates,
    this.localeListResolutionCallback,
    this.localeResolutionCallback,
    this.supportedLocales = const <Locale>[Locale('en', 'US')],
    this.scaffoldMessengerKey,
    this.scrollBehavior,
    this.restorationScopeId,
    this.shortcuts,
    this.actions,
    this.themeAnimationDuration = kThemeAnimationDuration,
    this.themeAnimationCurve = Curves.linear,
    this.themeAnimationStyle,
    this.debugShowMaterialGrid = false,
    this.showPerformanceOverlay = false,
    this.checkerboardRasterCacheImages = false,
    this.checkerboardOffscreenLayers = false,
    this.showSemanticsDebugger = false,
    this.debugShowCheckedModeBanner = false,
    // Kept for MaterialApp parity; removing it is a breaking change.
    @Deprecated(
      'Remove this parameter as it is now ignored. '
      'MaterialApp never introduces its own MediaQuery; the View widget takes '
      'care of that. This feature was deprecated after v3.7.0-29.0.pre.',
    )
    this.useInheritedMediaQuery = false,
    this.routeInformationProvider,
    this.routeInformationParser,
    this.routerDelegate,
    this.routerConfig,
    this.backButtonDispatcher,
  }) : home = null,
       routes = const <String, WidgetBuilder>{},
       initialRoute = null,
       onGenerateRoute = null,
       onGenerateInitialRoutes = null,
       onUnknownRoute = null,
       navigatorKey = null,
       navigatorObservers = const <NavigatorObserver>[],
       _useRouter = true,
       assert(
         routerDelegate != null || routerConfig != null,
         'Either routerDelegate or routerConfig must be provided.',
       );

  final WiredThemeData wiredTheme;
  final WiredThemeData? darkWiredTheme;
  final WiredThemeData? highContrastWiredTheme;
  final WiredThemeData? highContrastDarkWiredTheme;
  final ThemeMode themeMode;
  final String title;
  final GenerateAppTitle? onGenerateTitle;
  final NotificationListenerCallback<NavigationNotification>?
  onNavigationNotification;
  final Color? color;
  final Widget? home;
  final Map<String, WidgetBuilder> routes;
  final String? initialRoute;
  final RouteFactory? onGenerateRoute;
  final InitialRouteListFactory? onGenerateInitialRoutes;
  final RouteFactory? onUnknownRoute;
  final GlobalKey<NavigatorState>? navigatorKey;
  final List<NavigatorObserver> navigatorObservers;
  final TransitionBuilder? builder;
  final Locale? locale;
  final Iterable<LocalizationsDelegate<dynamic>>? localizationsDelegates;
  final LocaleListResolutionCallback? localeListResolutionCallback;
  final LocaleResolutionCallback? localeResolutionCallback;
  final Iterable<Locale> supportedLocales;
  final GlobalKey<ScaffoldMessengerState>? scaffoldMessengerKey;
  final ScrollBehavior? scrollBehavior;
  final String? restorationScopeId;
  final Map<ShortcutActivator, Intent>? shortcuts;
  final Map<Type, Action<Intent>>? actions;
  final Duration themeAnimationDuration;
  final Curve themeAnimationCurve;
  final AnimationStyle? themeAnimationStyle;
  final bool debugShowMaterialGrid;
  final bool showPerformanceOverlay;
  final bool checkerboardRasterCacheImages;
  final bool checkerboardOffscreenLayers;
  final bool showSemanticsDebugger;
  final bool debugShowCheckedModeBanner;

  // Kept for MaterialApp parity; removing it is a breaking change.
  @Deprecated(
    'Remove this parameter as it is now ignored. '
    'MaterialApp never introduces its own MediaQuery; the View widget takes '
    'care of that. This feature was deprecated after v3.7.0-29.0.pre.',
  )
  final bool useInheritedMediaQuery;

  final RouteInformationProvider? routeInformationProvider;
  final RouteInformationParser<Object>? routeInformationParser;
  final RouterDelegate<Object>? routerDelegate;
  final RouterConfig<Object>? routerConfig;
  final BackButtonDispatcher? backButtonDispatcher;
  final bool _useRouter;

  @override
  Widget build(BuildContext context) {
    final effectiveDarkTheme = darkWiredTheme ?? wiredTheme;
    final effectiveHighContrastTheme = highContrastWiredTheme ?? wiredTheme;
    final effectiveHighContrastDarkTheme =
        highContrastDarkWiredTheme ?? darkWiredTheme ?? wiredTheme;
    final effectiveWiredTheme = resolveWiredAppTheme(
      context: context,
      light: wiredTheme,
      dark: effectiveDarkTheme,
      highContrastLight: effectiveHighContrastTheme,
      highContrastDark: effectiveHighContrastDarkTheme,
      themeMode: switch (themeMode) {
        ThemeMode.light => SkribbleThemeMode.light,
        ThemeMode.dark => SkribbleThemeMode.dark,
        ThemeMode.system => SkribbleThemeMode.system,
      },
    );
    // Each conversion runs ColorScheme.fromSeed and builds a full ThemeData.
    // They only change with their input theme, so keep them across rebuilds.
    final theme = useMemoized(
      wiredTheme.toThemeData,
      <Object?>[wiredTheme],
    );
    final darkTheme = useMemoized(
      () => effectiveDarkTheme.toThemeData(brightness: Brightness.dark),
      <Object?>[effectiveDarkTheme],
    );
    final highContrastTheme = useMemoized(
      effectiveHighContrastTheme.toThemeData,
      <Object?>[effectiveHighContrastTheme],
    );
    final highContrastDarkTheme = useMemoized(
      () => effectiveHighContrastDarkTheme.toThemeData(
        brightness: Brightness.dark,
      ),
      <Object?>[effectiveHighContrastDarkTheme],
    );

    return WiredTheme(
      data: effectiveWiredTheme,
      child: _useRouter
          ? MaterialApp.router(
              title: title,
              onGenerateTitle: onGenerateTitle,
              onNavigationNotification: onNavigationNotification,
              color: color,
              theme: theme,
              darkTheme: darkTheme,
              highContrastTheme: highContrastTheme,
              highContrastDarkTheme: highContrastDarkTheme,
              themeMode: themeMode,
              themeAnimationDuration: themeAnimationDuration,
              themeAnimationCurve: themeAnimationCurve,
              themeAnimationStyle: themeAnimationStyle,
              routeInformationProvider: routeInformationProvider,
              routeInformationParser: routeInformationParser,
              routerDelegate: routerDelegate,
              routerConfig: routerConfig,
              backButtonDispatcher: backButtonDispatcher,
              builder: builder,
              locale: locale,
              localizationsDelegates: localizationsDelegates,
              localeListResolutionCallback: localeListResolutionCallback,
              localeResolutionCallback: localeResolutionCallback,
              supportedLocales: supportedLocales,
              scaffoldMessengerKey: scaffoldMessengerKey,
              scrollBehavior: scrollBehavior,
              restorationScopeId: restorationScopeId,
              shortcuts: shortcuts,
              actions: actions,
              debugShowMaterialGrid: debugShowMaterialGrid,
              showPerformanceOverlay: showPerformanceOverlay,
              checkerboardRasterCacheImages: checkerboardRasterCacheImages,
              checkerboardOffscreenLayers: checkerboardOffscreenLayers,
              showSemanticsDebugger: showSemanticsDebugger,
              debugShowCheckedModeBanner: debugShowCheckedModeBanner,
              // ignore: deprecated_member_use_from_same_package
              useInheritedMediaQuery: useInheritedMediaQuery,
            )
          : MaterialApp(
              title: title,
              onGenerateTitle: onGenerateTitle,
              onNavigationNotification: onNavigationNotification,
              color: color,
              theme: theme,
              darkTheme: darkTheme,
              highContrastTheme: highContrastTheme,
              highContrastDarkTheme: highContrastDarkTheme,
              themeMode: themeMode,
              themeAnimationDuration: themeAnimationDuration,
              themeAnimationCurve: themeAnimationCurve,
              themeAnimationStyle: themeAnimationStyle,
              home: home,
              routes: routes,
              initialRoute: initialRoute,
              onGenerateRoute: onGenerateRoute,
              onGenerateInitialRoutes: onGenerateInitialRoutes,
              onUnknownRoute: onUnknownRoute,
              navigatorKey: navigatorKey,
              navigatorObservers: navigatorObservers,
              builder: builder,
              locale: locale,
              localizationsDelegates: localizationsDelegates,
              localeListResolutionCallback: localeListResolutionCallback,
              localeResolutionCallback: localeResolutionCallback,
              supportedLocales: supportedLocales,
              scaffoldMessengerKey: scaffoldMessengerKey,
              scrollBehavior: scrollBehavior,
              restorationScopeId: restorationScopeId,
              shortcuts: shortcuts,
              actions: actions,
              debugShowMaterialGrid: debugShowMaterialGrid,
              showPerformanceOverlay: showPerformanceOverlay,
              checkerboardRasterCacheImages: checkerboardRasterCacheImages,
              checkerboardOffscreenLayers: checkerboardOffscreenLayers,
              showSemanticsDebugger: showSemanticsDebugger,
              debugShowCheckedModeBanner: debugShowCheckedModeBanner,
              // ignore: deprecated_member_use_from_same_package
              useInheritedMediaQuery: useInheritedMediaQuery,
            ),
    );
  }
}
