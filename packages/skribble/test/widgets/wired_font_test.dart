import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';

void main() {
  test('variable families resolve package assets at every roughness', () {
    for (final level in WiredRoughness.values) {
      final family = WiredFont.variableFamilyFor(level);
      expect(WiredFont.isBundled(family), isTrue);
      expect(
        WiredThemeData(fontFamily: family).fontPackage,
        'skribble_font_recursive',
      );
    }
  });
  test('each bundled typeface follows the roughness and copyWith', () {
    expect(WiredThemeData().font, WiredFont.casual);
    for (final font in WiredFont.values) {
      for (final level in WiredRoughness.values) {
        final theme = WiredThemeData().copyWith(
          font: font,
          roughnessLevel: level,
        );
        expect(theme.fontFamily, font.familyFor(level));
        expect(theme.fontPackage, font.package);
        expect(theme.roughness, level.roughness);
        expect(theme.copyWith(strokeWidth: 3).font, font);
        expect(
          theme.toThemeData().textTheme.bodyMedium!.fontFamily,
          'packages/${font.package}/${font.familyFor(level)}',
        );
      }
    }
  });

  test('recursive typefaces follow the roughness from one package', () {
    expect(WiredFont.recursiveFonts, [
      WiredFont.casual,
      WiredFont.linear,
      WiredFont.mono,
    ]);
    for (final font in WiredFont.recursiveFonts) {
      expect(font.followsRoughness, isTrue);
      expect(font.package, 'skribble_font_recursive');
      final families = {
        for (final level in WiredRoughness.values) font.familyFor(level),
      };
      expect(families, hasLength(WiredRoughness.values.length));
    }
  });

  test('Skribble Noto levels are fixed families in their own packages', () {
    expect(WiredFont.notoFonts, [
      WiredFont.noto,
      WiredFont.notoSketch,
      WiredFont.notoLively,
    ]);
    const expected = {
      WiredFont.noto: ('SkribbleNoto', 'skribble_font_noto'),
      WiredFont.notoSketch: ('SkribbleNotoSketch', 'skribble_font_noto_sketch'),
      WiredFont.notoLively: ('SkribbleNotoLively', 'skribble_font_noto_lively'),
    };
    for (final MapEntry(key: font, value: (family, package))
        in expected.entries) {
      expect(font.followsRoughness, isFalse);
      expect(font.package, package);
      for (final level in WiredRoughness.values) {
        expect(font.familyFor(level), family);
      }
      expect(WiredFont.isBundled(family), isTrue);
      expect(WiredFont.packageFor(family), package);
      expect(WiredThemeData(fontFamily: family).fontPackage, package);
    }
  });

  test('Skribble Noto keeps the theme ink while changing the lettering', () {
    final theme = WiredThemeData(
      font: WiredFont.notoSketch,
      roughnessLevel: WiredRoughness.expressive,
    );
    expect(theme.fontFamily, 'SkribbleNotoSketch');
    expect(theme.fontPackage, 'skribble_font_noto_sketch');
    expect(theme.roughness, WiredRoughness.expressive.roughness);
    expect(
      theme.copyWith(font: WiredFont.noto).fontFamily,
      'SkribbleNoto',
    );
    expect(
      theme.copyWith(font: WiredFont.casual).fontPackage,
      'skribble_font_recursive',
    );
  });

  test('unknown families resolve to no package', () {
    expect(WiredFont.packageFor('Noto Sans'), isNull);
    expect(WiredFont.packageFor(''), isNull);
    expect(WiredFont.isBundled('SkribbleNotoSoft'), isFalse);
  });

  test('explicit font overrides survive family and roughness changes', () {
    final custom = WiredThemeData(
      fontFamily: 'MyFont',
    ).copyWith(font: WiredFont.mono, roughnessLevel: WiredRoughness.expressive);
    expect(custom.fontFamily, 'MyFont');
    expect(custom.fontPackage, isNull);
    final bundled = WiredThemeData(fontFamily: 'SkribbleMonoGentle');
    expect(bundled.fontPackage, 'skribble_font_recursive');
  });

  testWidgets('nested themes resolve typefaces without changing parent ink', (
    tester,
  ) async {
    late WiredThemeData outer;
    late WiredThemeData inner;
    Future<void> render(WiredFont font) => tester.pumpWidget(
      WiredTheme(
        data: WiredThemeData(roughnessLevel: WiredRoughness.gentle),
        child: Builder(
          builder: (context) {
            outer = WiredTheme.of(context);
            return WiredTheme(
              data: outer.copyWith(font: font),
              child: Builder(
                builder: (context) {
                  inner = WiredTheme.of(context);
                  return const SizedBox();
                },
              ),
            );
          },
        ),
      ),
    );
    await render(WiredFont.linear);
    expect(inner.fontFamily, 'SkribbleLinearGentle');
    await render(WiredFont.mono);
    expect(inner.fontFamily, 'SkribbleMonoGentle');
    expect(outer.fontFamily, 'SkribbleGentle');
    expect(inner.roughness, outer.roughness);
  });
}
