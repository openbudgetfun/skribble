import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';

void main() {
  group('WiredMaterialApp', () {
    testWidgets('renders home and provides the wired theme', (tester) async {
      late WiredThemeData capturedTheme;
      final wiredTheme = WiredThemeData(
        borderColor: const Color(0xFF4A3470),
        fillColor: const Color(0xFFFFFCF1),
      );

      await tester.pumpWidget(
        WiredMaterialApp(
          wiredTheme: wiredTheme,
          home: Builder(
            builder: (context) {
              capturedTheme = WiredTheme.of(context);
              return const Text('Home');
            },
          ),
        ),
      );

      expect(find.text('Home'), findsOneWidget);
      expect(capturedTheme.borderColor, wiredTheme.borderColor);
      expect(capturedTheme.fillColor, wiredTheme.fillColor);
    });

    testWidgets('uses routes and initialRoute', (tester) async {
      await tester.pumpWidget(
        WiredMaterialApp(
          wiredTheme: WiredThemeData(),
          initialRoute: '/details',
          routes: {
            '/': (_) => const Text('Root'),
            '/details': (_) => const Text('Details'),
          },
        ),
      );

      expect(find.text('Details'), findsOneWidget);
      expect(find.text('Root'), findsNothing);
    });

    testWidgets('forwards onGenerateInitialRoutes when provided', (
      tester,
    ) async {
      List<Route<dynamic>> onGenerateInitialRoutes(String initialRoute) =>
          <Route<dynamic>>[
            MaterialPageRoute<void>(
              builder: (_) => Text('Generated $initialRoute'),
            ),
          ];

      await tester.pumpWidget(
        WiredMaterialApp(
          wiredTheme: WiredThemeData(),
          onGenerateInitialRoutes: onGenerateInitialRoutes,
          builder: (context, child) => child ?? const SizedBox.shrink(),
        ),
      );

      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(
        materialApp.onGenerateInitialRoutes,
        same(onGenerateInitialRoutes),
      );
    });

    testWidgets('applies dark wired theme when themeMode is dark', (
      tester,
    ) async {
      late WiredThemeData capturedTheme;
      final darkTheme = WiredThemeData(
        borderColor: const Color(0xFFF6E7CE),
        textColor: const Color(0xFFF8F3EA),
        fillColor: const Color(0xFF211A17),
      );

      await tester.pumpWidget(
        WiredMaterialApp(
          wiredTheme: WiredThemeData(),
          darkWiredTheme: darkTheme,
          themeMode: ThemeMode.dark,
          home: Builder(
            builder: (context) {
              capturedTheme = WiredTheme.of(context);
              return const Text('Dark Home');
            },
          ),
        ),
      );

      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(materialApp.themeMode, ThemeMode.dark);
      expect(capturedTheme.fillColor, darkTheme.fillColor);
      expect(capturedTheme.borderColor, darkTheme.borderColor);
    });

    testWidgets('forwards shared MaterialApp configuration', (tester) async {
      Locale localeListCallback(
        List<Locale>? locales,
        Iterable<Locale> supportedLocales,
      ) => const Locale('en', 'US');
      Locale localeCallback(
        Locale? locale,
        Iterable<Locale> supportedLocales,
      ) => const Locale('en', 'US');
      const scrollBehavior = _TestScrollBehavior();
      final action = _TestIntentAction();
      String titleBuilder(BuildContext context) => 'Generated Title';

      await tester.pumpWidget(
        WiredMaterialApp(
          wiredTheme: WiredThemeData(),
          onGenerateTitle: titleBuilder,
          color: const Color(0xFF112233),
          localeListResolutionCallback: localeListCallback,
          localeResolutionCallback: localeCallback,
          scrollBehavior: scrollBehavior,
          restorationScopeId: 'wired-app',
          shortcuts: const <ShortcutActivator, Intent>{
            SingleActivator(LogicalKeyboardKey.keyK): _TestIntent(),
          },
          actions: <Type, Action<Intent>>{_TestIntent: action},
          themeAnimationDuration: const Duration(milliseconds: 420),
          themeAnimationCurve: Curves.easeInOutCubic,
          home: const Text('Config Home'),
        ),
      );

      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(materialApp.onGenerateTitle, same(titleBuilder));
      expect(materialApp.color, const Color(0xFF112233));
      expect(materialApp.localeListResolutionCallback, same(localeListCallback));
      expect(materialApp.localeResolutionCallback, same(localeCallback));
      expect(materialApp.scrollBehavior, same(scrollBehavior));
      expect(materialApp.restorationScopeId, 'wired-app');
      expect(materialApp.themeAnimationDuration, const Duration(milliseconds: 420));
      expect(materialApp.themeAnimationCurve, Curves.easeInOutCubic);
      expect(materialApp.shortcuts, isNotNull);
      expect(materialApp.actions, isNotNull);
      expect(materialApp.actions![_TestIntent], same(action));
    });

    testWidgets('router constructor renders routerConfig child', (
      tester,
    ) async {
      late WiredThemeData capturedTheme;
      final wiredTheme = WiredThemeData(
        borderColor: const Color(0xFF3C2A5A),
        fillColor: const Color(0xFFFFFBF0),
      );

      await tester.pumpWidget(
        WiredMaterialApp.router(
          wiredTheme: wiredTheme,
          routerConfig: RouterConfig<Object>(
            routeInformationProvider: PlatformRouteInformationProvider(
              initialRouteInformation: RouteInformation(uri: Uri(path: '/')),
            ),
            routeInformationParser: const _TestRouteInformationParser(),
            routerDelegate: _TestRouterDelegate((context) {
              capturedTheme = WiredTheme.of(context);
              return const Text('Router Home');
            }),
          ),
        ),
      );

      expect(find.text('Router Home'), findsOneWidget);
      expect(capturedTheme.borderColor, wiredTheme.borderColor);
      expect(capturedTheme.fillColor, wiredTheme.fillColor);
    });

    testWidgets('router constructor works with delegate and parser fields', (
      tester,
    ) async {
      await tester.pumpWidget(
        WiredMaterialApp.router(
          wiredTheme: WiredThemeData(),
          routeInformationParser: const _TestRouteInformationParser(),
          routerDelegate: _TestRouterDelegate(
            (_) => const Text('Direct Router'),
          ),
        ),
      );

      expect(find.text('Direct Router'), findsOneWidget);
    });

    testWidgets('router constructor applies dark wired theme', (
      tester,
    ) async {
      late WiredThemeData capturedTheme;
      final darkTheme = WiredThemeData(
        borderColor: const Color(0xFFF6E7CE),
        textColor: const Color(0xFFF8F3EA),
        fillColor: const Color(0xFF211A17),
      );

      await tester.pumpWidget(
        WiredMaterialApp.router(
          wiredTheme: WiredThemeData(),
          darkWiredTheme: darkTheme,
          themeMode: ThemeMode.dark,
          routeInformationParser: const _TestRouteInformationParser(),
          routerDelegate: _TestRouterDelegate((context) {
            capturedTheme = WiredTheme.of(context);
            return const Text('Dark Router Home');
          }),
        ),
      );

      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(materialApp.themeMode, ThemeMode.dark);
      expect(capturedTheme.fillColor, darkTheme.fillColor);
      expect(capturedTheme.borderColor, darkTheme.borderColor);
    });

    testWidgets('router constructor forwards shared MaterialApp configuration', (
      tester,
    ) async {
      Locale localeListCallback(
        List<Locale>? locales,
        Iterable<Locale> supportedLocales,
      ) => const Locale('en', 'US');
      Locale localeCallback(
        Locale? locale,
        Iterable<Locale> supportedLocales,
      ) => const Locale('en', 'US');
      const scrollBehavior = _TestScrollBehavior();
      final action = _TestIntentAction();
      String titleBuilder(BuildContext context) => 'Router Title';

      await tester.pumpWidget(
        WiredMaterialApp.router(
          wiredTheme: WiredThemeData(),
          onGenerateTitle: titleBuilder,
          color: const Color(0xFF332211),
          localeListResolutionCallback: localeListCallback,
          localeResolutionCallback: localeCallback,
          scrollBehavior: scrollBehavior,
          restorationScopeId: 'wired-router-app',
          shortcuts: const <ShortcutActivator, Intent>{
            SingleActivator(LogicalKeyboardKey.keyR): _TestIntent(),
          },
          actions: <Type, Action<Intent>>{_TestIntent: action},
          themeAnimationDuration: const Duration(milliseconds: 360),
          themeAnimationCurve: Curves.easeOutQuart,
          routeInformationParser: const _TestRouteInformationParser(),
          routerDelegate: _TestRouterDelegate(
            (_) => const Text('Router Config Home'),
          ),
        ),
      );

      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(materialApp.onGenerateTitle, same(titleBuilder));
      expect(materialApp.color, const Color(0xFF332211));
      expect(materialApp.localeListResolutionCallback, same(localeListCallback));
      expect(materialApp.localeResolutionCallback, same(localeCallback));
      expect(materialApp.scrollBehavior, same(scrollBehavior));
      expect(materialApp.restorationScopeId, 'wired-router-app');
      expect(materialApp.themeAnimationDuration, const Duration(milliseconds: 360));
      expect(materialApp.themeAnimationCurve, Curves.easeOutQuart);
      expect(materialApp.shortcuts, isNotNull);
      expect(materialApp.actions, isNotNull);
      expect(materialApp.actions![_TestIntent], same(action));
    });
  });
}

class _TestRouteInformationParser extends RouteInformationParser<Object> {
  const _TestRouteInformationParser();

  @override
  Future<Object> parseRouteInformation(RouteInformation routeInformation) {
    return SynchronousFuture<Object>(routeInformation.uri.toString());
  }
}

class _TestRouterDelegate extends RouterDelegate<Object> with ChangeNotifier {
  _TestRouterDelegate(this.builder);

  final WidgetBuilder builder;

  @override
  Widget build(BuildContext context) => Builder(builder: builder);

  @override
  Object? get currentConfiguration => null;

  @override
  Future<bool> popRoute() => SynchronousFuture<bool>(false);

  @override
  Future<void> setNewRoutePath(Object configuration) async {}
}

class _TestScrollBehavior extends MaterialScrollBehavior {
  const _TestScrollBehavior();
}

class _TestIntent extends Intent {
  const _TestIntent();
}

class _TestIntentAction extends Action<_TestIntent> {
  @override
  Object? invoke(_TestIntent intent) => null;
}
