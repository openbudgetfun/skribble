import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';

void main() {
  group('WiredSvgIconData', () {
    test('stores dimensions and primitive list', () {
      const iconData = WiredSvgIconData(
        width: 24,
        height: 24,
        primitives: [
          WiredSvgPrimitive.circle(cx: 12, cy: 12, radius: 10),
        ],
      );

      expect(iconData.width, 24);
      expect(iconData.height, 24);
      expect(iconData.primitives, hasLength(1));
    });
  });

  group('WiredSvgPrimitive', () {
    test('path primitive builds path from SVG data', () {
      const primitive = WiredSvgPrimitive.path('M0 0 L10 0 L10 10 Z');

      final path = primitive.buildPath();

      expect(path.getBounds(), const Rect.fromLTWH(0, 0, 10, 10));
      expect(path.fillType, PathFillType.nonZero);
    });

    test('circle primitive builds oval path with expected bounds', () {
      const primitive = WiredSvgPrimitive.circle(cx: 10, cy: 12, radius: 4);

      final path = primitive.buildPath();

      expect(path.getBounds(), const Rect.fromLTWH(6, 8, 8, 8));
      expect(path.fillType, PathFillType.nonZero);
    });

    test('ellipse primitive builds oval path with expected bounds', () {
      const primitive = WiredSvgPrimitive.ellipse(
        cx: 10,
        cy: 12,
        radiusX: 6,
        radiusY: 4,
      );

      final path = primitive.buildPath();

      expect(path.getBounds(), const Rect.fromLTWH(4, 8, 12, 8));
      expect(path.fillType, PathFillType.nonZero);
    });

    test('evenOdd fillRule is mapped to PathFillType.evenOdd', () {
      const primitive = WiredSvgPrimitive.circle(
        cx: 10,
        cy: 10,
        radius: 5,
        fillRule: WiredSvgFillRule.evenOdd,
      );

      final path = primitive.buildPath();

      expect(path.fillType, PathFillType.evenOdd);
    });
  });
}
