import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';
import 'package:skribble_emoji/skribble_emoji.dart';

void main() {
  final config = DrawConfig.build(seed: 5);

  EmojiVector vector(String emoji, {EmojiPalette? palette}) => EmojiVector(
    SkribbleEmoji.lookup(emoji)!,
    size: 72,
    config: config,
    palette: palette ?? EmojiPalette.skribble,
  );

  int count(String text, String pattern) => pattern.allMatches(text).length;

  group('EmojiVector', () {
    test('has the parts the drawing paints', () {
      final grin = SkribbleEmoji.lookup('😀')!;
      final drawing = EmojiDrawing(grin, size: 72, config: config);
      final shapes = vector('😀').shapes;
      expect({for (final shape in shapes) ?shape.part}, drawing.parts.toSet());
      expect(
        shapes.every((shape) => shape.fill != null || shape.ink != null),
        isTrue,
      );
    });

    test('writes a square SVG with a group per shape', () {
      final grin = vector('😀');
      final svg = grin.toSvg();
      expect(
        svg,
        startsWith(
          '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 72 72" '
          'width="72" height="72">',
        ),
      );
      expect(svg, endsWith('</svg>'));
      expect(count(svg, '<g'), grin.shapes.length);
      expect(count(svg, '</g>'), grin.shapes.length);
      expect(svg, contains('data-part="eyes"'));
      // The marker palette is opaque, and nothing here is clipped.
      expect(svg, isNot(contains('fill-opacity')));
      expect(svg, isNot(contains('<defs>')));
    });

    test('defines each clip once and points its shape at it', () {
      final socks = vector('🧦');
      final clipped = socks.shapes.where((shape) => shape.clip != null);
      expect(clipped, isNotEmpty);
      final svg = socks.toSvg();
      expect(count(svg, '<clipPath id='), clipped.length);
      for (var index = 0; index < clipped.length; index++) {
        expect(svg, contains('clip-path="url(#c$index)"'));
        expect(svg, contains('<clipPath id="c$index">'));
      }
      expect(count(svg, '<defs>'), 1);
    });

    test('keeps the even-odd rule for fills with holes', () {
      final scissors = vector('✂️');
      final holes = scissors.shapes.where((shape) => shape.evenOdd);
      expect(holes, isNotEmpty);
      expect(count(scissors.toSvg(), 'fill-rule="evenodd"'), holes.length);
    });

    test('writes translucent colours with their opacity', () {
      final ghostly = vector(
        '😀',
        palette: EmojiPalette.skribble.copyWith(
          colors: {EmojiToken.ink: const Color(0x80112233)},
        ),
      );
      final svg = ghostly.toSvg();
      expect(svg, contains('fill="#112233" fill-opacity="0.5"'));
    });
  });
}
