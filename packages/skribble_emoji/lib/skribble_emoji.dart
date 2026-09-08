/// Hand-drawn emoji for Skribble.
///
/// Provides `kSkribbleEmoji`, a compile-time map from codepoint to
/// `WiredSvgIconData`, and [lookupSkribbleEmojiByName] /
/// [lookupSkribbleEmojiByUnicode] for convenient access.
///
/// Emoji SVG sources are from [OpenMoji](https://openmoji.org/) under
/// CC-BY-SA 4.0.
library;

import 'package:skribble_emoji/src/generated/skribble_emoji.g.dart' as gen;
import 'package:skribble_emoji/src/generated/skribble_emoji_codepoints.g.dart'
    as gen_cp;
import 'package:skribble_emoji/src/generated/skribble_emoji_sequences.g.dart'
    as sequences;
import 'package:skribble_emoji/src/wired_svg_icon_data.dart';

export 'package:skribble_emoji/src/emoji_search.dart'
    show EmojiSearch, EmojiSearchResult;
export 'package:skribble_emoji/src/generated/skribble_emoji.g.dart'
    show kSkribbleEmoji;
export 'package:skribble_emoji/src/generated/skribble_emoji_codepoints.g.dart'
    show kSkribbleEmojiCodePoints, kSkribbleEmojiNames;
export 'package:skribble_emoji/src/precomputed_emoji.dart'
    show PrecomputedEmoji;
export 'package:skribble_emoji/src/wired_emoji.dart' show WiredEmoji;
export 'package:skribble_emoji/src/wired_svg_icon_data.dart'
    show
        WiredSvgCirclePrimitive,
        WiredSvgEllipsePrimitive,
        WiredSvgFillRule,
        WiredSvgIconData,
        WiredSvgPathPrimitive,
        WiredSvgPrimitive;

// ---------------------------------------------------------------------------
// Lookup helpers
// ---------------------------------------------------------------------------

/// Returns the `WiredSvgIconData` for the emoji [name], or `null` if not
/// found.
///
/// ```dart
/// final data = lookupSkribbleEmojiByName('grinning_face');
/// ```
WiredSvgIconData? lookupSkribbleEmojiByName(String name) {
  final codePoint = gen_cp.kSkribbleEmojiCodePoints[name];
  if (codePoint != null) return gen.kSkribbleEmoji[codePoint];
  final sequence = gen_cp.kSkribbleEmojiNames[name];
  if (sequence == null) return null;
  return sequences.kSkribbleEmojiSequences[sequence];
}

/// Returns the `WiredSvgIconData` for the given Unicode [codePoint], or `null`
/// if not found.
///
/// ```dart
/// final data = lookupSkribbleEmojiByUnicode(0x1f600);
/// ```
WiredSvgIconData? lookupSkribbleEmojiByUnicode(int codePoint) {
  return gen.kSkribbleEmoji[codePoint];
}

/// Looks up a full emoji string or a hyphenated Unicode hexadecimal sequence.
/// Variation selector FE0F is optional; skin tones, flags, and ZWJ are preserved.
WiredSvgIconData? lookupSkribbleEmojiBySequence(String value) {
  final isHex = RegExp(r'^[0-9a-fA-F]{4,6}(-[0-9a-fA-F]{4,6})*$')
      .hasMatch(value);
  final points = isHex
      ? value.split('-').map((part) => int.parse(part, radix: 16))
      : value.runes;
  final sequence = points
      .where((point) => point != 0xfe0f)
      .map(
        (point) => point.toRadixString(16).toUpperCase().padLeft(4, '0'),
      )
      .join('-');
  if (!sequence.contains('-')) {
    final point = int.tryParse(sequence, radix: 16);
    return point == null ? null : gen.kSkribbleEmoji[point];
  }
  return sequences.kSkribbleEmojiSequences[sequence];
}
