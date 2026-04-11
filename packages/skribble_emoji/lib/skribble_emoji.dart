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
import 'package:skribble_emoji/src/wired_svg_icon_data.dart';

export 'package:skribble_emoji/src/generated/skribble_emoji.g.dart'
    show kSkribbleEmoji;
export 'package:skribble_emoji/src/generated/skribble_emoji_codepoints.g.dart'
    show kSkribbleEmojiCodePoints;
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
  if (codePoint == null) return null;
  return gen.kSkribbleEmoji[codePoint];
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
