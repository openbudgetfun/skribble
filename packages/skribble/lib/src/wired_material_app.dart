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
    this.themeMode = ThemeMode.system,
    this.title = '',
    this.home,
    this.routes = const <String, WidgetBuilder>{},
    this.initialRoute,
    this.onGenerateRoute,
    this.onUnknownRoute,
    this.navigatorKey,
    this.navigatorObservers = const <NavigatorObserver>[],
    this.builder,
    this.locale,
    this.localizationsDelegates,
    this.supportedLocales = const <Locale>[Locale('en', 'US')],
    this.scaffoldMessengerKey,
    this.debugShowCheckedModeBanner = false,
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
    this.themeMode = ThemeMode.system,
    this.title = '',
    this.builder,
    this.locale,
    this.localizationsDelegates,
    this.supportedLocales = const <Locale>[Locale('en', 'US')],
    this.scaffoldMessengerKey,
    this.debugShowCheckedModeBanner = false,
    this.routeInformationProvider,
    this.routeInformationParser,
    this.routerDelegate,
    this.routerConfig,
    this.backButtonDispatcher,
  }) : home = null,
       routes = const <String, WidgetBuilder>{},
       initialRoute = null,
       onGenerateRoute = null,
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
  final ThemeMode themeMode;
  final String title;
  final Widget? home;
  final Map<String, WidgetBuilder> routes;
  final String? initialRoute;
  final RouteFactory? onGenerateRoute;
  final RouteFactory? onUnknownRoute;
  final GlobalKey<NavigatorState>? navigatorKey;
  final List<NavigatorObserver> navigatorObservers;
  final TransitionBuilder? builder;
  final Locale? locale;
  final Iterable<LocalizationsDelegate<dynamic>>? localizationsDelegates;
  final Iterable<Locale> supportedLocales;
  final GlobalKey<ScaffoldMessengerState>? scaffoldMessengerKey;
  final bool debugShowCheckedModeBanner;
  final RouteInformationProvider? routeInformationProvider;
  final RouteInformationParser<Object>? routeInformationParser;
  final RouterDelegate<Object>? routerDelegate;
  final RouterConfig<Object>? routerConfig;
  final BackButtonDispatcher? backButtonDispatcher;
  final bool _useRouter;

  @override
  Widget build(BuildContext context) {
    final effectiveDarkTheme = darkWiredTheme ?? wiredTheme;
    final effectiveWiredTheme = _resolveWiredTheme(effectiveDarkTheme);
    final theme = wiredTheme.toThemeData();
    final darkTheme = effectiveDarkTheme.toThemeData(
      brightness: Brightness.dark,
    );

    return WiredTheme(
      data: effectiveWiredTheme,
      child: _useRouter
          ? MaterialApp.router(
              title: title,
              theme: theme,
              darkTheme: darkTheme,
              themeMode: themeMode,
              routeInformationProvider: routeInformationProvider,
              routeInformationParser: routeInformationParser,
              routerDelegate: routerDelegate,
              routerConfig: routerConfig,
              backButtonDispatcher: backButtonDispatcher,
              builder: builder,
              locale: locale,
              localizationsDelegates: localizationsDelegates,
              supportedLocales: supportedLocales,
              scaffoldMessengerKey: scaffoldMessengerKey,
              debugShowCheckedModeBanner: debugShowCheckedModeBanner,
            )
          : MaterialApp(
              title: title,
              theme: theme,
              darkTheme: darkTheme,
              themeMode: themeMode,
              home: home,
              routes: routes,
              initialRoute: initialRoute,
              onGenerateRoute: onGenerateRoute,
              onUnknownRoute: onUnknownRoute,
              navigatorKey: navigatorKey,
              navigatorObservers: navigatorObservers,
              builder: builder,
              locale: locale,
              localizationsDelegates: localizationsDelegates,
              supportedLocales: supportedLocales,
              scaffoldMessengerKey: scaffoldMessengerKey,
              debugShowCheckedModeBanner: debugShowCheckedModeBanner,
            ),
    );
  }

  WiredThemeData _resolveWiredTheme(WiredThemeData effectiveDarkTheme) {
    switch (themeMode) {
      case ThemeMode.light:
        return wiredTheme;
      case ThemeMode.dark:
        return effectiveDarkTheme;
      case ThemeMode.system:
        return PlatformDispatcher.instance.platformBrightness == Brightness.dark
            ? effectiveDarkTheme
            : wiredTheme;
    }
  }
}
