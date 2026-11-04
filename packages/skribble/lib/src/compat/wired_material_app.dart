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
  /// Creates a [MaterialApp] that uses a [Navigator] and keeps [WiredTheme]
  /// in sync with the Material theme.
  ///
  /// See [MaterialApp.new].
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

  /// Creates a [MaterialApp] that uses a [Router] and keeps [WiredTheme] in
  /// sync with the Material theme.
  ///
  /// Either [routerDelegate] or [routerConfig] must be provided.
  ///
  /// See [MaterialApp.router].
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

  /// The light (primary) skribble theme.
  ///
  /// It is also converted to the Material [MaterialApp.theme].
  final WiredThemeData wiredTheme;

  /// The dark skribble theme. Falls back to [wiredTheme].
  ///
  /// It is also converted to the Material [MaterialApp.darkTheme].
  final WiredThemeData? darkWiredTheme;

  /// The high-contrast light skribble theme. Falls back to [wiredTheme].
  ///
  /// It is also converted to the Material [MaterialApp.highContrastTheme].
  final WiredThemeData? highContrastWiredTheme;

  /// The high-contrast dark skribble theme. Falls back through
  /// [darkWiredTheme], then [wiredTheme].
  ///
  /// It is also converted to the Material
  /// [MaterialApp.highContrastDarkTheme].
  final WiredThemeData? highContrastDarkWiredTheme;

  /// Which theme to use. Defaults to [ThemeMode.system].
  ///
  /// It picks both the skribble theme and the Material theme.
  /// See [MaterialApp.themeMode].
  final ThemeMode themeMode;

  /// See [MaterialApp.title].
  final String title;

  /// See [MaterialApp.onGenerateTitle].
  final GenerateAppTitle? onGenerateTitle;

  /// See [MaterialApp.onNavigationNotification].
  final NotificationListenerCallback<NavigationNotification>?
  onNavigationNotification;

  /// See [MaterialApp.color].
  final Color? color;

  /// See [MaterialApp.home].
  final Widget? home;

  /// See [MaterialApp.routes].
  final Map<String, WidgetBuilder> routes;

  /// See [MaterialApp.initialRoute].
  final String? initialRoute;

  /// See [MaterialApp.onGenerateRoute].
  final RouteFactory? onGenerateRoute;

  /// See [MaterialApp.onGenerateInitialRoutes].
  final InitialRouteListFactory? onGenerateInitialRoutes;

  /// See [MaterialApp.onUnknownRoute].
  final RouteFactory? onUnknownRoute;

  /// See [MaterialApp.navigatorKey].
  final GlobalKey<NavigatorState>? navigatorKey;

  /// See [MaterialApp.navigatorObservers].
  final List<NavigatorObserver> navigatorObservers;

  /// See [MaterialApp.builder].
  final TransitionBuilder? builder;

  /// See [MaterialApp.locale].
  final Locale? locale;

  /// See [MaterialApp.localizationsDelegates].
  final Iterable<LocalizationsDelegate<dynamic>>? localizationsDelegates;

  /// See [MaterialApp.localeListResolutionCallback].
  final LocaleListResolutionCallback? localeListResolutionCallback;

  /// See [MaterialApp.localeResolutionCallback].
  final LocaleResolutionCallback? localeResolutionCallback;

  /// See [MaterialApp.supportedLocales].
  final Iterable<Locale> supportedLocales;

  /// See [MaterialApp.scaffoldMessengerKey].
  final GlobalKey<ScaffoldMessengerState>? scaffoldMessengerKey;

  /// See [MaterialApp.scrollBehavior].
  final ScrollBehavior? scrollBehavior;

  /// See [MaterialApp.restorationScopeId].
  final String? restorationScopeId;

  /// See [MaterialApp.shortcuts].
  final Map<ShortcutActivator, Intent>? shortcuts;

  /// See [MaterialApp.actions].
  final Map<Type, Action<Intent>>? actions;

  /// See [MaterialApp.themeAnimationDuration].
  final Duration themeAnimationDuration;

  /// See [MaterialApp.themeAnimationCurve].
  final Curve themeAnimationCurve;

  /// See [MaterialApp.themeAnimationStyle].
  final AnimationStyle? themeAnimationStyle;

  /// See [MaterialApp.debugShowMaterialGrid].
  final bool debugShowMaterialGrid;

  /// See [MaterialApp.showPerformanceOverlay].
  final bool showPerformanceOverlay;

  /// See [MaterialApp.checkerboardRasterCacheImages].
  final bool checkerboardRasterCacheImages;

  /// See [MaterialApp.checkerboardOffscreenLayers].
  final bool checkerboardOffscreenLayers;

  /// See [MaterialApp.showSemanticsDebugger].
  final bool showSemanticsDebugger;

  /// Defaults to false, unlike [MaterialApp].
  /// See [MaterialApp.debugShowCheckedModeBanner].
  final bool debugShowCheckedModeBanner;

  /// Ignored. Kept for [MaterialApp] parity; removing it is a breaking
  /// change.
  @Deprecated(
    'Remove this parameter as it is now ignored. '
    'MaterialApp never introduces its own MediaQuery; the View widget takes '
    'care of that. This feature was deprecated after v3.7.0-29.0.pre.',
  )
  final bool useInheritedMediaQuery;

  /// See [MaterialApp.routeInformationProvider].
  final RouteInformationProvider? routeInformationProvider;

  /// See [MaterialApp.routeInformationParser].
  final RouteInformationParser<Object>? routeInformationParser;

  /// See [MaterialApp.routerDelegate].
  final RouterDelegate<Object>? routerDelegate;

  /// See [MaterialApp.routerConfig].
  final RouterConfig<Object>? routerConfig;

  /// See [MaterialApp.backButtonDispatcher].
  final BackButtonDispatcher? backButtonDispatcher;
  final bool _useRouter;

  @override
  Widget build(BuildContext context) {
    // The same fallbacks as SkribbleApp and MaterialApp: with no dark theme
    // a dark platform keeps the light one, and the high-contrast dark theme
    // falls back to the dark theme, then to the high-contrast light theme.
    final effectiveDarkTheme = darkWiredTheme ?? wiredTheme;
    final effectiveHighContrastTheme = highContrastWiredTheme ?? wiredTheme;
    final effectiveHighContrastDarkTheme =
        highContrastDarkWiredTheme ??
        darkWiredTheme ??
        effectiveHighContrastTheme;
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
    // A Material theme is only dark when it was built from a dark Wired
    // theme. Converting the light palette with a dark brightness gave
    // Material widgets dark menus, fields, and text styles on light paper.
    ThemeData convert(WiredThemeData data, ThemeData? light) =>
        light ?? data.toThemeData(brightness: Brightness.dark);
    final darkTheme = useMemoized(
      () => convert(effectiveDarkTheme, darkWiredTheme == null ? theme : null),
      <Object?>[effectiveDarkTheme, theme, darkWiredTheme == null],
    );
    final highContrastTheme = useMemoized(
      effectiveHighContrastTheme.toThemeData,
      <Object?>[effectiveHighContrastTheme],
    );

    final highContrastDarkTheme = useMemoized(
      () => convert(
        effectiveHighContrastDarkTheme,
        highContrastDarkWiredTheme == null && darkWiredTheme == null
            ? highContrastTheme
            : null,
      ),
      <Object?>[
        effectiveHighContrastDarkTheme,
        highContrastTheme,
        highContrastDarkWiredTheme == null && darkWiredTheme == null,
      ],
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
