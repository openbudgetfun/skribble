import 'package:skribble_emoji/src/emoji_art.dart';
import 'package:skribble_emoji/src/emoji_palette.dart';
import 'package:skribble_emoji/src/generated/emoji_art.g.dart';
import 'package:skribble_emoji/src/generated/emoji_catalog.g.dart';

/// The Unicode emoji groups, in the order emoji pickers list them.
enum EmojiGroup {
  /// Faces, hearts, and feelings.
  smileysAndEmotion('Smileys & Emotion'),

  /// Hands, people, roles, families, and activities.
  peopleAndBody('People & Body'),

  /// Skin tone and hair components.
  component('Component'),

  /// Animals, plants, and weather.
  animalsAndNature('Animals & Nature'),

  /// Food and drink.
  foodAndDrink('Food & Drink'),

  /// Places, transport, time, and sky.
  travelAndPlaces('Travel & Places'),

  /// Events, sports, games, and arts.
  activities('Activities'),

  /// Clothing, sound, devices, tools, and household things.
  objects('Objects'),

  /// Signs, arrows, shapes, and other symbols.
  symbols('Symbols'),

  /// National, regional, and other flags.
  flags('Flags');

  const EmojiGroup(this.label);

  /// The group's name as Unicode writes it.
  final String label;
}

/// One fully-qualified emoji from the Unicode catalog and how to draw it.
final class EmojiEntry {
  /// Creates an entry. The generated catalog is the only producer.
  const EmojiEntry(
    this.emoji,
    this.name,
    this.group,
    this.subgroup,
    this.art, {
    this.tone = EmojiSkinTone.none,
    this.tone2 = EmojiSkinTone.none,
    this.variant,
    this.mirrored = false,
    this.hasTones = false,
  });

  /// The emoji itself, such as `👍🏽`.
  final String emoji;

  /// The Unicode short name, such as `thumbs up: medium skin tone`.
  final String name;

  /// The Unicode group.
  final EmojiGroup group;

  /// The Unicode subgroup, such as `face-smiling`.
  final String subgroup;

  /// The key of the art this emoji is drawn with.
  final String art;

  /// The first person's skin tone.
  final EmojiSkinTone tone;

  /// The second person's skin tone, in two-person emoji.
  final EmojiSkinTone tone2;

  /// Which hair variant of the art to draw, for gendered emoji.
  final EmojiVariant? variant;

  /// Whether the art is drawn mirrored, for the "facing right" emoji.
  final bool mirrored;

  /// Whether skin-toned variants of this emoji exist.
  final bool hasTones;

  /// The short name in snake case, such as `thumbs_up_medium_skin_tone`.
  String get identifier => name
      .toLowerCase()
      .replaceAll(RegExp("[’'.!]"), '')
      .replaceAll(RegExp('[^a-z0-9]+'), '_')
      .replaceAll(RegExp(r'^_+|_+$'), '');

  /// The drawing for this emoji.
  EmojiArt get drawing => kSkribbleEmojiArt[art]!;

  @override
  String toString() => 'EmojiEntry($emoji, $name)';
}

/// Lookups over skribble's emoji catalog.
///
/// The catalog covers every fully-qualified emoji in Unicode Emoji 18.0,
/// including skin tones, gendered variants, families, keycaps, and flags.
abstract final class SkribbleEmoji {
  /// Every fully-qualified emoji, in Unicode order.
  static List<EmojiEntry> get all => kSkribbleEmojiEntries;

  /// Emoji without skin-tone modifiers, in Unicode order. Pickers show these
  /// and offer [withTone] on the ones whose [EmojiEntry.hasTones] is set.
  static List<EmojiEntry> get defaults => _defaults;

  static final List<EmojiEntry> _defaults = [
    for (final entry in kSkribbleEmojiEntries)
      if (entry.tone == EmojiSkinTone.none &&
          entry.group != EmojiGroup.component)
        entry,
  ];

  static final Map<String, EmojiEntry> _byEmoji = {
    for (final entry in kSkribbleEmojiEntries) _normalize(entry.emoji): entry,
  };

  static final Map<String, EmojiEntry> _byIdentifier = {
    for (final entry in kSkribbleEmojiEntries) entry.identifier: entry,
  };

  /// The entry for emoji [text], ignoring variation selectors, or null.
  ///
  /// Minimally-qualified and unqualified forms (such as `❤` without
  /// `U+FE0F`) resolve to their fully-qualified entry.
  static EmojiEntry? lookup(String text) => _byEmoji[_normalize(text)];

  /// The entry with snake-case [identifier], such as `grinning_face`.
  static EmojiEntry? named(String identifier) => _byIdentifier[identifier];

  /// The entry for [entry] drawn with skin [tone], or null when the emoji has
  /// no such variant.
  ///
  /// Every person in the emoji takes the same tone. Mixed tones, such as two
  /// people holding hands with different skin, are separate entries in [all].
  static EmojiEntry? withTone(EmojiEntry entry, EmojiSkinTone tone) {
    final base = _stripTones(entry.emoji);
    if (tone == EmojiSkinTone.none) return lookup(base);
    final variants = kSkribbleEmojiTones[_normalize(base)];
    if (variants == null) return null;
    return lookup(variants[tone.index - 1]);
  }

  /// Emoji in [group], without skin-tone modifiers.
  static List<EmojiEntry> inGroup(EmojiGroup group) => [
    for (final entry in _defaults)
      if (entry.group == group) entry,
  ];

  /// Emoji whose name contains every word in [query], best matches first.
  ///
  /// Matches at the start of a word rank above matches inside one, and
  /// shorter names rank above longer ones. Skin-toned variants are left out.
  static List<EmojiEntry> search(String query, {int limit = 50}) {
    final words = query
        .toLowerCase()
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .toList();
    if (words.isEmpty) return const [];
    final scored = <(EmojiEntry, int)>[];
    for (final entry in _defaults) {
      final name = entry.name.toLowerCase();
      var score = 0;
      var matches = true;
      for (final word in words) {
        final index = name.indexOf(word);
        if (index < 0) {
          matches = false;
          break;
        }
        score += index == 0 || name[index - 1] == ' ' ? 0 : 10;
      }
      if (matches) scored.add((entry, score * 100 + name.length));
    }
    scored.sort((a, b) => a.$2.compareTo(b.$2));
    return [for (final (entry, _) in scored.take(limit)) entry];
  }

  static String _normalize(String text) => text.replaceAll('️', '');

  static String _stripTones(String text) => String.fromCharCodes(
    text.runes.where((rune) => EmojiSkinTone.fromModifier(rune) == null),
  );
}
