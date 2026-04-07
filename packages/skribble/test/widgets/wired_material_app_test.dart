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
  });
}
