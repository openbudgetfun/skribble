import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'skribble_localizations.dart';
import 'wired_theme.dart';
import 'wired_theme_scope.dart';

/// Which [WiredThemeData] variant a [SkribbleApp] installs.
///
/// The widgets layer has no theme-mode type of its own (`ThemeMode` lives in
/// `package:flutter/material.dart`), so the shell defines the smallest
/// equivalent. `WiredThemeMode` in the compatibility layer converts to and
/// from Material's `ThemeMode`.
enum SkribbleThemeMode {
  /// Follow the platform brightness and high-contrast accessibility setting.
  system,

  /// Always use the light theme.
  light,

  /// Always use the dark theme.
  dark,
}

/// A widgets-based application shell for Skribble.
///
/// `SkribbleApp` is the Material-free replacement for `MaterialApp` as the root
/// of a Skribble app. It is built on [WidgetsApp] -- Flutter's own
/// widgets-layer app shell -- so it needs neither `package:flutter/material.dart`
/// nor `package:flutter/cupertino.dart`, and a Skribble app no longer has to
/// pretend to be a Material app to run.
///
/// What it provides:
///
/// * The full [WidgetsApp] navigation surface: [home] plus a route table
///   ([routes], [initialRoute], [onGenerateRoute], [onUnknownRoute]) or
///   [SkribbleApp.router] for [RouterConfig]-based navigation.
/// * A [WiredThemeScope] ancestor, so `WiredTheme.of(context)` and every
///   `Wired*` widget pick up [wiredTheme] without a Material ancestor.
/// * A widgets-only localization default ([SkribbleLocalizationsDelegate])
///   that resolves text direction for right-to-left locales. See
///   [localizationsDelegates] for how to opt into `flutter_localizations`.
/// * Text and icons in the theme's ink: the [WiredThemeScope] sets the
///   default text style (the theme's font and `textColor`) and the icon
///   colour, so plain `Text` and `Icon` widgets read on light and dark paper.
/// * Text selection in the theme's ink: a [DefaultSelectionStyle] whose
///   cursor is the theme's `borderColor` and whose highlight is a translucent
///   wash of its `textColor`, which keeps selected text readable in both
///   brightnesses.
/// * Scrolling that suits the paper: [scrollBehavior], which defaults to
///   [SkribbleScrollBehavior].
/// * The debugging and configuration switches a real app expects:
///   [showPerformanceOverlay], [showSemanticsDebugger], [shortcuts],
///   [actions], and [restorationScopeId].
///
/// Text scaling is not clamped: the platform's text scale reaches every
/// `Text` unchanged, and skribble controls grow with it (their heights are
/// minimums). Wrap [builder]'s child in a `MediaQuery.withClampedTextScaling`
/// if your layout needs a ceiling.
///
/// The light and dark themes resolve the way `MaterialApp`'s do: without a
/// [darkWiredTheme], a dark platform keeps the light [wiredTheme]. Pass
/// `WiredThemeData.cuddly(brightness: Brightness.dark)` for skribble's night
/// paper.
///
/// Navigation transitions are plain widgets-layer fades because the shell
/// cannot use `MaterialPageRoute`. Override [pageRouteBuilder] to customize
/// them.
///
/// To host Material widgets inside a `SkribbleApp`, wrap them with the
/// compatibility layer's `WiredMaterialTheme`, which installs the Material
/// `ThemeData` and localizations those widgets need.
///
/// See also:
///
/// * `WiredMaterialApp`, the compatibility bridge for apps that must keep
///   using `MaterialApp`.
/// * `WiredThemeFromCupertino` and `WiredThemeInterop`, which put Wired
///   widgets on a Cupertino app's palette. There is no `WiredCupertinoApp`
///   shell: `CupertinoApp` already exists as the Cupertino root, and a
///   Skribble shell for Cupertino apps would only re-export it -- use
///   `SkribbleApp` directly, or `CupertinoApp` with a `WiredThemeScope`.
class SkribbleApp extends StatelessWidget {
  /// Creates a Skribble app with a [Navigator]-based route setup.
  ///
  /// Either [home], a `'/'` entry in [routes], [onGenerateRoute], or
  /// [onUnknownRoute] must be provided, matching [WidgetsApp].
  const SkribbleApp({
    super.key,
    this.wiredTheme,
    this.darkWiredTheme,
    this.highContrastWiredTheme,
    this.highContrastDarkWiredTheme,
    this.themeMode = SkribbleThemeMode.system,
    this.title = '',
    this.onGenerateTitle,
    this.color,
    this.home,
    this.routes = const <String, WidgetBuilder>{},
    this.initialRoute,
    this.onGenerateRoute,
    this.onGenerateInitialRoutes,
    this.onUnknownRoute,
    this.navigatorKey,
    this.navigatorObservers = const <NavigatorObserver>[],
    this.pageRouteBuilder,
    this.builder,
    this.locale,
    this.localizationsDelegates,
    this.localeListResolutionCallback,
    this.localeResolutionCallback,
    this.supportedLocales = const <Locale>[Locale('en', 'US')],
    this.shortcuts,
    this.actions,
    this.restorationScopeId,
    this.scrollBehavior = const SkribbleScrollBehavior(),
    this.onNavigationNotification,
    this.debugShowCheckedModeBanner = false,
    this.showPerformanceOverlay = false,
    this.showSemanticsDebugger = false,
  }) : routeInformationProvider = null,
       routeInformationParser = null,
       routerDelegate = null,
       routerConfig = null,
       backButtonDispatcher = null;

  /// Creates a Skribble app whose navigation is driven by a [Router].
  ///
  /// Either [routerDelegate] or [routerConfig] must be provided. The
  /// `Router`-based constructor forwards the same theme, localization, and
  /// debugging parameters as the default constructor.
  const SkribbleApp.router({
    super.key,
    this.wiredTheme,
    this.darkWiredTheme,
    this.highContrastWiredTheme,
    this.highContrastDarkWiredTheme,
    this.themeMode = SkribbleThemeMode.system,
    this.title = '',
    this.onGenerateTitle,
    this.color,
    this.builder,
    this.locale,
    this.localizationsDelegates,
    this.localeListResolutionCallback,
    this.localeResolutionCallback,
    this.supportedLocales = const <Locale>[Locale('en', 'US')],
    this.shortcuts,
    this.actions,
    this.restorationScopeId,
    this.scrollBehavior = const SkribbleScrollBehavior(),
    this.onNavigationNotification,
    this.debugShowCheckedModeBanner = false,
    this.showPerformanceOverlay = false,
    this.showSemanticsDebugger = false,
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
       pageRouteBuilder = null,
       assert(
         routerDelegate != null || routerConfig != null,
         'Either routerDelegate or routerConfig must be provided.',
       );

  /// The light (primary) theme. Defaults to [WiredThemeData.defaultTheme].
  ///
  /// Passing `WiredThemeData()` overrides the palette, roughness, font, and
  /// motion policy for the whole app.
  final WiredThemeData? wiredTheme;

  /// The dark theme. Falls back to [wiredTheme], then to the default theme.
  final WiredThemeData? darkWiredTheme;

  /// The high-contrast light theme. Falls back to [wiredTheme], then to the
  /// default theme.
  final WiredThemeData? highContrastWiredTheme;

  /// The high-contrast dark theme. Falls back to [darkWiredTheme], then
  /// [highContrastWiredTheme], then [wiredTheme], then the default theme,
  /// matching how `MaterialApp` resolves its high-contrast dark theme.
  final WiredThemeData? highContrastDarkWiredTheme;

  /// Which theme variant to install. See [SkribbleThemeMode].
  final SkribbleThemeMode themeMode;

  /// A one-line description of the app, used by the host operating system.
  final String title;

  /// Called instead of [title] to produce a localized app description.
  final GenerateAppTitle? onGenerateTitle;

  /// The primary color reported to the host for this app.
  ///
  /// Defaults to the resolved theme's `borderColor`, mirroring how
  /// `MaterialApp` derives its primary color from the theme.
  final Color? color;

  /// The widget for the default route.
  final Widget? home;

  /// The named route table, read by the [Navigator].
  final Map<String, WidgetBuilder> routes;

  /// The first route shown when the app starts.
  final String? initialRoute;

  /// Builds a route for any name not found in [routes].
  final RouteFactory? onGenerateRoute;

  /// Builds the initial route stack.
  final InitialRouteListFactory? onGenerateInitialRoutes;

  /// Builds the route shown when no other route matches.
  final RouteFactory? onUnknownRoute;

  /// The key used to address the app's [Navigator].
  final GlobalKey<NavigatorState>? navigatorKey;

  /// Observers attached to the app's [Navigator].
  final List<NavigatorObserver> navigatorObservers;

  /// Builds page routes for [home] and [routes].
  ///
  /// Defaults to a fade in a widgets-layer [PageRouteBuilder]. This exists
  /// because [WidgetsApp] requires a page route factory when it has routes but
  /// no [builder], and the shell cannot use `MaterialPageRoute`.
  final PageRouteFactory? pageRouteBuilder;

  /// Wraps the navigator, for example to insert app-wide overlays.
  final TransitionBuilder? builder;

  /// The locale the app renders in. Defaults to the platform locale.
  final Locale? locale;

  /// The localization delegates for the app.
  ///
  /// `SkribbleApp` appends [SkribbleLocalizationsDelegate], a widgets-only
  /// delegate that provides English labels and correct right-to-left text
  /// direction. It appends rather than replaces, and [Localizations] uses the
  /// first delegate of each resource type, so a `WidgetsLocalizations`
  /// delegate you pass here (for example
  /// `GlobalWidgetsLocalizations.delegate` from `flutter_localizations`) wins.
  ///
  /// Full per-locale strings are intentionally not part of the core: add
  /// `flutter_localizations` delegates here if you need them, or use
  /// `WiredMaterialApp` / `WiredMaterialTheme`, which install the English
  /// Material defaults.
  final Iterable<LocalizationsDelegate<dynamic>>? localizationsDelegates;

  /// Resolves the app locale from the full platform locale list.
  final LocaleListResolutionCallback? localeListResolutionCallback;

  /// Resolves the app locale from a single platform locale.
  final LocaleResolutionCallback? localeResolutionCallback;

  /// The locales the app supports.
  final Iterable<Locale> supportedLocales;

  /// Overrides the app-level keyboard shortcuts.
  final Map<ShortcutActivator, Intent>? shortcuts;

  /// Overrides the app-level intent actions.
  final Map<Type, Action<Intent>>? actions;

  /// Identifies the app's state-restoration bucket.
  final String? restorationScopeId;

  /// How scrollable widgets in the app behave: drag devices, scrollbars,
  /// and overscroll.
  ///
  /// Defaults to [SkribbleScrollBehavior]. Pass null to use Flutter's plain
  /// [ScrollBehavior], or `const SkribbleScrollBehavior().copyWith(...)` to
  /// change one aspect, for example to let a mouse drag lists on desktop.
  final ScrollBehavior? scrollBehavior;

  /// Called when a navigation notification bubbles up to the app, for
  /// example to tell the platform whether a back gesture can pop a route.
  ///
  /// See [WidgetsApp.onNavigationNotification].
  final NotificationListenerCallback<NavigationNotification>?
  onNavigationNotification;

  /// Whether to show the debug-mode banner. Defaults to false so a Skribble
  /// app starts clean; set true while debugging.
  final bool debugShowCheckedModeBanner;

  /// Whether to overlay a performance graph.
  final bool showPerformanceOverlay;

  /// Whether to overlay the semantics tree.
  final bool showSemanticsDebugger;

  /// The [Router] configuration, for the [SkribbleApp.router] constructor.
  final RouteInformationProvider? routeInformationProvider;

  /// The route information parser, for [SkribbleApp.router].
  final RouteInformationParser<Object>? routeInformationParser;

  /// The router delegate, for [SkribbleApp.router].
  final RouterDelegate<Object>? routerDelegate;

  /// The full router configuration, for [SkribbleApp.router].
  final RouterConfig<Object>? routerConfig;

  /// The back-button dispatcher, for [SkribbleApp.router].
  final BackButtonDispatcher? backButtonDispatcher;

  @override
  Widget build(BuildContext context) {
    final defaultTheme = WiredThemeData.defaultTheme;
    final light = wiredTheme ?? defaultTheme;
    final dark = darkWiredTheme ?? light;
    final highContrastLight = highContrastWiredTheme ?? light;
    final highContrastDark =
        highContrastDarkWiredTheme ?? darkWiredTheme ?? highContrastLight;
    final theme = resolveWiredAppTheme(
      context: context,
      light: light,
      dark: dark,
      highContrastLight: highContrastLight,
      highContrastDark: highContrastDark,
      themeMode: themeMode,
    );

    final app =
        routerConfig != null ||
            routerDelegate != null ||
            routeInformationProvider != null ||
            routeInformationParser != null ||
            backButtonDispatcher != null
        ? WidgetsApp.router(
            routeInformationProvider: routeInformationProvider,
            routeInformationParser: routeInformationParser,
            routerDelegate: routerDelegate,
            routerConfig: routerConfig,
            backButtonDispatcher: backButtonDispatcher,
            builder: builder,
            title: title,
            onGenerateTitle: onGenerateTitle,
            onNavigationNotification: onNavigationNotification,
            color: color ?? theme.borderColor,
            locale: locale,
            localizationsDelegates: _effectiveLocalizationsDelegates,
            localeListResolutionCallback: localeListResolutionCallback,
            localeResolutionCallback: localeResolutionCallback,
            supportedLocales: supportedLocales,
            showPerformanceOverlay: showPerformanceOverlay,
            showSemanticsDebugger: showSemanticsDebugger,
            debugShowCheckedModeBanner: debugShowCheckedModeBanner,
            shortcuts: shortcuts,
            actions: actions,
            restorationScopeId: restorationScopeId,
          )
        : WidgetsApp(
            navigatorKey: navigatorKey,
            onGenerateRoute: onGenerateRoute,
            onGenerateInitialRoutes: onGenerateInitialRoutes,
            onUnknownRoute: onUnknownRoute,
            navigatorObservers: navigatorObservers,
            initialRoute: initialRoute,
            pageRouteBuilder: pageRouteBuilder ?? _defaultPageRouteBuilder,
            home: home,
            routes: routes,
            builder: builder,
            title: title,
            onGenerateTitle: onGenerateTitle,
            onNavigationNotification: onNavigationNotification,
            color: color ?? theme.borderColor,
            locale: locale,
            localizationsDelegates: _effectiveLocalizationsDelegates,
            localeListResolutionCallback: localeListResolutionCallback,
            localeResolutionCallback: localeResolutionCallback,
            supportedLocales: supportedLocales,
            showPerformanceOverlay: showPerformanceOverlay,
            showSemanticsDebugger: showSemanticsDebugger,
            debugShowCheckedModeBanner: debugShowCheckedModeBanner,
            shortcuts: shortcuts,
            actions: actions,
            restorationScopeId: restorationScopeId,
          );

    final behavior = scrollBehavior;
    return WiredThemeScope(
      data: theme,
      child: DefaultSelectionStyle(
        cursorColor: theme.borderColor,
        selectionColor: theme.textColor.withValues(alpha: 0.25),
        child: behavior == null
            ? app
            : ScrollConfiguration(behavior: behavior, child: app),
      ),
    );
  }

  Iterable<LocalizationsDelegate<dynamic>>
  get _effectiveLocalizationsDelegates {
    return <LocalizationsDelegate<dynamic>>[
      ...?localizationsDelegates,
      const SkribbleLocalizationsDelegate(),
    ];
  }
}

/// Resolves the active [WiredThemeData] for an app shell.
///
/// Shared by [SkribbleApp] and the compatibility layer's `WiredMaterialApp` so
/// both resolve light, dark, and high-contrast variants identically. Reads
/// through [MediaQuery] so a platform brightness or accessibility change
/// rebuilds the shell. It depends only on those two aspects: insets, size,
/// and text scale change every frame while a keyboard opens or a window
/// resizes, and must not rebuild the whole app.
@internal
WiredThemeData resolveWiredAppTheme({
  required BuildContext context,
  required WiredThemeData light,
  required WiredThemeData dark,
  required WiredThemeData highContrastLight,
  required WiredThemeData highContrastDark,
  required SkribbleThemeMode themeMode,
}) {
  PlatformDispatcher platformDispatcher() =>
      View.maybeOf(context)?.platformDispatcher ?? PlatformDispatcher.instance;
  final isHighContrast =
      MediaQuery.maybeHighContrastOf(context) ??
      platformDispatcher().accessibilityFeatures.highContrast;

  switch (themeMode) {
    case SkribbleThemeMode.light:
      return isHighContrast ? highContrastLight : light;
    case SkribbleThemeMode.dark:
      return isHighContrast ? highContrastDark : dark;
    case SkribbleThemeMode.system:
      final isDark =
          (MediaQuery.maybePlatformBrightnessOf(context) ??
              platformDispatcher().platformBrightness) ==
          Brightness.dark;

      if (isDark) {
        return isHighContrast ? highContrastDark : dark;
      }
      return isHighContrast ? highContrastLight : light;
  }
}

/// The default page route: a widgets-layer [PageRouteBuilder] with a fade.
PageRoute<T> _defaultPageRouteBuilder<T>(
  RouteSettings settings,
  WidgetBuilder builder,
) {
  return PageRouteBuilder<T>(
    settings: settings,
    pageBuilder: (context, animation, secondaryAnimation) => builder(context),
    transitionsBuilder: (context, animation, secondaryAnimation, child) =>
        FadeTransition(opacity: animation, child: child),
  );
}

/// The scroll behaviour [SkribbleApp] installs by default.
///
/// Flutter's plain [ScrollBehavior] paints a white overscroll glow on
/// Android, which disappears on light paper and flares on dark paper, and a
/// grey desktop scrollbar. This behaviour keeps the rest of
/// [ScrollBehavior] and changes those two:
///
/// * On Android and Fuchsia, overscroll stretches the content, which needs
///   no colour, instead of painting a glow.
/// * On desktop the scrollbar thumb is a translucent wash of the theme's
///   `textColor`, so it reads on light and dark paper alike.
///
/// Like `MaterialApp`, it does not let a mouse drag a list: that would make
/// selecting text inside scrollables difficult. Opt in with
/// `const SkribbleScrollBehavior().copyWith(dragDevices: {...})`.
class SkribbleScrollBehavior extends ScrollBehavior {
  /// Creates the default skribble scroll behaviour.
  const SkribbleScrollBehavior();

  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    switch (getPlatform(context)) {
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
        return StretchingOverscrollIndicator(
          axisDirection: details.direction,
          clipBehavior: details.decorationClipBehavior ?? Clip.hardEdge,
          child: child,
        );
      case TargetPlatform.iOS:
      case TargetPlatform.linux:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
        return child;
    }
  }

  @override
  Widget buildScrollbar(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    switch (getPlatform(context)) {
      case TargetPlatform.linux:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
        assert(details.controller != null);
        return RawScrollbar(
          controller: details.controller,
          thumbColor: WiredThemeScope.of(
            context,
          ).textColor.withValues(alpha: 0.4),
          radius: const Radius.circular(4),
          child: child,
        );
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
      case TargetPlatform.iOS:
        return child;
    }
  }
}
