import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'wired_theme.dart';

/// A convenience [MaterialApp] wrapper that keeps Material theming and
/// [WiredTheme] in sync.
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
    final effectiveWiredTheme = _resolveWiredTheme(
      context: context,
      effectiveDarkTheme: effectiveDarkTheme,
      effectiveHighContrastTheme: effectiveHighContrastTheme,
      effectiveHighContrastDarkTheme: effectiveHighContrastDarkTheme,
    );
    final theme = wiredTheme.toThemeData();
    final darkTheme = effectiveDarkTheme.toThemeData(
      brightness: Brightness.dark,
    );
    final highContrastTheme = effectiveHighContrastTheme.toThemeData();
    final highContrastDarkTheme = effectiveHighContrastDarkTheme.toThemeData(
      brightness: Brightness.dark,
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

  WiredThemeData _resolveWiredTheme({
    required BuildContext context,
    required WiredThemeData effectiveDarkTheme,
    required WiredThemeData effectiveHighContrastTheme,
    required WiredThemeData effectiveHighContrastDarkTheme,
  }) {
    final platformDispatcher =
        View.maybeOf(context)?.platformDispatcher ?? PlatformDispatcher.instance;
    final isHighContrast = platformDispatcher.accessibilityFeatures.highContrast;

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
}
