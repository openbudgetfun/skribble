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
              initialRouteInformation: RouteInformation(
                uri: Uri(path: '/'),
              ),
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
