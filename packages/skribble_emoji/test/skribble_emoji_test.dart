import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble_emoji/skribble_emoji.dart';

void main() {
  group('kSkribbleEmoji map', () {
    test('exists and is empty (scaffold state)', () {
      expect(kSkribbleEmoji, isEmpty);
    });
  });

  group('kSkribbleEmojiCodePoints map', () {
    test('exists and is empty (scaffold state)', () {
      expect(kSkribbleEmojiCodePoints, isEmpty);
    });
  });

  group('lookupSkribbleEmojiByName', () {
    test('returns null for any name (no emoji loaded yet)', () {
      expect(lookupSkribbleEmojiByName('grinning_face'), isNull);
      expect(lookupSkribbleEmojiByName('thumbs_up'), isNull);
      expect(lookupSkribbleEmojiByName(''), isNull);
    });
  });

  group('lookupSkribbleEmojiByUnicode', () {
    test('returns null for any codepoint (no emoji loaded yet)', () {
      expect(lookupSkribbleEmojiByUnicode(0x1f600), isNull);
      expect(lookupSkribbleEmojiByUnicode(0x1f44d), isNull);
      expect(lookupSkribbleEmojiByUnicode(0), isNull);
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

    testWidgets('fromName renders without error with unknown name',
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
      // Should show placeholder since emoji is not found
      expect(find.text('?'), findsOneWidget);
    });

    testWidgets('fromUnicode renders without error with unknown codepoint',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: WiredEmoji.fromUnicode(0x1f600, size: 32),
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
  });
}
