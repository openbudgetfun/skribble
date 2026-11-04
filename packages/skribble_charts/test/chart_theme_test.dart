import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';
import 'package:skribble_charts/skribble_charts.dart';

void main() {
  group('WiredChartStyle', () {
    test('fromTheme uses the theme paper and ink', () {
      final theme = WiredThemeData.cuddly();
      final style = WiredChartStyle.fromTheme(theme, handDrawn: false);

      expect(style.background, theme.fillColor);
      expect(style.foreground, theme.textColor);
      expect(style.handDrawn, isFalse);
      expect(style.grid, isNot(style.background));
      expect(style.grid, isNot(style.foreground));
    });

    test('fromTheme keeps rise, fall, and indicator ink readable', () {
      for (final brightness in Brightness.values) {
        final theme = WiredThemeData.cuddly(brightness: brightness);
        final style = WiredChartStyle.fromTheme(theme);

        for (final ink in [style.rise, style.fall, ...style.indicatorColors]) {
          expect(
            _contrast(ink, style.background),
            greaterThanOrEqualTo(3),
            reason: '$ink on ${style.background} ($brightness)',
          );
        }
        expect(
          _contrast(style.foreground, style.background),
          greaterThanOrEqualTo(4.5),
        );
      }
    });

    test('equal settings compare equal so charts keep their layout', () {
      final theme = WiredThemeData.cuddly(brightness: Brightness.dark);
      expect(
        WiredChartStyle.fromTheme(theme),
        WiredChartStyle.fromTheme(theme),
      );
      expect(
        WiredChartStyle.fromTheme(theme).hashCode,
        WiredChartStyle.fromTheme(theme).hashCode,
      );
      expect(
        const WiredChartStyle(),
        isNot(const WiredChartStyle(roughness: 1)),
      );
      expect(
        const WiredChartStyle(indicatorColors: [Color(0xFF000000)]),
        isNot(const WiredChartStyle()),
      );
    });
  });
}

double _contrast(Color a, Color b) {
  final first = a.computeLuminance();
  final second = b.computeLuminance();
  final light = first > second ? first : second;
  final dark = first > second ? second : first;
  return (light + 0.05) / (dark + 0.05);
}
