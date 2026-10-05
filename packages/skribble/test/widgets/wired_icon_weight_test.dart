import 'dart:typed_data';

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';

import '../helpers/finders.dart';

const ValueKey<String> _key = ValueKey('icon');

/// A filled square with a square hole, drawn in the ambient colour.
const _frame = WiredSvgIconData(
  width: 24,
  height: 24,
  primitives: [
    WiredSvgPrimitive.path(
      'M3 3H21V21H3ZM8 8H16V16H8Z',
      fillRule: WiredSvgFillRule.evenOdd,
    ),
  ],
);

Future<Uint8List> _render(
  WidgetTester tester,
  Widget icon, {
  WiredThemeData? theme,
  IconThemeData iconTheme = const IconThemeData(),
  TextDirection direction = TextDirection.ltr,
}) async {
  await tester.pumpWidget(
    Directionality(
      textDirection: direction,
      child: WiredThemeScope(
        data: theme ?? WiredThemeData(),
        child: IconTheme(
          data: iconTheme,
          child: Center(
            child: RepaintBoundary(key: _key, child: icon),
          ),
        ),
      ),
    ),
  );
  await tester.pump();
  return (await tester.runAsync(() async {
    final image = await tester
        .renderObject<RenderRepaintBoundary>(find.byKey(_key))
        .toImage(pixelRatio: 2);
    final bytes = (await image.toByteData())!.buffer.asUint8List();
    image.dispose();
    return bytes;
  }))!;
}

int _ink(Uint8List pixels) {
  var total = 0;
  for (var i = 3; i < pixels.length; i += 4) {
    total += pixels[i];
  }
  return total;
}

void main() {
  group('wiredIconWeightFactor', () {
    test('maps Flutter weights onto a pen multiplier', () {
      expect(wiredIconWeightFactor(100), 0.5);
      expect(wiredIconWeightFactor(400), 1);
      expect(wiredIconWeightFactor(700), 1.75);
      expect(wiredIconWeightFactor(250), closeTo(0.75, 1e-9));
    });

    test('clamps weights outside the scale', () {
      expect(wiredIconWeightFactor(0), wiredIconWeightFactor(100));
      expect(wiredIconWeightFactor(5000), wiredIconWeightFactor(900));
    });
  });

  group('WiredSvgIcon weight', () {
    testWidgets('stroke glyphs ink more heavily as the weight rises', (
      tester,
    ) async {
      final ink = <int>[];
      for (final weight in [200.0, 400.0, 700.0]) {
        ink.add(
          _ink(
            await _render(
              tester,
              WiredSvgIcon(data: SkribbleGlyphs.home, size: 48, weight: weight),
            ),
          ),
        );
      }
      expect(ink[0], lessThan(ink[1]));
      expect(ink[1], lessThan(ink[2]));
    });

    testWidgets('silhouettes grow and shrink while their counters stay open', (
      tester,
    ) async {
      final ink = <int>[];
      for (final weight in [150.0, 400.0, 700.0]) {
        final pixels = await _render(
          tester,
          WiredSvgIcon(
            data: _frame,
            size: 48,
            weight: weight,
            drawConfig: DrawConfig.build(roughness: 0),
          ),
        );
        ink.add(_ink(pixels));
        // The centre of the 96-pixel image sits inside the hole.
        expect(pixels[(48 * 96 + 48) * 4 + 3], 0, reason: 'weight $weight');
      }
      expect(ink[0], lessThan(ink[1]));
      expect(ink[1], lessThan(ink[2]));
    });

    testWidgets('reads the weight from IconTheme when none is given', (
      tester,
    ) async {
      final themed = await _render(
        tester,
        const WiredSvgIcon(data: SkribbleGlyphs.check, size: 48),
        iconTheme: const IconThemeData(weight: 700),
      );
      final explicit = await _render(
        tester,
        const WiredSvgIcon(data: SkribbleGlyphs.check, size: 48, weight: 700),
      );
      final normal = await _render(
        tester,
        const WiredSvgIcon(data: SkribbleGlyphs.check, size: 48),
      );
      expect(themed, explicit);
      expect(_ink(themed), greaterThan(_ink(normal)));
    });

    testWidgets("scales with the theme's stroke width", (tester) async {
      final normal = await _render(
        tester,
        const WiredSvgIcon(data: SkribbleGlyphs.plus, size: 48),
      );
      final bold = await _render(
        tester,
        const WiredSvgIcon(data: SkribbleGlyphs.plus, size: 48),
        theme: WiredThemeData(strokeWidth: 3.6),
      );
      expect(_ink(bold), greaterThan(_ink(normal)));
    });
  });

  group('WiredSvgIcon fill styles', () {
    testWidgets('none draws only the outline of a silhouette', (tester) async {
      final pixels = await _render(
        tester,
        const WiredSvgIcon(
          data: WiredSvgIconData(
            width: 24,
            height: 24,
            primitives: [WiredSvgPrimitive.path('M2 2H22V22H2Z')],
          ),
          size: 48,
          fillStyle: WiredIconFillStyle.none,
        ),
      );
      expect(pixels[(48 * 96 + 48) * 4 + 3], 0, reason: 'empty middle');
      expect(_ink(pixels), greaterThan(0));
    });

    testWidgets('every fill style paints without errors', (tester) async {
      for (final style in WiredIconFillStyle.values) {
        final pixels = await _render(
          tester,
          WiredSvgIcon(data: _frame, size: 48, fillStyle: style),
        );
        expect(_ink(pixels), greaterThan(0), reason: style.name);
        expect(tester.takeException(), isNull);
      }
    });
  });

  group('SkribbleGlyphs', () {
    test('ships the full vocabulary as stroke drawings', () {
      expect(SkribbleGlyphs.all, hasLength(51));
      for (final MapEntry(key: name, value: glyph)
          in SkribbleGlyphs.all.entries) {
        expect(glyph.width, 24, reason: name);
        expect(glyph.primitives, isNotEmpty, reason: name);
        for (final primitive in glyph.primitives) {
          expect(primitive.strokeColor, 'currentColor', reason: name);
          expect(primitive.strokeWidth, 2, reason: name);
        }
      }
      expect(SkribbleGlyphs.all['arrow_left'], same(SkribbleGlyphs.arrowLeft));
    });
  });

  group('WiredIcon without a catalog', () {
    setUp(clearWiredIconCatalog);

    testWidgets('draws the built-in glyph for a common Material icon', (
      tester,
    ) async {
      await _render(
        tester,
        const WiredIcon(icon: IconData(0xe156, fontFamily: 'MaterialIcons')),
      );
      expect(findWiredGlyph(SkribbleGlyphs.check), findsOneWidget);
    });

    testWidgets('mirrors directional glyphs in right-to-left layouts', (
      tester,
    ) async {
      const back = IconData(
        0xe092,
        fontFamily: 'MaterialIcons',
        matchTextDirection: true,
      );
      await _render(
        tester,
        const WiredIcon(icon: back),
        direction: TextDirection.rtl,
      );
      final icon = tester.widget<WiredSvgIcon>(
        findWiredGlyph(SkribbleGlyphs.arrowLeft),
      );
      expect(icon.flipHorizontally, isTrue);
    });

    testWidgets('leaves icons outside the glyph set to the font', (
      tester,
    ) async {
      await _render(
        tester,
        const WiredIcon(icon: IconData(0xe03b, fontFamily: 'MaterialIcons')),
      );
      expect(find.byType(WiredSvgIcon), findsNothing);
    });

    testWidgets('ignores codepoints from other icon fonts', (tester) async {
      await _render(
        tester,
        const WiredIcon(icon: IconData(0xe156, fontFamily: 'OtherIcons')),
      );
      expect(find.byType(WiredSvgIcon), findsNothing);
    });
  });

  testWidgets('a semantic label describes the icon as an image', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await _render(
      tester,
      const WiredSvgIcon(data: SkribbleGlyphs.heart, semanticLabel: 'Liked'),
    );
    expect(find.bySemanticsLabel('Liked'), findsOneWidget);
    semantics.dispose();
  });
}
