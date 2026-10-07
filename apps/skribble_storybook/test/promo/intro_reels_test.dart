import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble_storybook/promo/intro_reels.dart';

import '../support/skribble_fonts.dart';

/// A line each reel shows at a moment, in portrait and landscape.
final Map<IntroReel, Map<double, String>> _lines = {
  IntroReel.funAgain: {
    2.0: 'Every app\nlooks the same.',
    15.0: 'Weekend plans',
    21.0: 'flutter pub add skribble',
  },
  IntroReel.drawnByAPen: {
    1.5: 'Every border,',
    13.6: 'Expressive',
    20.8: 'flutter pub add skribble',
  },
  IntroReel.emojiParty: {
    1.0: 'Hand-drawn',
    9.0: '3,963',
    19.6: 'flutter pub add skribble',
  },
  IntroReel.makeItYours: {
    4.0: 'Morning pages',
    15.6: 'Night',
    21.0: 'flutter pub add skribble',
  },
};

void main() {
  setUpAll(loadSkribbleFonts);

  for (final (aspect, size) in const [
    ('portrait', Size(540, 960)),
    ('landscape', Size(960, 540)),
  ]) {
    for (final reel in IntroReel.values) {
      testWidgets('${reel.slug} builds every scene in $aspect', (
        tester,
      ) async {
        tester.view
          ..physicalSize = size * 2
          ..devicePixelRatio = 2;
        addTearDown(tester.view.reset);
        final seconds = reel.duration.inMilliseconds / 1000;
        for (var t = 0.0; t < seconds; t += .5) {
          await tester.pumpWidget(reel.build(t));
          expect(tester.takeException(), isNull, reason: '${reel.slug} at $t');
        }
        for (final MapEntry(key: t, value: line) in _lines[reel]!.entries) {
          await tester.pumpWidget(reel.build(t));
          await tester.pump(const Duration(milliseconds: 100));
          expect(
            find.textContaining(line, findRichText: true),
            findsWidgets,
            reason: '${reel.slug} at $t',
          );
        }
      });
    }
  }

  test('every reel has a unique slug and runs about 20 seconds', () {
    expect(IntroReel.values.map((reel) => reel.slug).toSet(), hasLength(4));
    for (final reel in IntroReel.values) {
      expect(reel.duration.inSeconds, inInclusiveRange(18, 25));
    }
  });
}
