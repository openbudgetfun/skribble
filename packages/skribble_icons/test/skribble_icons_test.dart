import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';
import 'package:skribble_icons/skribble_icons.dart';

void main() {
  group('unified lookup', () {
    test("prefers skribble's own glyphs for their names", () {
      final match = lookupSkribbleIcon('home');
      expect(match, isNotNull);
      expect(match!.set, SkribbleIconSet.glyphs);
      expect(match.data, SkribbleGlyphs.home);
    });

    test('falls through to Material for Flutter identifiers', () {
      final match = lookupSkribbleIcon('access_alarm');
      expect(match, isNotNull);
      expect(match!.set, SkribbleIconSet.material);
    });

    test('resolves Iconify sets', () {
      expect(lookupSkribbleIcon('a-arrow-down')?.set, SkribbleIconSet.lucide);
      expect(lookupSkribbleIcon('analyse')?.set, SkribbleIconSet.bxs);
      expect(lookupSkribbleIcon('github')?.set, SkribbleIconSet.simple);
      expect(lookupSkribbleIcon('adobe-photoshop')?.set, SkribbleIconSet.cib);
    });

    test('returns null for unknown identifiers', () {
      expect(lookupSkribbleIconByIdentifier('not_a_real_icon_name'), isNull);
      expect(lookupSkribbleIcon('not_a_real_icon_name'), isNull);
    });

    test('convenience accessor returns the geometry', () {
      final data = lookupSkribbleIconByIdentifier('search');
      expect(data, isNotNull);
      expect(data!.primitives, isNotEmpty);
    });
  });

  group('aggregate counts', () {
    test('reports every bundled set', () {
      expect(SkribbleGlyphs.all, hasLength(51));
      expect(simpleIconCount, greaterThan(3400));
      expect(lucideIconCount, greaterThan(2000));
      expect(bxsIconCount, greaterThan(600));
      expect(cibIconCount, greaterThan(800));
      expect(skribbleMaterialIconCount, greaterThan(5000));
      expect(
        skribbleIconCount,
        SkribbleGlyphs.all.length +
            simpleIconCount +
            lucideIconCount +
            bxsIconCount +
            cibIconCount,
      );
    });

    test('excludes Material from the cheap identifier list', () {
      expect(skribbleIconIdentifiers, contains('home'));
      expect(skribbleIconIdentifiers, contains('a-arrow-down'));
      expect(skribbleIconIdentifiers, isNot(contains('access_alarm')));
    });
  });

  group('registration', () {
    test('registers the Material catalog for WiredIcon', () {
      clearWiredIconCatalog();
      expect(lookupMaterialRoughIcon(Icons.search), isNull);

      registerSkribbleIcons();
      expect(lookupMaterialRoughIcon(Icons.search), isNotNull);
      expect(materialRoughFontFamily, isNotEmpty);
      expect(materialRoughIconIdentifiers, contains('search'));
    });

    test('ignores non-Material icon families', () {
      registerSkribbleIcons();
      expect(
        lookupMaterialRoughIcon(const IconData(0xe000, fontFamily: 'Other')),
        isNull,
      );
    });
  });

  group('WiredIcon integration', () {
    testWidgets('draws hand-drawn geometry once registered', (tester) async {
      registerSkribbleIcons();
      await tester.pumpWidget(
        MaterialApp(
          home: WiredTheme(
            data: WiredThemeData(),
            child: const WiredIcon(icon: Icons.search),
          ),
        ),
      );
      expect(find.byType(WiredSvgIcon), findsOneWidget);
    });

    testWidgets('draws a built-in glyph for common icons without a catalog', (
      tester,
    ) async {
      clearWiredIconCatalog();
      await tester.pumpWidget(
        MaterialApp(
          home: WiredTheme(
            data: WiredThemeData(),
            child: const WiredIcon(icon: Icons.search),
          ),
        ),
      );
      final icon = tester.widget<WiredSvgIcon>(find.byType(WiredSvgIcon));
      expect(icon.data, same(SkribbleGlyphs.search));
    });

    testWidgets('falls back to the font glyph for other icons', (
      tester,
    ) async {
      clearWiredIconCatalog();
      await tester.pumpWidget(
        MaterialApp(
          home: WiredTheme(
            data: WiredThemeData(),
            child: const WiredIcon(icon: Icons.access_alarm),
          ),
        ),
      );
      expect(find.byType(WiredSvgIcon), findsNothing);
      expect(find.byType(Icon), findsOneWidget);
    });
  });
}
