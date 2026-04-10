import 'package:flutter_test/flutter_test.dart';
import 'package:skribble_icons/skribble_icons.dart';

void main() {
  group('kSkribbleIcons map', () {
    test('is non-empty', () {
      expect(kSkribbleIcons, isNotEmpty);
    });

    test('contains exactly 30 icons', () {
      expect(kSkribbleIcons.length, 30);
    });

    test('every entry has a non-empty primitives list', () {
      for (final entry in kSkribbleIcons.entries) {
        expect(
          entry.value.primitives,
          isNotEmpty,
          reason: 'Icon 0x${entry.key.toRadixString(16)} has no primitives',
        );
      }
    });

    test('every entry has positive dimensions', () {
      for (final entry in kSkribbleIcons.entries) {
        expect(
          entry.value.width,
          greaterThan(0),
          reason: '0x${entry.key.toRadixString(16)} width must be > 0',
        );
        expect(
          entry.value.height,
          greaterThan(0),
          reason: '0x${entry.key.toRadixString(16)} height must be > 0',
        );
      }
    });
  });

  group('kSkribbleIconsCodePoints map', () {
    test('contains all expected identifiers', () {
      expect(
        kSkribbleIconsCodePoints.keys,
        containsAll(<String>[
          'home',
          'search',
          'settings',
          'star',
          'heart',
          'user',
          'menu',
          'close',
          'check',
          'plus',
          'minus',
          'arrow_left',
          'arrow_right',
          'arrow_up',
          'arrow_down',
          'edit',
          'delete',
          'share',
          'copy',
          'mail',
          'phone',
          'camera',
          'image',
          'calendar',
          'clock',
          'lock',
          'unlock',
          'eye',
          'eye_off',
          'notification',
        ]),
      );
    });

    test('every identifier resolves to a codepoint present in the icon map',
        () {
      for (final entry in kSkribbleIconsCodePoints.entries) {
        expect(
          kSkribbleIcons,
          contains(entry.value),
          reason: 'Identifier "${entry.key}" codepoint '
              '0x${entry.value.toRadixString(16)} missing from map',
        );
      }
    });
  });

  group('lookupSkribbleIconByIdentifier', () {
    test('returns icon data for known identifiers', () {
      for (final name in <String>[
        'home',
        'search',
        'settings',
        'star',
        'heart',
        'user',
        'menu',
        'close',
        'check',
        'plus',
        'minus',
        'arrow_left',
        'arrow_right',
        'arrow_up',
        'arrow_down',
        'edit',
        'delete',
        'share',
        'copy',
        'mail',
        'phone',
        'camera',
        'image',
        'calendar',
        'clock',
        'lock',
        'unlock',
        'eye',
        'eye_off',
        'notification',
      ]) {
        final result = lookupSkribbleIconByIdentifier(name);
        expect(result, isA<WiredSvgIconData>(), reason: '"$name" not found');
      }
    });

    test('returns null for unknown identifier', () {
      expect(lookupSkribbleIconByIdentifier('does_not_exist'), isNull);
    });

    test('home icon has expected codepoint 0xf001', () {
      expect(kSkribbleIconsCodePoints['home'], 0xf001);
    });
  });

  group('WiredSvgIconData structure', () {
    test('home icon has a path primitive', () {
      final home = lookupSkribbleIconByIdentifier('home')!;
      expect(home.primitives.first, isA<WiredSvgPathPrimitive>());
    });

    test('search icon SVG path is non-empty', () {
      final search = lookupSkribbleIconByIdentifier('search')!;
      final path = search.primitives.first as WiredSvgPathPrimitive;
      expect(path.data, isNotEmpty);
    });
  });
}
