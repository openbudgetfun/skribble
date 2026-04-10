import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart' show WiredSvgIcon;
import 'package:skribble_emoji/skribble_emoji.dart';

void main() {
  group('kSkribbleEmoji map', () {
    test('contains 50 emoji entries', () {
      expect(kSkribbleEmoji, hasLength(50));
    });

    test('all entries have valid dimensions', () {
      for (final entry in kSkribbleEmoji.entries) {
        expect(
          entry.value.width,
          72.0,
          reason: 'Emoji 0x${entry.key.toRadixString(16)} width',
        );
        expect(
          entry.value.height,
          72.0,
          reason: 'Emoji 0x${entry.key.toRadixString(16)} height',
        );
      }
    });

    test('all entries have at least one primitive', () {
      for (final entry in kSkribbleEmoji.entries) {
        expect(
          entry.value.primitives,
          isNotEmpty,
          reason: 'Emoji 0x${entry.key.toRadixString(16)} primitives',
        );
      }
    });

    test('all primitives are WiredSvgPathPrimitive', () {
      for (final entry in kSkribbleEmoji.entries) {
        for (final prim in entry.value.primitives) {
          expect(
            prim,
            isA<WiredSvgPathPrimitive>(),
            reason: 'Emoji 0x${entry.key.toRadixString(16)} primitive type',
          );
        }
      }
    });
  });

  group('kSkribbleEmojiCodePoints map', () {
    test('contains 50 entries', () {
      expect(kSkribbleEmojiCodePoints, hasLength(50));
    });

    test('maps known emoji names to correct codepoints', () {
      expect(kSkribbleEmojiCodePoints['grinning_face'], 0x1f600);
      expect(kSkribbleEmojiCodePoints['thumbs_up'], 0x1f44d);
      expect(kSkribbleEmojiCodePoints['red_heart'], 0x2764);
      expect(kSkribbleEmojiCodePoints['fire'], 0x1f525);
      expect(kSkribbleEmojiCodePoints['rocket'], 0x1f680);
      expect(kSkribbleEmojiCodePoints['star'], 0x2b50);
    });

    test('all codepoints exist in kSkribbleEmoji', () {
      for (final entry in kSkribbleEmojiCodePoints.entries) {
        expect(
          kSkribbleEmoji.containsKey(entry.value),
          isTrue,
          reason: '${entry.key} -> 0x${entry.value.toRadixString(16)}',
        );
      }
    });
  });

  group('lookupSkribbleEmojiByName', () {
    test('returns data for known emoji names', () {
      expect(lookupSkribbleEmojiByName('grinning_face'), isNotNull);
      expect(lookupSkribbleEmojiByName('thumbs_up'), isNotNull);
      expect(lookupSkribbleEmojiByName('fire'), isNotNull);
      expect(lookupSkribbleEmojiByName('red_heart'), isNotNull);
      expect(lookupSkribbleEmojiByName('rocket'), isNotNull);
    });

    test('returns null for unknown names', () {
      expect(lookupSkribbleEmojiByName('nonexistent_emoji'), isNull);
      expect(lookupSkribbleEmojiByName(''), isNull);
      expect(lookupSkribbleEmojiByName('smiley'), isNull);
    });

    test('returned data has correct dimensions', () {
      final data = lookupSkribbleEmojiByName('grinning_face');
      expect(data, isNotNull);
      expect(data!.width, 72.0);
      expect(data.height, 72.0);
      expect(data.primitives, isNotEmpty);
    });
  });

  group('lookupSkribbleEmojiByUnicode', () {
    test('returns data for known codepoints', () {
      expect(lookupSkribbleEmojiByUnicode(0x1f600), isNotNull);
      expect(lookupSkribbleEmojiByUnicode(0x1f44d), isNotNull);
      expect(lookupSkribbleEmojiByUnicode(0x2764), isNotNull);
      expect(lookupSkribbleEmojiByUnicode(0x1f525), isNotNull);
      expect(lookupSkribbleEmojiByUnicode(0x1f680), isNotNull);
    });

    test('returns null for unknown codepoints', () {
      expect(lookupSkribbleEmojiByUnicode(0), isNull);
      expect(lookupSkribbleEmojiByUnicode(0xffff), isNull);
      expect(lookupSkribbleEmojiByUnicode(-1), isNull);
    });

    test('returned data matches lookupByName', () {
      final byName = lookupSkribbleEmojiByName('grinning_face');
      final byUnicode = lookupSkribbleEmojiByUnicode(0x1f600);
      expect(byName, same(byUnicode));
    });
  });

  group('WiredEmoji widget', () {
    testWidgets('renders without error with null data', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: WiredEmoji(),
            ),
          ),
        ),
      );

      expect(find.byType(WiredEmoji), findsOneWidget);
      // Placeholder should show "?"
      expect(find.text('?'), findsOneWidget);
    });

    testWidgets('renders with explicit null data', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: WiredEmoji(size: 48),
            ),
          ),
        ),
      );

      expect(find.byType(WiredEmoji), findsOneWidget);
    });

    testWidgets('fromName renders real emoji data', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: WiredEmoji.fromName('grinning_face', size: 32),
            ),
          ),
        ),
      );

      expect(find.byType(WiredEmoji), findsOneWidget);
      // Should NOT show placeholder since emoji is found
      expect(find.text('?'), findsNothing);
      // Should render a WiredSvgIcon
      expect(find.byType(WiredSvgIcon), findsOneWidget);
    });

    testWidgets('fromName renders placeholder for unknown name',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: WiredEmoji.fromName('nonexistent_emoji', size: 32),
            ),
          ),
        ),
      );

      expect(find.byType(WiredEmoji), findsOneWidget);
      expect(find.text('?'), findsOneWidget);
    });

    testWidgets('fromUnicode renders real emoji data', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: WiredEmoji.fromUnicode(0x1f525, size: 48),
            ),
          ),
        ),
      );

      expect(find.byType(WiredEmoji), findsOneWidget);
      expect(find.text('?'), findsNothing);
      expect(find.byType(WiredSvgIcon), findsOneWidget);
    });

    testWidgets('fromUnicode renders placeholder for unknown codepoint',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: WiredEmoji.fromUnicode(0xffff, size: 32),
            ),
          ),
        ),
      );

      expect(find.byType(WiredEmoji), findsOneWidget);
      expect(find.text('?'), findsOneWidget);
    });

    testWidgets('respects size parameter', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: WiredEmoji(size: 64),
            ),
          ),
        ),
      );

      final sizedBox = tester.widget<SizedBox>(find.byType(SizedBox).first);
      expect(sizedBox.width, 64);
      expect(sizedBox.height, 64);
    });

    testWidgets('renders with explicit WiredSvgIconData', (tester) async {
      final data = lookupSkribbleEmojiByName('star')!;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: WiredEmoji(data: data, size: 40),
            ),
          ),
        ),
      );

      expect(find.byType(WiredEmoji), findsOneWidget);
      expect(find.text('?'), findsNothing);
      expect(find.byType(WiredSvgIcon), findsOneWidget);
    });
  });
}
