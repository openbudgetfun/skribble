import 'generated/skribble_emoji.g.dart';
import 'generated/skribble_emoji_codepoints.g.dart';
import 'wired_svg_icon_data.dart';

/// A utility class for searching and filtering Skribble emoji.
///
/// Provides methods for searching emoji by partial name match,
/// filtering by category, and getting emoji suggestions.
///
/// ## Example
///
/// ```dart
/// // Search for emoji containing "face"
/// final results = EmojiSearch.search('face');
///
/// // Get all emoji in a category
/// final smileys = EmojiSearch.getByCategory('smileys');
///
/// // Get emoji suggestions for a partial input
/// final suggestions = EmojiSearch.suggest('grin');
/// ```
class EmojiSearch {
  EmojiSearch._();

  /// Searches for emoji whose names contain the given [query].
  ///
  /// The search is case-insensitive and returns a list of
  /// [EmojiSearchResult] objects containing the emoji data and
  /// the matched name.
  ///
  /// ```dart
  /// final results = EmojiSearch.search('heart');
  /// for (final result in results) {
  ///   print('${result.name}: ${result.data}');
  /// }
  /// ```
  static List<EmojiSearchResult> search(String query) {
    if (query.isEmpty) return [];

    final lowerQuery = query.toLowerCase();
    final results = <EmojiSearchResult>[];

    for (final entry in kSkribbleEmojiCodePoints.entries) {
      if (entry.key.toLowerCase().contains(lowerQuery)) {
        final data = kSkribbleEmoji[entry.value];
        if (data != null) {
          results.add(EmojiSearchResult(
            name: entry.key,
            codePoint: entry.value,
            data: data,
          ));
        }
      }
    }

    return results;
  }

  /// Returns emoji names that start with the given [prefix].
  ///
  /// Useful for autocomplete functionality.
  ///
  /// ```dart
  /// final suggestions = EmojiSearch.suggest('thumb');
  /// // Returns: ['thumbs_up', 'thumbs_down']
  /// ```
  static List<String> suggest(String prefix) {
    if (prefix.isEmpty) return [];

    final lowerPrefix = prefix.toLowerCase();
    final suggestions = <String>[];

    for (final name in kSkribbleEmojiCodePoints.keys) {
      if (name.toLowerCase().startsWith(lowerPrefix)) {
        suggestions.add(name);
      }
    }

    return suggestions;
  }

  /// Returns all emoji names in the collection.
  ///
  /// ```dart
  /// final allNames = EmojiSearch.allNames();
  /// print('Total emoji: ${allNames.length}');
  /// ```
  static List<String> allNames() {
    return kSkribbleEmojiCodePoints.keys.toList();
  }

  /// Returns the total number of emoji in the collection.
  ///
  /// ```dart
  /// final count = EmojiSearch.count();
  /// print('Total emoji: $count');
  /// ```
  static int count() {
    return kSkribbleEmojiCodePoints.length;
  }

  /// Returns emoji grouped by common category prefixes.
  ///
  /// Categories are determined by common name prefixes like:
  /// - 'face' - Face emoji
  /// - 'hand' - Hand gesture emoji
  /// - 'heart' - Heart emoji
  /// - 'animal' - Animal emoji
  /// - 'food' - Food emoji
  /// - 'travel' - Travel emoji
  /// - 'object' - Object emoji
  /// - 'symbol' - Symbol emoji
  ///
  /// ```dart
  /// final categories = EmojiSearch.categories();
  /// for (final category in categories.entries) {
  ///   print('${category.key}: ${category.value.length} emoji');
  /// }
  /// ```
  static Map<String, List<EmojiSearchResult>> categories() {
    final categories = <String, List<EmojiSearchResult>>{};

    for (final entry in kSkribbleEmojiCodePoints.entries) {
      final name = entry.key;
      final data = kSkribbleEmoji[entry.value];

      if (data == null) continue;

      // Determine category from name prefix
      String category;
      if (name.startsWith('face') || name.contains('_face')) {
        category = 'faces';
      } else if (name.startsWith('hand') || name.contains('_hand') || name.contains('thumb')) {
        category = 'hands';
      } else if (name.contains('heart')) {
        category = 'hearts';
      } else if (name.contains('animal') || name.contains('cat') || name.contains('dog') || name.contains('bird')) {
        category = 'animals';
      } else if (name.contains('food') || name.contains('fruit') || name.contains('vegetable')) {
        category = 'food';
      } else if (name.contains('travel') || name.contains('car') || name.contains('plane') || name.contains('ship')) {
        category = 'travel';
      } else if (name.contains('object') || name.contains('tool') || name.contains('phone') || name.contains('computer')) {
        category = 'objects';
      } else if (name.contains('symbol') || name.contains('warning') || name.contains('check')) {
        category = 'symbols';
      } else {
        category = 'other';
      }

      categories.putIfAbsent(category, () => []);
      categories[category]!.add(EmojiSearchResult(
        name: name,
        codePoint: entry.value,
        data: data,
      ));
    }

    return categories;
  }
}

/// A result from an emoji search.
class EmojiSearchResult {
  /// The name of the emoji (e.g., 'grinning_face').
  final String name;

  /// The Unicode codepoint of the emoji.
  final int codePoint;

  /// The emoji icon data.
  final WiredSvgIconData data;

  /// Creates an emoji search result.
  const EmojiSearchResult({
    required this.name,
    required this.codePoint,
    required this.data,
  });

  @override
  String toString() => 'EmojiSearchResult($name, U+${codePoint.toRadixString(16).toUpperCase()})';
}
