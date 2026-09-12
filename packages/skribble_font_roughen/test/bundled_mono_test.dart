import 'dart:io';

import 'package:skribble_font_roughen/src/truetype_font.dart';
import 'package:test/test.dart';

import 'helpers/metrics.dart';

void main() {
  for (final style in ['Regular', 'Bold', 'Italic', 'BoldItalic']) {
    for (final level in ['Gentle', 'Playful', 'Expressive']) {
      test('Mono $level $style preserves spacing and shaping', () {
        final original = TrueTypeFont(
          File('../skribble/tool/font/RecursiveMonoLnrSt-$style.ttf')
              .readAsBytesSync(),
        );
        final rough = TrueTypeFont(
          File('../skribble/assets/fonts/SkribbleMono$level-$style.ttf')
              .readAsBytesSync(),
        );
        expect(rough.glyphCount, original.glyphCount);
        expect(rough.tables.containsKey('fvar'), isFalse);
        expect(advances(rough), advances(original));
        for (final table in ['cmap', 'GSUB', 'GPOS', 'GDEF']) {
          expect(rough.tables[table], original.tables[table], reason: table);
        }
        expect(rough.tables['glyf'], isNot(original.tables['glyf']));
        // Static Mono advertises fixed pitch after pinning the variable axis.
        expect(
          rough.tables['post']!.sublist(12, 16),
          [0, 0, 0, 1],
        );
      });
    }
  }
}
