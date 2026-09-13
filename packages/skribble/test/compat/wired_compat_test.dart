import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';

void main() {
  group('Wired widgets in a Material app', () {
    testWidgets('render with the default Skribble theme', (tester) async {
      late WiredThemeData captured;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                captured = WiredTheme.of(context);
                return const WiredButton(child: Text('Save'));
              },
            ),
          ),
        ),
      );

      expect(find.text('Save'), findsOneWidget);
      expect(captured.borderColor, WiredThemeData.defaultTheme.borderColor);
    });

    testWidgets('WiredThemeFromMaterial adopts the Material palette', (
      tester,
    ) async {
      final materialTheme = ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF00695C),
        ),
      );

      late WiredThemeData captured;
      await tester.pumpWidget(
        MaterialApp(
          theme: materialTheme,
          home: WiredThemeFromMaterial(
            child: Builder(
              builder: (context) {
                captured = WiredTheme.of(context);
                return const WiredButton(child: Text('Save'));
              },
            ),
          ),
        ),
      );

      expect(captured.borderColor, materialTheme.colorScheme.primary);
      expect(captured.fillColor, materialTheme.colorScheme.surface);
      expect(find.text('Save'), findsOneWidget);
    });

    testWidgets('WiredThemeFromMaterial accepts explicit tokens', (
      tester,
    ) async {
      final explicit = WiredThemeData(borderColor: const Color(0xFFAA0000));

      late WiredThemeData captured;
      await tester.pumpWidget(
        MaterialApp(
          home: WiredThemeFromMaterial(
            data: explicit,
            child: Builder(
              builder: (context) {
                captured = WiredTheme.of(context);
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      );

      expect(captured.borderColor, explicit.borderColor);
    });
  });

  group('Wired widgets in a Cupertino app', () {
    testWidgets('WiredThemeFromCupertino adopts the Cupertino palette', (
      tester,
    ) async {
      const cupertinoTheme = CupertinoThemeData(
        primaryColor: Color(0xFF1B5E20),
        scaffoldBackgroundColor: Color(0xFFF1F8E9),
      );

      late WiredThemeData captured;
      await tester.pumpWidget(
        CupertinoApp(
          theme: cupertinoTheme,
          home: WiredThemeFromCupertino(
            child: Builder(
              builder: (context) {
                captured = WiredTheme.of(context);
                return const WiredCupertinoButton(
                  onPressed: null,
                  child: Text('Tap'),
                );
              },
            ),
          ),
        ),
      );

      expect(captured.borderColor, cupertinoTheme.primaryColor);
      expect(captured.fillColor, cupertinoTheme.scaffoldBackgroundColor);
      expect(find.text('Tap'), findsOneWidget);
    });
  });

  group('Material widgets in a SkribbleApp', () {
    testWidgets('WiredMaterialTheme installs Material theming and '
        'localizations', (tester) async {
      final wiredTheme = WiredThemeData(
        borderColor: const Color(0xFF283593),
        fillColor: const Color(0xFFE8EAF6),
      );

      late ThemeData materialTheme;
      await tester.pumpWidget(
        SkribbleApp(
          wiredTheme: wiredTheme,
          builder: (context, child) => WiredMaterialTheme(child: child!),
          home: Builder(
            builder: (context) {
              materialTheme = Theme.of(context);
              // Scaffold asserts on MaterialLocalizations; reaching this
              // builder proves the bridge installed them.
              return const Scaffold(body: Text('Material inside Skribble'));
            },
          ),
        ),
      );

      expect(find.text('Material inside Skribble'), findsOneWidget);
      expect(materialTheme.colorScheme.primary, wiredTheme.borderColor);
      expect(
        materialTheme.scaffoldBackgroundColor,
        wiredTheme.paperBackgroundColor,
      );
    });

    testWidgets('Material theme is only installed when requested', (
      tester,
    ) async {
      late ThemeData fallback;
      await tester.pumpWidget(
        SkribbleApp(
          home: Builder(
            builder: (context) {
              fallback = Theme.of(context);
              return const Text('No bridge');
            },
          ),
        ),
      );

      // Without the bridge there is no Material ancestor, so `Theme.of`
      // returns its fallback rather than the Skribble palette.
      expect(
        fallback.colorScheme.primary,
        isNot(WiredThemeData.defaultTheme.borderColor),
      );
    });
  });

  group('WiredMaterialApp still works as the Material bridge', () {
    testWidgets('hosts Wired widgets and Material widgets together', (
      tester,
    ) async {
      final wiredTheme = WiredThemeData(borderColor: const Color(0xFF4E342E));

      late ThemeData materialTheme;
      await tester.pumpWidget(
        WiredMaterialApp(
          wiredTheme: wiredTheme,
          home: Scaffold(
            body: Builder(
              builder: (context) {
                materialTheme = Theme.of(context);
                return const Column(
                  children: [
                    Text('Material text'),
                    WiredButton(child: Text('Wired button')),
                  ],
                );
              },
            ),
          ),
        ),
      );

      expect(find.text('Material text'), findsOneWidget);
      expect(find.text('Wired button'), findsOneWidget);
      expect(materialTheme.colorScheme.primary, wiredTheme.borderColor);
      expect(
        WiredTheme.of(tester.element(find.text('Wired button'))).borderColor,
        wiredTheme.borderColor,
      );
    });
  });
}
