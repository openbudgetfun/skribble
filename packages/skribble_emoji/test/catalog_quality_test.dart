import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble_emoji/skribble_emoji.dart';

void main() {
  test('OpenMoji 17 retains every name and distinct joined sequences', () {
    expect(kSkribbleEmojiNames.length, 4495);
    for (final name in kSkribbleEmojiNames.keys) {
      final data = lookupSkribbleEmojiByName(name);
      expect(data, isNotNull, reason: name);
      expect(data!.primitives, isNotEmpty, reason: name);
      for (final primitive in data.primitives) {
        final bounds = primitive.buildPath().getBounds();
        expect(bounds.isFinite, isTrue, reason: name);
      }
    }
    for (final sequence in ['👩🏽‍💻', '🇬🇧', '🇫🇷', '👍🏿', '1️⃣', '❤️']) {
      expect(
        lookupSkribbleEmojiBySequence(sequence),
        isNotNull,
        reason: sequence,
      );
    }
    expect(
      lookupSkribbleEmojiBySequence('🇬🇧'),
      isNot(same(lookupSkribbleEmojiBySequence('🇫🇷'))),
    );
    expect(
      lookupSkribbleEmojiBySequence('👍🏿'),
      isNot(same(lookupSkribbleEmojiBySequence('👍'))),
    );
    expect(
      lookupSkribbleEmojiBySequence('1F469-1F3FD-200D-1F4BB'),
      same(lookupSkribbleEmojiBySequence('👩🏽‍💻')),
    );
    for (final name in [
      'distorted_face',
      'orca',
      'trombone',
      'treasure_chest',
    ]) {
      expect(lookupSkribbleEmojiByName(name), isNotNull, reason: name);
    }
  });

  testWidgets('late emoji data and size changes keep hooks and labels valid', (
    tester,
  ) async {
    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: Center(
          child: PrecomputedEmoji(semanticLabel: 'Waiting for a smile'),
        ),
      ),
    );
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Center(
          child: PrecomputedEmoji.fromName(
            'grinning_face',
            size: 64,
            semanticLabel: 'A smile',
          ),
        ),
      ),
    );
    expect(tester.getSize(find.byType(PrecomputedEmoji)), const Size(64, 64));
    expect(find.bySemanticsLabel('A smile'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
