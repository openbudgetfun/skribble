import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';
import 'package:skribble_emoji/lottie.dart';
import 'package:skribble_emoji/skribble_emoji.dart';

void main() {
  final config = emojiDrawConfig(WiredThemeData(), 72);

  Map<String, Object?> export(String emoji, {int inkings = 3}) => emojiLottie(
    SkribbleEmoji.lookup(emoji)!,
    config: config,
    inkings: inkings,
  );

  List<Map<String, Object?>> layers(Map<String, Object?> lottie) =>
      (lottie['layers']! as List).cast<Map<String, Object?>>();

  test('describes one loop of the motion at the frame rate', () {
    final heart = export('❤️');
    final motion = EmojiMotions.of(SkribbleEmoji.lookup('❤️')!)!;
    expect(heart['fr'], 24);
    expect(heart['op'], (motion.duration.inMilliseconds * 24 / 1000).round());
    expect(heart['w'], 512);
    expect(heart['nm'], 'red heart');
    // The JSON is plain data.
    expect(() => jsonEncode(heart), returnsNormally);
  });

  test('parents shapes through null layers for each track', () {
    final hand = layers(export('👋'));
    final nulls = hand.where((layer) => layer['ty'] == 3).toList();
    final shapes = hand.where((layer) => layer['ty'] == 4).toList();
    expect(nulls.map((layer) => layer['nm']), containsAll(['scale', 'hand']));
    expect(shapes, isNotEmpty);
    final indices = {for (final layer in hand) layer['ind']};
    for (final layer in hand) {
      if (layer['parent'] case final parent?) {
        expect(indices, contains(parent));
      }
    }
    final handLayer = nulls.firstWhere((layer) => layer['nm'] == 'hand');
    final rotation = (handLayer['ks']! as Map)['r']! as Map;
    expect(rotation['a'], 1, reason: 'the hand turns');
  });

  test('boils by cycling inkings with held opacity', () {
    final boiled = layers(export('🔥'));
    final layer = boiled.firstWhere((layer) => layer['ty'] == 4);
    final groups = layer['shapes']! as List;
    expect(groups, hasLength(3));
    final transform = ((groups.first as Map)['it']! as List).last as Map;
    final opacity = transform['o']! as Map;
    expect(opacity['a'], 1);
    expect(((opacity['k']! as List).first as Map)['h'], 1);

    final still = layers(export('🔥', inkings: 1));
    final single = still.firstWhere((layer) => layer['ty'] == 4);
    expect(single['shapes'], hasLength(1));
  });

  test('fades parts through their layer opacity', () {
    final joy = layers(export('😂'));
    final tears = joy.firstWhere(
      (layer) => layer['ty'] == 4 && layer['nm'] == 'tears',
    );
    final opacity = (tears['ks']! as Map)['o']! as Map;
    expect(opacity['a'], 1);
  });

  test('masks clipped shapes with their clip path', () {
    final socks = layers(export('🧦', inkings: 1));
    final masked = [
      for (final layer in socks)
        if (layer['hasMask'] == true) layer,
    ];
    expect(masked, isNotEmpty);
    for (final layer in masked) {
      final masks = (layer['masksProperties']! as List)
          .cast<Map<String, Object?>>();
      expect(masks, isNotEmpty);
      expect(masks.first['mode'], 'a', reason: 'clips add, they never cut');
      expect((masks.first['pt']! as Map)['k'], isA<Map<String, Object?>>());
    }
  });

  // Writes Lottie files for review when EMOJI_LOTTIE_OUT is set, for the
  // comma-separated emoji in EMOJI_LOTTIE (default: every choreographed one).
  test('export Lottie files', () {
    final out = Platform.environment['EMOJI_LOTTIE_OUT'];
    if (out == null) return;
    final wanted = Platform.environment['EMOJI_LOTTIE'];
    final entries = wanted == null
        ? [
            for (final art in EmojiMotions.choreographed.keys)
              ?SkribbleEmoji.all.where((entry) => entry.art == art).firstOrNull,
          ]
        : [for (final emoji in wanted.split(',')) ?SkribbleEmoji.lookup(emoji)];
    Directory(out).createSync(recursive: true);
    for (final entry in entries) {
      File('$out/${entry.identifier}.json').writeAsStringSync(
        jsonEncode(emojiLottie(entry, config: config)),
      );
    }
  });
}
