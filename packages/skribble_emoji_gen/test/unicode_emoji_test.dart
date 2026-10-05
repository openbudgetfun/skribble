import 'package:skribble_emoji_gen/unicode_emoji.dart';
import 'package:test/test.dart';

/// A small `emoji-test.txt` in Unicode's format.
const _sample = '''
# group: Smileys & Emotion
# subgroup: face-smiling
1F600                                                  ; fully-qualified     # 😀 E1.0 grinning face
# subgroup: heart
2764 FE0F                                              ; fully-qualified     # ❤️ E0.6 red heart
2764                                                   ; unqualified         # ❤ E0.6 red heart

# group: People & Body
# subgroup: hand-fingers-closed
1F44D                                                  ; fully-qualified     # 👍 E0.6 thumbs up
1F44D 1F3FD                                            ; fully-qualified     # 👍🏽 E1.0 thumbs up: medium skin tone
# subgroup: person-role
1F9D1 200D 1F4BB                                       ; fully-qualified     # 🧑‍💻 E12.1 technologist
1F468 200D 1F4BB                                       ; fully-qualified     # 👨‍💻 E4.0 man technologist
1F469 1F3FF 200D 1F4BB                                 ; fully-qualified     # 👩🏿‍💻 E4.0 woman technologist: dark skin tone
1F575 FE0F                                             ; fully-qualified     # 🕵️ E0.7 detective
1F575 FE0F 200D 2642 FE0F                              ; fully-qualified     # 🕵️‍♂️ E4.0 man detective
1F9D3                                                  ; fully-qualified     # 🧓 E5.0 older person
1F474                                                  ; fully-qualified     # 👴 E0.6 old man
# subgroup: person-activity
1F6B6 200D 27A1 FE0F                                   ; fully-qualified     # 🚶‍➡️ E15.1 person walking facing right
1F6B6                                                  ; fully-qualified     # 🚶 E0.6 person walking
1F468 200D 1F9AF                                       ; fully-qualified     # 👨‍🦯 E12.0 man with white cane
# subgroup: family
1F9D1 1F3FB 200D 1F91D 200D 1F9D1 1F3FF                ; fully-qualified     # 🧑🏻‍🤝‍🧑🏿 E12.0 people holding hands: light skin tone, dark skin tone

# group: Symbols
# subgroup: keycap
0023 FE0F 20E3                                         ; fully-qualified     # #️⃣ E0.6 keycap: #
0031 FE0F 20E3                                         ; fully-qualified     # 1️⃣ E0.6 keycap: 1

# group: Flags
# subgroup: country-flag
1F1EF 1F1F5                                            ; fully-qualified     # 🇯🇵 E0.6 flag: Japan
# subgroup: subdivision-flag
1F3F4 E0067 E0062 E0065 E006E E0067 E007F              ; fully-qualified     # 🏴󠁧󠁢󠁥󠁮󠁧󠁿 E5.0 flag: England
''';

void main() {
  final emoji = parseEmojiTest(_sample);
  final plans = {for (final plan in planEmoji(emoji)) plan.emoji.name: plan};

  test('parses fully-qualified emoji with their group and version', () {
    expect(emoji, hasLength(19));
    final heart = emoji[1];
    expect(heart.name, 'red heart');
    expect(heart.emoji, '❤️');
    expect(heart.group, 'Smileys & Emotion');
    expect(heart.subgroup, 'heart');
    expect(heart.version, '0.6');
  });

  test('keys art by the kebab-case name', () {
    expect(plans['grinning face']!.art, 'grinning-face');
    expect(plans['red heart']!.art, 'red-heart');
  });

  test('shares art across skin tones', () {
    final toned = plans['thumbs up: medium skin tone']!;
    expect(toned.art, 'thumbs-up');
    expect(toned.tone, 3);
    expect(toned.baseName, 'thumbs up');
    expect(plans['thumbs up']!.tone, 0);
  });

  test('gives each person in a pair their own tone', () {
    final pair =
        plans['people holding hands: light skin tone, dark skin tone']!;
    expect(pair.art, 'people-holding-hands');
    expect((pair.tone, pair.tone2), (1, 5));
  });

  test('shares one drawing between gendered variants', () {
    expect(plans['technologist']!.art, 'technologist');
    expect(plans['technologist']!.variant, 'person');
    expect(plans['man technologist']!.variant, 'man');
    final woman = plans['woman technologist: dark skin tone']!;
    expect(
      (woman.art, woman.variant, woman.tone),
      ('technologist', 'woman', 5),
    );
    expect(plans['man detective']!.art, 'detective');
    expect(plans['detective']!.variant, 'person');
  });

  test('pairs Unicode aliases such as older person and old man', () {
    expect(plans['older person']!.art, 'old');
    expect(plans['older person']!.variant, 'person');
    expect(plans['old man']!.art, 'old');
    expect(plans['old man']!.variant, 'man');
  });

  test('leaves concepts with only one gender as their own art', () {
    final cane = plans['man with white cane']!;
    expect(cane.art, 'man-with-white-cane');
    expect(cane.variant, isNull);
  });

  test('mirrors facing-right emoji onto the art they turn around', () {
    final right = plans['person walking facing right']!;
    expect(right.art, 'person-walking');
    expect(right.mirrored, isTrue);
    expect(plans['person walking']!.mirrored, isFalse);
  });

  test('names keycaps and flags by key and ISO code', () {
    expect(plans['keycap: #']!.art, 'keycap-hash');
    expect(plans['keycap: 1']!.art, 'keycap-1');
    expect(plans['flag: Japan']!.art, 'flag-jp');
    expect(plans['flag: England']!.art, 'flag-gb-eng');
  });
}
