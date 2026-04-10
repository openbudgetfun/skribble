import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';

import '../helpers/pump_app.dart';

void main() {
  group('WiredThemeData', () {
    test('has correct default values', () {
      final theme = WiredThemeData();

      expect(theme.borderColor, const Color(0xFF1A2B3C));
      expect(theme.textColor, Colors.black);
      expect(theme.disabledTextColor, Colors.grey);
      expect(theme.fillColor, const Color(0xFFFEFEFE));
      expect(theme.strokeWidth, 2);
      expect(theme.roughness, 1);
      expect(theme.fontFamily, skribbleFontFamily);
    });

    test('skribbleFontFamily constant is ArchitectsDaughter', () {
      expect(skribbleFontFamily, 'ArchitectsDaughter');
    });

    test('drawConfig returns defaultValues when not provided', () {
      final theme = WiredThemeData();

      expect(theme.drawConfig, DrawConfig.defaultValues);
    });

    test('drawConfig returns custom value when provided', () {
      final customConfig = DrawConfig.build(roughness: 3);
      final theme = WiredThemeData(drawConfig: customConfig);

      expect(theme.drawConfig, customConfig);
    });

    test('defaultTheme is a valid WiredThemeData instance', () {
      final defaultTheme = WiredThemeData.defaultTheme;

      expect(defaultTheme, isA<WiredThemeData>());
      expect(defaultTheme.borderColor, const Color(0xFF1A2B3C));
      expect(defaultTheme.strokeWidth, 2);
    });

    test('accepts custom values', () {
      final theme = WiredThemeData(
        borderColor: Colors.red,
        textColor: Colors.blue,
        disabledTextColor: Colors.green,
        fillColor: Colors.yellow,
        strokeWidth: 4,
        roughness: 2.5,
        fontFamily: 'Comic Sans',
      );

      expect(theme.borderColor, Colors.red);
      expect(theme.textColor, Colors.blue);
      expect(theme.disabledTextColor, Colors.green);
      expect(theme.fillColor, Colors.yellow);
      expect(theme.strokeWidth, 4);
      expect(theme.roughness, 2.5);
      expect(theme.fontFamily, 'Comic Sans');
    });

    test('paperBackgroundColor softly lifts fillColor', () {
      final theme = WiredThemeData(fillColor: const Color(0xFFFFF8E1));

      expect(theme.paperBackgroundColor, isNot(theme.fillColor));
      expect(theme.paperBackgroundColor.alpha, 0xFF);
    });

    test('toColorScheme maps Skribble palette to Material colors', () {
      final theme = WiredThemeData(
        borderColor: const Color(0xFF4A3470),
        textColor: const Color(0xFF2A2238),
        fillColor: const Color(0xFFFFFCF1),
      );

      final scheme = theme.toColorScheme();

      expect(scheme.primary, theme.borderColor);
      expect(scheme.secondary, theme.textColor);
      expect(scheme.surface, theme.fillColor);
      expect(scheme.onSurface, theme.textColor);
    });

    test(
      'toThemeData builds a Material theme aligned with Skribble colors',
      () {
        final theme = WiredThemeData(
          borderColor: const Color(0xFF4A3470),
          textColor: const Color(0xFF2A2238),
          fillColor: const Color(0xFFFFFCF1),
          strokeWidth: 3,
        );

        final materialTheme = theme.toThemeData();

        expect(materialTheme.useMaterial3, isTrue);
        expect(
          materialTheme.scaffoldBackgroundColor,
          theme.paperBackgroundColor,
        );
        expect(materialTheme.colorScheme.primary, theme.borderColor);
        expect(materialTheme.colorScheme.surface, theme.fillColor);
        expect(materialTheme.cardTheme.color, theme.fillColor);
        expect(
          materialTheme.inputDecorationTheme.enabledBorder,
          isA<OutlineInputBorder>(),
        );
      },
    );

    test('toThemeData applies the Skribble font family to text theme', () {
      final theme = WiredThemeData();
      final materialTheme = theme.toThemeData();

      expect(
        materialTheme.textTheme.bodyLarge?.fontFamily,
        skribbleFontFamily,
      );
      expect(
        materialTheme.textTheme.bodyMedium?.fontFamily,
        skribbleFontFamily,
      );
      expect(
        materialTheme.textTheme.headlineMedium?.fontFamily,
        skribbleFontFamily,
      );
      expect(
        materialTheme.textTheme.titleLarge?.fontFamily,
        skribbleFontFamily,
      );
    });

    test('toThemeData applies a custom font family to text theme', () {
      final theme = WiredThemeData(fontFamily: 'CustomFont');
      final materialTheme = theme.toThemeData();

      expect(materialTheme.textTheme.bodyLarge?.fontFamily, 'CustomFont');
      expect(materialTheme.textTheme.displayLarge?.fontFamily, 'CustomFont');
    });

    group('copyWith', () {
      test('returns new instance with updated borderColor', () {
        final original = WiredThemeData();
        final copied = original.copyWith(borderColor: Colors.red);

        expect(copied.borderColor, Colors.red);
        expect(copied.textColor, original.textColor);
        expect(copied.fillColor, original.fillColor);
        expect(copied.strokeWidth, original.strokeWidth);
      });

      test('returns new instance with updated textColor', () {
        final original = WiredThemeData();
        final copied = original.copyWith(textColor: Colors.purple);

        expect(copied.textColor, Colors.purple);
        expect(copied.borderColor, original.borderColor);
      });

      test('returns new instance with updated disabledTextColor', () {
        final original = WiredThemeData();
        final copied = original.copyWith(disabledTextColor: Colors.orange);

        expect(copied.disabledTextColor, Colors.orange);
      });

      test('returns new instance with updated fillColor', () {
        final original = WiredThemeData();
        final copied = original.copyWith(fillColor: Colors.cyan);

        expect(copied.fillColor, Colors.cyan);
      });

      test('returns new instance with updated strokeWidth', () {
        final original = WiredThemeData();
        final copied = original.copyWith(strokeWidth: 5);

        expect(copied.strokeWidth, 5);
      });

      test('returns new instance with updated roughness', () {
        final original = WiredThemeData();
        final copied = original.copyWith(roughness: 3.0);

        expect(copied.roughness, 3.0);
      });

      test('returns new instance with updated drawConfig', () {
        final original = WiredThemeData();
        final newConfig = DrawConfig.build(roughness: 5);
        final copied = original.copyWith(drawConfig: newConfig);

        expect(copied.drawConfig, newConfig);
      });

      test('returns new instance with updated fontFamily', () {
        final original = WiredThemeData();
        final copied = original.copyWith(fontFamily: 'Roboto');

        expect(copied.fontFamily, 'Roboto');
        expect(copied.borderColor, original.borderColor);
      });

      test('preserves all values when no arguments provided', () {
        final original = WiredThemeData(
          borderColor: Colors.red,
          textColor: Colors.blue,
          disabledTextColor: Colors.green,
          fillColor: Colors.yellow,
          strokeWidth: 4,
          roughness: 2.5,
          fontFamily: 'TestFont',
        );
        final copied = original.copyWith();

        expect(copied.borderColor, original.borderColor);
        expect(copied.textColor, original.textColor);
        expect(copied.disabledTextColor, original.disabledTextColor);
        expect(copied.fillColor, original.fillColor);
        expect(copied.strokeWidth, original.strokeWidth);
        expect(copied.roughness, original.roughness);
        expect(copied.fontFamily, original.fontFamily);
      });
    });
  });

  group('WiredTheme', () {
    testWidgets('renders child widget', (tester) async {
      await pumpApp(
        tester,
        WiredTheme(data: WiredThemeData(), child: const Text('Hello')),
      );

      expect(find.text('Hello'), findsOneWidget);
    });

    testWidgets('provides theme data to descendants', (tester) async {
      late WiredThemeData capturedTheme;

      await pumpApp(
        tester,
        WiredTheme(
          data: WiredThemeData(borderColor: Colors.red),
          child: Builder(
            builder: (context) {
              capturedTheme = WiredTheme.of(context);
              return const SizedBox();
            },
          ),
        ),
      );

      expect(capturedTheme.borderColor, Colors.red);
    });

    testWidgets('of() returns defaultTheme when no WiredTheme ancestor', (
      tester,
    ) async {
      late WiredThemeData capturedTheme;

      await pumpApp(
        tester,
        Builder(
          builder: (context) {
            capturedTheme = WiredTheme.of(context);
            return const SizedBox();
          },
        ),
      );

      expect(
        capturedTheme.borderColor,
        WiredThemeData.defaultTheme.borderColor,
      );
      expect(capturedTheme.textColor, WiredThemeData.defaultTheme.textColor);
      expect(
        capturedTheme.strokeWidth,
        WiredThemeData.defaultTheme.strokeWidth,
      );
    });

    testWidgets('nearest WiredTheme wins when nested', (tester) async {
      late WiredThemeData capturedTheme;

      await pumpApp(
        tester,
        WiredTheme(
          data: WiredThemeData(borderColor: Colors.red),
          child: WiredTheme(
            data: WiredThemeData(borderColor: Colors.blue),
            child: Builder(
              builder: (context) {
                capturedTheme = WiredTheme.of(context);
                return const SizedBox();
              },
            ),
          ),
        ),
      );

      // The nearest ancestor theme (blue) should be returned.
      expect(capturedTheme.borderColor, Colors.blue);
    });

    testWidgets('updateShouldNotify returns true when data changes', (
      tester,
    ) async {
      var buildCount = 0;
      final themeData = ValueNotifier(WiredThemeData(borderColor: Colors.red));

      await pumpApp(
        tester,
        ValueListenableBuilder<WiredThemeData>(
          valueListenable: themeData,
          builder: (context, data, _) {
            return WiredTheme(
              data: data,
              child: Builder(
                builder: (context) {
                  // Access the theme to register dependency.
                  WiredTheme.of(context);
                  buildCount++;
                  return const SizedBox();
                },
              ),
            );
          },
        ),
      );

      final initialBuildCount = buildCount;

      // Change the theme data to trigger updateShouldNotify.
      themeData.value = WiredThemeData(borderColor: Colors.green);
      await tester.pump();

      // The builder should have been called again because the theme data
      // changed.
      expect(buildCount, greaterThan(initialBuildCount));
    });

    testWidgets('renders without error with default theme', (tester) async {
      await pumpApp(
        tester,
        WiredTheme(
          data: WiredThemeData.defaultTheme,
          child: const Text('Default theme'),
        ),
      );

      expect(find.text('Default theme'), findsOneWidget);
      expect(find.byType(WiredTheme), findsOneWidget);
    });

    testWidgets('WiredButton reads border color from theme', (tester) async {
      await pumpApp(
        tester,
        WiredTheme(
          data: WiredThemeData(borderColor: Colors.red),
          child: WiredButton(onPressed: () {}, child: const Text('Themed')),
        ),
      );
      // Should render without error using the custom theme
      expect(find.text('Themed'), findsOneWidget);
    });

    testWidgets('WiredDialog reads fill color from theme', (tester) async {
      await pumpApp(
        tester,
        WiredTheme(
          data: WiredThemeData(fillColor: Colors.amber),
          child: const WiredDialog(child: Text('Dialog')),
        ),
      );
      expect(find.text('Dialog'), findsOneWidget);
    });

    testWidgets('WiredCard reads fill color from theme', (tester) async {
      await pumpApp(
        tester,
        WiredTheme(
          data: WiredThemeData(fillColor: Colors.lime),
          child: WiredCard(child: const Text('Card')),
        ),
      );
      expect(find.text('Card'), findsOneWidget);
    });

    testWidgets('is an InheritedWidget', (tester) async {
      await pumpApp(
        tester,
        WiredTheme(data: WiredThemeData(), child: const SizedBox()),
      );

      final widget = tester.widget<WiredTheme>(find.byType(WiredTheme));
      expect(widget, isA<InheritedWidget>());
    });

    testWidgets('provides all custom theme properties to descendants', (
      tester,
    ) async {
      late WiredThemeData capturedTheme;

      final customTheme = WiredThemeData(
        borderColor: Colors.purple,
        textColor: Colors.orange,
        disabledTextColor: Colors.pink,
        fillColor: Colors.teal,
        strokeWidth: 5,
        roughness: 3.0,
      );

      await pumpApp(
        tester,
        WiredTheme(
          data: customTheme,
          child: Builder(
            builder: (context) {
              capturedTheme = WiredTheme.of(context);
              return const SizedBox();
            },
          ),
        ),
      );

      expect(capturedTheme.borderColor, Colors.purple);
      expect(capturedTheme.textColor, Colors.orange);
      expect(capturedTheme.disabledTextColor, Colors.pink);
      expect(capturedTheme.fillColor, Colors.teal);
      expect(capturedTheme.strokeWidth, 5);
      expect(capturedTheme.roughness, 3.0);
    });

    testWidgets('provides fontFamily to descendants', (tester) async {
      late WiredThemeData capturedTheme;

      await pumpApp(
        tester,
        WiredTheme(
          data: WiredThemeData(fontFamily: 'TestHandwritten'),
          child: Builder(
            builder: (context) {
              capturedTheme = WiredTheme.of(context);
              return const SizedBox();
            },
          ),
        ),
      );

      expect(capturedTheme.fontFamily, 'TestHandwritten');
    });

    testWidgets('default fontFamily is skribbleFontFamily', (tester) async {
      late WiredThemeData capturedTheme;

      await pumpApp(
        tester,
        WiredTheme(
          data: WiredThemeData(),
          child: Builder(
            builder: (context) {
              capturedTheme = WiredTheme.of(context);
              return const SizedBox();
            },
          ),
        ),
      );

      expect(capturedTheme.fontFamily, skribbleFontFamily);
    });
  });
}
