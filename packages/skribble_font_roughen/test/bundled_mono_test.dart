import 'dart:io';

import 'package:skribble_font_roughen/src/truetype_font.dart';
import 'package:test/test.dart';

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
        for (final table in ['hmtx', 'cmap', 'GSUB', 'GPOS', 'GDEF', 'OS/2']) {
          expect(rough.tables[table], original.tables[table], reason: table);
        }
        expect(rough.tables['glyf'], isNot(original.tables['glyf']));
        // The post table's isFixedPitch field must survive renaming.
        expect(
          rough.tables['post']!.sublist(12, 16),
          original.tables['post']!.sublist(12, 16),
        );
      });
    }
  }
}
