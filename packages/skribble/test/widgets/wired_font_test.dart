import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';

void main() {
  test('variable families resolve package assets at every roughness', () {
    for (final level in WiredRoughness.values) {
      final family = WiredFont.variableFamilyFor(level);
      expect(WiredFont.isBundled(family), isTrue);
      expect(WiredThemeData(fontFamily: family).fontPackage, 'skribble');
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
        expect(theme.fontPackage, 'skribble');
        expect(theme.roughness, level.roughness);
        expect(theme.copyWith(strokeWidth: 3).font, font);
        expect(
          theme.toThemeData().textTheme.bodyMedium!.fontFamily,
          'packages/skribble/${font.familyFor(level)}',
        );
      }
    }
  });

  test('explicit font overrides survive family and roughness changes', () {
    final custom = WiredThemeData(
      fontFamily: 'MyFont',
    ).copyWith(font: WiredFont.mono, roughnessLevel: WiredRoughness.expressive);
    expect(custom.fontFamily, 'MyFont');
    expect(custom.fontPackage, isNull);
    final bundled = WiredThemeData(fontFamily: 'SkribbleMonoGentle');
    expect(bundled.fontPackage, 'skribble');
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
