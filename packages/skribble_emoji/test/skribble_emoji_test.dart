import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';
import 'package:skribble_emoji/skribble_emoji.dart';

Future<Uint8List> _pixels(EmojiDrawing drawing) async {
  final recorder = ui.PictureRecorder();
  drawing.paint(Canvas(recorder));
  final size = drawing.size.ceil();
  final image = await recorder.endRecording().toImage(size, size);
  final bytes = (await image.toByteData())!.buffer.asUint8List();
  image.dispose();
  return bytes;
}

int _ink(Uint8List pixels) {
  var total = 0;
  for (var i = 3; i < pixels.length; i += 4) {
    total += pixels[i];
  }
  return total;
}

void main() {
  final config = DrawConfig.build(seed: 3);

  group('SkribbleEmoji lookups', () {
    test('find an emoji by its text, with or without variation selectors', () {
      final heart = SkribbleEmoji.lookup('❤️');
      expect(heart?.name, 'red heart');
      expect(SkribbleEmoji.lookup('❤'), same(heart));
      expect(SkribbleEmoji.lookup('not an emoji'), isNull);
    });

    test('find an emoji by its snake-case name', () {
      expect(SkribbleEmoji.named('grinning_face')?.emoji, '😀');
      expect(SkribbleEmoji.named('keycap_1')?.emoji, '1️⃣');
      expect(SkribbleEmoji.named('nope'), isNull);
    });

    test('describe group, subgroup, and art', () {
      final grin = SkribbleEmoji.lookup('😀')!;
      expect(grin.group, EmojiGroup.smileysAndEmotion);
      expect(grin.subgroup, 'face-smiling');
      expect(grin.art, 'grinning-face');
      expect(grin.drawing.shapes, isNotEmpty);
      expect(grin.identifier, 'grinning_face');
    });

    test('map skin tones onto the same art', () {
      final thumbs = SkribbleEmoji.lookup('👍')!;
      expect(thumbs.hasTones, isTrue);
      final medium = SkribbleEmoji.withTone(thumbs, EmojiSkinTone.medium)!;
      expect(medium.emoji, '👍🏽');
      expect(medium.tone, EmojiSkinTone.medium);
      expect(medium.art, thumbs.art);
      expect(SkribbleEmoji.withTone(medium, EmojiSkinTone.none), same(thumbs));
      expect(
        SkribbleEmoji.withTone(SkribbleEmoji.lookup('😀')!, EmojiSkinTone.dark),
        isNull,
      );
    });

    test('share one drawing between gendered variants', () {
      final man = SkribbleEmoji.lookup('👨‍💻')!;
      final woman = SkribbleEmoji.lookup('👩‍💻')!;
      expect(man.art, 'technologist');
      expect(woman.art, 'technologist');
      expect(man.variant, EmojiVariant.man);
      expect(woman.variant, EmojiVariant.woman);
      expect(SkribbleEmoji.lookup('🧑‍💻')!.variant, EmojiVariant.person);
    });

    test('name country flags by ISO code', () {
      final japan = SkribbleEmoji.lookup('🇯🇵')!;
      expect(japan.name, 'flag: Japan');
      expect(japan.art, 'flag-jp');
      expect(japan.group, EmojiGroup.flags);
    });

    test('search names, ranking word starts first', () {
      final results = SkribbleEmoji.search('heart');
      final starts = [
        for (final entry in results) RegExp('(^| )heart').hasMatch(entry.name),
      ];
      // Word-start matches come before matches inside a word.
      expect(
        starts,
        orderedEquals(
          List<bool>.of(starts)..sort((a, b) => a == b ? 0 : (a ? -1 : 1)),
        ),
      );
      expect(results.map((entry) => entry.name), contains('red heart'));
      expect(SkribbleEmoji.search('  '), isEmpty);
      expect(
        SkribbleEmoji.search('thumbs').every(
          (entry) => entry.tone == EmojiSkinTone.none,
        ),
        isTrue,
      );
    });

    test('defaults leave out toned variants and components', () {
      expect(
        SkribbleEmoji.defaults.every(
          (entry) =>
              entry.tone == EmojiSkinTone.none &&
              entry.group != EmojiGroup.component,
        ),
        isTrue,
      );
      expect(
        SkribbleEmoji.inGroup(EmojiGroup.smileysAndEmotion),
        everyElement(
          predicate<EmojiEntry>(
            (entry) => entry.group == EmojiGroup.smileysAndEmotion,
          ),
        ),
      );
    });
  });

  group('EmojiPalette', () {
    test('resolves tokens and skin tones', () {
      const palette = EmojiPalette.skribble;
      expect(
        EmojiPaint.skin.resolve(palette),
        palette.skins[EmojiSkinTone.none],
      );
      expect(
        EmojiPaint.skin.resolve(palette, tone: EmojiSkinTone.dark),
        palette.skins[EmojiSkinTone.dark],
      );
      expect(
        EmojiPaint.skin2.resolve(palette, tone2: EmojiSkinTone.light),
        palette.skins[EmojiSkinTone.light],
      );
      expect(
        const EmojiPaint(0xFF112233).resolve(palette),
        const Color(0xFF112233),
      );
    });

    test('defines a colour for every token and tone', () {
      const palette = EmojiPalette.skribble;
      for (final token in EmojiToken.values) {
        for (final tone in EmojiSkinTone.values) {
          expect(
            () => palette.colorOf(token, tone: tone, tone2: tone),
            returnsNormally,
            reason: '$token $tone',
          );
        }
      }
    });

    test('names tokens the way art writes them', () {
      expect(EmojiToken.yellowShade.artName, 'yellow-shade');
      expect(EmojiToken.skin2Shade.artName, 'skin2-shade');
      expect(EmojiToken.fromArtName('skin2-shade'), EmojiToken.skin2Shade);
      expect(EmojiToken.fromArtName('chartreuse'), isNull);
    });
  });

  group('EmojiDrawing', () {
    test('paints ink, and paints skin tones differently', () async {
      final thumbs = SkribbleEmoji.lookup('👍')!;
      final light = await _pixels(
        EmojiDrawing(
          SkribbleEmoji.withTone(thumbs, EmojiSkinTone.light)!,
          size: 48,
          config: config,
        ),
      );
      final dark = await _pixels(
        EmojiDrawing(
          SkribbleEmoji.withTone(thumbs, EmojiSkinTone.dark)!,
          size: 48,
          config: config,
        ),
      );
      expect(_ink(light), greaterThan(0));
      expect(light, isNot(dark));
    });

    test('is deterministic for the same configuration', () async {
      final grin = SkribbleEmoji.lookup('😀')!;
      expect(
        await _pixels(EmojiDrawing(grin, size: 40, config: config)),
        await _pixels(EmojiDrawing(grin, size: 40, config: config)),
      );
    });

    test('draws only the selected hair variant', () async {
      final man = await _pixels(
        EmojiDrawing(SkribbleEmoji.lookup('👨‍💻')!, size: 48, config: config),
      );
      final woman = await _pixels(
        EmojiDrawing(SkribbleEmoji.lookup('👩‍💻')!, size: 48, config: config),
      );
      expect(man, isNot(woman));
    });

    test('mirrors art for facing-right entries', () async {
      final art = SkribbleEmoji.lookup('👍')!.drawing;
      final left = await _pixels(
        EmojiDrawing.art(art, size: 40, config: config),
      );
      final right = await _pixels(
        EmojiDrawing.art(art, size: 40, config: config, mirrored: true),
      );
      expect(left, isNot(right));
    });

    test('moves named parts with a pose', () async {
      final grin = SkribbleEmoji.lookup('😀')!;
      final drawing = EmojiDrawing(grin, size: 48, config: config);
      expect(drawing.parts, containsAll(['face', 'eyes', 'mouth']));
      final rest = await _pixels(drawing);
      final recorder = ui.PictureRecorder();
      drawing.paint(
        Canvas(recorder),
        pose: {'eyes': Matrix4.translationValues(0, 6, 0)},
      );
      final image = await recorder.endRecording().toImage(48, 48);
      final moved = (await image.toByteData())!.buffer.asUint8List();
      image.dispose();
      expect(moved, isNot(rest));
    });
  });

  group('WiredEmoji', () {
    Future<void> pump(WidgetTester tester, Widget child) => tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: WiredThemeScope(
          data: WiredThemeData(),
          child: Center(child: child),
        ),
      ),
    );

    testWidgets('fills a square of its size and reads its name', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      await pump(tester, const WiredEmoji('🎉', size: 40));
      expect(tester.getSize(find.byType(WiredEmoji)), const Size.square(40));
      expect(find.bySemanticsLabel('party popper'), findsOneWidget);
      semantics.dispose();
    });

    testWidgets('uses a custom semantic label', (tester) async {
      final semantics = tester.ensureSemantics();
      await pump(tester, const WiredEmoji('🎉', semanticLabel: 'Launch party'));
      expect(find.bySemanticsLabel('Launch party'), findsOneWidget);
      semantics.dispose();
    });

    testWidgets('looks emoji up by name', (tester) async {
      await pump(tester, WiredEmoji.named('red_heart'));
      expect(find.byType(CustomPaint), findsWidgets);
    });

    testWidgets('shows unknown text as text', (tester) async {
      await pump(tester, const WiredEmoji('zz'));
      expect(find.text('zz'), findsOneWidget);
    });

    testWidgets('shares prepared drawings between identical emoji', (
      tester,
    ) async {
      final entry = SkribbleEmoji.lookup('😀')!;
      final config = emojiDrawConfig(WiredThemeData(), 32);
      expect(
        emojiDrawingFor(entry, size: 32, config: config),
        same(emojiDrawingFor(entry, size: 32, config: config)),
      );
    });
  });

  group('WiredEmojiText', () {
    test('splits text into words and drawn emoji', () {
      final spans = emojiSpans('Ship it 🚀 now ❤️!', 20);
      expect(spans, hasLength(5));
      expect((spans[0] as TextSpan).text, 'Ship it ');
      expect(
        ((spans[1] as WidgetSpan).child as WiredEmoji).emoji,
        '🚀',
      );
      expect((spans[2] as TextSpan).text, ' now ');
      expect(((spans[3] as WidgetSpan).child as WiredEmoji).emoji, '❤️');
      expect((spans[4] as TextSpan).text, '!');
    });

    test('keeps whole sequences together', () {
      final spans = emojiSpans('👩🏽‍💻🇯🇵', 20);
      expect(spans, hasLength(2));
    });

    testWidgets('renders emoji inside text', (tester) async {
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: WiredThemeScope(
            data: WiredThemeData(),
            child: const WiredEmojiText(
              'Party 🎉',
              style: TextStyle(fontSize: 20),
            ),
          ),
        ),
      );
      expect(find.byType(WiredEmoji), findsOneWidget);
      expect(tester.getSize(find.byType(WiredEmoji)).width, closeTo(23, 0.01));
    });
  });
}
