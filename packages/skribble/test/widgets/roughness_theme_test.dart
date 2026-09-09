import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';
import 'package:skribble/src/rough/renderer.dart';

void main() {
  testWidgets(
    'icons inherit level changes and respect an explicit draw config',
    (tester) async {
      const key = ValueKey('icon-ink');
      Future<List<int>> pixels(
        WiredRoughness level, {
        DrawConfig? config,
      }) async {
        await tester.pumpWidget(
          WiredMaterialApp(
            wiredTheme: WiredThemeData(roughnessLevel: level),
            home: Center(
              child: RepaintBoundary(
                key: key,
                child: WiredSvgIcon(
                  size: 96,
                  drawConfig: config,
                  fillStyle: WiredIconFillStyle.hachure,
                  data: const WiredSvgIconData(
                    width: 24,
                    height: 24,
                    primitives: [WiredSvgPrimitive.path('M12 2L2 22h20L12 2z')],
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        final boundary = tester.renderObject<RenderRepaintBoundary>(
          find.byKey(key),
        );
        return (await tester.runAsync(() async {
          final image = await boundary.toImage();
          final bytes = (await image.toByteData())!.buffer.asUint8List();
          image.dispose();
          return bytes;
        }))!;
      }

      final gentle = await pixels(WiredRoughness.gentle);
      final expectedGentle = DrawConfig.build(
        maxRandomnessOffset: 1.2,
        roughness: 1.25 * 0.65 / 1.8,
        lineWobble: 0,
        bowing: 0.8,
        curveFitting: 0.9,
        curveTightness: 0,
        curveStepCount: 8,
        seed: 1,
      );
      expect(
        gentle,
        await pixels(WiredRoughness.expressive, config: expectedGentle),
        reason: 'large gentle icons inherit the bowed line style',
      );
      final expressive = await pixels(WiredRoughness.expressive);
      expect(expressive, isNot(gentle));
      final fixed = DrawConfig.build(roughness: 0);
      expect(
        await pixels(WiredRoughness.gentle, config: fixed),
        await pixels(WiredRoughness.expressive, config: fixed),
      );
    },
  );

  test('levels coordinate typography, geometry, and package resolution', () {
    for (final level in WiredRoughness.values) {
      final theme = WiredThemeData(roughnessLevel: level);
      expect(theme.fontFamily, level.fontFamily);
      expect(theme.fontPackage, 'skribble');
      expect(theme.drawConfig.roughness, level.roughness);
      expect(theme.drawConfig.maxRandomnessOffset, level.maxRandomnessOffset);
      expect(theme.drawConfig.lineWobble, level.lineWobble);
      expect(
        theme.toThemeData().textTheme.bodyMedium!.fontFamily,
        'packages/skribble/${level.fontFamily}',
      );
    }
  });

  test('gentle restores bowed edges and expressive uses local wandering', () {
    final gentle = OpsGenerator.doubleLine(
      0,
      0,
      960,
      0,
      WiredThemeData(roughnessLevel: WiredRoughness.gentle).drawConfig,
    );
    final expressive = OpsGenerator.doubleLine(
      0,
      0,
      960,
      0,
      WiredThemeData(roughnessLevel: WiredRoughness.expressive).drawConfig,
    );
    expect(gentle.where((op) => op.op == OpType.curveTo), hasLength(2));
    expect(expressive.length, greaterThan(gentle.length));
  });

  test('copyWith changes level defaults and retains palette and overrides', () {
    final original = WiredThemeData(borderColor: const Color(0xff123456));
    final gentle = original.copyWith(roughnessLevel: WiredRoughness.gentle);
    expect(gentle.fontFamily, 'SkribbleGentle');
    expect(gentle.roughness, 1.25);
    expect(gentle.borderColor, original.borderColor);
    final explicit = original.copyWith(
      fontFamily: 'MyInk',
      roughness: 0.3,
      drawConfig: DrawConfig.build(roughness: 0.2),
    );
    final changed = explicit.copyWith(roughnessLevel: WiredRoughness.gentle);
    expect(changed.fontFamily, 'MyInk');
    expect(changed.fontPackage, isNull);
    expect(changed.roughness, 0.3);
    expect(changed.drawConfig.roughness, 0.2);
    expect(
      gentle.copyWith(textColor: const Color(0xffabcdef)).fontFamily,
      'SkribbleGentle',
    );
  });

  test('lineWobble participates in config copy, equality and hash', () {
    final base = DrawConfig.build();
    final gentle = base.copyWith(lineWobble: 0);
    expect(gentle.lineWobble, 0);
    expect(gentle, isNot(base));
    expect(gentle.copyWith(), gentle);
    expect(gentle.copyWith().hashCode, gentle.hashCode);
  });

  for (final level in WiredRoughness.values) {
    testWidgets('${level.name} cascades to plain text and Wired controls', (
      tester,
    ) async {
      await tester.pumpWidget(
        WiredMaterialApp(
          wiredTheme: WiredThemeData(roughnessLevel: level),
          home: WiredScaffold(
            body: Column(
              children: [
                const Text('Plain lettering'),
                WiredOutlinedButton(
                  onPressed: () {},
                  child: const Text('Button lettering'),
                ),
                const WiredListTile(title: Text('List lettering')),
                const WiredChip(label: Text('Chip lettering')),
                const WiredInput(hintText: 'Input lettering'),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      for (final label in [
        'Plain lettering',
        'Button lettering',
        'List lettering',
        'Chip lettering',
      ]) {
        final context = tester.element(find.text(label));
        expect(
          DefaultTextStyle.of(context).style.fontFamily,
          'packages/skribble/${level.fontFamily}',
          reason: label,
        );
        expect(WiredTheme.of(context).roughnessLevel, level);
      }
      final field = tester.widget<EditableText>(find.byType(EditableText));
      expect(field.style.fontFamily, 'packages/skribble/${level.fontFamily}');
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets(
    'nested level is isolated and updates typography without losing input',
    (tester) async {
      final level = ValueNotifier(WiredRoughness.gentle);
      addTearDown(level.dispose);
      await tester.pumpWidget(
        WiredMaterialApp(
          wiredTheme: WiredThemeData(),
          home: WiredScaffold(
            body: Column(
              children: [
                const Text('Outer'),
                ValueListenableBuilder<WiredRoughness>(
                  valueListenable: level,
                  builder: (context, value, child) => WiredTheme(
                    data: WiredTheme.of(context)
                        .copyWith(roughnessLevel: value),
                    child: Column(
                      children: [
                        const Text('Inner'),
                        WiredOutlinedButton(
                          onPressed: () {},
                          child: const Text('Inner button'),
                        ),
                        const WiredInput(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(EditableText), 'Keep café £12.50');
      for (final selected in [
        WiredRoughness.playful,
        WiredRoughness.expressive,
        WiredRoughness.gentle,
      ]) {
        level.value = selected;
        await tester.pumpAndSettle();
        expect(
          DefaultTextStyle.of(tester.element(find.text('Outer')))
              .style
              .fontFamily,
          'packages/skribble/SkribblePlayful',
        );
        for (final label in ['Inner', 'Inner button']) {
          expect(
            DefaultTextStyle.of(tester.element(find.text(label)))
                .style
                .fontFamily,
            'packages/skribble/${selected.fontFamily}',
          );
        }
        final input = tester.widget<EditableText>(find.byType(EditableText));
        expect(input.controller.text, 'Keep café £12.50');
        expect(
          input.style.fontFamily,
          'packages/skribble/${selected.fontFamily}',
        );
        expect(tester.takeException(), isNull);
      }
    },
  );
}
