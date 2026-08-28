import 'package:flutter_test/flutter_test.dart';
import 'package:skribble_emoji/skribble_emoji.dart';

void main() {
  group('Emoji Performance', () {
    test('emoji lookup by unicode is fast', () {
      final stopwatch = Stopwatch()..start();

      // Test looking up 1000 emoji by unicode
      for (var i = 0; i < 1000; i++) {
        final codePoint = 0x1F600 + (i % 100); // Smileys range
        lookupSkribbleEmojiByUnicode(codePoint);
      }

      stopwatch.stop();

      // Should complete in less than 100ms
      expect(stopwatch.elapsedMilliseconds, lessThan(100));
    });

    test('emoji lookup by name is fast', () {
      final stopwatch = Stopwatch()..start();

      // Test looking up emoji by name
      final names = [
        'grinning_face',
        'smiling_face_with_heart_eyes',
        'thumbs_up',
        'red_heart',
        'fire',
      ];

      for (var i = 0; i < 1000; i++) {
        lookupSkribbleEmojiByName(names[i % names.length]);
      }

      stopwatch.stop();

      // Should complete in less than 100ms
      expect(stopwatch.elapsedMilliseconds, lessThan(100));
    });

    test('emoji map contains expected count', () {
      // Verify we have the full OpenMoji set
      expect(kSkribbleEmoji.length, greaterThanOrEqualTo(1800));
    });

    test('emoji codepoints map is consistent', () {
      // Verify codepoints map matches main map
      for (final entry in kSkribbleEmojiCodePoints.entries) {
        final emoji = kSkribbleEmoji[entry.value];
        expect(
          emoji,
          isNotNull,
          reason: 'Codepoint ${entry.key} points to missing emoji',
        );
      }
    });
  });
}
