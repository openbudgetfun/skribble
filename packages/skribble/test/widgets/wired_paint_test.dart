import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';

void main() {
  group('sizing constants', () {
    test('buttons and chips start at their least heights', () {
      expect(kWiredButtonHeight, 42);
      expect(kWiredChipHeight, 36);
      expect(kWiredChipHeight, lessThan(kWiredButtonHeight));
    });

    test('the ink padding keeps 8 above and below and 12 at the sides', () {
      expect(
        kWiredInkPadding,
        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      );
    });

    test('buttons pad wider than the ink padding, never tighter', () {
      expect(kWiredButtonPadding.top, kWiredInkPadding.top);
      expect(kWiredButtonPadding.bottom, kWiredInkPadding.bottom);
      expect(kWiredButtonPadding.left, greaterThan(kWiredInkPadding.left));
      expect(kWiredButtonPadding.right, greaterThan(kWiredInkPadding.right));
    });
  });

  group('WiredBase', () {
    test('fill paint strokes in the given colour', () {
      final paint = WiredBase.fillPainter(WiredPalette.lilac);
      expect(paint.color.toARGB32(), WiredPalette.lilac.toARGB32());
      expect(paint.style, PaintingStyle.stroke);
      expect(paint.isAntiAlias, isTrue);
    });

    test('path paint draws round-ended lines at the given width', () {
      final paint = WiredBase.pathPainter(3, color: WiredPalette.ink);
      expect(paint.color.toARGB32(), WiredPalette.ink.toARGB32());
      expect(paint.strokeWidth, 3);
      expect(paint.style, PaintingStyle.stroke);
      expect(paint.strokeCap, StrokeCap.round);
      expect(paint.strokeJoin, StrokeJoin.round);
    });
  });
}
