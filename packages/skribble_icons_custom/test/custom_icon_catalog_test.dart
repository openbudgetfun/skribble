import 'package:flutter_test/flutter_test.dart';
import 'package:skribble_icons_custom/skribble_icons_custom.dart';

void main() {
  group('kCustomRoughIcons map', () {
    test('is non-empty', () {
      expect(kCustomRoughIcons, isNotEmpty);
    });

    test('contains exactly 5 icons', () {
      expect(kCustomRoughIcons.length, 5);
    });

    test('every entry has a non-empty primitives list', () {
      for (final entry in kCustomRoughIcons.entries) {
        expect(
          entry.value.primitives,
          isNotEmpty,
          reason: 'Icon 0x${entry.key.toRadixString(16)} has no primitives',
        );
      }
    });

    test('every entry has positive dimensions', () {
      for (final entry in kCustomRoughIcons.entries) {
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

  group('kCustomRoughIconsCodePoints map', () {
    test('contains all expected identifiers', () {
      expect(
        kCustomRoughIconsCodePoints.keys,
        containsAll(<String>['home', 'search', 'settings', 'star', 'favorite']),
      );
    });

    test('every identifier resolves to a codepoint present in the icon map', () {
      for (final entry in kCustomRoughIconsCodePoints.entries) {
        expect(
          kCustomRoughIcons,
          contains(entry.value),
          reason: 'Identifier "${entry.key}" codepoint '
              '0x${entry.value.toRadixString(16)} missing from map',
        );
      }
    });
  });

  group('lookupCustomRoughIconByIdentifier', () {
    test('returns icon data for known identifiers', () {
      for (final name in <String>[
        'home',
        'search',
        'settings',
        'star',
        'favorite',
      ]) {
        final result = lookupCustomRoughIconByIdentifier(name);
        expect(result, isA<WiredSvgIconData>(), reason: '"$name" not found');
      }
    });

    test('returns null for unknown identifier', () {
      expect(lookupCustomRoughIconByIdentifier('does_not_exist'), isNull);
    });

    test('home icon has expected codepoint 0xe901', () {
      expect(kCustomRoughIconsCodePoints['home'], 0xe901);
    });
  });

  group('WiredSvgIconData structure', () {
    test('home icon has a path primitive', () {
      final home = lookupCustomRoughIconByIdentifier('home')!;
      expect(home.primitives.first, isA<WiredSvgPathPrimitive>());
    });

    test('search icon SVG path is non-empty', () {
      final search = lookupCustomRoughIconByIdentifier('search')!;
      final path = search.primitives.first as WiredSvgPathPrimitive;
      expect(path.data, isNotEmpty);
    });
  });
}
