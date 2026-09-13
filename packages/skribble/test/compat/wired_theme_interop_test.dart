import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';

void main() {
  group('WiredThemeInterop.fromThemeData', () {
    test('maps Material color roles onto Skribble tokens', () {
      final theme = ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2D6A4F),
        ),
      );

      final wired = WiredThemeInterop.fromThemeData(theme);

      expect(wired.borderColor, theme.colorScheme.primary);
      expect(wired.textColor, theme.colorScheme.onSurface);
      expect(wired.fillColor, theme.colorScheme.surface);
      expect(wired.disabledTextColor, theme.disabledColor);
    });

    test('derives the stroke width from the shape language', () {
      final themed = WiredThemeData(strokeWidth: 3.5).toThemeData();
      final wired = WiredThemeInterop.fromThemeData(themed);

      expect(wired.strokeWidth, 3.5);
    });

    test('derives the font family from the text theme', () {
      final theme = ThemeData(
        textTheme: const TextTheme(
          bodyMedium: TextStyle(fontFamily: 'Inter'),
        ),
      );

      expect(WiredThemeInterop.fromThemeData(theme).fontFamily, 'Inter');
    });

    test('keeps Skribble roughness and motion defaults', () {
      final wired = WiredThemeInterop.fromThemeData(ThemeData());

      expect(wired.roughnessLevel, WiredThemeData().roughnessLevel);
      expect(wired.motionEnabled, isTrue);
    });
  });

  group('WiredThemeInterop.fromColorScheme', () {
    test('maps color roles without a full ThemeData', () {
      final scheme = ColorScheme.fromSeed(
        seedColor: const Color(0xFF9D0208),
        brightness: Brightness.dark,
      );

      final wired = WiredThemeInterop.fromColorScheme(scheme);

      expect(wired.borderColor, scheme.primary);
      expect(wired.fillColor, scheme.surface);
      expect(wired.textColor, scheme.onSurface);
      expect(wired.disabledTextColor.a, closeTo(0.38, 0.01));
    });
  });

  group('WiredThemeInterop.fromCupertinoTheme', () {
    test('maps Cupertino colors onto Skribble tokens', () {
      final cupertino = CupertinoThemeData(
        brightness: Brightness.dark,
        primaryColor: CupertinoColors.systemPink,
        scaffoldBackgroundColor: const Color(0xFF101010),
        textTheme: const CupertinoTextThemeData(
          textStyle: TextStyle(color: Color(0xFFEEEEEE), fontFamily: 'Inter'),
        ),
      );

      final wired = WiredThemeInterop.fromCupertinoTheme(cupertino);

      expect(wired.borderColor, CupertinoColors.systemPink);
      expect(wired.fillColor, const Color(0xFF101010));
      expect(wired.textColor, const Color(0xFFEEEEEE));
      expect(wired.fontFamily, 'Inter');
      expect(wired.disabledTextColor.a, lessThan(1));
    });

    test('defaults the text color to black in light mode', () {
      final wired = WiredThemeInterop.fromCupertinoTheme(
        CupertinoThemeData(
          brightness: Brightness.light,
          textTheme: const CupertinoTextThemeData(
            textStyle: TextStyle(fontFamily: 'Inter'),
          ),
        ),
      );

      expect(wired.textColor, const Color(0xFF000000));
    });
  });

  group('WiredThemeData.toCupertinoThemeData', () {
    test('maps Skribble tokens onto a Cupertino theme', () {
      final wired = WiredThemeData(
        borderColor: const Color(0xFF223344),
        textColor: const Color(0xFF111111),
        fillColor: const Color(0xFFFAFAFA),
      );

      final cupertino = wired.toCupertinoThemeData();

      expect(cupertino.primaryColor, wired.borderColor);
      expect(cupertino.barBackgroundColor, wired.fillColor);
      expect(_textStyleOf(cupertino).color, wired.textColor);
      expect(_textStyleOf(cupertino).fontFamily, contains(wired.fontFamily));
    });
  });

  group('WiredThemeModeInterop', () {
    test('round trips every Material ThemeMode', () {
      for (final mode in ThemeMode.values) {
        final skribble = WiredThemeModeInterop.fromThemeMode(mode);
        expect(skribble.toThemeMode, mode);
      }
    });
  });
}

TextStyle _textStyleOf(CupertinoThemeData theme) => theme.textTheme.textStyle;
