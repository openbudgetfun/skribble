import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';
import 'package:skribble_icons_dynamic/skribble_icons_dynamic.dart';

void main() {
  group('kSkribbleDynamicIcons (curated 30 — clean paths)', () {
    test('is non-empty', () {
      expect(kSkribbleDynamicIcons, isNotEmpty);
    });

    test('contains exactly 30 icons', () {
      expect(kSkribbleDynamicIcons.length, 30);
    });

    test('every entry has a non-empty primitives list', () {
      for (final entry in kSkribbleDynamicIcons.entries) {
        expect(
          entry.value.primitives,
          isNotEmpty,
          reason: 'Icon 0x${entry.key.toRadixString(16)} has no primitives',
        );
      }
    });

    test('every entry has positive dimensions', () {
      for (final entry in kSkribbleDynamicIcons.entries) {
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

  group('kSkribbleDynamicIconsCodePoints', () {
    test('contains all 30 custom identifiers', () {
      expect(
        kSkribbleDynamicIconsCodePoints.keys,
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

    test('every identifier resolves to a codepoint in the dynamic map', () {
      for (final entry in kSkribbleDynamicIconsCodePoints.entries) {
        expect(
          kSkribbleDynamicIcons,
          contains(entry.value),
          reason: '"${entry.key}" codepoint '
              '0x${entry.value.toRadixString(16)} missing from dynamic map',
        );
      }
    });
  });

  group('lookupSkribbleDynamicIconByIdentifier (unified)', () {
    test('returns dynamic icon for custom identifier', () {
      final result = lookupSkribbleDynamicIconByIdentifier('heart');
      expect(result, isA<WiredSvgIconData>());
    });

    test('returns Material icon for Material-only identifier', () {
      final result = lookupSkribbleDynamicIconByIdentifier('access_alarm');
      expect(result, isA<WiredSvgIconData>());
    });

    test('returns null for unknown identifier', () {
      expect(
        lookupSkribbleDynamicIconByIdentifier('does_not_exist_xyz'),
        isNull,
      );
    });

    test('custom icons take precedence over Material for shared names', () {
      final unified = lookupSkribbleDynamicIconByIdentifier('home');
      final custom = lookupSkribbleDynamicCustomIconByIdentifier('home');
      expect(unified, isNotNull);
      expect(custom, isNotNull);
      expect(identical(unified, custom), isTrue);
    });
  });

  group('lookupSkribbleDynamicCustomIconByIdentifier', () {
    test('returns data for all 30 custom icons', () {
      for (final name in kSkribbleDynamicIconsCodePoints.keys) {
        final result = lookupSkribbleDynamicCustomIconByIdentifier(name);
        expect(result, isA<WiredSvgIconData>(), reason: '"$name" not found');
      }
    });

    test('returns null for Material-only identifier', () {
      expect(
        lookupSkribbleDynamicCustomIconByIdentifier('access_alarm'),
        isNull,
      );
    });
  });

  group('icon counts', () {
    test('skribbleDynamicCustomIconCount equals 30', () {
      expect(skribbleDynamicCustomIconCount, 30);
    });

    test('skribbleDynamicMaterialIconCount is over 5000', () {
      expect(skribbleDynamicMaterialIconCount, greaterThan(5000));
    });
  });

  group('SkribbleDynamicIcon widget', () {
    testWidgets('renders without error', (tester) async {
      final iconData = kSkribbleDynamicIcons.values.first;
      await tester.pumpWidget(
        MaterialApp(
          home: WiredTheme(data: WiredThemeData(), child: SkribbleDynamicIcon(data: iconData)),
        ),
      );
      expect(find.byType(SkribbleDynamicIcon), findsOneWidget);
      expect(find.byType(WiredSvgIcon), findsOneWidget);
    });

    testWidgets('respects custom size', (tester) async {
      final iconData = kSkribbleDynamicIcons.values.first;
      await tester.pumpWidget(
        MaterialApp(
          home: WiredTheme(
            data: WiredThemeData(),
            child: SkribbleDynamicIcon(data: iconData, size: 48),
          ),
        ),
      );

      final wiredIcon = tester.widget<WiredSvgIcon>(find.byType(WiredSvgIcon));
      expect(wiredIcon.size, 48);
    });

    testWidgets('passes fill style to WiredSvgIcon', (tester) async {
      final iconData = kSkribbleDynamicIcons.values.first;
      await tester.pumpWidget(
        MaterialApp(
          home: WiredTheme(
            data: WiredThemeData(),
            child: SkribbleDynamicIcon(
              data: iconData,
              fillStyle: WiredIconFillStyle.hachure,
            ),
          ),
        ),
      );

      final wiredIcon = tester.widget<WiredSvgIcon>(find.byType(WiredSvgIcon));
      expect(wiredIcon.fillStyle, WiredIconFillStyle.hachure);
    });

    testWidgets('adds semantics label when provided', (tester) async {
      final iconData = kSkribbleDynamicIcons.values.first;
      await tester.pumpWidget(
        MaterialApp(
          home: WiredTheme(
            data: WiredThemeData(),
            child: SkribbleDynamicIcon(
              data: iconData,
              semanticLabel: 'Test dynamic icon',
            ),
          ),
        ),
      );

      expect(find.bySemanticsLabel('Test dynamic icon'), findsOneWidget);
    });
  });
}
