import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart' as widgets;
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';

void main() {
  group('SkribbleApp', () {
    testWidgets('renders home without a MaterialApp ancestor', (tester) async {
      await tester.pumpWidget(
        const SkribbleApp(home: Text('Home')),
      );

      expect(find.text('Home'), findsOneWidget);
      expect(find.byType(MaterialApp), findsNothing);
      expect(find.byType(widgets.WidgetsApp), findsOneWidget);
    });

    testWidgets('installs the default Skribble theme', (tester) async {
      late WiredThemeData captured;

      await tester.pumpWidget(
        SkribbleApp(
          home: Builder(
            builder: (context) {
              captured = WiredTheme.of(context);
              return const Text('Home');
            },
          ),
        ),
      );

      expect(captured, WiredThemeData.defaultTheme);
    });

    testWidgets('installs a custom theme through wiredTheme', (tester) async {
      final theme = WiredThemeData(
        borderColor: const Color(0xFF4A3470),
        fillColor: const Color(0xFFFFFCF1),
      );

      late WiredThemeData captured;
      await tester.pumpWidget(
        SkribbleApp(
          wiredTheme: theme,
          home: Builder(
            builder: (context) {
              captured = WiredTheme.of(context);
              return const Text('Themed');
            },
          ),
        ),
      );

      expect(captured.borderColor, theme.borderColor);
      expect(captured.fillColor, theme.fillColor);
    });

    testWidgets('resolves darkWiredTheme for dark mode', (tester) async {
      final dark = WiredThemeData(
        borderColor: const Color(0xFFF6E7CE),
        fillColor: const Color(0xFF211A17),
      );

      late WiredThemeData captured;
      await tester.pumpWidget(
        SkribbleApp(
          themeMode: SkribbleThemeMode.dark,
          darkWiredTheme: dark,
          home: Builder(
            builder: (context) {
              captured = WiredTheme.of(context);
              return const Text('Dark');
            },
          ),
        ),
      );

      expect(captured.borderColor, dark.borderColor);
      expect(captured.fillColor, dark.fillColor);
    });

    testWidgets('follows platform brightness in system mode', (tester) async {
      addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
      final dark = WiredThemeData(borderColor: const Color(0xFF101010));

      late WiredThemeData captured;
      await tester.pumpWidget(
        SkribbleApp(
          darkWiredTheme: dark,
          home: Builder(
            builder: (context) {
              captured = WiredTheme.of(context);
              return const Text('System');
            },
          ),
        ),
      );

      expect(captured.borderColor, WiredThemeData.defaultTheme.borderColor);

      tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
      await tester.pump();

      expect(captured.borderColor, dark.borderColor);
    });

    testWidgets('resolves the high-contrast theme', (tester) async {
      addTearDown(() {
        tester.platformDispatcher.accessibilityFeaturesTestValue =
            const FakeAccessibilityFeatures();
      });
      final highContrast = WiredThemeData(
        borderColor: const Color(0xFF12006B),
      );

      late WiredThemeData captured;
      await tester.pumpWidget(
        SkribbleApp(
          highContrastWiredTheme: highContrast,
          home: Builder(
            builder: (context) {
              captured = WiredTheme.of(context);
              return const Text('High contrast');
            },
          ),
        ),
      );

      expect(captured.borderColor, isNot(highContrast.borderColor));

      tester.platformDispatcher.accessibilityFeaturesTestValue =
          FakeAccessibilityFeatures.allOn;
      await tester.pump();

      expect(captured.borderColor, highContrast.borderColor);
    });

    testWidgets('uses routes and initialRoute', (tester) async {
      await tester.pumpWidget(
        SkribbleApp(
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

    testWidgets('pushes named routes with the default page route builder', (
      tester,
    ) async {
      final navigatorKey = GlobalKey<NavigatorState>();
      await tester.pumpWidget(
        SkribbleApp(
          navigatorKey: navigatorKey,
          home: const Text('Root'),
          onGenerateRoute: (settings) => PageRouteBuilder<void>(
            settings: settings,
            pageBuilder: (context, animation, secondaryAnimation) =>
                Text('Generated ${settings.name}'),
          ),
        ),
      );

      navigatorKey.currentState!.pushNamed('/next');
      await tester.pumpAndSettle();

      expect(find.text('Generated /next'), findsOneWidget);
    });

    testWidgets('calls onUnknownRoute for unmatched names', (tester) async {
      final navigatorKey = GlobalKey<NavigatorState>();
      await tester.pumpWidget(
        SkribbleApp(
          navigatorKey: navigatorKey,
          home: const Text('Root'),
          onUnknownRoute: (settings) => PageRouteBuilder<void>(
            settings: settings,
            pageBuilder: (context, animation, secondaryAnimation) =>
                const Text('Not found'),
          ),
        ),
      );

      navigatorKey.currentState!.pushNamed('/missing');
      await tester.pumpAndSettle();

      expect(find.text('Not found'), findsOneWidget);
    });

    testWidgets('uses a custom pageRouteBuilder when provided', (tester) async {
      final routeNames = <String?>[];
      PageRoute<T> routeFactory<T>(
        RouteSettings routeSettings,
        WidgetBuilder builder,
      ) {
        routeNames.add(routeSettings.name);
        return PageRouteBuilder<T>(
          settings: routeSettings,
          pageBuilder: (context, animation, secondaryAnimation) =>
              builder(context),
        );
      }

      await tester.pumpWidget(
        SkribbleApp(home: const Text('Home'), pageRouteBuilder: routeFactory),
      );

      expect(find.text('Home'), findsOneWidget);
      expect(routeNames, contains('/'));
    });

    testWidgets('invokes navigatorObservers', (tester) async {
      final observer = _TestNavigatorObserver();

      await tester.pumpWidget(
        SkribbleApp(home: const Text('Home'), navigatorObservers: [observer]),
      );

      expect(observer.pushes, 1);
    });

    testWidgets('wraps the navigator with builder', (tester) async {
      await tester.pumpWidget(
        SkribbleApp(
          builder: (context, child) => Column(
            children: [
              const Text('Chrome'),
              Expanded(child: child!),
            ],
          ),
          home: const Text('Content'),
        ),
      );

      expect(find.text('Chrome'), findsOneWidget);
      expect(find.text('Content'), findsOneWidget);
    });

    testWidgets('shows a Title from title or onGenerateTitle', (tester) async {
      await tester.pumpWidget(
        const SkribbleApp(title: 'Skribble', home: Text('Home')),
      );

      expect(tester.widget<Title>(find.byType(Title)).title, 'Skribble');

      await tester.pumpWidget(
        SkribbleApp(
          onGenerateTitle: (context) => 'Generated title',
          home: const Text('Home'),
        ),
      );

      expect(
        tester.widget<Title>(find.byType(Title)).title,
        'Generated title',
      );
    });

    testWidgets('hides the checked mode banner by default', (tester) async {
      await tester.pumpWidget(const SkribbleApp(home: Text('Home')));
      expect(find.byType(CheckedModeBanner), findsNothing);

      await tester.pumpWidget(
        const SkribbleApp(debugShowCheckedModeBanner: true, home: Text('Home')),
      );
      expect(find.byType(CheckedModeBanner), findsOneWidget);
    });

    testWidgets('forwards shortcuts and actions', (tester) async {
      final action = _TestIntentAction();
      await tester.pumpWidget(
        SkribbleApp(
          shortcuts: const <ShortcutActivator, Intent>{
            SingleActivator(LogicalKeyboardKey.keyK): _TestIntent(),
          },
          actions: <Type, Action<Intent>>{_TestIntent: action},
          home: const Text('Home'),
        ),
      );

      final app = tester.widget<widgets.WidgetsApp>(
        find.byType(widgets.WidgetsApp),
      );
      expect(app.shortcuts, isNotNull);
      expect(app.actions![_TestIntent], same(action));
    });

    testWidgets('enables the performance overlay', (tester) async {
      await tester.pumpWidget(
        const SkribbleApp(showPerformanceOverlay: true, home: Text('Home')),
      );

      expect(find.byType(PerformanceOverlay), findsOneWidget);
    });

    testWidgets('forwards the restoration scope id', (tester) async {
      await tester.pumpWidget(
        const SkribbleApp(
          restorationScopeId: 'skribble-app',
          home: Text('Home'),
        ),
      );

      final scope = tester.widget<RootRestorationScope>(
        find.byType(RootRestorationScope),
      );
      expect(scope.restorationId, 'skribble-app');
    });

    testWidgets('defaults to left-to-right for English', (tester) async {
      late widgets.WidgetsLocalizations localizations;
      await tester.pumpWidget(
        SkribbleApp(
          home: Builder(
            builder: (context) {
              localizations = widgets.WidgetsLocalizations.of(context);
              return const Text('Home');
            },
          ),
        ),
      );

      expect(localizations, isA<SkribbleLocalizations>());
      expect(localizations.textDirection, widgets.TextDirection.ltr);
      expect(
        Directionality.of(tester.element(find.text('Home'))),
        widgets.TextDirection.ltr,
      );
    });

    testWidgets('resolves right-to-left for Arabic', (tester) async {
      await tester.pumpWidget(
        const SkribbleApp(
          locale: Locale('ar'),
          supportedLocales: <Locale>[Locale('ar')],
          home: Text('Home'),
        ),
      );

      expect(
        Directionality.of(tester.element(find.text('Home'))),
        widgets.TextDirection.rtl,
      );
    });

    testWidgets('caller localizationsDelegates take precedence', (
      tester,
    ) async {
      await tester.pumpWidget(
        SkribbleApp(
          localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
            _TestWidgetsLocalizationsDelegate(),
          ],
          home: Builder(
            builder: (context) {
              expect(
                widgets.WidgetsLocalizations.of(context).textDirection,
                widgets.TextDirection.rtl,
              );
              return const Text('Home');
            },
          ),
        ),
      );

      expect(
        Directionality.of(tester.element(find.text('Home'))),
        widgets.TextDirection.rtl,
      );
    });

    testWidgets('router constructor renders routerConfig content', (
      tester,
    ) async {
      late WiredThemeData captured;
      final theme = WiredThemeData(borderColor: const Color(0xFF3C2A5A));

      await tester.pumpWidget(
        SkribbleApp.router(
          wiredTheme: theme,
          routerConfig: RouterConfig<Object>(
            routeInformationProvider: PlatformRouteInformationProvider(
              initialRouteInformation: RouteInformation(uri: Uri(path: '/')),
            ),
            routeInformationParser: const _TestRouteInformationParser(),
            routerDelegate: _TestRouterDelegate((context) {
              captured = WiredTheme.of(context);
              return const Text('Router home');
            }),
          ),
        ),
      );

      expect(find.text('Router home'), findsOneWidget);
      expect(captured.borderColor, theme.borderColor);
      expect(find.byType(MaterialApp), findsNothing);
    });

    testWidgets('router constructor works with delegate and parser fields', (
      tester,
    ) async {
      await tester.pumpWidget(
        SkribbleApp.router(
          routeInformationParser: const _TestRouteInformationParser(),
          routerDelegate: _TestRouterDelegate(
            (_) => const Text('Direct router'),
          ),
        ),
      );

      expect(find.text('Direct router'), findsOneWidget);
    });

    test('router constructor requires routerDelegate or routerConfig', () {
      expect(
        SkribbleApp.router,
        throwsA(isA<AssertionError>()),
      );
    });

    testWidgets('renders Wired widgets without a Material ancestor', (
      tester,
    ) async {
      var pressed = 0;
      await tester.pumpWidget(
        SkribbleApp(
          wiredTheme: WiredThemeData(borderColor: const Color(0xFF223344)),
          home: Center(
            child: WiredButton(
              onPressed: () => pressed++,
              child: const Text('Save'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Save'));
      await tester.pump();

      expect(pressed, 1);
      expect(find.byType(MaterialApp), findsNothing);
    });
  });
}

class _TestNavigatorObserver extends NavigatorObserver {
  int pushes = 0;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    pushes++;
  }
}

class _TestWidgetsLocalizationsDelegate
    extends LocalizationsDelegate<widgets.WidgetsLocalizations> {
  const _TestWidgetsLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<widgets.WidgetsLocalizations> load(Locale locale) =>
      SynchronousFuture<widgets.WidgetsLocalizations>(
        const _RightToLeftLocalizations(),
      );

  @override
  bool shouldReload(_TestWidgetsLocalizationsDelegate old) => false;
}

class _RightToLeftLocalizations implements widgets.WidgetsLocalizations {
  const _RightToLeftLocalizations();

  @override
  widgets.TextDirection get textDirection => widgets.TextDirection.rtl;

  @override
  String get reorderItemToStart => 'Start';

  @override
  String get reorderItemToEnd => 'End';

  @override
  String get reorderItemUp => 'Up';

  @override
  String get reorderItemDown => 'Down';

  @override
  String get reorderItemLeft => 'Left';

  @override
  String get reorderItemRight => 'Right';

  @override
  String get copyButtonLabel => 'Copy';

  @override
  String get cutButtonLabel => 'Cut';

  @override
  String get pasteButtonLabel => 'Paste';

  @override
  String get selectAllButtonLabel => 'Select all';

  @override
  String get lookUpButtonLabel => 'Look up';

  @override
  String get searchWebButtonLabel => 'Search web';

  @override
  String get shareButtonLabel => 'Share';

  @override
  String get radioButtonUnselectedLabel => 'Not selected';

  @override
  String get searchResultsFound => 'Search results found';

  @override
  String get noResultsFound => 'No results found';
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

class _TestIntent extends Intent {
  const _TestIntent();
}

class _TestIntentAction extends Action<_TestIntent> {
  @override
  Object? invoke(_TestIntent intent) => null;
}
