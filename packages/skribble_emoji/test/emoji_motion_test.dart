import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';
import 'package:skribble_emoji/skribble_emoji.dart';

/// Every built-in move, with a name for failure messages.
const Map<String, EmojiMove> _moves = {
  'beat': EmojiMove.beat(),
  'blink': EmojiMove.blink(),
  'bob': EmojiMove.bob(),
  'wave': EmojiMove.wave(),
  'sway': EmojiMove.sway(),
  'shake': EmojiMove.shake(),
  'flicker': EmojiMove.flicker(),
  'spin': EmojiMove.spin(),
  'hop': EmojiMove.hop(),
  'breathe': EmojiMove.breathe(),
  'drip': EmojiMove.drip(),
  'float': EmojiMove.float(),
  'burst': EmojiMove.burst(),
};

Future<Uint8List> _pixels(void Function(Canvas) paint, int size) async {
  final recorder = ui.PictureRecorder();
  paint(Canvas(recorder));
  final image = await recorder.endRecording().toImage(size, size);
  final bytes = (await image.toByteData())!.buffer.asUint8List();
  image.dispose();
  return bytes;
}

/// A custom move that hides its part.
final class _Vanish extends EmojiMove {
  const _Vanish();

  @override
  EmojiPose at(double t) => const EmojiPose(opacity: 0);
}

Matrix4 _matrix(EmojiPose pose) => pose.toMatrix(const Offset(18, 18), 1);

void main() {
  final config = DrawConfig.build(seed: 5);

  group('EmojiPose', () {
    test('combines by adding movement and multiplying scale', () {
      const a = EmojiPose(dx: 1, rotation: .1, scaleX: 2);
      const b = EmojiPose(dx: 2, dy: 3, rotation: .2, scaleX: 1.5);
      final both = a + b;
      expect(both.dx, 3);
      expect(both.dy, 3);
      expect(both.rotation, closeTo(.3, 1e-9));
      expect(both.scaleX, 3);
      expect(EmojiPose.rest.isRest, isTrue);
      expect(both.isRest, isFalse);
      const faded = EmojiPose(opacity: .5);
      expect((faded + faded).opacity, .25);
      expect(faded.isStill, isTrue);
      expect(faded.isRest, isFalse);
    });

    test('turns and scales around its pivot', () {
      const pivot = Offset(10, 20);
      final matrix = const EmojiPose(
        rotation: 1,
        scaleX: 2,
        scaleY: .5,
      ).toMatrix(pivot, 2);
      expect(MatrixUtils.transformPoint(matrix, pivot), pivot);
    });

    test('moves in art units', () {
      final matrix = const EmojiPose(dx: 1, dy: -2).toMatrix(Offset.zero, 3);
      expect(
        MatrixUtils.transformPoint(matrix, Offset.zero),
        const Offset(3, -6),
      );
    });
  });

  group('EmojiMove', () {
    test('every built-in move starts at rest', () {
      for (final MapEntry(key: name, value: move) in _moves.entries) {
        expect(move.at(0).isRest, isTrue, reason: name);
      }
    });

    test('every looping move ends where it starts', () {
      for (final MapEntry(key: name, value: move) in _moves.entries) {
        // A drip falls away and reappears, on purpose.
        if (name == 'drip') continue;
        final end = _matrix(move.at(1 - 1e-6)).storage;
        final start = _matrix(move.at(0)).storage;
        for (var i = 0; i < 16; i++) {
          expect(end[i], closeTo(start[i], 1e-3), reason: '$name[$i]');
        }
      }
    });

    test('every built-in move moves during the loop', () {
      for (final MapEntry(key: name, value: move) in _moves.entries) {
        final moved = [
          for (var t = 0.05; t < 1; t += .05) move.at(t),
        ].any((pose) => !pose.isRest);
        expect(moved, isTrue, reason: name);
      }
    });

    test('a delayed move rests, then plays in the time left', () {
      const beat = EmojiMove.beat();
      final later = beat.delayed(.5);
      expect(later.at(.25).isRest, isTrue);
      expect(later.at(.5 + .5 * .08), beat.at(.08));
    });

    test('a drip falls and fades away', () {
      const drip = EmojiMove.drip(distance: 4);
      expect(drip.at(.2).isRest, isTrue);
      final late = drip.at(.9);
      expect(late.dy, greaterThan(2));
      expect(late.opacity, lessThan(.2));
    });

    test('a blink closes the eyes near the end of the loop', () {
      const blink = EmojiMove.blink();
      expect(blink.at(.5).scaleY, 1);
      expect(blink.at(.89).scaleY, lessThan(.2));
    });
  });

  group('EmojiMotion', () {
    final heart = SkribbleEmoji.lookup('❤️')!;

    test('moves the drawing during the loop and rests at the start', () async {
      final drawing = EmojiDrawing(heart, size: 48, config: config);
      const motion = EmojiMotion([EmojiTrack(null, EmojiMove.beat())]);
      final still = await _pixels(drawing.paint, 48);
      final atStart = await _pixels((c) => motion.paint(c, drawing, 0), 48);
      final beating = await _pixels((c) => motion.paint(c, drawing, .08), 48);
      expect(atStart, still);
      expect(beating, isNot(still));
    });

    test('skips tracks for parts the drawing does not have', () async {
      final drawing = EmojiDrawing(heart, size: 48, config: config);
      const motion = EmojiMotion([
        EmojiTrack('no-such-part', EmojiMove.spin()),
      ]);
      expect(
        await _pixels((c) => motion.paint(c, drawing, .5), 48),
        await _pixels(drawing.paint, 48),
      );
    });

    test('fades parts without moving them', () async {
      final joy = SkribbleEmoji.lookup('😂')!;
      final drawing = EmojiDrawing(joy, size: 48, config: config);
      const gone = EmojiMotion([EmojiTrack('tears', _Vanish())]);
      final still = await _pixels(drawing.paint, 48);
      final faded = await _pixels((c) => gone.paint(c, drawing, .5), 48);
      final hidden = await _pixels(
        (c) => drawing.paint(c, opacity: const {'tears': 0}),
        48,
      );
      expect(faded, isNot(still));
      expect(faded, hidden);
    });

    test('measures parts so they move around their own pivot', () {
      final grin = SkribbleEmoji.lookup('😀')!;
      final drawing = EmojiDrawing(grin, size: 36, config: config);
      final eyes = drawing.boundsOf('eyes')!;
      expect(eyes.top, greaterThan(6));
      expect(eyes.bottom, lessThan(20));
      expect(drawing.boundsOf('nope'), isNull);
    });
  });

  group('EmojiMotions', () {
    test('gives popular emoji their own motion', () {
      final heart = SkribbleEmoji.lookup('❤️')!;
      expect(
        EmojiMotions.of(heart),
        same(EmojiMotions.choreographed['red-heart']),
      );
    });

    test('shares a motion across skin tones', () {
      final thumbs = SkribbleEmoji.lookup('👍')!;
      final dark = SkribbleEmoji.withTone(thumbs, EmojiSkinTone.dark)!;
      expect(EmojiMotions.of(dark), same(EmojiMotions.of(thumbs)));
    });

    test('leaves flags still', () {
      expect(EmojiMotions.of(SkribbleEmoji.lookup('🇯🇵')!), isNull);
    });

    test('choreography only names parts its drawings have', () {
      final problems = <String>[];
      for (final MapEntry(key: art, value: motion)
          in EmojiMotions.choreographed.entries) {
        final entry = SkribbleEmoji.all
            .where((entry) => entry.art == art)
            .firstOrNull;
        // Art that is not drawn yet has nothing to check.
        if (entry == null) continue;
        final drawing = EmojiDrawing(entry, size: 36, config: config);
        for (final track in motion.tracks) {
          final part = track.part;
          if (part != null && drawing.boundsOf(part) == null) {
            problems.add('$art has no part "$part" (has ${drawing.parts})');
          }
        }
      }
      expect(problems, isEmpty);
    });
  });

  group('WiredAnimatedEmoji', () {
    Future<void> pump(
      WidgetTester tester,
      Widget child, {
      bool disableAnimations = false,
    }) => tester.pumpWidget(
      MediaQuery(
        data: MediaQueryData(disableAnimations: disableAnimations),
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: WiredThemeScope(
            data: WiredThemeData(),
            child: Center(child: child),
          ),
        ),
      ),
    );

    Finder painter() => find.descendant(
      of: find.byType(WiredAnimatedEmoji),
      matching: find.byType(CustomPaint),
    );

    testWidgets('loops on its own clock', (tester) async {
      await pump(tester, const WiredAnimatedEmoji('❤️', size: 48));
      expect(tester.hasRunningAnimations, isTrue);
      expect(find.byType(WiredEmoji), findsNothing);
      expect(painter(), findsOneWidget);
      expect(
        tester.getSize(find.byType(WiredAnimatedEmoji)),
        const Size.square(48),
      );
      await tester.pump(const Duration(milliseconds: 300));
      expect(tester.takeException(), isNull);
    });

    testWidgets('rests when motion is turned off', (tester) async {
      await pump(
        tester,
        const WiredMotion(enabled: false, child: WiredAnimatedEmoji('❤️')),
      );
      expect(tester.hasRunningAnimations, isFalse);
      expect(find.byType(WiredEmoji), findsOneWidget);
    });

    testWidgets('rests when the platform asks for reduced motion', (
      tester,
    ) async {
      await pump(
        tester,
        const WiredAnimatedEmoji('❤️'),
        disableAnimations: true,
      );
      expect(tester.hasRunningAnimations, isFalse);
      expect(find.byType(WiredEmoji), findsOneWidget);
    });

    testWidgets('rests when not animating', (tester) async {
      await pump(tester, const WiredAnimatedEmoji('❤️', animating: false));
      expect(tester.hasRunningAnimations, isFalse);
      expect(find.byType(WiredEmoji), findsOneWidget);
    });

    testWidgets('starts when motion is turned back on', (tester) async {
      await pump(
        tester,
        const WiredMotion(enabled: false, child: WiredAnimatedEmoji('❤️')),
      );
      await pump(
        tester,
        const WiredMotion(child: WiredAnimatedEmoji('❤️')),
      );
      expect(tester.hasRunningAnimations, isTrue);
    });

    testWidgets('borrows a progress animation without driving it', (
      tester,
    ) async {
      final controller = AnimationController(vsync: const TestVSync());
      addTearDown(controller.dispose);
      await pump(tester, WiredAnimatedEmoji('🔥', progress: controller));
      expect(tester.hasRunningAnimations, isFalse);
      expect(painter(), findsOneWidget);
      controller.value = .5;
      await tester.pump();
      expect(controller.isAnimating, isFalse);
      expect(tester.takeException(), isNull);
    });

    testWidgets('boils emoji that have no motion of their own', (
      tester,
    ) async {
      await pump(tester, const WiredAnimatedEmoji('🇯🇵'));
      expect(tester.hasRunningAnimations, isTrue);
      await pump(tester, const WiredAnimatedEmoji('🇯🇵', boil: false));
      expect(tester.hasRunningAnimations, isFalse);
    });

    testWidgets('reads its name and shows unknown text as text', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      await pump(tester, const WiredAnimatedEmoji('🎉'));
      expect(find.bySemanticsLabel('party popper'), findsOneWidget);
      await pump(tester, const WiredAnimatedEmoji('zz'));
      expect(find.text('zz'), findsOneWidget);
      semantics.dispose();
    });
  });
}
