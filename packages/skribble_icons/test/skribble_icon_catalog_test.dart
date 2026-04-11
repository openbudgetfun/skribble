import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';
import 'package:skribble_icons/skribble_icons.dart';

void main() {
  group('kSkribbleCustomIcons (curated 30 — clean paths)', () {
    test('is non-empty', () {
      expect(kSkribbleCustomIcons, isNotEmpty);
    });

    test('contains exactly 30 icons', () {
      expect(kSkribbleCustomIcons.length, 30);
    });

    test('every entry has a non-empty primitives list', () {
      for (final entry in kSkribbleCustomIcons.entries) {
        expect(
          entry.value.primitives,
          isNotEmpty,
          reason: 'Icon 0x${entry.key.toRadixString(16)} has no primitives',
        );
      }
    });

    test('every entry has positive dimensions', () {
      for (final entry in kSkribbleCustomIcons.entries) {
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

  group('kSkribbleCustomIconsRough (curated 30 — pre-computed rough)', () {
    test('is non-empty', () {
      expect(kSkribbleCustomIconsRough, isNotEmpty);
    });

    test('contains exactly 30 icons', () {
      expect(kSkribbleCustomIconsRough.length, 30);
    });

    test('every entry has a non-empty primitives list', () {
      for (final entry in kSkribbleCustomIconsRough.entries) {
        expect(
          entry.value.primitives,
          isNotEmpty,
          reason:
              'Rough icon 0x${entry.key.toRadixString(16)} has no primitives',
        );
      }
    });

    test('every entry has positive dimensions', () {
      for (final entry in kSkribbleCustomIconsRough.entries) {
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

    test('rough icons have more primitives than clean icons', () {
      for (final codePoint in kSkribbleCustomIcons.keys) {
        final clean = kSkribbleCustomIcons[codePoint]!;
        final rough = kSkribbleCustomIconsRough[codePoint]!;
        expect(
          rough.primitives.length,
          greaterThanOrEqualTo(clean.primitives.length),
          reason:
              '0x${codePoint.toRadixString(16)}: rough should have >= '
              'primitives than clean',
        );
      }
    });
  });

  group('Material rough icons (full set via re-export)', () {
    test('materialRoughIconIdentifiers is non-empty', () {
      expect(materialRoughIconIdentifiers, isNotEmpty);
    });

    test('contains thousands of icons', () {
      expect(materialRoughIconIdentifiers.length, greaterThan(5000));
    });

    test('common Material icons are present', () {
      for (final identifier in <String>[
        'search',
        'home',
        'settings',
        'favorite',
        'add',
        'delete',
        'edit',
        'share',
        'menu',
        'close',
        'check',
        'arrow_back',
        'arrow_forward',
        'person',
        'email',
        'phone',
        'camera_alt',
      ]) {
        final data = lookupMaterialRoughIconByIdentifier(identifier);
        expect(
          data,
          isNotNull,
          reason: 'Material icon "$identifier" should be available',
        );
      }
    });
  });

  group('kSkribbleCustomIconsCodePoints', () {
    test('contains all 30 custom identifiers', () {
      expect(
        kSkribbleCustomIconsCodePoints.keys,
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

    test('every identifier resolves to a codepoint in the rough map', () {
      for (final entry in kSkribbleCustomIconsCodePoints.entries) {
        expect(
          kSkribbleCustomIconsRough,
          contains(entry.value),
          reason: '"${entry.key}" codepoint '
              '0x${entry.value.toRadixString(16)} missing from rough map',
        );
      }
    });
  });

  group('lookupSkribbleIconByIdentifier (unified)', () {
    test('returns rough custom icon for custom identifier', () {
      final result = lookupSkribbleIconByIdentifier('heart');
      expect(result, isA<WiredSvgIconData>());
    });

    test('returns Material icon for Material-only identifier', () {
      final result = lookupSkribbleIconByIdentifier('access_alarm');
      expect(result, isA<WiredSvgIconData>());
    });

    test('returns null for unknown identifier', () {
      expect(lookupSkribbleIconByIdentifier('does_not_exist_xyz'), isNull);
    });

    test('custom icons take precedence over Material for shared names', () {
      final unified = lookupSkribbleIconByIdentifier('home');
      final custom = lookupSkribbleCustomIconByIdentifier('home');
      expect(unified, isNotNull);
      expect(custom, isNotNull);
      expect(identical(unified, custom), isTrue);
    });
  });

  group('lookupSkribbleCustomIconByIdentifier', () {
    test('returns data for all 30 custom icons', () {
      for (final name in kSkribbleCustomIconsCodePoints.keys) {
        final result = lookupSkribbleCustomIconByIdentifier(name);
        expect(result, isA<WiredSvgIconData>(), reason: '"$name" not found');
      }
    });

    test('returns null for Material-only identifier', () {
      expect(lookupSkribbleCustomIconByIdentifier('access_alarm'), isNull);
    });
  });

  group('icon counts', () {
    test('skribbleCustomIconCount equals 30', () {
      expect(skribbleCustomIconCount, 30);
    });

    test('skribbleMaterialIconCount is over 5000', () {
      expect(skribbleMaterialIconCount, greaterThan(5000));
    });
  });

  group('WiredSvgIconData structure', () {
    test('custom home rough icon has path primitives', () {
      final home = lookupSkribbleCustomIconByIdentifier('home')!;
      expect(home.primitives.first, isA<WiredSvgPathPrimitive>());
    });

    test('Material search icon has valid primitives', () {
      final search = lookupMaterialRoughIconByIdentifier('search')!;
      expect(search.primitives, isNotEmpty);
      expect(search.width, greaterThan(0));
      expect(search.height, greaterThan(0));
    });
  });

  group('SkribbleIcon widget', () {
    testWidgets('renders without error', (tester) async {
      final iconData = kSkribbleCustomIconsRough.values.first;
      await tester.pumpWidget(
        MaterialApp(
          home: WiredTheme(data: WiredThemeData(), child: SkribbleIcon(data: iconData)),
        ),
      );
      expect(find.byType(SkribbleIcon), findsOneWidget);
      expect(find.byType(RepaintBoundary), findsWidgets);
    });

    testWidgets('respects custom size', (tester) async {
      final iconData = kSkribbleCustomIconsRough.values.first;
      await tester.pumpWidget(
        MaterialApp(
          home: WiredTheme(data: WiredThemeData(), child: SkribbleIcon(data: iconData, size: 48)),
        ),
      );

      final sizedBox = tester.widget<SizedBox>(find.byType(SizedBox));
      expect(sizedBox.width, 48);
      expect(sizedBox.height, 48);
    });

    testWidgets('adds semantics label when provided', (tester) async {
      final iconData = kSkribbleCustomIconsRough.values.first;
      await tester.pumpWidget(
        MaterialApp(
          home: WiredTheme(
            data: WiredThemeData(),
            child: SkribbleIcon(data: iconData, semanticLabel: 'Test icon'),
          ),
        ),
      );

      expect(find.bySemanticsLabel('Test icon'), findsOneWidget);
    });
  });
}
