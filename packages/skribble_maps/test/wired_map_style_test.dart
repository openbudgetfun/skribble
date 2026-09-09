import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';
import 'package:skribble_maps/skribble_maps.dart';

void main() {
  group('WiredMapStyle', () {
    test('paper style resolves semantic road paint', () {
      final paint = WiredMapStyle.paper.paintFor(WiredMapFeatureKind.road);

      expect(paint.ink, WiredMapStyle.paper.roadColor);
      expect(paint.secondaryInk, WiredMapStyle.paper.roadPaperColor);
    });

    test('copyWith replaces selected values', () {
      final style = WiredMapStyle.paper.copyWith(
        roughness: 0,
        minimumBuildingZoom: 12,
      );

      expect(style.roughness, 0);
      expect(style.minimumBuildingZoom, 12);
      expect(style.waterColor, WiredMapStyle.paper.waterColor);
    });

    test('styles use value equality for cache stability', () {
      final first = WiredMapStyle.paper.copyWith();
      final second = WiredMapStyle.paper.copyWith();

      expect(first, second);
      expect(first.hashCode, second.hashCode);
    });

    test('fromTheme follows the Wired palette', () {
      final theme = WiredThemeData(
        borderColor: const Color(0xFF123456),
        textColor: const Color(0xFF101010),
        disabledTextColor: const Color(0xFF999999),
        fillColor: const Color(0xFFF5F2E9),
      );

      final style = WiredMapStyle.fromTheme(theme);

      expect(style.paperColor, theme.fillColor);
      expect(style.roadColor, theme.borderColor);
      expect(style.labelColor, theme.textColor);
    });
  });
}
