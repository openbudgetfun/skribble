/// One fully-qualified emoji from Unicode's `emoji-test.txt`.
final class UnicodeEmoji {
  /// Creates an emoji record.
  const UnicodeEmoji({
    required this.codePoints,
    required this.name,
    required this.group,
    required this.subgroup,
    required this.version,
  });

  /// The scalar values, including variation selectors and joiners.
  final List<int> codePoints;

  /// The Unicode short name, such as `thumbs up: medium skin tone`.
  final String name;

  /// The Unicode group, such as `People & Body`.
  final String group;

  /// The Unicode subgroup, such as `hand-fingers-closed`.
  final String subgroup;

  /// The Emoji version that introduced it, such as `15.1`.
  final String version;

  /// The emoji as a string.
  String get emoji => String.fromCharCodes(codePoints);
}

/// Parses the fully-qualified emoji from the text of `emoji-test.txt`.
List<UnicodeEmoji> parseEmojiTest(String text) {
  final result = <UnicodeEmoji>[];
  String? group;
  String? subgroup;
  final line = RegExp(
    r'^([0-9A-F ]+);\s*fully-qualified\s*#\s*\S+\s+E([\d.]+)\s+(.+)$',
  );
  for (final raw in text.split('\n')) {
    if (raw.startsWith('# group:')) {
      group = raw.substring(8).trim();
      continue;
    }
    if (raw.startsWith('# subgroup:')) {
      subgroup = raw.substring(11).trim();
      continue;
    }
    final match = line.firstMatch(raw.trim());
    if (match == null) continue;
    result.add(
      UnicodeEmoji(
        codePoints: [
          for (final hex in match.group(1)!.trim().split(RegExp(r'\s+')))
            int.parse(hex, radix: 16),
        ],
        name: match.group(3)!.trim(),
        group: group!,
        subgroup: subgroup!,
        version: match.group(2)!,
      ),
    );
  }
  return result;
}

/// Skin tone qualifiers in Unicode names, in modifier order.
const List<String> kToneNames = [
  'light skin tone',
  'medium-light skin tone',
  'medium skin tone',
  'medium-dark skin tone',
  'dark skin tone',
];

/// How one emoji is drawn: which art, which hair variant, which tones.
final class EmojiPlan {
  /// Creates a plan.
  const EmojiPlan({
    required this.emoji,
    required this.art,
    required this.baseName,
    this.variant,
    this.mirrored = false,
    this.tone = 0,
    this.tone2 = 0,
  });

  /// The emoji being drawn.
  final UnicodeEmoji emoji;

  /// The art key, such as `thumbs-up`.
  final String art;

  /// The name without skin tone qualifiers, which identifies the emoji's
  /// untoned form.
  final String baseName;

  /// `person`, `man`, or `woman` for gendered art, otherwise null.
  final String? variant;

  /// Whether the art is mirrored, for "facing right" emoji.
  final bool mirrored;

  /// The first person's tone: 0 for none, 1–5 light to dark.
  final int tone;

  /// The second person's tone: 0 for none, 1–5 light to dark.
  final int tone2;
}

/// Works out the art, variant, tones, and mirroring for every emoji.
///
/// Gendered emoji that Unicode names "man …", "woman …", and "person …" (or
/// "… man", "man: …", or "men …") share one drawing with three hair
/// variants, keyed by the shared concept. A bare concept, such as "detective", is the person
/// variant. Skin tones never change the art. "Facing right" emoji mirror the
/// art of the emoji they turn around.
List<EmojiPlan> planEmoji(List<UnicodeEmoji> emoji) {
  final split = [for (final item in emoji) _split(item)];

  // Concepts seen with at least two genders become shared, variant art.
  final genders = <String, Set<String>>{};
  for (final (_, base, _, _) in split) {
    final gendered = _gendered(base);
    if (gendered != null) {
      (genders[gendered.$1] ??= {}).add(gendered.$2);
    }
  }
  final bareNames = {for (final (_, base, _, _) in split) base};

  final plans = <EmojiPlan>[];
  for (final (index, (item, base, tones, mirrored)) in split.indexed) {
    var art = _artKey(emoji[index], base);
    String? variant;
    final gendered = _gendered(base);
    if (gendered != null) {
      final (concept, gender) = gendered;
      final seen = {
        ...?genders[concept],
        if (bareNames.contains(concept)) 'person',
      };
      if (seen.length >= 2) {
        art = _kebab(concept);
        variant = gender;
      }
    } else if ((genders[base]?.length ?? 0) >= 1) {
      // The bare concept beside its gendered forms is the person variant.
      art = _kebab(base);
      variant = 'person';
    }
    plans.add(
      EmojiPlan(
        emoji: item,
        art: art,
        baseName: base + (mirrored ? ': facing right' : ''),
        variant: variant,
        mirrored: mirrored,
        tone: tones.isEmpty ? 0 : tones.first,
        tone2: tones.isEmpty ? 0 : tones.last,
      ),
    );
  }
  return plans;
}

/// Splits a name into the emoji, its untoned name, its tones, and whether it
/// faces right.
(UnicodeEmoji, String, List<int>, bool) _split(UnicodeEmoji emoji) {
  const facingRight = ' facing right';
  var name = emoji.name;
  var mirrored = false;
  final colon = name.indexOf(': ');
  var head = colon < 0 ? name : name.substring(0, colon);
  if (head.endsWith(facingRight)) {
    mirrored = true;
    head = head.substring(0, head.length - facingRight.length);
    name = head + (colon < 0 ? '' : name.substring(colon));
  }
  if (colon < 0) return (emoji, head, const [], mirrored);
  final qualifiers = name.substring(name.indexOf(': ') + 2).split(', ');
  final tones = <int>[];
  final kept = <String>[];
  for (final qualifier in qualifiers) {
    final tone = kToneNames.indexOf(qualifier);
    if (tone >= 0) {
      tones.add(tone + 1);
    } else if (qualifier == 'facing right') {
      mirrored = true;
    } else {
      kept.add(qualifier);
    }
  }
  final base = kept.isEmpty ? head : '$head: ${kept.join(', ')}';
  return (emoji, base, tones, mirrored);
}

/// Names Unicode spells differently from their gendered siblings.
const Map<String, (String, String)> _genderedAliases = {
  'older person': ('old', 'person'),
};

/// `(concept, gender)` for gendered names, or null.
(String, String)? _gendered(String name) {
  if (_genderedAliases[name] case final alias?) return alias;
  final prefix = RegExp(r'^(man|woman|person|men|women|people):? (.+)$')
      .firstMatch(name);
  if (prefix != null) {
    final gender = switch (prefix.group(1)!) {
      'men' => 'man',
      'women' => 'woman',
      'people' => 'person',
      final single => single,
    };
    return (prefix.group(2)!, gender);
  }
  final suffix = RegExp(r'^(.+) (man|woman|person)$').firstMatch(name);
  if (suffix != null &&
      !suffix.group(1)!.contains(':') &&
      !suffix.group(1)!.endsWith(' and')) {
    return (suffix.group(1)!, suffix.group(2)!);
  }
  return null;
}

String _artKey(UnicodeEmoji emoji, String base) {
  final points = emoji.codePoints;
  // Country flags: two regional indicators spell the ISO code.
  if (points.length == 2 &&
      points.every((point) => point >= 0x1F1E6 && point <= 0x1F1FF)) {
    final code = String.fromCharCodes([
      for (final point in points) point - 0x1F1E6 + 0x61,
    ]);
    return 'flag-$code';
  }
  // Subdivision flags: black flag, tag letters, cancel tag.
  if (points.first == 0x1F3F4 && points.length > 2 && points[1] >= 0xE0061) {
    final tags = String.fromCharCodes([
      for (final point in points.skip(1))
        if (point >= 0xE0061 && point <= 0xE007A) point - 0xE0000,
    ]);
    return 'flag-${tags.substring(0, 2)}-${tags.substring(2)}';
  }
  if (base.startsWith('keycap: ')) {
    final key = base.substring(8);
    return 'keycap-${switch (key) {
      '#' => 'hash',
      '*' => 'asterisk',
      _ => key,
    }}';
  }
  return _kebab(base);
}

const Map<String, String> _accents = {
  'á': 'a', 'à': 'a', 'â': 'a', 'ä': 'a', 'ã': 'a', 'å': 'a', //
  'é': 'e', 'è': 'e', 'ê': 'e', 'ë': 'e', //
  'í': 'i', 'ì': 'i', 'î': 'i', 'ï': 'i', //
  'ó': 'o', 'ò': 'o', 'ô': 'o', 'ö': 'o', 'õ': 'o', //
  'ú': 'u', 'ù': 'u', 'û': 'u', 'ü': 'u', //
  'ñ': 'n', 'ç': 'c', 'ō': 'o', 'ş': 's', 'ţ': 't',
};

String _kebab(String name) {
  final lower = name.toLowerCase();
  final buffer = StringBuffer();
  for (final rune in lower.runes) {
    final character = String.fromCharCode(rune);
    buffer.write(_accents[character] ?? character);
  }
  return buffer
      .toString()
      .replaceAll(RegExp('[’\'“”"]'), '')
      .replaceAll(RegExp('[^a-z0-9]+'), '-')
      .replaceAll(RegExp(r'^-+|-+$'), '');
}
