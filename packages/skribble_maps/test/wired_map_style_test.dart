import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble_maps/skribble_maps.dart';

void main() {
  group('WiredMapStyle', () {
    test('paper uses the quiet OpenFreeMap Positron style', () {
      expect(WiredMapStyle.paper, WiredMapStyle.positron);
      expect(
        WiredMapStyle.paper.styleString,
        'https://tiles.openfreemap.org/styles/positron',
      );
    });

    test('night uses the OpenFreeMap dark style', () {
      expect(WiredMapStyle.night, WiredMapStyle.dark);
      expect(
        WiredMapStyle.night.attributionButtonColor,
        const Color(0xFFF4F0E7),
      );
    });

    test('accepts hosted or raw MapLibre styles', () {
      const style = WiredMapStyle(
        styleString: 'asset/styles/check-in-map.json',
      );

      expect(style.styleString, 'asset/styles/check-in-map.json');
    });

    test('copyWith replaces selected values', () {
      final style = WiredMapStyle.paper.copyWith(
        styleString: 'https://maps.example.com/style.json',
      );

      expect(style.styleString, 'https://maps.example.com/style.json');
      expect(
        style.attributionButtonColor,
        WiredMapStyle.paper.attributionButtonColor,
      );
    });

    test('styles use value equality', () {
      const first = WiredMapStyle(styleString: 'style.json');
      const second = WiredMapStyle(styleString: 'style.json');

      expect(first, second);
      expect(first.hashCode, second.hashCode);
    });
  });
}
