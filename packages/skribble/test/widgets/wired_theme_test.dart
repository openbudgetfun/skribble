import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';

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
      );

      expect(theme.borderColor, Colors.red);
      expect(theme.textColor, Colors.blue);
      expect(theme.disabledTextColor, Colors.green);
      expect(theme.fillColor, Colors.yellow);
      expect(theme.strokeWidth, 4);
      expect(theme.roughness, 2.5);
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

      test('preserves all values when no arguments provided', () {
        final original = WiredThemeData(
          borderColor: Colors.red,
          textColor: Colors.blue,
          disabledTextColor: Colors.green,
          fillColor: Colors.yellow,
          strokeWidth: 4,
          roughness: 2.5,
        );
        final copied = original.copyWith();

        expect(copied.borderColor, original.borderColor);
        expect(copied.textColor, original.textColor);
        expect(copied.disabledTextColor, original.disabledTextColor);
        expect(copied.fillColor, original.fillColor);
        expect(copied.strokeWidth, original.strokeWidth);
        expect(copied.roughness, original.roughness);
      });
    });
  });

  group('WiredTheme', () {
    testWidgets('renders child widget', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WiredTheme(
              data: WiredThemeData(),
              child: const Text('Hello'),
            ),
          ),
        ),
      );

      expect(find.text('Hello'), findsOneWidget);
    });

    testWidgets('provides theme data to descendants', (tester) async {
      late WiredThemeData capturedTheme;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WiredTheme(
              data: WiredThemeData(borderColor: Colors.red),
              child: Builder(
                builder: (context) {
                  capturedTheme = WiredTheme.of(context);
                  return const SizedBox();
                },
              ),
            ),
          ),
        ),
      );

      expect(capturedTheme.borderColor, Colors.red);
    });

    testWidgets('of() returns defaultTheme when no WiredTheme ancestor',
        (tester) async {
      late WiredThemeData capturedTheme;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                capturedTheme = WiredTheme.of(context);
                return const SizedBox();
              },
            ),
          ),
        ),
      );

      expect(capturedTheme.borderColor, WiredThemeData.defaultTheme.borderColor);
      expect(capturedTheme.textColor, WiredThemeData.defaultTheme.textColor);
      expect(capturedTheme.strokeWidth, WiredThemeData.defaultTheme.strokeWidth);
    });

    testWidgets('nearest WiredTheme wins when nested', (tester) async {
      late WiredThemeData capturedTheme;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WiredTheme(
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
          ),
        ),
      );

      // The nearest ancestor theme (blue) should be returned.
      expect(capturedTheme.borderColor, Colors.blue);
    });

    testWidgets('updateShouldNotify returns true when data changes',
        (tester) async {
      var buildCount = 0;
      final themeData = ValueNotifier(WiredThemeData(borderColor: Colors.red));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ValueListenableBuilder<WiredThemeData>(
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
          ),
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
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WiredTheme(
              data: WiredThemeData.defaultTheme,
              child: const Text('Default theme'),
            ),
          ),
        ),
      );

      expect(find.text('Default theme'), findsOneWidget);
      expect(find.byType(WiredTheme), findsOneWidget);
    });

    testWidgets('is an InheritedWidget', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WiredTheme(
              data: WiredThemeData(),
              child: const SizedBox(),
            ),
          ),
        ),
      );

      final widget = tester.widget<WiredTheme>(find.byType(WiredTheme));
      expect(widget, isA<InheritedWidget>());
    });

    testWidgets('provides all custom theme properties to descendants',
        (tester) async {
      late WiredThemeData capturedTheme;

      final customTheme = WiredThemeData(
        borderColor: Colors.purple,
        textColor: Colors.orange,
        disabledTextColor: Colors.pink,
        fillColor: Colors.teal,
        strokeWidth: 5,
        roughness: 3.0,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WiredTheme(
              data: customTheme,
              child: Builder(
                builder: (context) {
                  capturedTheme = WiredTheme.of(context);
                  return const SizedBox();
                },
              ),
            ),
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
  });
}
