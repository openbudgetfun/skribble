import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
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

    testWidgets('router constructor renders configured route content', (
      tester,
    ) async {
      final routerDelegate = _TestRouterDelegate();
      final routeInformationProvider = PlatformRouteInformationProvider(
        initialRouteInformation: RouteInformation(
          uri: Uri(path: '/details'),
        ),
      );

      await tester.pumpWidget(
        WiredMaterialApp.router(
          wiredTheme: WiredThemeData(),
          routerConfig: RouterConfig<Object>(
            routeInformationProvider: routeInformationProvider,
            routeInformationParser: const _TestRouteInformationParser(),
            routerDelegate: routerDelegate,
            backButtonDispatcher: RootBackButtonDispatcher(),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Details Route'), findsOneWidget);
      expect(find.text('Home Route'), findsNothing);
    });

    testWidgets('router constructor keeps WiredTheme synchronized', (
      tester,
    ) async {
      late WiredThemeData capturedTheme;
      final darkTheme = WiredThemeData(
        borderColor: const Color(0xFFF6E7CE),
        textColor: const Color(0xFFF8F3EA),
        fillColor: const Color(0xFF211A17),
      );
      final routerDelegate = _TestRouterDelegate(
        onBuild: (context) {
          capturedTheme = WiredTheme.of(context);
        },
      );
      final routeInformationProvider = PlatformRouteInformationProvider(
        initialRouteInformation: RouteInformation(
          uri: Uri(path: '/details'),
        ),
      );

      await tester.pumpWidget(
        WiredMaterialApp.router(
          wiredTheme: WiredThemeData(),
          darkWiredTheme: darkTheme,
          themeMode: ThemeMode.dark,
          routeInformationProvider: routeInformationProvider,
          routeInformationParser: const _TestRouteInformationParser(),
          routerDelegate: routerDelegate,
          backButtonDispatcher: RootBackButtonDispatcher(),
        ),
      );
      await tester.pump();

      expect(find.text('Details Route'), findsOneWidget);
      expect(capturedTheme.fillColor, darkTheme.fillColor);
      expect(capturedTheme.borderColor, darkTheme.borderColor);
    });

    test('router constructor requires routerDelegate or routerConfig', () {
      expect(
        () => WiredMaterialApp.router(wiredTheme: WiredThemeData()),
        throwsA(isA<AssertionError>()),
      );
    });
  });
}

class _TestRouteInformationParser extends RouteInformationParser<Object> {
  const _TestRouteInformationParser();

  @override
  Future<Object> parseRouteInformation(RouteInformation routeInformation) =>
      SynchronousFuture<Object>(routeInformation.uri.path);

  @override
  RouteInformation restoreRouteInformation(Object configuration) {
    return RouteInformation(uri: Uri(path: configuration as String));
  }
}

class _TestRouterDelegate extends RouterDelegate<Object>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<Object> {
  _TestRouterDelegate({this.onBuild});

  final void Function(BuildContext context)? onBuild;

  @override
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  String _currentPath = '/';

  @override
  Widget build(BuildContext context) {
    final child = Builder(
      builder: (context) {
        onBuild?.call(context);
        return Text(
          _currentPath == '/details' ? 'Details Route' : 'Home Route',
        );
      },
    );

    return Navigator(
      key: navigatorKey,
      pages: <Page<void>>[MaterialPage<void>(child: child)],
      onDidRemovePage: (_) {},
    );
  }

  @override
  Future<void> setNewRoutePath(Object configuration) {
    _currentPath = configuration as String;
    notifyListeners();
    return SynchronousFuture<void>(null);
  }

  @override
  Object? get currentConfiguration => _currentPath;
}
