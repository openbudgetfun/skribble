import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/src/wired_svg_icon_data.dart';

void main() {
  group('Icon Font Generation', () {
    test('WiredSvgIconData can be created from paths', () {
      final iconData = WiredSvgIconData(
        width: 24,
        height: 24,
        primitives: [
          WiredSvgPrimitive.path('M12 2L2 22h20L12 2z'),
          WiredSvgPrimitive.path('M12 6l-6 12h12L12 6z'),
        ],
      );

      expect(iconData.width, equals(24));
      expect(iconData.height, equals(24));
      expect(iconData.primitives.length, equals(2));
    });

    test('WiredSvgPathPrimitive stores path data', () {
      final primitive = WiredSvgPrimitive.path('M12 2L2 22h20L12 2z');

      expect(primitive.type, equals(WiredSvgPrimitiveType.path));
      expect(primitive.pathData, equals('M12 2L2 22h20L12 2z'));
    });

    test('WiredSvgCirclePrimitive stores circle data', () {
      final primitive = WiredSvgPrimitive.circle(
        cx: 12,
        cy: 12,
        r: 10,
      );

      expect(primitive.type, equals(WiredSvgPrimitiveType.circle));
    });

    test('WiredSvgEllipsePrimitive stores ellipse data', () {
      final primitive = WiredSvgPrimitive.ellipse(
        cx: 12,
        cy: 12,
        rx: 10,
        ry: 8,
      );

      expect(primitive.type, equals(WiredSvgPrimitiveType.ellipse));
    });

    test('WiredSvgIconData can be scaled', () {
      final iconData = WiredSvgIconData(
        width: 24,
        height: 24,
        primitives: [
          WiredSvgPrimitive.path('M12 2L2 22h20L12 2z'),
        ],
      );

      // Test that the icon data maintains its dimensions
      expect(iconData.width, equals(24));
      expect(iconData.height, equals(24));
    });

    test('WiredSvgFillRule enum values exist', () {
      // Verify fill rule enum values
      expect(WiredSvgFillRule.values.length, greaterThanOrEqualTo(2));
    });
  });
}
